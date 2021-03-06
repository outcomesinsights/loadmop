require_relative 'loader'

module Loadmop
  module Loaders
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
