require "pathname"
require "csv"
require "sequelizer"
require_relative "../data_filer"
require "benchmark"
require "pp"
require "pry-byebug"

module Loadmop
  module Loaders
    class Loader

      attr :db, :options, :data_filer, :data_model_name, :force, :tables, :data, :indexes, :pk_constraints, :fk_constraints, :logger, :allow_nulls

      def initialize(db, data_files_path, options = {})
        @data_filer = Loadmop::DataFiler.data_filer(data_files_path, self, options)
        @data_model_name = options.delete(:data_model) or raise "You need to specify a data model"
        @force = options.delete(:force)
        @tables = options.delete(:tables)
        @data = options.delete(:data)
        @indexes = options.delete(:indexes)
        @pk_constraints = options.delete("primary-keys".to_sym)
        @logger = options.delete(:logger) || Logger.new(STDOUT)
        @fk_constraints = options.delete("foreign-keys".to_sym)
        @allow_nulls = options.delete("allow-nulls".to_sym)
        @options = options
        @db = db
        db.loggers = Array(Logger.new(STDOUT))
      end

      def create_database
        create_schema_if_necessary
        create_tables if tables
        report_tables if tables
        load_files if data
        perform_load_post_processing if data
        create_indexes if indexes && supports_indexes?
        create_primary_key_constraints if pk_constraints && supports_pk_constraints?
        create_foreign_key_constraints if fk_constraints && supports_fk_constraints?
      end

      def data_model
        Psych.load_file(File.dirname(__FILE__) + "/../../../schemas/#{data_model_name}/schema.yml")
      end

      private

      def perform_load_post_processing
      end

      def report_tables
        logger.debug do
          db.tables(qualify: true).map do |table_name|
            logger.debug table_name
            [table_name, db.schema(table_name)]
          end.to_h.pretty_inspect
        end
      end

      def all_files
        data_filer.all_files
      end

      def load_file_set(table, columns, files, delimiter = ",")
        files.each do |file|
          logger.info "Loading #{file} into #{table}"
          CSV.open(file, "rb", { col_sep: delimiter }) do |csv|
            csv.each_slice(1000) do |rows|
              print '.'
              logger.debug rows.first
              logger.debug db.schema(table)
              converted_rows = convert(table, columns, rows)
              logger.debug converted_rows.first
              db[table].import(columns, converted_rows)
            end
          end
        end
      end

      def load_files
        all_files.each do |table, columns, files, delimiter|
          table = table_name(table)
          orig_count = db[table].count
          logger.info "Loading #{table.inspect}..."
          elapsed = Benchmark.realtime do
            load_file_set(table, columns, files, delimiter)
          end
          count = db[table].count - orig_count
          logger.info "Loaded #{count} records into #{table} in #{elapsed} seconds #{count/elapsed} rec/sec"
        end
      end

      def drop_table_opts
        {cascade: true}
      end

      def create_tables
        s = self
        data_model.dup.each do |table_name, table_info|
          logger.info "Creating table #{table_name}..."
          db.drop_table(table_name, drop_table_opts.merge(if_exists: true)) if force
          db.create_table(send(table_name)) do
            columns = table_info[:columns]
            columns.each do |column_name, column_options|
              type = column_options.delete(:type)
              column_options[:null] = s.allow_nulls || column_options.fetch(:null, true)
              raise "No type for column #{table_name}.#{column_name}" if type.nil?
              send(type, column_name, column_options)
            end
          end
        end
        post_create_tables if respond_to?(:post_create_tables)
      end

      def indices
        @indices ||= Hash[
          data_model.map do |table_name, table_info|
            table_indices = table_info[:indexes]
            next unless table_indices
            [table_name, table_indices]
          end.compact
        ]
      end

      def create_primary_key_constraints
        data_model.each do |table, table_info|
          next unless db.table_exists?(table)
          columns = table_info[:columns]
          columns.each do |column_name, column_options|
            next unless pk = column_options[:primary_key]
            if pk_column = db.primary_key(table)
              puts "Can't set #{column_name} as PK since #{table}.#{pk_column} is already PK"
              next
            end

            db.alter_table(table) do
              add_primary_key([column_name])
            end
            create_index(table, [column_name], unique: true)
          end
        end
      end

      def create_foreign_key_constraints
        data_model.each do |table, table_info|
          next unless db.table_exists?(table)
          columns = table_info[:columns]
          columns.each do |column_name, column_options|
            next unless fk = column_options[:foreign_key]
            next unless db.table_exists?(fk.to_sym)
            key = get_key(fk)
            db.alter_table(table) do
              add_foreign_key([column_name], fk, key: key)
            end
          end
        end
      end

      def create_indexes
        indices.each do |table_name, table_indices|
          if table_indices.is_a?(Hash)
            table_indices.each do |index_name, details|
              logger.info "Creating index '#{index_name}' for table #{table_name}..."
              columns = details.delete(:columns).map(&:to_sym)
              create_index(table_name, columns, { name: index_name }.merge(details))
            end
          else
            table_indices.each do |columns|
              next unless index_allowed?(columns)
              logger.debug columns.pretty_inspect
              details = columns.pop if columns.last.is_a?(Hash)
              columns = columns.map do |column|
                unless column.is_a?(Array)
                  column
                else
                  Sequel.function(column.shift, *column)
                end
              end
              details ||= {}
              create_index(table_name, columns, details)
            end
          end
        end
      end

      def index_allowed?(columns)
        true
      end

      def create_index(table_name, columns, details)
        elapsed = Benchmark.realtime do
          begin
            db.add_index(table_name, columns, details)
          rescue Sequel::DatabaseError, PG::DuplicateTable
            logger.info $!.message
          end
        end
        logger.info "Took #{elapsed}"
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

      def get_key(fk)
        return :id if data_model_name.to_s == "gdm"
        return [fk, :id].join("_").to_sym
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

      def supports_pk_constraints?
        true
      end

      def supports_fk_constraints?
        true
      end
    end
  end
end
