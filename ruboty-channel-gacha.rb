require 'slack'
require 'active_support'

module Ruboty
  module Handlers
    class ChannelGacha < Base
      on(
        %r!((?<option>\S+) )?((channel_gacha)|(チャンネルガチャ))!,
        name: 'channel_gacha',
        description: 'returns randomly channel information',
      )

      def channel_gacha(message)
        set_option(message)
        message.reply messages.join("\n")
      end

      private

      def set_option(message)
        @option = message.match_data['option']
      end

      def messages
        [pre_message, selected_channel.channel_information].compact
      end

      def pre_message
        @option.split('=', 2)[1] if with_pre_message?
      end

      def selected_channel
        channels.sample
      end

      def channels
        @channels = (reload? || !@channels) ? Ruboty::RubyJP::Channel.all : @channels
      end

      def reload?
        @option == '-r'
      end

      def with_pre_message?
        @option =~ /\A-pre/
      end
    end
  end

  module RubyJP
    class Channel
      attr_writer :id, :topic, :purpose

      def initialize(channel)
        @id = channel['id']
        @topic = channel['topic']['value']
        @purpose = channel['purpose']['value']
      end

      class << self
        def all
          Ruboty::SlackApi::Channel.all_public_channels.map(&method(:new))
        end
      end

      def channel_information
        [channel_name, topic, purpose].compact.join("\n")
      end

      def channel_name
        "チャンネル名: <##{@id}>"
      end

      def topic
        "トピック: #{@topic}" if @topic.present?
      end

      def purpose
        "説明: #{@purpose}" if @purpose.present?
      end
    end
  end

  module SlackApi
    class Channel
      class << self
        def all_public_channels
          new.fetch_public_channels
        end
      end

      def fetch_public_channels
        channels, next_cursor = [], nil
        until next_cursor&.empty?
          response = request_params(next_cursor).then(&client.method(:conversations_list))
          next_cursor = response['response_metadata']['next_cursor']
          channels.concat(response['channels'])
        end
        channels
      end

      private

      def client
        Slack::Client.new(token: ENV.fetch('SLACK_TOKEN'))
      end

      def request_params(next_cursor)
        { exclude_archived: true, limit: 200 }.tap { _1.merge!({ cursor: next_cursor }) if next_cursor.present? }
      end
    end
  end
end
