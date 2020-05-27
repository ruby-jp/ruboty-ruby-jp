require "ruboty"
require 'ruboty/slack_rtm' unless ENV['RUBOTY_CLI']

require_relative './ruboty-parse_ruby'
require_relative './ruboty-golf'
require_relative './ruboty-kawa'
require_relative './ruboty-matz'
require_relative './ruboty-tshirt'
require_relative './ruboty-twitter-handler'
require_relative './ruboty-tenki'
require_relative './ruboty-gsub'
require_relative './ruboty-in'
require_relative './ruboty-numberplace'
require_relative './ruboty-channel-gacha'
require_relative './ruboty-kata'

module RobotSayHelp
  def receive(attributes)
    super
  rescue => ex
    say body: <<~MSG, to: '#times-pocke'
      I'm dead! See the following error

      #{ex.inspect}
      #{ex.backtrace.join("\n")}
    MSG
    raise ex
  end
end

Ruboty::Robot.prepend RobotSayHelp

Ruboty::CommandBuilder.new(ARGV).build.call
