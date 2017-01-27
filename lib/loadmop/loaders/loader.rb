require 'pathname'
require 'csv'
require 'sequelizer'

module Loadmop
  module Loaders
    class Loader
      attr :db, :options, :data_files_dir, :data_model_name

      def initialize(db, data_files_dir, options = {})
        @data_files_dir = Pathname.new(data_files_dir).expand_path
        @data_model_name = options.delete(:data_model) or raise "You need to specify a data model"
        @options = options
        @db = db
      end

      def create_database
        create_schema_if_necessary
        create_tables
        load_files
        create_indexes
      end

      def all_files
        @all_files ||= make_all_files
      end

      private
      def files_of_interest
        dir = Pathname.new(data_files_dir)
        data_model.keys.map { |k| dir + "#{k}.csv"}.select(&:exist?)
      end

      def create_indexes
        raise NotImplementedError
      end

      def create_tables
        data_model.dup.each do |table_name, columns|
          db.create_table!(send(table_name)) do
            columns.each do |column_name, column_options|
              next if column_name == :indexes
              type = column_options.delete(:type)
              raise "No type for column #{table_name}.#{column_name}" if type.nil?
              send(type, column_name, column_options)
            end
          end
        end
      end

      def data_model
        @data_model ||= Psych.load_file(File.dirname(__FILE__) + "/../../../schemas/#{data_model_name}.yml")
      end

      def method_missing(symbol, *args)
        if data_model.keys.include?(symbol)
          return table_name(symbol)
        else
          super
        end
      end

      def load_files
        all_files.each do |table, columns, files|
          files.each do |file|
            puts "Loading #{file} into #{table}"
            CSV.open(file, "rb", {}) do |csv|
              csv.each_slice(1000) do |rows|
                print '.'
                p rows.first
                p db.schema(table)
                converted_rows = convert(table, columns, rows)
                p converted_rows.first
                db[table_name(table)].import(columns, converted_rows)
              end
            end
            puts
          end
        end
      end

      def create_schema
        raise NotImplementedError
      end

      def convert(table, columns, rows)
        schema_info = Hash[db.schema(table)]
        rows.map do |row|
          columns.map.with_index do |column, i|
            next if row[i].nil?
            case schema_info[column][:type]
            when :integer
              row[i].to_i
            when :string
              row[i]
            else
              raise schema_info[column][:type]
            end
          end
        end
      end

      def adapter
        db.database_type
      end

      def database
        db.opts[:database]
      end

      def headers_for(file)
        if file.to_s =~ /split/
          file = Pathname.new(file.dirname.to_s.sub('split/', '') + '.csv')
        end
        header_line = File.open(file, 'rb', &:readline).downcase.gsub(/\|$/, '')
        delimiter = ','
        delimiter = "\t" if header_line =~ Regexp.new("\t")
        return CSV.parse_line(header_line, col_sep: delimiter).tap{|o|p o}.map(&:to_sym), delimiter
      end

      def lines_per_split
        10000
      end

      def additional_cleaning_steps
        ['iconv -c -t UTF-8']
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

      def schemas
        @schemas ||= (options[:search_path] || '').split(',').map(&:strip).map(&:to_sym)
      end

      def table_name(name)
        return name unless schemas.length > 0
        Sequel.qualify(schemas.first, name)
      end

      def create_schema_if_necessary
        return unless options[:search_path]
        create_schema
      end
    end
  end
end
