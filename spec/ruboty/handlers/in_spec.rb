require "spec_helper"
require_relative '../../../ruboty-in'

describe Ruboty::Handlers::In do
  let(:robot) do
    Ruboty::Robot.new
  end

  describe "#in" do
    let(:from) do
      "alice"
    end

    let(:to) do
      "#general"
    end

    let(:said) do
    end

    let(:lied) do
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

    it "returns a in b" do
      said = "@ruboty a in b"
      replied = <<~TEXT.chomp
       :b::b::b:
       :b::a::b:
       :b::b::b:
      TEXT
      assert_reply(replied, said)
    end

    it "returns a in b in c" do
      said = "@ruboty a in b in c"
      replied = <<~TEXT.chomp
        :c::c::c::c::c:
        :c::b::b::b::c:
        :c::b::a::b::c:
        :c::b::b::b::c:
        :c::c::c::c::c:
      TEXT
      assert_reply(replied, said)
    end
  end
end
