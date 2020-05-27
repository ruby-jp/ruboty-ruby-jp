require 'open3'

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
        stdout, _status = Open3.capture2e('rbs', 'method', kind, m[:klass], m[:method])
        message.reply <<~MARKDOWN
          ```
          #{stdout.chomp}
          ```
        MARKDOWN
      end
    end
  end
end
