source "https://rubygems.org"

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5' # the same version as .ruby-version

gem "rake"
gem 'parser'
# Same as https://github.com/rosylilly/ruboty-slack_rtm/pull/40,
# but forked branch to avoid removing the original branch.
gem "ruboty-slack_rtm", require: false, github: 'pocke/ruboty-slack_rtm', branch: 'fix/no-reaction'
gem 'ruboty-redis'
gem 'ruboty-cron'
gem 'ruboty-rurema'
gem 'twitter'
gem 'ruboty-rainfall_jp'
gem 'ruboty-google_image'
