require 'ruboty/slack_rtm'

module Ruboty_Adapters_SlackRTM_MonkeyPatch
  def make_channels_cache
    # resp = client.channels_list
    # => {"ok"=>false, "error"=>"unknown_method", "req_method"=>"channels.list"}
    resp = client.conversations_list
    if resp['ok']
      resp['channels'].each do |channel|
        @channel_info_caches[channel['id']] = channel
      end
    end
  end
end

Ruboty::Adapters::SlackRTM.prepend Ruboty_Adapters_SlackRTM_MonkeyPatch
