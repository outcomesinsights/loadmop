FROM ruby:2.6-slim

RUN apt-get update && apt-get -y install \
build-essential \
curl \
docker \
docker-compose \
git \
gnupg2 \
libpq-dev \
libsqlite3-dev \
pass \
pigz \
postgresql-client \
sqlite3 \
zip \
zstd \
&& gem update --system && gem install bundler \
&& mkdir -p lib/loadmop

ENV LANG C.UTF-8

COPY ./lib/loadmop/version.rb ./lib/loadmop
COPY ./Gemfile* ./*.gemspec ./
RUN bundle install
COPY . ./
