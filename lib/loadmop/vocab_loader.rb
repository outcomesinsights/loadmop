require_relative 'loader'

module Loadmop
  class VocabLoader < Loader

    attr :options, :data_files_dir

    def initialize(data_files_dir, options = {})
      @data_files_dir = Pathname.new(data_files_dir)
      @options = options
      @schemas_dir = 'schemas/vocabulary'
    end

    private
    def files
      fix_vocab_data
      Pathname.glob(data_files_dir + 'cleaned' + '*.csv')
    end

    def fix_vocab_data
      Pathname.glob(data_files_dir + '/*.csv') do |vocab_file|
        clean_dir = vocab_file.dirname + 'cleaned'
        clean_dir.mkdir unless clean_dir.exist?
        clean_file = clean_dir + vocab_file.basename
        next if clean_file.exist?
        puts "Cleaning #{vocab_file}"
        system("head -n 1 #{vocab_file} | sed 's/\|$//' | tr '[A-Z]' '[a-z]' >> #{clean_file}")
        system("tail -n +2 #{vocab_file} | sed 's/\|$//' >> #{clean_file}")
      end
    end
  end
end

