module Ruboty
  module Handlers
    class Gsub < Base
      on(
        %r!gsub (?<receiver>".+") /(?<pattern>.+)/ (?<replacement>".+")!im,
         name: 'gsub',
         description: '$1.gsub(Regexp.new($2), $3)',
      )

      def gsub(message)
        m = message.match_data
        recv = m['receiver'].undump
        pattern = Regexp.new(m['pattern'])
        rep = m['replacement'].undump

        message.reply recv.gsub(pattern, rep)
      end
    end
  end
end
