require_relative 'loader'

module Loadmop
  module Loaders
    class PostgresLoader < Loader
      def create_schema
        schemas.each do |schema|
          db.execute("CREATE SCHEMA IF NOT EXISTS #{schema}")
        end
        db.execute("SET search_path TO #{options[:search_path]}")
      end

      def load_files
        all_files.each do |table_name, headers, files, delimiter|
          puts "Loading #{table_name}..."
          db[table_name].truncate(cascade: true)
          files.each do |file|
            puts "Loading #{file} into #{table_name}(#{headers.join(", ")})"
            db.copy_into(
              table_name, {
                format:  :csv,
                columns: headers,
                delimiter: delimiter,
                data:    File.binread(file),
              }.merge(postgres_copy_into_options)
            )
          end
          puts " #{db[table_name].count} loaded"
        end
      end

      def postgres_copy_into_options
        {}
      end
    end
  end
end
