require 'pathname'
require 'csv'
require 'sequelizer'
require_relative '../data_filer'
require 'benchmark'

module Loadmop
  module Loaders
    class Loader
      attr :db, :options, :data_filer, :data_model_name, :force, :tables, :data, :indexes

      def initialize(db, data_files_path, options = {})
        @data_filer = Loadmop::DataFiler.data_filer(data_files_path, self)
        @data_model_name = options.delete(:data_model) or raise "You need to specify a data model"
        p options
        @force = options.delete(:force)
        @tables = options.delete(:tables)
        @data = options.delete(:data)
        @indexes = options.delete(:indexes)
        @options = options
        @db = db
      end

      def create_database
        create_schema_if_necessary
        create_tables if tables
        load_files if data
        create_indexes if indexes && supports_indexes?
      end

      def data_model
        @data_model ||= Psych.load_file(File.dirname(__FILE__) + "/../../../schemas/#{data_model_name}.yml")
      end

      private

      def all_files
        data_filer.all_files
      end

      def load_file_set(table, columns, files, delimiter = ",")
        files.each do |file|
          puts "Loading #{file} into #{table}"
          CSV.open(file, "rb", {}) do |csv|
            csv.each_slice(1000) do |rows|
              print '.'
              p rows.first
              p db.schema(table)
              converted_rows = convert(table, columns, rows)
              p converted_rows.first
              db[table].import(columns, converted_rows)
            end
          end
          puts
        end
      end

      def load_files
        all_files.each do |table, columns, files|
          table = table_name(table)
          orig_count = db[table].count
          puts "Loading #{table}..."
          elapsed = Benchmark.realtime do
            load_file_set(table, columns, files)
          end
          count = db[table].count - orig_count
          puts "Loaded #{count} records into #{table} in #{elapsed} seconds #{count/elapsed} rec/sec"
        end
      end

      def create_tables
        data_model.dup.each do |table_name, columns|
          db.send(create_method, send(table_name)) do
            columns.each do |column_name, column_options|
              next if column_name == :indexes
              type = column_options.delete(:type)
              raise "No type for column #{table_name}.#{column_name}" if type.nil?
              send(type, column_name, column_options)
            end
          end
        end
        post_create_tables if respond_to?(:post_create_tables)
      end

      def indices
        @indices ||= Hash[
          data_model.map do |table_name, columns|
            table_indices = columns[:indexes]
            next unless table_indices
            [table_name, table_indices]
          end.compact
        ]
      end

      def create_indexes
        indices.each do |table_name, table_indices|
          table_indices.each do |index_name, details|
            puts "Creating index '#{index_name}' for table #{table_name}..."
            columns = details.delete(:columns).map(&:to_sym)
            elapsed = Benchmark.realtime do
              begin
                db.add_index(table_name, columns, { name: index_name }.merge(details))
              rescue Sequel::DatabaseError, PG::DuplicateTable
                puts $!.message
              end
            end
            puts "Took #{elapsed}"
          end
        end
      end

      def method_missing(symbol, *args)
        if data_model.keys.include?(symbol)
          return table_name(symbol)
        else
          super
        end
      end

      def create_schema
        raise NotImplementedError
      end

      def adapter
        db.database_type
      end

      def database
        db.opts[:database]
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

      def supports_indexes?
        true
      end

      def create_method
        force ? :create_table! : :create_table?
      end
    end
  end
end
