module Loadmop
  class QuickIndexer
    attr_reader :db, :options
    def initialize(db, options = {})
      @db = db
      @options = options
    end

    def index_it
      return
      db.tables.map do |table|
        db[table].columns.select { |col| col.to_s.end_with?("_id") }.each do |column|
          puts "Indexing #{table}.#{column}..."
          db.add_index(table, [column], if_not_exists: true)
        end
      end
    end
  end
end
