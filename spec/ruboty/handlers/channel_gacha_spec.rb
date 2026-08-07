require 'spec_helper'
require_relative '../../../ruboty-channel-gacha'

describe Options::Channel do
  describe '#reload?' do
    it 'returns true for -r' do
      expect(described_class.new('-r').reload?).to eq true
    end

    it 'returns false for other options' do
      expect(described_class.new('-pre=hi').reload?).to eq false
    end

    it 'returns false when option is nil' do
      expect(described_class.new(nil).reload?).to eq false
    end
  end

  describe '#with_pre_message?' do
    it 'is truthy for -pre=hello' do
      expect(described_class.new('-pre=hello').with_pre_message?).to be_truthy
    end

    it 'is falsy for -r' do
      expect(described_class.new('-r').with_pre_message?).to be_falsy
    end

    it 'is nil when option is nil' do
      expect(described_class.new(nil).with_pre_message?).to be_nil
    end
  end

  describe '#pre_message' do
    it 'returns the text after -pre=' do
      expect(described_class.new('-pre=hello').pre_message).to eq 'hello'
    end

    it 'returns nil when option has no -pre prefix' do
      expect(described_class.new('-r').pre_message).to be_nil
    end

    it 'returns nil when option is nil' do
      expect(described_class.new(nil).pre_message).to be_nil
    end
  end
end

describe RubyJP::Channel do
  describe '#channel_information' do
    it 'joins channel name, topic and purpose with newlines' do
      channel = described_class.new(
        'id' => 'C123',
        'topic' => { 'value' => 'topic-value' },
        'purpose' => { 'value' => 'purpose-value' },
      )

      expect(channel.channel_information).to eq <<~TEXT.chomp
        チャンネル名: <#C123>
        トピック: topic-value
        説明: purpose-value
      TEXT
    end

    it 'omits the topic line when topic is empty' do
      channel = described_class.new(
        'id' => 'C123',
        'topic' => { 'value' => '' },
        'purpose' => { 'value' => 'purpose-value' },
      )

      expect(channel.channel_information).to eq <<~TEXT.chomp
        チャンネル名: <#C123>
        説明: purpose-value
      TEXT
    end

    it 'omits the purpose line when purpose is empty' do
      channel = described_class.new(
        'id' => 'C123',
        'topic' => { 'value' => 'topic-value' },
        'purpose' => { 'value' => '' },
      )

      expect(channel.channel_information).to eq <<~TEXT.chomp
        チャンネル名: <#C123>
        トピック: topic-value
      TEXT
    end

    it 'omits both topic and purpose lines when both are empty' do
      channel = described_class.new(
        'id' => 'C123',
        'topic' => { 'value' => '' },
        'purpose' => { 'value' => '' },
      )

      expect(channel.channel_information).to eq 'チャンネル名: <#C123>'
    end
  end
end

describe Replies::ChannelGacha do
  describe '.create' do
    it 'joins pre_message and the sampled channel information' do
      channel = double('channel', channel_information: 'チャンネル情報')

      result = described_class.create([channel], 'メッセージ')

      expect(result).to eq "メッセージ\nチャンネル情報"
    end

    it 'omits the pre_message line when pre_message is nil' do
      channel = double('channel', channel_information: 'チャンネル情報')

      result = described_class.create([channel], nil)

      expect(result).to eq 'チャンネル情報'
    end

    it 'samples one channel information out of the given channels' do
      channels = [double('a', channel_information: 'A'), double('b', channel_information: 'B')]

      result = described_class.create(channels, nil)

      expect(%w[A B]).to include(result)
    end
  end
end
