require "spec_helper"
require "json"
require "uri"
require_relative '../../../ruboty-numberplace'

describe Ruboty::Handlers::NumberPlace do
  let(:robot) do
    Ruboty::Robot.new
  end

  let(:handler) do
    described_class.new(robot)
  end

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

  describe "randomness injection" do
    def generate_reply(prng:, n: 9)
      params = handler.send(:parameters, n)
      boxes = handler.send(:gen, **params, prng: prng)
      handler.send(:format, boxes, **params)
    end

    it "produces identical output for the same seed" do
      expect(generate_reply(prng: Random.new(42))).to eq(generate_reply(prng: Random.new(42)))
    end

    it "produces different output for different seeds (very likely)" do
      expect(generate_reply(prng: Random.new(1))).not_to eq(generate_reply(prng: Random.new(2)))
    end

    it "produces the exact same board and URI for a fixed seed (reproducible)" do
      params = handler.send(:parameters, 9)
      boxes = handler.send(:gen, **params, prng: Random.new(42))

      board_reply = handler.send(:format, boxes, **params)
      uri_reply = handler.send(:to_uri, boxes, **params)

      expected_board = [
        ":one::two::transparent2: :transparent2::transparent2::transparent2: :transparent2::three::transparent2: ",
        ":nine::transparent2::four: :six::transparent2::two: :seven::eight::transparent2: ",
        ":seven::transparent2::transparent2: :transparent2::transparent2::transparent2: :transparent2::transparent2::transparent2: ",
        "",
        ":transparent2::one::transparent2: :eight::transparent2::transparent2: :six::transparent2::transparent2: ",
        ":two::seven::nine: :one::transparent2::six: :transparent2::four::transparent2: ",
        ":transparent2::three::transparent2: :four::transparent2::nine: :two::transparent2::five: ",
        "",
        ":eight::nine::two: :transparent2::one::transparent2: :transparent2::seven::six: ",
        ":five::four::seven: :three::six::transparent2: :transparent2::transparent2::transparent2: ",
        ":transparent2::transparent2::transparent2: :transparent2::transparent2::transparent2: :transparent2::transparent2::transparent2: ",
        "",
        "",
      ].join("\n")

      expect(board_reply).to eq(expected_board)
      expect(uri_reply).to eq("https://puzzle.pocke.me/#/number_place_from_param?board=%5B%5B1%2C2%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2C3%2Cnull%5D%2C%5B9%2Cnull%2C4%2C6%2Cnull%2C2%2C7%2C8%2Cnull%5D%2C%5B7%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%5D%2C%5Bnull%2C1%2Cnull%2C8%2Cnull%2Cnull%2C6%2Cnull%2Cnull%5D%2C%5B2%2C7%2C9%2C1%2Cnull%2C6%2Cnull%2C4%2Cnull%5D%2C%5Bnull%2C3%2Cnull%2C4%2Cnull%2C9%2C2%2Cnull%2C5%5D%2C%5B8%2C9%2C2%2Cnull%2C1%2Cnull%2Cnull%2C7%2C6%5D%2C%5B5%2C4%2C7%2C3%2C6%2Cnull%2Cnull%2Cnull%2Cnull%5D%2C%5Bnull%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%5D%5D")

      # run again with a fresh Random of the same seed to prove reproducibility
      # within this same example (in addition to running the whole spec file
      # multiple times from the shell, see task notes).
      boxes_again = handler.send(:gen, **params, prng: Random.new(42))
      expect(handler.send(:format, boxes_again, **params)).to eq(board_reply)
      expect(handler.send(:to_uri, boxes_again, **params)).to eq(uri_reply)
    end
  end

  describe "#numberplace" do
    context "with an unsupported size" do
      it "replies with an error message" do
        said = "@ruboty numberplace 5"
        replied = "not supported N: 5"
        assert_reply(replied, said)
      end
    end

    context "with a supported size" do
      it "replies with a full emoji grid and a puzzle.pocke.me URL" do
        replies = []
        allow(robot).to receive(:say) { |args| replies << args[:body] }

        robot.receive(body: "@ruboty numberplace 9", from: from, to: to)

        expect(replies.size).to eq(2)
        board_reply, uri_reply = replies

        emoji_tokens = board_reply.scan(/:[a-z0-9]+:/)
        expect(emoji_tokens.size).to eq(81)

        content_lines = board_reply.lines.reject { |line| line.strip.empty? }
        expect(content_lines.size).to eq(9)
        content_lines.each do |line|
          expect(line.scan(/:[a-z0-9]+:/).size).to eq(9)
        end

        expect(uri_reply).to start_with("https://puzzle.pocke.me/#/number_place_from_param?")
      end
    end
  end
end
