require 'ruboty/brains/redis'

module Ruboty_Brains_Redis_MonkeyPatch
  def redis
    ::Redis.new(url: url, ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
  end
end

Ruboty::Brains::Redis.prepend Ruboty_Brains_Redis_MonkeyPatch
