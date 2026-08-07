require "spec_helper"
require_relative '../../../ruboty-parse_ruby'

describe Ruboty::Handlers::ParseRuby do
  let(:robot) do
    Ruboty::Robot.new
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

  describe "#parse" do
    it "replies with the Ripper sexp of the given code, wrapped in a code block" do
      said = "@ruboty parse 1 + 1"
      replied = <<~TEXT.chomp
        ```
        [:program, [[:binary, [:@int, "1", [1, 0]], :+, [:@int, "1", [1, 4]]]]]
        ```
      TEXT
      assert_reply(replied, said)
    end
  end

  describe "#syntax_check" do
    it "reports ok for every known ruby version when the code is syntactically valid" do
      said = "@ruboty syntax-check 1 + 1"
      replied = (18..27).map { |v| "#{v}: ok" }.join("\n")
      assert_reply(replied, said)
    end

    it "reports the parse error for every known ruby version when the code is invalid" do
      said = "@ruboty syntax-check def foo"
      replied = (18..27).map { |v| "#{v}: unexpected token $end" }.join("\n")
      assert_reply(replied, said)
    end
  end

  describe "#cw" do
    it "reports Syntax OK for valid code with no warnings" do
      said = "@ruboty cw puts 1"
      expect(robot).to receive(:say).with(
        hash_including(body: a_string_including("Syntax OK"))
      )
      robot.receive(body: said, from: from, to: to)
    end

    it "reports a warning for code with an unused variable, while still being syntactically valid" do
      said = "@ruboty cw def foo; a = 1; end"
      expect(robot).to receive(:say).with(
        hash_including(
          body: a_string_including("warning: assigned but unused variable - a", "Syntax OK")
        )
      )
      robot.receive(body: said, from: from, to: to)
    end
  end
end
