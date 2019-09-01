require "ruboty"
require 'ruboty/slack_rtm' unless ENV['RUBOTY_CLI']

require_relative './ruboty-parse_ruby'
require_relative './ruboty-golf'

Ruboty::CommandBuilder.new(ARGV).build.call
