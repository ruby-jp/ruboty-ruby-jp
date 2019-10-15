module Ruboty
  module Handlers
    class Tenki < Base
      on(
        /(tenki|天気) (?<location>\S+)/i,
         name: 'tenki',
         description: "Show wttr.in",
      )

      def tenki(message)
        location = message.match_data['location']

        message.reply "https://wttr.in/#{location}?lang=ja"
      end
    end
  end
end
