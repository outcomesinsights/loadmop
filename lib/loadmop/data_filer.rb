require 'uri'
require 'pathname'
require 'open3'
require "find"

module Loadmop
  module DataFiler
    def self.data_filer(string, loader, options = {})
      case string
      when %r{s3}
        S3Filer.new(URI(string.chomp("/")), loader, options)
      when nil
        NullFiler.new
      else
        PathFiler.new(Pathname.new(string), loader, options)
      end
    end

    class NullFiler
      def all_files
        []
      end
    end

    class Filer
      attr :source, :loader, :options
      def initialize(source, loader, options = {})
        @source = source
        @loader = loader
        @options = options
      end

      def all_files
        @all_files ||= make_all_files
      end

      def convert(table, columns, rows)
        loader.convert(table, columns, rows)
      end

      def additional_cleaning_steps
        ['iconv -c -t UTF-8']
      end

      def headers_for(file)
        header_line = get_header_line(file)
        delimiter = ","
        delimiter = "\t" if header_line =~ Regexp.new("\t")
        return CSV.parse_line(header_line, col_sep: delimiter).tap{ |o| p o }.map(&:to_sym), delimiter
      end
    end

    class PathFiler < Filer
      LEXICON_TABLES = %i[ancestors concepts mappings vocabularies]
      EXTENSIONS = %w(csv tsv)

      def files_of_interest
        lexicon_files.merge(data_files)
      end

      def lexicon_files
        known_files = loader.data_model.keys
          .select { |k| LEXICON_TABLES.include?(k) }
          .map { |k| EXTENSIONS.map { |ext| "#{k}.#{ext}" } }.flatten

        files = Find.find(source)
          .select { |f| known_files.include?(File.basename(f)) }
          .map { |f| Pathname.new(f) }
          .group_by { |f| f.basename }
      end

      def data_files
        known_files = loader.data_model.keys
          .reject { |k| LEXICON_TABLES.include?(k) }
          .map { |k| EXTENSIONS.map { |ext| "#{k}.#{ext}" } }.flatten

        files = search_paths.flat_map do |search_path|
          Find.find(search_path)
            .select { |f| known_files.include?(File.basename(f)) }
            .map { |f| Pathname.new(f) }
        end.group_by { |f| f.basename }
      end

      def search_paths
        return [source] unless options[:shards]
        options[:shards].split(",").map { |shard| Pathname.new(source) + shard }
      end

      def get_header_line(file)
        if file.to_s =~ /split/
          file = Pathname.new(file.dirname.to_s.sub('split/', '') + file.extname)
        end
        File.open(file, 'rb', &:readline).downcase.gsub(/\|$/, '')
      rescue
        puts "Failed to get header for #{file}"
        raise
      end

      def lines_per_split
        options["lines-per-split".to_sym] || 100000
      end

      def make_all_files
        split_dir = source + 'split'
        split_dir.mkdir unless split_dir.exist?
        files_of_interest.map do |basename, files|
          file = files.first
          table_name = file.basename('.*').to_s.downcase.to_sym
          headers, delimiter = headers_for(file)
          dir = split_dir + table_name.to_s
          unless dir.exist?
            dir.mkdir
            Dir.chdir(dir) do
              puts "Splitting #{files}"
              steps = []
              steps << "tail --quiet --lines=+2 #{files.map(&:expand_path).join(" ")}"
              steps += additional_cleaning_steps
              steps << "split --suffix-length=6 --lines=#{lines_per_split}"
              command = steps.compact.join(" | ")
              puts command
              system(command)
            end
          end
          [table_name, headers, dir.children.sort, delimiter]
        end
      end
    end

    class S3Filer < Filer
      def make_all_files
        matching_folders.map do |folder|
          file = files[folder]
          next if file_size(file).zero?
          table_name = folder.to_sym
          headers, delimiter = headers_for(file)
          inny, outty, pid = Open3.popen2("aws s3 cp #{file} - | tail -n +2")
          [table_name, headers, [outty], delimiter]
        end.compact
      end

      def file_size(file)
        `s3cmd info #{file}`.match(/File size:\s*(\d+)/)[1].to_i
      end

      def get_header_line(file)
        puts file
        `./bin/s3curl.pl --id=personal -- --range 0-1000 '#{s3_as_url(file)}' | head`.split("\n").first
      end

      def matching_folders
        @matching_folders ||= loader.data_model.keys.map(&:to_s) & folders
      end

      def files
        @files ||= Hash[folders.map do |folder|
          path = [@source, folder, "#{folder}.csv"].join("/")
          [folder, path]
        end]
      end

      def folders
        @folders ||= `aws s3 ls #{@source}`.split("\n").map do |line|
          line.strip.split(/\s+/).last.chop
        end
      end

      def s3_as_url(file)
	u = URI(file)
        "http://#{u.host}.s3.amazonaws.com#{u.path}"
      end
    end
  end
end
