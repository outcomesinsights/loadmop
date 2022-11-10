FROM ruby:2.7-slim-bullseye

RUN apt-get update && apt-get -y install \
    curl ca-certificates gnupg2
RUN curl https://www.postgresql.org/media/keys/ACCC4CF8.asc \
  | gpg --dearmor \
  | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main" > /etc/apt/sources.list.d/postgresql.list
RUN apt-get update && apt-get -y install \
build-essential \
docker \
docker-compose \
git \
libpq-dev \
libsqlite3-dev \
pass \
pigz \
postgresql-client-14 \
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
