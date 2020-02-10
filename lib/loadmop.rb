require 'loadmop/version'
require 'loadmop/ancestorizer'
require 'loadmop/gdm_full_indexer'
require 'loadmop/quick_indexer'
require 'loadmop/test_schema_zapper'
require 'facets/kernel/constant'
require 'sequelizer'

module Loadmop
  LOADERS_DIR = "loadmop/loaders/"
  LOADERS = Hash[Dir.glob(File.dirname(__FILE__) + "/" + LOADERS_DIR + "*.rb").map do |loader_file|
    loader_name = File.basename(loader_file, ".*")
    parts = loader_name.split('_')
    loader_class_name = (['loadmop::', 'loaders::'] + parts).map(&:capitalize).join
    parts.pop
    loader_key = parts.join('_').to_sym
    require_relative LOADERS_DIR + loader_name
    [loader_key, constant(loader_class_name)]
  end]

  class << self
    include Sequelizer

    def logger
      @logger ||= Logger.new(STDOUT).tap { |l| l.level = Logger::DEBUG }
    end

    def loader_klass(db)
      LOADERS[db.database_type.to_sym] || LOADERS[:loader]
    end

    def create_complete_database(data_model, database_name, files_dir, db_options)
      create_database(data_model, database_name, files_dir, db_options.merge(data: true, tables: true, indexes: true, "foreign-keys".to_sym => true))
    end

    def create_database(data_model, database_name, files_dir, options = {})
      _db = new_db(options.merge(database: database_name, loggers: Array(logger)))
      loader = loader_klass(_db).new(_db, files_dir, options.merge(data_model: data_model, logger: logger))
      loader.create_database
    end

    def ancestorize(database_name, opts = {})
      _db = new_db(opts.merge(database: database_name, loggers: Array(logger)))
      Ancestorizer.new(_db).ancestorize
    end

    def quick_index(options = {})
      QuickIndexer.new(db, options).quick_index
    end

    def gdm_full_index(options = {})
      GdmFullIndexer.new(db, options).index_it
    end

    def zap_test_schemas(opts = {})
      TestSchemaZapper.new(db, opts).zap
    end
  end
end
