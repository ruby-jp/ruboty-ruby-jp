FROM rubylang/ruby:2.6.4-bionic
WORKDIR /ruboty-ruby-jp

RUN apt update \
    && apt install -y g++ \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock /ruboty-ruby-jp/
RUN bundle install

COPY . .
