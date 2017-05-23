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
      type: :boolean,
      default: false,
      desc: 'Loading into Citus DB'
    class_option :force,
      aliases: :f,
      type: :boolean,
      default: false,
      desc: 'Force all tables to be recreated'
    class_option :tables,
      aliases: :t,
      type: :boolean,
      default: true,
      desc: "Create tables"
    class_option :data,
      aliases: :d,
      type: :boolean,
      default: true,
      desc: "Load data"
    class_option :indexes,
      aliases: :i,
      type: :boolean,
      default: true,
      desc: "Create indexes"

    desc 'create {omopv4, omopv4_plus, vocab} database_name files_dir', 'Creates the tables specified in database_name and loads the files specified into them'
    def create(schema, database_name, files_dir)
      Loadmop.create_database(schema, database_name, files_dir, options)
    end
  end
end

