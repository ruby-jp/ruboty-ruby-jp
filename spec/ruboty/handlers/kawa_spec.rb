require "spec_helper"
require_relative '../../../ruboty-kawa'

describe Ruboty::Handlers::Kawa do
  let(:robot) do
    Ruboty::Robot.new
  end

  describe "#kawa" do
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

    it "returns the river camera links" do
      said = "@ruboty kawa"
      replied = <<~KAWA
        http://cam.wni.co.jp/houraibashi/camera.jpg
        http://cam.wni.co.jp/taikobashi/camera.jpg
        http://www.kasen-suibo.metro.tokyo.jp/img/im/suiiGraph_2B14_1.gif
      KAWA
      assert_reply(replied, said)
    end
  end
end
