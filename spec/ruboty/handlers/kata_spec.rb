require "spec_helper"
require_relative '../../../ruboty-kata'

describe Ruboty::Handlers::Kata do
  let(:robot) do
    Ruboty::Robot.new
  end

  let(:from) do
    "alice"
  end

  let(:to) do
    "#general"
  end

  describe "#kata" do
    it "shows the rbs signature for an instance method (Klass#method)" do
      said = "@ruboty kata String#gsub"
      expect(robot).to receive(:say).with(
        hash_including(
          body: a_string_including("::String#gsub", "defined_in: ::String", "accessibility: public")
        )
      )
      robot.receive(body: said, from: from, to: to)
    end

    it "shows the rbs signature for a singleton method (Klass.method)" do
      said = "@ruboty kata Integer.sqrt"
      expect(robot).to receive(:say).with(
        hash_including(
          body: a_string_including("::Integer.sqrt", "defined_in: ::Integer", "accessibility: public")
        )
      )
      robot.receive(body: said, from: from, to: to)
    end
  end
end
