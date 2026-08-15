require "spec_helper"
require_relative '../../../ruboty-gsub'

describe Ruboty::Handlers::Gsub do
  let(:robot) do
    Ruboty::Robot.new
  end

  describe "#gsub" do
    let(:from) do
      "alice"
    end

    let(:to) do
      "#general"
    end

    def assert_reply(replied, said)
      expect(robot).to receive(:say).with({
        body: replied,
        from: to,
        to: from,
        original: {
          body: said,
          from: from,
          robot: robot,
          to: to,
        },
      })
      robot.receive(body: said, from: from, to: to)
    end

    it "gsubs a matched pattern with a replacement" do
      said = %(@ruboty gsub "hello world" /o/ "0")
      replied = "hell0 w0rld"
      assert_reply(replied, said)
    end

    it "gsubs all occurrences" do
      said = %(@ruboty gsub "banana" /a/ "A")
      replied = "bAnAnA"
      assert_reply(replied, said)
    end
  end
end
