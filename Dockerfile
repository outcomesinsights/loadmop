FROM ruby:2.6-slim

RUN apt-get update && apt-get -y install \
build-essential \
curl \
docker \
docker-compose \
git \
gnupg2 \
libpq-dev \
locales \
pass \
pigz \
postgresql-client \
&& gem update --system && gem install bundler \
&& mkdir -p lib/loadmop


RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.UTF-8

COPY ./lib/loadmop/version.rb ./lib/loadmop
COPY ./Gemfile* ./*.gemspec ./
RUN bundle install
COPY . ./
