require 'spec_helper'
require 'webmock/rspec'
require_relative '../../ruboty-channel-gacha'

describe SlackApi::Channel do
  describe '#fetch_public_channels' do
    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with('SLACK_TOKEN').and_return('xoxb-test')

      stub_request(:post, 'https://slack.com/api/conversations.list')
        .with(body: hash_including('exclude_archived' => 'true', 'limit' => '200'))
        .to_return(
          status: 200,
          headers: { 'Content-Type' => 'application/json' },
          body: {
            ok: true,
            channels: [
              { id: 'C001', name: 'general', topic: { value: 'topic1' }, purpose: { value: 'purpose1' } },
              { id: 'C002', name: 'random', topic: { value: 'topic2' }, purpose: { value: 'purpose2' } },
            ],
            response_metadata: { next_cursor: 'cur1' },
          }.to_json,
        )

      stub_request(:post, 'https://slack.com/api/conversations.list')
        .with(body: hash_including('cursor' => 'cur1'))
        .to_return(
          status: 200,
          headers: { 'Content-Type' => 'application/json' },
          body: {
            ok: true,
            channels: [
              { id: 'C003', name: 'dev', topic: { value: 'topic3' }, purpose: { value: 'purpose3' } },
            ],
            response_metadata: { next_cursor: '' },
          }.to_json,
        )
    end

    it 'fetches every page and returns all public channels' do
      channels = described_class.new.fetch_public_channels

      expect(channels.map { |channel| channel['id'] }).to eq %w[C001 C002 C003]
    end
  end
end
