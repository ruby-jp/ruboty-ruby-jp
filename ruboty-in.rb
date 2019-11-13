module Ruboty
  module Handlers
    class In < Base
      IN_RE = /(?<a_colon>:?)(?<a>.+)\g<a_colon> in (?<b_colon>:?)(?<b>.+)\g<b_colon>/

      on(
         IN_RE,
         name: 'in',
         description: "emoji in emoji",
      )

      def nest(a, b)
        if IN_RE =~ a
          inner = nest($~[:a], $~[:b])
        else
          inner = [a]
        end
        [
          [b] * (inner.size + 2),
          *inner.map{|row| [b, *row, b] },
          [b] * (inner.size + 2),
        ]
      end

      def in(message)
        m = message.match_data
        resp = nest(m[:a], m[:b]).map do |row|
          row.map do |s|
            ":#{s}:"
          end.join('')
        end.join("\n")
        message.reply resp
      end
    end
  end
end
