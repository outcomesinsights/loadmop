# Loadmop

Helps load up the OMOP Vocabulary files into the database of your choice

## Installation

Clone this repository to where you want it.  I'm not familiar enough with RubyGems to make this a proper program.

## Usage

Create a .env file in the root directory of the clone, specifying:

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

See the [Sequelizer Gem](https://github.com/outcomesinsights/sequelizer) for [some .env examples](https://github.com/outcomesinsights/sequelizer/tree/master/examples)

Then:

- **Create the database you just specified in your .env file**
    - loadmop isn't (yet) cool enough to actually create the database for you
- Download the [OMOP Vocabulary Files](http://vocabbuild.omop.org/vocabulary-release) and unzip them to some directory.  I recommend you use the restricted files since they include CPT codes and other useful vocabularies.
- cd into the clone of this repo
- You'll probably want to just run `./bin/loadmop create_vocab_database /path/to/directory/holding/unzipped/files`
    - This runs all the steps for creating the vocabulary database, namely
        - Creating the proper tables
        - Prepping the CSV files to load into the database
        - Loading the CSV files into the database
        - Adding some useful indexes to the vocabulary tablesj

To run an individual command, run `./bin/loadmop` with no arguments to get a help screen and figure out which command you want to run.

## Future Plans

- Provide commands to work with the [OMOP CDMv4](http://omop.org/CDM) schema
    - Create a database structured for OMOP CDM data
    - Load data into an OMOP CDM database

## Pleas for Help

I've written methods to quickly load the data into PostgreSQL and SQLite, but I don't regularly use many other RDBMSs.  Right now they use a method that should work for all RDBMSs, but is pretty slow.

Please submit suggestions or pull requests to speed up loading under other RDBMSs and I'll incorporate them.  Thanks!

## Contributing

1. Fork it ( https://github.com/outcomesinsights/loadmop/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Thanks

- [Outcomes Insights, Inc.](http://outins.com)
    - Many thanks for allowing me to release a portion of my work asu
    Open Source Software!
- [IMEDS](http://imeds.reaganudall.org/Vocabularies)/[OMOP](http://omop.org)/[OHDSI](http://ohdsi.org)
    - For developing the vocabulary files.  What a fantastic resource!
