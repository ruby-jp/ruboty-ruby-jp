require 'twitter'
require 'optparse'
require 'shellwords'

module Ruboty
  module Handlers
    class Twitter < Base
      on(
        /twitter user[-_]timeline (?<query>.+)/i,
        name: 'user_timeline',
        description: 'Reply user tweets',
      )

      def user_timeline(message)
        query = Shellwords.split(message.match_data['query'])
        opt = OptionParser.new
        opt.on('--channel=CHANNEL')
        opt.on('--include=QUERY')
        params = {}
        user = opt.parse(query, into: params).join(' ')

        tweets = client.user_timeline(user)
        if params[:include]
          tweets = tweets.select { |t| t.text.include?(params[:include]) }
        end
        if already_tweeted_tweet_id = robot.brain.data[user_timeline_key(user, params)]
          tweets = tweets.select { |t| t.id > already_tweeted_tweet_id }
        end

        unless tweets.empty?
          robot.brain.data[user_timeline_key(user, params)] = tweets.first.id
          o = {}
          if params[:channel]
            o[:to] = params[:channel]
          end
          # Need each_slice because twitter does not exand the URL if it receive too many URLs
          tweets.each_slice(4) do |tws|
            message.reply tws.map(&:url).join("\n"), o
          end
        end
      end

      private def client
        @client ||= ::Twitter::REST::Client.new do |config|
          config.consumer_key        = ENV.fetch "TWITTER_CONSUMER_KEY"
          config.consumer_secret     = ENV.fetch "TWITTER_CONSUMER_SECRET"
        end
      end

      private def user_timeline_key(user, params)
        "twitter-user-timeline.#{user}.#{params}"
      end
    end
  end
end
