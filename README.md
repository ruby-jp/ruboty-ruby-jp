Ruboty ruby-jp
===

Ruboty for ruby-jp slack workspace.



Development
---

```bash
$ bundle install
$ REDIS_URL=redis://localhost:6379/ RUBOTY_CLI=1 bundle exec ruby main.rb
> ruboty ping
pong
```

If you have docker environment, also can development by run below command

```bash
$ docker compose build
$ docker compose run --rm ruboty
> ruboty ping
pong
```



Contributing
---


Bug reports and pull requests are welcome on GitHub at https://github.com/ruby-jp/ruboty-ruby-jp.
日本語でもokです


Slack app setup
---

1. Open https://api.slack.com/apps and create a new app with "From an app manifest" using [slack-app-manifest.yml](slack-app-manifest.yml) (or paste the manifest into an existing app's "App Manifest" page).
2. In "Basic Information" > "App-Level Tokens", generate a token with the `connections:write` scope. This is `SLACK_APP_TOKEN` (`xapp-...`), used for Socket Mode.
3. Install the app to the workspace and copy the "Bot User OAuth Token". This is `SLACK_TOKEN` (`xoxb-...`).
4. Invite the bot to the channels it should watch and post to, e.g. `#emoji` and `#new_channel`.


Deployment
---

ruboty-ruby-jp is running on Heroku.
It requires the following environment variables.

* `REDIS_URL`
* `SLACK_APP_TOKEN`
* `SLACK_AUTO_RECONNECT=1`
* `SLACK_TOKEN`
* `YAHOO_JAPAN_APP_ID`

The following are optional.

* `SLACK_EMOJI_CHANGED_CHANNEL` (default: `#emoji`)
* `SLACK_EMOJI_IGNORE_REMOVED` (set to skip removed-emoji notifications)
* `SLACK_CHANNEL_CREATED_NOTIFY_CHANNEL` (default: `#new_channel`)

License
---


These codes are licensed under CC0.

[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png "CC0")](http://creativecommons.org/publicdomain/zero/1.0/deed.en)
