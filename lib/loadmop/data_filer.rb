require 'uri'
require 'pathname'
require 'open3'

module Loadmop
  module DataFiler
    def self.data_filer(string, loader)
      case string
      when %r{s3}
        S3Filer.new(string, loader)
      else
        PathFiler.new(string, loader)
      end
    end

    class Filer
      attr :source, :loader
      def initialize(string, loader)
        @source = URI(string.chomp("/"))
        @loader = loader
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
        return CSV.parse_line(header_line, col_sep: delimiter).tap{|o|p o}.map(&:to_sym), delimiter
      end
    end

    class PathFiler < Filer
      def files_of_interest
        dir = Pathname.new(data_files_dir)
        loader.data_model.keys.map { |k| dir + "#{k}.csv"}.select(&:exist?)
      end

      def get_header_line(file)
        if file.to_s =~ /split/
          file = Pathname.new(file.dirname.to_s.sub('split/', '') + '.csv')
        end
        File.open(file, 'rb', &:readline).downcase.gsub(/\|$/, '')
      end

      def lines_per_split
        10000
      end

      def make_all_files
        split_dir = data_files_dir + 'split'
        split_dir.mkdir unless split_dir.exist?
        files_of_interest.map do |file|
          table_name = file.basename('.*').to_s.downcase.to_sym
          headers, delimiter = headers_for(file)
          dir = split_dir + table_name.to_s
          unless dir.exist?
            dir.mkdir
            Dir.chdir(dir) do
              puts "Splitting #{file}"
              steps = []
              steps << "tail -n +2 #{file.expand_path}"
              steps += additional_cleaning_steps
              steps << "split -a 5 -l #{lines_per_split}"
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
