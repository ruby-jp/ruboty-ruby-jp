require 'open-uri'

module Ruboty
  module Handlers
    class Golf < Base
      GOLF_URL = 'http://golf.shinh.org/'

      on(
         /golf list/i,
         name: 'list',
         description: "List the active problems",
      )

      on(
        /golf set-topic\s+(?<channel>\S+)/i,
        name: 'topic',
        description: 'Update channel topic with active problems. It requires ruboty-slack_rtm',
      )

      def list(message)
        resp = format active_problems
        message.reply resp
      end

      def topic(message)
        require 'slack'

        channel = message.match_data['channel']

        problems = format active_problems
        c = Slack::Client.new(token: ENV.fetch('SLACK_TOKEN'))
        channel_id = resolve_channel_id(channel)
        c.channels_setTopic(channel: channel_id, topic: problems)
      rescue => ex
        message.reply "Error: #{ex.inspect}"
      end

      private def active_problems
        html = URI.open(GOLF_URL).read
        list = html[%r!<h2>Active problems</h2><ul>((?~</ul>))</ul>!im, 1]
        list.scan(%r!<li>((?~</li>))</li>!).map do |text,|
          {
            number: text[/^\d+/],
            url: URI.join(GOLF_URL, text[/href="([^"]+)"/, 1]),
            title: text[%r!">((?~</a>))</a>!, 1],
            deadline: text[/\(([^()]+)\)\s*$/, 1],
          }
        end
      end

      private def format(problems)
        problems.map { |p| "* \##{p[:number]}: *#{p[:title]}* until #{p[:deadline] } #{p[:url]}"}.join("\n")
      end

      private def adapter
        robot.__send__(:adapter).tap do |adapter|
          raise "Adapter must be a Ruboty::Adapters::SlackRTM" unless adapter.is_a?(Ruboty::Adapters::SlackRTM)
        end
      end

      private def resolve_channel_id(name)
        adapter.__send__(:resolve_channel_id, name)
      end
    end
  end
end
