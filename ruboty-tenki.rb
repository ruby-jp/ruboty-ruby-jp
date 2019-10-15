module Ruboty
  module Handlers
    class Tenki < Base
      on(
        /(tenki|天気) (?<location>\w+)/i,
         name: 'tenki',
         description: "Show wttr.in",
      )

      LOCATIONS = {
        '東京': 'tokyo',
        '大阪': 'osaka',
      }

      def tenki(message)
        location = message.match_data['location']
        location = LOCATIONS[location] || location

        message.reply "https://wttr.in/#{location}?lang=ja"
      end
    end
  end
end
