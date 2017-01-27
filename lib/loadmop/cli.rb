require 'thor'
require 'loadmop'

module Loadmop
  class CLI < Thor
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
    class_option :citus,
      aliases: :c,
      desc: 'Loading into a Citus DB'

    desc 'create {cdmv4, cdmv4_plus, vocab} database_name files_dir', 'Creates the tables specified in database_name and loads the files specified into them'
    def create(schema, database_name, files_dir)
      #loader = Loadmop.loader(schema).new(database_name, files_dir, options)
      loader = Loadmop::GenericLoader.new(database_name, files_dir, options.merge(data_model: schema))
      loader.create_database
    end
  end
end

