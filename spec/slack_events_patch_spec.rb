require "spec_helper"
require 'ruboty/slack_events'
require_relative '../ruboty-slack_events-patch'

describe Ruboty::Adapters::SlackEvents::SlackEventsHandler do
  let(:slack_client) { double('slack_client', chat_postMessage: nil) }
  let(:robot) { double('robot', name: 'ruboty') }
  let(:user_info) { double('user_info', name: 'alice') }
  let(:user_resolver) { double('user_resolver', user_info_by_id: user_info) }
  let(:resolvers) { double('resolvers', user_resolver: user_resolver) }
  let(:rubotify) { double('rubotify', call: 'hi') }
  let(:adapter) do
    double(
      'adapter',
      slack_client: slack_client,
      robot: robot,
      resolvers: resolvers,
      rubotify: rubotify,
      ignore_bot_message?: false,
    )
  end
  let(:handler) { described_class.new(adapter) }

  def event_callback(event)
    Slack::Messages::Message.new(type: 'event_callback', event: event)
  end

  describe 'emoji_changed' do
    context 'when subtype is add' do
      it 'posts a notification to #emoji' do
        text = "A new emoji is added :parrot: `:parrot:`"
        expect(slack_client).to receive(:chat_postMessage).with(
          username: 'ruboty',
          channel: '#emoji',
          attachments: [{ fallback: text, text: text, color: 'good' }].to_json,
        )

        handler.handle_event(event_callback(type: 'emoji_changed', subtype: 'add', name: 'parrot', value: 'https://example.com/parrot.gif'))
      end

      it 'appends the alias origin when value is an alias' do
        text = "A new emoji is added :parrot: `:parrot:` (alias of `:blob:`)"
        expect(slack_client).to receive(:chat_postMessage).with(
          username: 'ruboty',
          channel: '#emoji',
          attachments: [{ fallback: text, text: text, color: 'good' }].to_json,
        )

        handler.handle_event(event_callback(type: 'emoji_changed', subtype: 'add', name: 'parrot', value: 'alias:blob'))
      end
    end

    context 'when subtype is remove' do
      it 'posts a danger notification listing removed names' do
        text = 'Removed emoji: a, b'
        expect(slack_client).to receive(:chat_postMessage).with(
          username: 'ruboty',
          channel: '#emoji',
          attachments: [{ fallback: text, text: text, color: 'danger' }].to_json,
        )

        handler.handle_event(event_callback(type: 'emoji_changed', subtype: 'remove', names: %w[a b]))
      end

      it 'posts nothing when SLACK_EMOJI_IGNORE_REMOVED is set' do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('SLACK_EMOJI_IGNORE_REMOVED').and_return('1')

        expect(slack_client).not_to receive(:chat_postMessage)

        handler.handle_event(event_callback(type: 'emoji_changed', subtype: 'remove', names: %w[a b]))
      end
    end

    context 'when subtype is unknown' do
      it 'posts nothing' do
        expect(slack_client).not_to receive(:chat_postMessage)

        handler.handle_event(event_callback(type: 'emoji_changed', subtype: 'rename', name: 'parrot', old_name: 'parrot2'))
      end
    end

    context 'when SLACK_EMOJI_CHANGED_CHANNEL is set' do
      it 'posts to the custom channel' do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('SLACK_EMOJI_CHANGED_CHANNEL').and_return('#custom')

        text = "A new emoji is added :parrot: `:parrot:`"
        expect(slack_client).to receive(:chat_postMessage).with(
          username: 'ruboty',
          channel: '#custom',
          attachments: [{ fallback: text, text: text, color: 'good' }].to_json,
        )

        handler.handle_event(event_callback(type: 'emoji_changed', subtype: 'add', name: 'parrot', value: 'https://example.com/parrot.gif'))
      end
    end
  end

  describe 'channel_created' do
    it 'posts a notification to #new_channel' do
      text = 'A new channel created: <#C024BE91L>'
      expect(slack_client).to receive(:chat_postMessage).with(
        username: 'ruboty',
        channel: '#new_channel',
        attachments: [{ fallback: text, text: text, color: 'good' }].to_json,
      )

      handler.handle_event(event_callback(type: 'channel_created', channel: { id: 'C024BE91L', name: 'fun' }))
    end

    context 'when SLACK_CHANNEL_CREATED_NOTIFY_CHANNEL is set' do
      it 'posts to the custom channel' do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('SLACK_CHANNEL_CREATED_NOTIFY_CHANNEL').and_return('#announce')

        text = 'A new channel created: <#C024BE91L>'
        expect(slack_client).to receive(:chat_postMessage).with(
          username: 'ruboty',
          channel: '#announce',
          attachments: [{ fallback: text, text: text, color: 'good' }].to_json,
        )

        handler.handle_event(event_callback(type: 'channel_created', channel: { id: 'C024BE91L', name: 'fun' }))
      end
    end

    it 'also works through the events_api envelope path' do
      text = 'A new channel created: <#C024BE91L>'
      expect(slack_client).to receive(:chat_postMessage).with(
        username: 'ruboty',
        channel: '#new_channel',
        attachments: [{ fallback: text, text: text, color: 'good' }].to_json,
      )

      message = Slack::Messages::Message.new(
        type: 'events_api',
        payload: {
          type: 'event_callback',
          event: { type: 'channel_created', channel: { id: 'C024BE91L', name: 'fun' } },
        },
      )
      handler.handle_event(message)
    end
  end

  describe 'regression: normal message events' do
    it 'still flows to the original on_message handling' do
      expect(adapter.robot).to receive(:receive)
      expect(slack_client).not_to receive(:chat_postMessage)

      handler.handle_event(Slack::Messages::Message.new(type: 'message', text: 'hi', channel: 'C1', user: 'U1'))
    end
  end
end
