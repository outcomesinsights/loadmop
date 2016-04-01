require 'pathname'
require 'csv'
require 'sequelizer'

module Loadmop
  class Loader
    include Sequelizer

    attr :options, :data_files_dir

    def initialize(database_name, data_files_dir, options = {})
      @data_files_dir = Pathname.new(data_files_dir).expand_path
      @options = options
      db(options.merge(database: database_name))
    end

    def create_database
      create_tables
      load_files
      create_indexes
    end

    private
    def create_tables
      raise NotImplementedError
    end

    def create_indexes
      raise NotImplementedError
    end

    def all_files
      @all_files ||= make_all_files
    end

    def load_files
      fast_load || slow_load
    end

    def fast_load
      case adapter
      when :postgres
        fast_load_postgres
      when :sqlite
        fast_load_sqlite
      else
        nil
      end
    end

    def postgres_copy_into_options
      {}
    end

    def fast_load_postgres
      all_files.each do |table_name, headers, files|
        db[table_name].truncate(cascade: true)
        files.each do |file|
          puts "Loading #{file} into #{table_name}(#{headers.join(", ")})"
          db.copy_into(
            table_name,
            {
              format:  :csv,
              columns: headers,
              data:    File.binread(file),
            }.merge(postgres_copy_into_options)
          )
        end
        puts " #{db[table_name].count} loaded"
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

    def ruby_csv_options
      {}
    end

    def slow_load
      all_files.each do |table, columns, files|
        files.each do |file|
          puts "Loading #{file} into #{table}"
          CSV.open(file, "rb", ruby_csv_options) do |csv|
            csv.each_slice(1000) do |rows|
              print '.'
              db[table_name(table)].import(columns, rows)
            end
          end
          puts
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
      CSV.parse(header_line).first.map(&:to_sym)
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
      files_of_interest.map do |file|
        table_name = file.basename('.*').to_s.downcase.to_sym
        headers = headers_for(file)
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
        [table_name, headers, dir.children.sort]
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
      if db.database_type == :mssql
        schemas.each do |schema|
          schema = schema.to_s.upcase

          create_if_not_exists = <<-EOF
          IF NOT EXISTS (
          SELECT  name
          FROM    sys.schemas
          WHERE   name = '#{schema}' )

          BEGIN
          EXEC sp_executesql N'CREATE SCHEMA #{schema}'
          END
          EOF

          db.execute(create_if_not_exists)
        end
      elsif db.database_type == :postgres
        schemas.each do |schema|
          db.execute("CREATE SCHEMA IF NOT EXISTS #{schema}")
        end
        db.execute("SET search_path TO #{options[:search_path]}")
      end
    end
  end
end
