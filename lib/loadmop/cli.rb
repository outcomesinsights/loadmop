require 'thor'
require_relative 'cdmv4_loader'
require_relative 'vocab_loader'

module Loadmop
  class CLI < Thor
    include Sequelizer

    class_option :adapter,
      aliases: :a,
      desc: 'adapter for database'
    class_option :host,
      aliases: :h,
      banner: 'localhost',
      desc: 'host for database'
    class_option :username,
      aliases: :u,
      desc: 'username for database'
    class_option :password,
      aliases: :P,
      desc: 'password for database'
    class_option :port,
      aliases: :p,
      type: :numeric,
      banner: '5432',
      desc: 'port for database'
    class_option :search_path,
      aliases: :s,
      desc: 'schema for database (PostgreSQL and SQL Server only)'

    desc 'create_vocab_database database_name vocab_files_dir', 'Creates the vocabulary tables in database_name and loads the OMOP Vocabulary data into them.'
    def create_vocab_database(database_name, vocab_files_dir)
      loader = VocabLoader.new(database_name, vocab_files_dir, options)
      loader.create_database
    end

    desc 'create_cdmv4_database database_name data_dir', 'Creates a set of tables in database_name for OMOP CDMv4 then loads data into them as specified by data_files_dir.'
    def create_cdmv4_database(database_name, data_files_dir)
      loader = CDMv4Loader.new(database_name, data_files_dir, options)
      loader.create_database
    end
  end
end

