require 'loadmop/version'
require 'loadmop/ancestorizer'
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

    def loader_klass(db)
      LOADERS[db.database_type.to_sym] || LOADERS[:loader]
    end

    def create_database(schema, database_name, files_dir, options = {})
      _db = db(options.merge(database: database_name))
      loader = loader_klass(_db).new(_db, files_dir, options.merge(data_model: schema))
      loader.create_database
    end

    def ancestorize(database_name)
      _db = db(database: database_name)
      Ancestorizer.new(_db).ancestorize
    end

    def quick_index(options = {})
      QuickIndexer.new(db, options = {}).quick_index
    end

    def zap_test_schemas(opts = {})
      TestSchemaZapper.new(db, opts).zap
    end
  end
end
