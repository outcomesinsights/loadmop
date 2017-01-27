module Loadmop
  class GenericLoader < Loader
    attr :data_model_name
    def initialize(database_name, data_files_dir, options = {})
      @data_model_name = options.delete(:data_model) or raise "You need to specify a data model"
      super(database_name, data_files_dir, options)
    end

    def create_indexes
    end

    def files_of_interest
      dir = Pathname.new(data_files_dir)
      data_model.keys.map { |k| dir + "#{k}.csv"}.select(&:exist?)
    end

    def create_tables
      data_model.dup.each do |table_name, columns|
        db.create_table!(send(table_name)) do
          columns.each do |column_name, column_options|
            next if column_name == :indexes
            type = column_options.delete(:type)
            raise "No type for column #{table_name}.#{column_name}" if type.nil?
            send(type, column_name, column_options)
          end
        end
      end
    end

    def data_model
      @data_model ||= Psych.load_file("schemas/#{data_model_name}.yml")
    end

    def method_missing(symbol, *args)
      if data_model.keys.include?(symbol)
        return table_name(symbol)
      else
        super
      end
    end
  end
end
