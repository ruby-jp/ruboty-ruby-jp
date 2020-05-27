require 'open3'
require 'pathname'

module Ruboty
  module Handlers
    class In < Base

      on(
         /kata\s+(?<klass>\S+)(?<kind>[#.])(?<method>\S+)/,
         name: 'kata',
         description: "型",
      )

      def kata(message)
        m = message.match_data
        
        kind = m[:kind] == '#' ? '--instance' : '--singleton'
        stdout, _status = Open3.capture2e('rbs', *requires, 'method', kind, m[:klass], m[:method])
        message.reply <<~MARKDOWN
          ```
          #{stdout.chomp}
          ```
        MARKDOWN
      end

      private def requires
        @requires ||= libraries.flat_map { |lib| ['-r', lib] }
      end

      private def libraries
        Pathname(`gem which rbs`.chomp)
          .join('../../stdlib/')
          .glob('*')
          .filter_map { |path| path.basename.to_s unless path.to_s.end_with?('/builtin') }
      end
    end
  end
end
