# Loadmop

Helps load up the OMOP [Vocabulary](http://imeds.reaganudall.org/Vocabularies)/[CDM](http://omop.org/CDM) into the database of your choice.

## Requirements

- Ruby 2.0+
- [Bundler](http://bundler.io/)
- Some sort of RDBMS to store OMOP Vocabulary files in

## Installation

Add this line to your application's Gemfile:

    gem 'loadmop'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install loadmop

## Usage

Create a .env file in the root directory of the clone, specifying:

- SEQUELIZER_DATABASE
    - The name of the database you want to install to
    - Required
- SEQUELIZER_ADAPTER
    - The name of the adapter to use (e.g. postgres, sqlite, mysql, oracle)
    - Required
- SEQUELIZER_HOST
    - The host on which the database lives
    - Optional
- SEQUELIZER_USERNAME
    - The username to connect to the database with
    - Optional
- SEQUELIZER_PASSWORD
    - The password to connect to the database with
    - Optional
- SEQUELIZER_SEARCH_PATH
    - At least for PostgreSQL, specifies a schema to install into
    - Optional

See the [Sequelizer Gem](https://github.com/outcomesinsights/sequelizer) for [some .env examples](https://github.com/outcomesinsights/sequelizer/tree/master/examples)

Then:

- **Create the database you just specified in your .env file**
    - loadmop isn't (yet) cool enough to actually create the database for you
    - If you're using SQLite, you don't have to create the database file
- Download the [OMOP Vocabulary Files](http://vocabbuild.omop.org/vocabulary-release) and unzip them to some directory.
    - I recommend you use the restricted files since they include CPT codes and other useful vocabularies.
- cd into a directory where you've defined a config/database.yml or .env file that is compatible with Sequelizer
- run `bundle install` to make sure you have all the needed dependencies installed
- run `bundle exec sequelizer config` to ensure your connection parameters are correctly set
- run `bundle exec sequelizer update_gemfile` to ensure your Gemfile has the right database gem
- You'll probably want to just run `bundle exec loadmop create_vocab_database /path/to/directory/holding/unzipped/files`
    - This runs all the steps for creating the vocabulary database, namely
        - Creating the proper tables
        - Prepping the CSV files to load into the database
        - Loading the CSV files into the database
        - Adding some useful indexes to the vocabulary tables

To run an individual command, run `bundle exec loadmop` with no arguments to get a help screen and figure out which command you want to run.

## Pleas for Help

I've written methods to quickly load the data into PostgreSQL and SQLite, but I don't regularly use many other RDBMSs.  Right now they use a method that should work for all RDBMSs, but is pretty slow.

Some of the faster methods are Unix-only as well.  If there are fast, platform-independent ways to load the data, I'm interested.

Please submit suggestions or pull requests to speed up loading under other RDBMSs and I'll incorporate them.  Thanks!

## Contributing

1. Fork it ( https://github.com/outcomesinsights/loadmop/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Thanks

- [Outcomes Insights, Inc.](http://outins.com)
    - Many thanks for allowing me to release a portion of my work as Open Source Software!
- [IMEDS](http://imeds.reaganudall.org/Vocabularies)/[OMOP](http://omop.org)/[OHDSI](http://ohdsi.org)
    - For developing the vocabulary files.  What a fantastic resource!
- [OMOP](http://omop.org)/[OHDSI](http://ohdsi.org)
    - For developing their [CDM](http://omop.org/CDM)
