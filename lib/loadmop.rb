require 'loadmop/version'
require 'loadmop/loaders/cdmv4_loader'
require 'loadmop/loaders/cdmv4_plus_loader'
require 'loadmop/loaders/vocab_loader'
require 'loadmop/loaders/generic_loader'

module Loadmop
  def self.loader(schema)
    {
      vocab: VocabLoader,
      cdmv4: CDMv4Loader,
      cdmv4_plus: CDMv4PlusLoader
    }[schema.to_sym]
  end
end
