module Loadmop
  module Loaders
    class SqliteLoader < Loader
      def load_file_set(table_name, headers, files, delimiter = ",")
        run_sqlite_commands(%Q(DELETE FROM #{table_name};))
        commands = []
        commands << %Q(.echo on)
        commands << %Q(.log stdout)
        commands << %Q(.mode csv)
        commands << ".separator #{delimiter.inspect}"
        commands << "placeholder"
        files.each do |file|
          puts "Loading #{file} into #{table_name}"
          commands.pop
          commands << ".import #{file} #{table_name}"
        end
        run_sqlite_commands(commands)
      end

      def perform_load_post_processing
        db.tables.each do |table|
          nullable_columns = db.schema(table).select do |name, column_info|
            column_info[:allow_null]
          end.map(&:first)
          nullable_columns.each do |col|
            db[table].where(col => "").update(col => nil)
          end
        end
      end

      def drop_table_opts
        {}
      end

      def index_allowed?(columns)
        !columns.any? { |c| c.is_a?(Array) }
      end

      def run_sqlite_commands(*commands)
        db_file_path = database
        File.open('/tmp/sqlite.load', 'w') do |command_file|
          command_file.puts commands.flatten.join("\n")
        end
        command = "sqlite3 #{db_file_path} '.read /tmp/sqlite.load'"
        puts command
        system(command)
      end
    end
  end
end

