require "spec_helper"
require_relative '../../../ruboty-tenki'

describe Ruboty::Handlers::Tenki do
  let(:robot) do
    Ruboty::Robot.new
  end

  describe "#tenki" do
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

    it "returns the wttr.in URL for the given location" do
      said = "@ruboty tenki tokyo"
      replied = "https://wttr.in/tokyo?lang=ja"
      assert_reply(replied, said)
    end
  end
end
