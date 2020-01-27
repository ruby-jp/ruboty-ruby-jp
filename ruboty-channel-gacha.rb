require 'slack'
require 'ostruct'

module Ruboty
  module Handlers
    class ChannelGacha < Base
      on(
        %r!(channel_gacha)|(チャンネルガチャ)!,
        name: 'channel_gacha',
        description: 'returns randomly channel information',
      )

      def channel_gacha(message)
        message.reply format(selected_channel)
      end

      private

      def format(channel)
        <<~MESSAGE
          チャンネル名: #{channel.name}
          トピック: #{channel.topic.presence || '未設定'}
          説明: #{channel.purpose.presence || '未設定'}
        MESSAGE
      end

      def selected_channel
        channels.map(&channel_information).sample
      end

      def channels
        @next_cursor, @channels = nil, []
        until @next_cursor&.empty?
          response = client.conversations_list(request_params)
          @next_cursor = response['response_metadata']['next_cursor']
          @channels.concat(response['channels'])
        end
        @channels
      end

      def client
        Slack::Client.new(token: ENV.fetch('SLACK_TOKEN'))
      end

      def request_params
        { exclude_archived: true, limit: 200 }.tap(&merge_cursor)
      end

      def merge_cursor
        -> (params) do
          params.merge!({ cursor: @next_cursor }) if @next_cursor.present?
        end
      end

      def channel_information
        -> (channel) do
          OpenStruct.new({
            name: channel['name'],
            topic: channel['topic']['value'],
            purpose: channel['purpose']['value']
          })
        end
      end
    end
  end
end
