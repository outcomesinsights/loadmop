module Loadmop
  module Loaders
    class ImpalaLoader < Loader
      def load_file_set(table_name, headers, files, delimiter = ',')
        types = db.schema(table_name).map{|col,s| [col, s[:db_type]]}
        types = Hash[types]
        types = types.values_at(*headers)
        casted_cols = headers.zip(types).map do |h, t|
          impala_type = case t
                        when 'double'
                          'float'
                        when '', nil
                          'timestamp'
                        else
                          t
                        end
          Sequel.cast(h.to_sym, impala_type).as(h.to_sym)
        end
        create_table_sql = "insert overwrite table `#{table_name}` "
        create_table_sql << db["#{table_name}_import".to_sym].select(*casted_cols).sql
        create_table_sql << ";"
        output << create_table_sql
        next

        db[table_name].delete

        files.each_with_index do |file, index|
          temp_db = new_db(db.opts.merge(:host => "hadoop#{(index % 3) + 2}.jsaw.io"))
          puts "Loading #{file} onto #{temp_db.opts[:host]} into #{table_name}(#{headers.join(", ")})"
          data = CSV.parse(File.binread(file))
          data = data.map do |row|
            row.zip(types).map do |v, t|
              Sequel.cast(v, t == 'double' ? 'float' : t)
            end
          end

          temp_db[table_name].import(headers, data, slice: 1000)
          sleep 2
        end
      end

      def supports_indexes?
        false
      end
    end
  end
end

