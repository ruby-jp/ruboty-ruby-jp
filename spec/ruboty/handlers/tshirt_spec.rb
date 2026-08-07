require "spec_helper"
require_relative '../../../ruboty-tshirt'

describe Ruboty::Handlers::Tshirt do
  let(:robot) do
    Ruboty::Robot.new
  end

  describe "#tshirt" do
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

    it "returns a t-shirt with the given emoji printed on it" do
      said = "@ruboty tshirt :smile:"
      replied = <<~TEXT.chomp
        :t-shirt-1::t-shirt-2::t-shirt-3:
        :t-shirt-4::smile::t-shirt-5:
        :t-shirt-6::t-shirt-7::t-shirt-8:
      TEXT
      assert_reply(replied, said)
    end
  end
end
