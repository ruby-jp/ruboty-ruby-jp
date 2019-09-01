require 'open-uri'

module Ruboty
  module Handlers
    class Golf < Base
      GOLF_URL = 'http://golf.shinh.org/'

      on(
         /golf list/i,
         name: 'golf_list',
         description: "List the active problems",
      )

      def golf_list(message)
        resp = active_problems.map { |p| "* \##{p[:number]}: *#{p[:title]}* until #{p[:deadline] } #{p[:url]}"}.join("\n")
        message.reply resp
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
    end
  end
end
