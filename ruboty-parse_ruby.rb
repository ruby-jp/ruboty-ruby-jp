module Ruboty
  module Handlers
    class ParseRuby < Base
      KNOWN_RUBY_VERSIONS = 18..27
      KNOWN_PARSERS = %w[ripper sexp tokenize lex rubyvm] + KNOWN_RUBY_VERSIONS.map {|v| "parser#{v}"}

      KNOWN_RUBY_VERSIONS.each do |v|
        require "parser/ruby#{v}"
      end
      require 'ripper'
      require 'pp'

      on(
         /(?<with_parse>parse\s)?(?:(?<parser>#{Regexp.union(*KNOWN_PARSERS)})\s)?(?<code>.+)/im,
         name: 'parse',
         description: "Parse Ruby code and response AST",
      )

      def parse(message)
        m = message.match_data
        parser = m['parser']
        code = m['code']
        with_parse = m['with_parse']
        return if !with_parse && !parser

        obj = parse_code(parser, code)
        message.reply "```\n#{obj.pretty_inspect.chomp}\n```"
      end

      private def parse_code(parser, code)
        case parser
        when 'ripper', 'sexp', nil
          Ripper.sexp(code)
        when 'tokenize'
          Ripper.tokenize(code)
        when 'lex'
          Ripper.lex(code)
        when /parser(?<version>\d+)/
          v = Regexp.last_match['version']
          Parser.const_get(:"Ruby#{v}").parse(code)
        when 'rubyvm'
          RubyVM::AbstractSyntaxTree.parse(code)
        else
          raise 'unreachable'
        end
      rescue SyntaxError, Parser::SyntaxError => ex
        ex
      end
    end
  end
end
