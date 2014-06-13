source 'https://rubygems.org'

# Specify your gem's dependencies in omop_vocab.gemspec
gemspec
gem 'sequelizer', path: '../sequelizer'
gem 'thor'

require 'dotenv'
Dotenv.load
case ENV['DB_ADAPTER']
when 'postgres'
  gem 'pg'
when 'sqlite'
  gem 'sqlite3'
else
  raise "I don't know what gem to use for adapter: '#{ENV['DB_ADAPTER']}'.  Please make sure your .env file is correct!"
end
