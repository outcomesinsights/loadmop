module Loadmop
  module Loaders
    class SqliteLoader < Loader
      def load_file_set(table_name, headers, files, delimiter = ",")
        run_sqlite_commands(%Q(DELETE FROM #{table_name};))
        commands = []
        commands << %Q(.echo on)
        commands << %Q(.log stdout)
        commands << %Q(.mode csv)
        commands << "placeholder"
        files.each do |file|
          puts "Loading #{file} into #{table_name}"
          commands.pop
          commands << ".import #{file} #{table_name}"
          run_sqlite_commands(commands)
        end
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

