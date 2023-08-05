FROM ruby:3.1.1

RUN apt-get update -qq
RUN apt-get install -y build-essential \
  openssl \
  mariadb-client

ENV LANG C.UTF-8
ENV APP_ROOT /app

ADD ./src/ $APP_ROOT

WORKDIR $APP_ROOT

RUN gem update --system
RUN bundle update --bundler
RUN bundle install

WORKDIR $APP_ROOT
