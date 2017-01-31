require 'thor'
require 'loadmop'
require 'sequelizer'

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
    class_option :citus,
      aliases: :c,
      type: :boolean,
      default: false,
      desc: 'Loading into Citus DB'
    class_option :force,
      aliases: :f,
      type: :boolean,
      default: false,
      desc: 'Force all tables to be recreated'

    desc 'create {omopv4, omopv4_plus, vocab} database_name files_dir', 'Creates the tables specified in database_name and loads the files specified into them'
    def create(schema, database_name, files_dir)
      _db = db(options.merge(database: database_name))
      loader = Loadmop.loader_klass(_db).new(_db, files_dir, options.merge(data_model: schema))
      loader.create_database
    end
  end
end

