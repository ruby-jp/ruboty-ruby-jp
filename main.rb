require "ruboty"
require 'ruboty/slack_rtm' unless ENV['RUBOTY_CLI']

require_relative './ruboty-rurema'
require_relative './ruboty-parse_ruby'

Ruboty::CommandBuilder.new(ARGV).build.call
