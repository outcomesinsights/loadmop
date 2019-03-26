module Loadmop
  class TestSchemaZapper
    attr_reader :db, :options

    def initialize(db, opts = {})
      @db = db
      @options = opts
    end

    def zap
      db[Sequel[:information_schema][:schemata]]
        .where(Sequel.ilike(:schema_name, "%_test_%"))
        .tap { |o| p o.sql}.select_order_map(:schema_name).each do |schema_name|
        puts "Dropping #{schema_name}..."
        db.drop_schema(schema_name, if_exists: true, cascade: true)
      end

      puts "Recreating jigsaw_temp schema..."
      db.drop_schema(:jigsaw_temp, if_exists: true, cascade: true)
      db.create_schema(:jigsaw_temp)
    end
  end
end
