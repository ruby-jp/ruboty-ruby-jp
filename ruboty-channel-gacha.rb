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
        client.channels_list["channels"].map(&channel_information).sample
      end

      def client
        Slack::Client.new(token: ENV.fetch('SLACK_TOKEN'))
      end

      def channel_information
        -> (channel) do
          OpenStruct.new({
            name: channel["name"],
            topic: channel["topic"]["value"],
            purpose: channel["purpose"]["value"]
          })
        end
      end
    end
  end
end