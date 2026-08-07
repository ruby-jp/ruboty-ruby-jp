require "spec_helper"
require "stringio"
require "ruboty/slack_events"
require_relative "../../../ruboty-golf"

describe Ruboty::Handlers::Golf do
  FIXTURE_HTML = <<~HTML
    <html>
    <body>
    <h2>Active problems</h2><ul>
    <li>1: <a href="/p/001">Problem One</a> (2026-08-10 23:59:59 +0900)</li>
    <li>2: <a href="/p/002">Problem Two</a> (2026-08-11 23:59:59 +0900)</li>
    </ul>
    </body>
    </html>
  HTML

  EXPECTED_TOPIC = [
    "* #1: <http://golf.shinh.org/p/001|Problem One> until 2026-08-10 23:59:59 +0900",
    "* #2: <http://golf.shinh.org/p/002|Problem Two> until 2026-08-11 23:59:59 +0900",
  ].join("\n")

  let(:robot) do
    Ruboty::Robot.new
  end

  let(:slack_client) do
    double("slack_client")
  end

  let(:adapter) do
    double("adapter").tap do |a|
      allow(a).to receive(:is_a?) { |klass| klass == Ruboty::Adapters::SlackEvents }
      allow(a).to receive(:slack_client).and_return(slack_client)
    end
  end

  let(:from) do
    "alice"
  end

  let(:to) do
    "#dev"
  end

  before do
    allow(robot).to receive(:adapter).and_return(adapter)
    allow(URI).to receive(:open).with("http://golf.shinh.org/").and_return(StringIO.new(FIXTURE_HTML))
  end

  describe "#topic" do
    it "resolves the channel id across pages and updates the topic when it differs" do
      allow(slack_client).to receive(:conversations_list)
        .with(exclude_archived: true, cursor: nil, limit: 200)
        .and_return(
          "ok" => true,
          "channels" => [{ "id" => "C1", "name" => "general" }],
          "response_metadata" => { "next_cursor" => "CURSOR1" },
        )
      allow(slack_client).to receive(:conversations_list)
        .with(exclude_archived: true, cursor: "CURSOR1", limit: 200)
        .and_return(
          "ok" => true,
          "channels" => [{ "id" => "C123", "name" => "dev" }],
          "response_metadata" => { "next_cursor" => "" },
        )
      allow(slack_client).to receive(:conversations_info)
        .with(channel: "C123")
        .and_return("ok" => true, "channel" => { "topic" => { "value" => "old topic" } })
      expect(slack_client).to receive(:conversations_setTopic)
        .with(channel: "C123", topic: EXPECTED_TOPIC)
        .and_return("ok" => true)

      robot.receive(body: "@ruboty golf set-topic #dev", from: from, to: to)
    end

    it "does not update the topic when it is already up to date" do
      allow(slack_client).to receive(:conversations_list)
        .with(exclude_archived: true, cursor: nil, limit: 200)
        .and_return(
          "ok" => true,
          "channels" => [{ "id" => "C123", "name" => "dev" }],
          "response_metadata" => { "next_cursor" => "" },
        )
      allow(slack_client).to receive(:conversations_info)
        .with(channel: "C123")
        .and_return("ok" => true, "channel" => { "topic" => { "value" => EXPECTED_TOPIC } })
      expect(slack_client).not_to receive(:conversations_setTopic)

      robot.receive(body: "@ruboty golf set-topic #dev", from: from, to: to)
    end
  end
end
