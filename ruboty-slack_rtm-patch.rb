require 'ruboty/slack_rtm'

module Ruboty_Adapters_SlackRTM_MonkeyPatch
  def make_channels_cache
    @channel_info_caches ||= {}
    # resp = client.channels_list
    # => {"ok"=>false, "error"=>"unknown_method", "req_method"=>"channels.list"}
    next_cursor = nil
    until next_cursor&.empty?
      resp = @client.conversations_list(exclude_archived: true, cursor: next_cursor, limit: 300)
      return unless resp['ok']
      next_cursor = resp.dig('response_metadata', 'next_cursor')
      resp['channels'].each do |channel|
        @channel_info_caches[channel['id']] = channel
      end
    end
  end
end

Ruboty::Adapters::SlackRTM.prepend Ruboty_Adapters_SlackRTM_MonkeyPatch
