module Ruboty
  module Handlers
    class Kawa < Base
      on(
        %r!gsub ['"](?<receiver>\S+)['"] /(?<pattern>\S+)/ ['"](?<replacement>\S+)['"]!i,
         name: 'gsub',
         description: '$1.gsub(Regexp.new($2), $3)',
      )

      def gsub(message)
        m = message.match_data
        pattern = Regexp.new(m['pattern'])

        message.reply m['receiver'].gsub(pattern, m['replacement'])
      end
    end
  end
end
