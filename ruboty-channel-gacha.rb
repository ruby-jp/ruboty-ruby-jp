require 'slack'
require 'ostruct'
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
        set_option(message)
        message.reply messages.join("\n")
      end

      private

      def set_option(message)
        @option = message.match_data['option']
      end

      def messages
        [pre_message, main_message(selected_channel)].compact
      end

      def pre_message
        @option.split('=', 2)[1] if with_pre_message?
      end

      def main_message(channel)
        [channel_name(channel), topic(channel), purpose(channel)].compact.join("\n")
      end

      def channel_name(channel)
        "チャンネル名: <##{channel.id}>"
      end

      def topic(channel)
        "トピック: #{channel.topic}" if channel.topic.present?
      end

      def purpose(channel)
        "説明: #{channel.purpose}" if channel.purpose.present?
      end

      def selected_channel
        channels.map(&channel_information).sample
      end

      def channels
        @channels = (reload? || !@channels) ? SlackApi::Channel.all_public_channels : @channels
      end

      def reload?
        @option == '-r'
      end

      def with_pre_message?
        @option =~ /\A-pre/
      end

      def channel_information
        -> (channel) do
          OpenStruct.new({
            id: channel['id'],
            topic: channel['topic']['value'],
            purpose: channel['purpose']['value']
          })
        end
      end
    end
  end

  module SlackApi
    class Channel
      class << self
        def all_public_channels
          new.fetch_public_channels
        end
      end

      def fetch_public_channels
        channels, next_cursor = [], nil
        until next_cursor&.empty?
          response = request_params(next_cursor).then(&client.method(:conversations_list))
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
end
