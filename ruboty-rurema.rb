require 'net/https'
require 'uri'
require 'json'
require 'open-uri'
require 'cgi'

module Ruboty
  module Handlers
    class Rurema < Base
      URL_BASE = 'https://docs.ruby-lang.org/ja/latest/'
      SEARCH_API_URL_BASE = 'https://docs.ruby-lang.org/ja/search/api:v1/'
      CLASS_RE = /[A-Z][\w:]+/

      on(
         /rurema\s+(?<query>.+)/i,
         name: 'rurema',
         description: "Response the Ruby reference manual",
      )

      def rurema(message)
        query = message.match_data['query']
        url = build_url(query)
        if url && exist_resource?(url)
          message.reply url
          return
        end

        # Is CGI.escape correct way?
        resp = get SEARCH_API_URL_BASE + query.split.map {|q| "query:#{CGI.escape(q)}"}.join('/')
        if resp.nil? || resp[:entries].empty?
          message.reply "No document for #{query}"
          return
        end

        url = resp.dig(:entries, 0, :documents, -1, :url)
        # BUG: rurema searcher returns URL with 'https://docs.ruby-lang.org/ja/search/', so we need removing it.
        url.sub!('docs.ruby-lang.org/ja/search/http://', '')
        message.reply url
      end

      private def build_url(query)
        case
        when klass = class?(query)
          URL_BASE + "class/#{encode_name(klass)}.html"
        when ok = module_method?(query)
          klass = encode_name ok[0]
          method = encode_name ok[1]
          URL_BASE + "method/#{klass}/m/#{method}.html"
        when ok = instance_method?(query)
          klass = encode_name ok[0]
          method = encode_name ok[1]
          URL_BASE + "method/#{klass}/i/#{method}.html"
        when ok = class_method?(query)
          klass = encode_name ok[0]
          method = encode_name ok[1]
          URL_BASE + "method/#{klass}/s/#{method}.html"
        else
          nil
        end
      end

      private def class?(query)
        query[/\A#{CLASS_RE}\z/]
      end

      private def module_method?(query)
        m = /\A(?<class>#{CLASS_RE})\.\#(?<method>.+)\z/.match(query)
        [m['class'], m['method']] if m
      end

      private def instance_method?(query)
        m = /\A(?<class>#{CLASS_RE})\#(?<method>.+)\z/.match(query)
        [m['class'], m['method']] if m
      end

      private def class_method?(query)
        m = /\A(?<class>#{CLASS_RE})\.(?<method>.+)\z/.match(query)
        [m['class'], m['method']] if m
      end

      private def exist_resource?(url)
        url = URI.parse(url)
        https = Net::HTTP.new(url.host, 443)
        https.use_ssl = true
        https.start do
          resp = https.head(url.path)
          return resp.code_type == Net::HTTPOK
        end
      end

      # It is copied and modified from bitclust.
      # The license for the method follows bitclust's one.
      # https://github.com/rurema/bitclust/blob/ba4b07e05ae41694e4930d7be355d32e9f17f396/lib/bitclust/nameutils.rb#L205-L208
      private def encode_name(name)
        name.gsub(/[^A-Za-z0-9_]/n) {|ch| sprintf('=%02x', ch.ord) }
      end

      private def get(url)
        JSON.parse(URI.open(url).read, symbolize_names: true)
      rescue OpenURI::HTTPError => ex
        p ex
        nil
      end
    end
  end
end
