module Ruboty
  module Handlers
    class Rurema < Base
      URL_BASE = 'https://docs.ruby-lang.org/ja/latest/'
      USAGE = "ruboty rurema Klass|Klass\#method|Klass.method|Klass::Child"
      CLASS_RE = /[A-Z][\w:]+/

      on(
         /rurema\s+(?<query>.+)/i,
         name: 'rurema',
         description: "Response the Ruby reference manual",
      )

      def rurema(message)
        q = message.match_data['query']
        resp =
          case q
          when /\A#{CLASS_RE}\z/
            URL_BASE + "class/#{encode_name(q)}.html"
          when /\A(?<class>#{CLASS_RE})\.\#(?<method>.+)\z/
            klass = encode_name Regexp.last_match['class']
            method = encode_name Regexp.last_match['method']
            URL_BASE + "method/#{klass}/m/#{method}.html"
          when /\A(?<class>#{CLASS_RE})\#(?<method>.+)\z/
            klass = encode_name Regexp.last_match['class']
            method = encode_name Regexp.last_match['method']
            URL_BASE + "method/#{klass}/i/#{method}.html"
          when /\A(?<class>#{CLASS_RE})\.(?<method>.+)\z/
            klass = encode_name Regexp.last_match['class']
            method = encode_name Regexp.last_match['method']
            URL_BASE + "method/#{klass}/s/#{method}.html"
          else
            "Sorry I cannot understand it. `#{USAGE}`"
          end
        message.reply resp
      end

      # It is copied and modified from bitclust.
      # The license for the method follows bitclust's one.
      # https://github.com/rurema/bitclust/blob/ba4b07e05ae41694e4930d7be355d32e9f17f396/lib/bitclust/nameutils.rb#L205-L208
      private def encode_name(name)
        name.gsub(/[^A-Za-z0-9_]/n) {|ch| sprintf('=%02x', ch.ord) }
      end
    end
  end
end
