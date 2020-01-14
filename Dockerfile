FROM rubylang/ruby:2.7.0-bionic
WORKDIR /ruboty-ruby-jp

RUN apt update \
    && apt install -y g++ \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock /ruboty-ruby-jp/
RUN bundle install

COPY . .
