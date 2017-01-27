require 'loadmop/version'
require 'facets/kernel/constant'

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

  def self.loader_klass(db)
    LOADERS[db.database_type.to_sym] || LOADERS[:loader]
  end
end
