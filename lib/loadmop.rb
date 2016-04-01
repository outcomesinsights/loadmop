require 'loadmop/version'
require 'loadmop/cdmv4_loader'
require 'loadmop/cdmv4_plus_loader'
require 'loadmop/vocab_loader'

module Loadmop
  def self.loader(schema)
    {
      vocab: VocabLoader,
      cdmv4: CDMv4Loader,
      cdmv4_plus: CDMv4PlusLoader
    }[schema.to_sym]
  end
end
