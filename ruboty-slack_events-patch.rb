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

    # The adapter logs the whole message with to_json when DEBUG logging is
    # enabled, but original[:robot] makes the hash cyclic (robot -> adapter
    # -> robot), so ActiveSupport's as_json recurses until SystemStackError
    # kills the process. The adapter only reads original[:thread_ts], so
    # hand over just that.
    module SaySafely
      def say(message)
        original = message[:original]
        message = message.merge(original: { thread_ts: original[:thread_ts] }) if original
        super
      end
    end
  end
end

Ruboty::Adapters::SlackEvents::SlackEventsHandler.prepend(Ruboty::SlackEventsPatch::NotifyEvents)
Ruboty::Adapters::SlackEvents.prepend(Ruboty::SlackEventsPatch::SaySafely)

# The gem passes its log level to Logger.new's second argument, which is
# shift_age, not level, so the logger always runs at DEBUG. Apply the level
# the DEBUG environment variable actually asks for.
Ruboty::SlackEvents::Logger.instance.level = Ruboty::SlackEvents::Logger.log_level
