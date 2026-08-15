require "spec_helper"
require "webmock/rspec"
require_relative "../../../ruboty-golf"

describe Ruboty::Handlers::Golf do
  let(:robot) do
    Ruboty::Robot.new
  end

  let(:from) do
    "alice"
  end

  let(:to) do
    "#general"
  end

  let(:said) do
    "@ruboty golf list"
  end

  def assert_reply(replied)
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

  describe "#list" do
    it "replies with the formatted list of active problems" do
      html = <<~HTML
        <html>
        <body>
        <h2>Active problems</h2><ul>
        <li>1: <a href="/p/001">Problem One</a> (2026-08-10 23:59:59 +0900)</li>
        <li>2: <a href="/p/002">Problem Two</a> (2026-08-11 23:59:59 +0900)</li>
        </ul>
        </body>
        </html>
      HTML
      stub_request(:get, "http://golf.shinh.org/").to_return(body: html)

      expected = [
        "* #1: <http://golf.shinh.org/p/001|Problem One> until 2026-08-10 23:59:59 +0900",
        "* #2: <http://golf.shinh.org/p/002|Problem Two> until 2026-08-11 23:59:59 +0900",
      ].join("\n")

      assert_reply(expected)
    end

    it "replies with an empty string when there is no active problems section" do
      html = <<~HTML
        <html>
        <body>
        <p>No active problems right now.</p>
        </body>
        </html>
      HTML
      stub_request(:get, "http://golf.shinh.org/").to_return(body: html)

      assert_reply("")
    end
  end
end
