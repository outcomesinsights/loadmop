module Loadmop
  class Ancestorizer
    attr_reader :db

    def initialize(db)
      @db = db.tap do |d|
        db.logger = Loadmop.logger
        Loadmop.logger.debug(db.opts.pretty_inspect)
      end
    end

    def ancestorize
      make_ancestors
      make_ancestors_view
      make_mappings_view
    end

    def make_ancestors
      first_ds = db[:mappings].select(Sequel[:concept_2_id].as(Sequel[:ancestor_id]), Sequel[:concept_2_id].as(Sequel[:descendant_id]))
      first_ds = first_ds.union(db[:mappings].select(Sequel[:concept_1_id].as(Sequel[:ancestor_id]), Sequel[:concept_1_id].as(Sequel[:descendant_id])))

      recursive_ds = db[Sequel[:annies].as(:a)]
        .join(:mappings, { Sequel[:m][:concept_2_id] => Sequel[:a][:ancestor_id] }, table_alias: :m)
        .select(Sequel[:a][:ancestor_id], Sequel[:m][:concept_1_id].as(Sequel[:descendant_id]))

      create_ds = db[:annies]
        .with_recursive(:annies, first_ds, recursive_ds, union_all: false)
        .order(:ancestor_id, :descendant_id)
        .select(:ancestor_id, :descendant_id)

      opts = {
        if_exists: true
      }

      Loadmop.logger.debug create_ds.all
      opts[:cascade] = true unless db.database_type == :sqlite
      db.drop_table(:ancestors, opts)
      db.create_table!(:ancestors, as: create_ds)
      db.add_index(:ancestors, [:ancestor_id], ignore_errors: true)
    end

    def make_ancestors_view
      c1 = Sequel[:c1]
      c2 = Sequel[:c2]
      a = Sequel[:ancestors]
      cols = %i(id vocabulary_id concept_code concept_text)

      c1_cols = cols.map do |col|
        c1[col].as("ancestor_#{col}".to_sym)
      end

      c2_cols = cols.map do |col|
        c2[col].as("descendant_#{col}".to_sym)
      end

      view_ds = db[:ancestors]
        .join(:concepts, { c1[:id] => a[:ancestor_id] }, table_alias: :c1)
        .join(:concepts, { c2[:id] => a[:descendant_id] }, table_alias: :c2)
        .order(c1[:id], c2[:id])
        .select(*c1_cols, *c2_cols)

      db.drop_view(:ancestors_view, if_exists: true)
      db.create_view(:ancestors_view, view_ds)
    end

    def make_mappings_view
      c1 = Sequel[:c1]
      c2 = Sequel[:c2]
      m = Sequel[:mappings]
      cols = %i(id vocabulary_id concept_code concept_text)

      c1_cols = cols.map do |col|
        c1[col].as("c1_#{col}".to_sym)
      end

      c2_cols = cols.map do |col|
        c2[col].as("c2_#{col}".to_sym)
      end

      view_ds = db[:mappings]
        .join(:concepts, { c1[:id] => m[:concept_1_id] }, table_alias: :c1)
        .join(:concepts, { c2[:id] => m[:concept_2_id] }, table_alias: :c2)
        .order(c1[:id], c2[:id])
        .select(*c1_cols, *c2_cols)

      db.drop_view(:mappings_view, if_exists: true)
      db.create_view(:mappings_view, view_ds)
    end
  end
end
