# OmopVocab

Helps load up the OMOP Vocabulary files into the database of your choice

## Installation

Download the [OMOP Vocabulary Files](http://vocabbuild.omop.org/vocabulary-release) and unzip them to some directory

Install the gem
    $ gem install omop_vocab

Then create a .env file specifying
- DB_DATABASE
    - The name of the database you want to install to
    - Required
- DB_ADAPTER
    - The name of the adapter to use (e.g. postgres, sqlite, mysql, oracle)
    - Required
- DB_HOST
    - The host on which the database lives
    - Optional
- DB_USERNAME
    - The username to connect to the database with
    - Optional
- DB_PASSWORD
    - The password to connect to the database with
    - Optional
- DB_SEARCH_PATH
    - At least for PostgreSQL, specifies a schema to install into
    - Optional

## Usage

Type loadmop for a list of command you can execute

## Contributing

1. Fork it ( https://github.com/[my-github-username]/omop_vocab/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
