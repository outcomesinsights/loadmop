require_relative 'loader'

module Loadmop
  class VocabLoader < Loader

    private

    def schemas_dir
      'schemas/vocabulary'
    end

    def additional_cleaning_steps
      ["sed 's/\|$//'"]
    end
  end
end

