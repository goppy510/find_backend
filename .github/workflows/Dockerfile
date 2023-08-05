FROM ruby:3.1.1

RUN echo "deb http://deb.debian.org/debian buster main" > /etc/apt/sources.list \
    && echo "deb http://security.debian.org/debian-security buster/updates main" >> /etc/apt/sources.list \
    && apt-get update -qq

RUN apt-get install -y build-essential \
  openssl \
  default-mysql-client

RUN gem install bundler -v '2.3.26'

ENV LANG C.UTF-8
ENV APP_ROOT /app
