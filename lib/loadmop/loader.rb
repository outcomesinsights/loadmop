require 'pathname'
require 'csv'
require 'sequelizer'

module Loadmop
  class Loader
    include Sequelizer

    attr :schemas_dir

    def create_database
      create_tables
      load_files
      create_indexes
    end

    private
    def create_tables
      Sequel.extension :migration
      Sequel::Migrator.run(db, schemas_dir, target: 1)
    end

    def create_indexes
      Sequel.extension :migration
      Sequel::Migrator.run(db, schemas_dir, target: 2)
    end

    def files
      Pathname.glob(data_files_dir + '*.csv')
    end

    def load_files
      fast_load || slow_load
    end

    def fast_load
      case adapter
      when 'postgres'
        fast_load_postgres
      when 'sqlite'
        fast_load_sqlite
      else
        nil
      end
    end

    def fast_load_postgres
      files.each do |file|
        table_name = file.basename('.*').to_s.downcase.to_sym
        puts "Loading #{file} into #{table_name}"
        headers = headers_for(file).map(&:to_sym)
        db[table_name].truncate(cascade: true)
        db.copy_into(
          table_name,
          format:  :csv,
          columns: headers,
          options: 'header',
          data:    File.read(file)
        )
      end
      true
    end

    def fast_load_sqlite
      return nil if `which sqlite3` =~ /not found/i
      db_file_path = database
      files.each do |file|
        File.open('/tmp/sqlite.load', 'w') do |command_file|
          table_name = file.basename('.*').to_s.downcase
          puts "Loading #{file} into #{table_name}"
          command_file.puts %Q(.echo on)
          command_file.puts %Q(.log stdout)
          command_file.puts %Q(DELETE FROM #{table_name};)
          command_file.puts %Q(.mode csv)
          command_file.puts ".import /dev/stdin #{table_name}"
        end
        command = "tail -n +2 #{file} | sqlite3 #{db_file_path} '.read /tmp/sqlite.load'"
        puts command
        system(command)
      end
      true
    end

    def slow_load
      files.each do |file|
        table_name = file.basename('.*').to_s.downcase.to_sym
        puts "Loading #{file} into #{table_name}"
        CSV.open(file, headers: true) do |csv|
          csv.each_slice(1000) do |rows|
            print '.'
            db[table_name].import(headers_for(file), rows.map(&:fields))
          end
        end
        puts
      end
    end

    def adapter
      db.sequelizer_options.adapter
    end

    def database
      db.sequelizer_options.database
    end

    def headers_for(file)
      header_line = file.readlines.first.downcase
      CSV.parse(header_line).first
    end
  end
end
