module Ruboty
  module Handlers
    class Matz < Base
      on(
        /matz/i,
         name: 'matz',
         description: ":matz:",
      )

      def matz(message)
        resp = (1..9).map{|x|":matz#{x}:"}.each_slice(3).map(&:join).join("\n")
        message.reply resp
      end
    end
  end
end
