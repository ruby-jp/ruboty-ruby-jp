FROM rubylang/ruby:2.7.8-bionic
WORKDIR /ruboty-ruby-jp

RUN apt update \
    && apt upgrade -y \
    && apt install -y g++ make \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock /ruboty-ruby-jp/
RUN bundle install

COPY . .
