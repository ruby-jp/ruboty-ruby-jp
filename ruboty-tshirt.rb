module Ruboty
  module Handlers
    class Tshirt < Base
      on(
        /t-?shirt :?(?<emoji>[^:]+):?/i,
         name: 'tshirt',
         description: "Make a T-shirt",
      )

      def tshirt(message)
        emoji = ':' + message.match_data['emoji'] + ':'
        resp = (1..3).map{|n| part(n) }.join
        resp << "\n"
        resp << part(4) << emoji << part(5) << "\n"
        resp << (6..8).map{|n| part(n) }.join

        message.reply resp
      end

      def part(n)
        ":t-shirt-#{n}:"
      end
    end
  end
end
