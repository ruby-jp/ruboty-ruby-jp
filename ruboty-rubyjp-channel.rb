require 'slack'
require 'active_support'

module Ruboty
  module Handlers
    class ChannelGacha < Base
      on(
        %r!(?<options>(\S+ )*)?((channel_gacha)|(チャンネルガチャ))!,
        name: 'channel_gacha',
        description: 'returns randomly channel information',
      )

      def channel_gacha(message)
        option = Options::Channel.build(message.match_data['options'])
        message.reply RubyJP::Channel.all(reload: option.reload?)
                                     .then { |channels| Replies::ChannelGacha.create(channels, option.pre_message) }
      end
    end

    class NewChannel < Base
      on(
        %r!(?<options>(\S+ )*)?((new_channels)|(新チャンネル))!,
        name: 'recent_new_channels',
        description: 'returns recent new channels information',
      )

      def recent_new_channels(message)
        option = Options::Channel.build(message.match_data['options'])
        message.reply RubyJP::Channel.all(reload: option.reload?)
                                     .then { |channels| Replies::NewChannel.create(channels, option.pre_message) }
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

  module NewChannel
    class << self
      def create(channels, pre_message)
        channels.select(&:created_until_now?).then { |new_channels| messages(new_channels, pre_message) }.join("\n\n")
      end

      private

      def messages(channels, pre_message)
        [pre_message, message_for_count(channels), *channels.map(&:channel_information)].compact
      end

      def message_for_count(channels)
        "新チャンネル数(24時間以内): #{channels.length}"
      end
    end
  end
end

module Options
  class Channel
    attr_reader :pre_message

    class << self
      def build(options)
        options.split(' ').map { parse _1 }.compact.to_h.then { |params| new(params) }
      end

      def parse(option)
        case option
        in /\A-(\S+?)=(\S+)/ => with_value
          option_name, value = with_value.split('=', 2)
          [option_name[1..].to_sym, value]
        in /\A-/ => option_name
          [option_name[1..].to_sym, true]
        in /\A[^-]?/
          nil
        end
      end
    end

    def initialize(options = {})
      @reload = options[:r] || false
      @pre_message = options[:pre]
    end

    def reload?
      @reload
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
      @created = Time.at(channel['created'])
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

    def created_until_now?
      Time.zone = 'Tokyo'
      @created.between?(Time.zone.now.yesterday, Time.zone.now)
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
