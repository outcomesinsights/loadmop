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
    class_option "primary-keys".to_sym,
      aliases: :I,
      type: :boolean,
      default: true,
      desc: "Create primary key constraints"
    class_option "foreign-keys".to_sym,
      aliases: :k,
      type: :boolean,
      default: true,
      desc: "Create foreign key constraints"
    class_option "allow-nulls".to_sym,
      aliases: :N,
      type: :boolean,
      default: false,
      desc: "Create null constraings"

    desc 'create {omopv4, omopv4_plus, gdm, vocab} database_name files_dir', 'Creates the tables specified in database_name and loads the files specified into them'
    def create(schema, database_name, files_dir)
      Loadmop.create_database(schema, database_name, files_dir, options)
    end

    desc 'ancestorize database_name', 'Creates the ancestors table and a couple helpful views'
    def ancestorize(database_name)
      Loadmop.ancestorize(database_name, options)
    end

    desc 'quick_index', 'Creates indexes on any column ending in _id'
    def quick_index
      Loadmop.quick_index(options)
    end

    desc 'gdm_full_indexes', 'Creates indexes on lots of potentially searched columns'
    def gdm_full_indexes
      Loadmop.gdm_full_index(options)
    end

    desc 'zap_test_schemas', 'Drops all schemas that contain "_test_" in the name.  Use with caution.'
    def zap_test_schemas
      Loadmop.zap_test_schemas(options)
    end
  end
end

