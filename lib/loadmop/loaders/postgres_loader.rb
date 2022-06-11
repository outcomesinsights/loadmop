require_relative 'loader'

module Loadmop
  module Loaders
    class Partitioner
      NON_PARTITIONED_TABLES = %w(
        addresses
        ancestors
        concepts
        contexts_practitioners
        facilities
        mappings
        practitioners
        vocabularies
      )

      attr_reader :max_shard_number, :loader

      def initialize(loader)
        @loader = loader
        @max_shard_number ||= loader.data_files_path.children.select(&:directory?).select { |k| k.basename.to_s =~ /^\d+$/ }.map { |k| k.basename.to_s.to_i }.max
      end

      def shard_numbers
        (0...max_shard_number)
      end

      def prepare_database
        db.run("CREATE EXTENSION IF NOT EXISTS pg_trgm")
        db.run("CREATE EXTENSION IF NOT EXISTS fuzzystrmatch")
      end

      def post_create_table(table_name)
        return if ignore_table?(table_name)

        msn = max_shard_number
        shard_numbers.each do |shard_number|
          partitioned_table_name = sprintf("%s_%04d", table_name, shard_number).to_sym
          loader.db.create_table(partitioned_table_name, partition_of: table_name.to_sym) do
            modulus msn
            remainder shard_number
          end
        end
      end

      def ignore_table?(table)
        return true unless loader.partitioned
        !is_table_partitioned?(table)
      end

      def is_table_partitioned?(table)
        !NON_PARTITIONED_TABLES.include?(table.to_s)
      end

      def create_table_options(table_name)
        return {} if ignore_table?(table_name)
        { partition_by: partition_column_for(table_name), partition_type: :hash }
      end

      def partition_column_for(table_name)
        return :id if is_patients?(table_name)
        return :patient_id
      end

      def is_patients?(table)
        table.to_s =~ /patients/
      end

      def primary_key_for(table_name, column_name)
        return [column_name] if ignore_table?(table_name) || is_patients?(table_name) || is_sub_partition_table?(table_name)
        return [column_name, :patient_id].uniq
      end

      def fk_columns_for(table_name, column_name)
        return [column_name] if ignore_table?(table_name) || is_patients?(table_name) || is_sub_partition_table?(table_name)
        return [column_name, :patient_id].uniq
      end

      def fk_table_for(table_name, fk_table_name)
        return fk_table_name if ignore_table?(fk_table_name)
        return fk_table_name unless is_sub_partition_table?(table_name) 
        return [fk_table_name, get_suffix(table_name)].join("_").to_sym
      end

      def is_sub_partition_table?(table_name)
        table_name.to_s =~ /_\d{4}$/
      end

      def get_suffix(table_name)
        table_name.to_s.split("_").last
      end

      def sub_partition_tables(table_name)
        return [] if ignore_table?(table_name)
        shard_numbers.map { |n| sprintf("%s_%04d", table_name, n).to_sym }
      end
    end

    class PostgresLoader < Loader
      def create_schema
        schemas.each do |schema|
          db.create_schema(schema, if_not_exists: true)
        end
        db.execute("SET search_path TO #{options[:search_path]}")
      end


      def load_file_set(table_name, headers, files, delimiter = ",")
        db[table_name].truncate(cascade: true)
        files.each do |file|
          logger.info "Loading #{file} into #{table_name}(#{headers.join(", ")})"
          file = File.binread(file) unless file.is_a?(IO)

          opts = {
            columns: headers,
            data: file
          }
          
          opts = opts.merge(format: :csv) if delimiter == ","

          db.copy_into(table_name, opts.merge(postgres_copy_into_options))
        end
      end

      def postgres_copy_into_options
        {}
      end

      def create_table_options(table_name)
        partitioner.create_table_options(table_name)
      end

      def post_create_table(table_name)
        partitioner.post_create_table(table_name)
      end

      def primary_key_for(table_name, column_name)
        partitioner.primary_key_for(table_name, column_name)
      end

      def fk_columns_for(foreign_table, column_name)
        partitioner.fk_columns_for(foreign_table, column_name)
      end

      def is_table_partitioned?(table)
        partitioner.is_table_partitioned?(table)
      end

      def sub_partition_tables(table)
        partitioner.sub_partition_tables(table)
      end

      def fk_table_for(table, fk)
        partitioner.fk_table_for(table, fk)
      end

      def partitioner
        @partitioner ||= Partitioner.new(self)
      end

      def post_create_tables
        return unless options[:citus]
        db.run(%Q|CREATE EXTENSION IF NOT EXISTS "citus"|)
        logger.info db['SELECT master_get_active_worker_nodes()'].all
        data_model.each do |table_name, columns|
          logger.info table_name
          person_id = columns[:person_id]
          next unless person_id
          unless %i(person death).include?(table_name)
            Sequel.extension :migration
            Sequel.migration do
              change do
                alter_table(table_name) do
                  drop_constraint("#{table_name}_pkey", cascade: true) rescue "Failed to remove pkey"
                  add_primary_key(["#{table_name}_id".to_sym, :person_id])
                end
              end
            end.apply(db, :up)
          end
          logger.info db["SELECT create_distributed_table('#{table_name}', 'person_id')"].all
        end
      end
    end
  end
end
