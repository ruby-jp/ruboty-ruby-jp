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
$ docker-compose run ruboty
> ruboty ping
pong
```



Contributing
---


Bug reports and pull requests are welcome on GitHub at https://github.com/pocke/ruboty-ruby-jp.
日本語でもokです


Deployment
---

ruboty-ruby-jp is running on Heroku.
It requires the following environment variables.

* `GOOGLE_CSE_ID`
* `GOOGLE_CSE_KEY`
* `REDIS_URL`
* `SLACK_AUTO_RECONNECT=1`
* `SLACK_TOKEN`
* `TWITTER_CONSUMER_KEY`
* `TWITTER_CONSUMER_SECRET`
* `YAHOO_JAPAN_APP_ID`

License
---


These codes are licensed under CC0.

[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png "CC0")](http://creativecommons.org/publicdomain/zero/1.0/deed.en)
