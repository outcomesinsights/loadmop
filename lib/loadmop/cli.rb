require 'thor'
require_relative 'cdmv4_loader'
require_relative 'vocab_loader'

module Loadmop
  class CLI < Thor
    include Sequelizer

    class_option :search_path,
      aliases: :s,
      desc: 'schema for database (PostgreSQL only)'

    desc 'create_vocab_database vocab_files_dir', 'Connects to database specified in the .env file and loads the OMOP Vocabulary schema and data into it'
    def create_vocab_database(vocab_files_dir)
      loader = VocabLoader.new(vocab_files_dir, options)
      loader.create_database
    end

    desc 'create_cdmv4_data data_dir', 'Creates a schema in a database for OMOP CDMv4 then loads data into it as specified by data_files_dir'
    def create_cdmv4_database(data_files_dir)
      cdm_loader = CDMv4Loader.new(data_files_dir, options)
      cdm_loader.create_database
    end
  end
end

