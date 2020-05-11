require 'slack'
require 'active_support'

module Ruboty
  module Handlers
    class ChannelGacha < Base
      on(
        %r!((?<option>\S+) )?((channel_gacha)|(チャンネルガチャ))!,
        name: 'channel_gacha',
        description: 'returns randomly channel information',
      )

      def channel_gacha(message)
        option = Options::Channel.new(message.match_data['option'])
        message.reply RubyJP::Channel.all(reload: option.reload?)
                                     .then { |channels| Replies::ChannelGacha.create(channels, option.pre_message) }
      end
    end
  end
end

module Replies
  module ChannelGacha
    class << self
      def create(channels, pre_message)
        messages(channels, pre_message).join("\n")
      end

      private

      def messages(channels, pre_message)
        [pre_message, channels.sample.channel_information].compact
      end
    end
  end
end

module Options
  class Channel
    def initialize(option)
      @option = option
    end

    def reload?
      @option == '-r'
    end

    def pre_message
      @option.split('=', 2)[1] if with_pre_message?
    end

    def with_pre_message?
      @option =~ /\A-pre/
    end
  end
end

module RubyJP
  class Cache
    @store ||= ActiveSupport::Cache::MemoryStore.new

    class << self
      def store
        @store
      end

      def fetch(name, reload: false, &block)
        store.tap { _1.delete(name) if reload }.fetch(name, &block)
      end
    end
  end

  class Channel
    attr_writer :id, :topic, :purpose

    def initialize(channel)
      @id = channel['id']
      @topic = channel['topic']['value']
      @purpose = channel['purpose']['value']
    end

    class << self
      def all(reload: false)
        cache(reload: reload) { SlackApi::Channel.new.fetch_public_channels.map(&method(:new)) }
      end

      private

      def cache(reload: false, &block)
        Cache.fetch('channels', reload: reload, &block)
      end
    end

    def channel_information
      [channel_name, topic, purpose].compact.join("\n")
    end

    def channel_name
      "チャンネル名: <##{@id}>"
    end

    def topic
      "トピック: #{@topic}" if @topic.present?
    end

    def purpose
      "説明: #{@purpose}" if @purpose.present?
    end
  end
end

module SlackApi
  class Channel
    def initialize
      @client = client
    end

    def fetch_public_channels
      channels, next_cursor = [], nil
      until next_cursor&.empty?
        response = @client.conversations_list request_params(next_cursor)
        next_cursor = response['response_metadata']['next_cursor']
        channels.concat(response['channels'])
      end
      channels
    end

    private

    def client
      Slack::Client.new(token: ENV.fetch('SLACK_TOKEN'))
    end

    def request_params(next_cursor)
      { exclude_archived: true, limit: 200 }.tap { _1.merge!({ cursor: next_cursor }) if next_cursor.present? }
    end
  end
end
