module Ruboty
  module SlackEventsPatch
    module NotifyEvents
      private

      def on_generic_event(message)
        case message.type
        when 'emoji_changed'
          on_emoji_changed(message)
        when 'channel_created'
          on_channel_created(message)
        else
          super
        end
      end

      def on_emoji_changed(message)
        case message.subtype
        when 'add'
          color = 'good'
          text = +"A new emoji is added :#{message.name}: `:#{message.name}:`"
          if message.value&.start_with?('alias:')
            origin = message.value.sub(/\Aalias:/, '')
            text << " (alias of `:#{origin}:`)"
          end
        when 'remove'
          return if ENV['SLACK_EMOJI_IGNORE_REMOVED']

          color = 'danger'
          text = "Removed emoji: #{message.names.join(', ')}"
        else
          return
        end

        post_notification(text: text, color: color, channel: ENV['SLACK_EMOJI_CHANGED_CHANNEL'] || '#emoji')
      end

      def on_channel_created(message)
        text = "A new channel created: <##{message.channel.id}>"

        post_notification(text: text, color: 'good', channel: ENV['SLACK_CHANNEL_CREATED_NOTIFY_CHANNEL'] || '#new_channel')
      end

      def post_notification(text:, color:, channel:)
        adapter.slack_client.chat_postMessage(
          username: adapter.robot.name,
          channel: channel,
          attachments: [
            {
              fallback: text,
              text: text,
              color: color,
            },
          ].to_json,
        )
      end
    end
  end
end

Ruboty::Adapters::SlackEvents::SlackEventsHandler.prepend(Ruboty::SlackEventsPatch::NotifyEvents)
