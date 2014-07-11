require 'pathname'
require 'csv'
require 'sequelizer'

module Loadmop
  class Loader
    include Sequelizer

    attr :options, :data_files_dir, :headers

    def initialize(data_files_dir, options = {})
      @data_files_dir = Pathname.new(data_files_dir)
      @options = options
      @headers = {}
    end

    def create_database
      create_tables
      load_files
      create_indexes
    end

    private
    def create_tables
      Sequel.extension :migration
      Sequel::Migrator.run(db, base_dir + schemas_dir, target: 1)
    end

    def create_indexes
      Sequel.extension :migration
      Sequel::Migrator.run(db, base_dir + schemas_dir, target: 2)
    end

    def all_files
      @all_files ||= make_all_files
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
      all_files.each do |table_name, files|
        db[table_name].truncate(cascade: true)
        files.each do |file|
          puts "Loading #{file} into #{table_name}"
          db.copy_into(
            table_name,
            format:  :csv,
            columns: headers[table_name],
            data:    File.read(file)
          )
        end
      end
      true
    end

    def fast_load_sqlite
      return nil if `which sqlite3` =~ /not found/i
      all_files.each do |table_name, files|
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
      true
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

    def slow_load
      all_files.each do |table_name, files|
        files.each do |file|
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
    end

    def adapter
      db.sequelizer_options.adapter
    end

    def database
      db.sequelizer_options.database
    end

    def headers_for(file)
      header_line = File.open(file, &:readline).downcase.gsub(/\|$/, '')
      CSV.parse(header_line).first.map(&:to_sym)
    end

    def files_of_interest
      Pathname.glob(data_files_dir + '*.csv')
    end

    def lines_per_split
      100000
    end

    def additional_cleaning_steps
      []
    end

    def make_all_files
      split_dir = data_files_dir + 'split'
      split_dir.mkdir unless split_dir.exist?
      files = files_of_interest.map do |file|
        table_name = file.basename('.*').to_s.downcase.to_sym
        headers[table_name] = headers_for(file)
        dir = split_dir + table_name.to_s
        unless dir.exist?
          dir.mkdir
          Dir.chdir(dir) do
            puts "Splitting #{file}"
            steps = []
            steps << "tail -n +2 #{file.expand_path}"
            steps += additional_cleaning_steps
            steps << "split -a 5 -l #{lines_per_split}"
            system(steps.compact.join(" | "))
          end
        end
        [table_name, dir.children.sort]
      end

      Hash[files]
    end

    # When installed as a gem, we need to find where the gem is installed
    # and look for files relative to that path.  base_dir returns the
    # path to the loadmop gem
    def base_dir
      Pathname.new(__FILE__).dirname + '../..'
    end
  end
end
