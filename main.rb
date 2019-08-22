require "ruboty"
require_relative './ruboty-rurema'

Ruboty::CommandBuilder.new(ARGV).build.call
