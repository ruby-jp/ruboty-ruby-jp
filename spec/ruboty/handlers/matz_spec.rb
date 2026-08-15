require "spec_helper"
require_relative '../../../ruboty-matz'

describe Ruboty::Handlers::Matz do
  let(:robot) do
    Ruboty::Robot.new
  end

  describe "#matz" do
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

    it "returns a 3x3 grid of matz emoji" do
      said = "@ruboty matz"
      replied = <<~TEXT.chomp
        :matz1::matz2::matz3:
        :matz4::matz5::matz6:
        :matz7::matz8::matz9:
      TEXT
      assert_reply(replied, said)
    end
  end
end
