module Loadmop
  class Ancestorizer
    attr_reader :db

    def initialize(db)
      @db = db
    end

=begin
drop table if exists ancestors;
create table ancestors as (
with recursive annies(ancestor_id, descendant_id) as (
  select ancestor_id, descendant_id from (
    select concept_2_id as ancestor_id, concept_2_id as descendant_id
    from mappings
    union
    select concept_1_id as ancestor_id, concept_1_id as descendant_id
    from mappings
  ) first_tab
  union
  select t1.ancestor_id, t2.concept_1_id as descendant_id
  from annies as t1
  join mappings as t2 on t1.ancestor_id = t2.concept_2_id
)
select *
from annies
order by ancestor_id, descendant_id
);

drop view if exists ancestors_view;
create view ancestors_view as (
  select
  c1.id as ancestor_id,
  c1.vocabulary_id as ancestor_vocabulary_id,
  c1.concept_code as ancestor_concept_code,
  c1.concept_text as ancestor_concept_text,
  c2.id as descendant_id,
  c2.vocabulary_id as descendant_vocabulary_id,
  c2.concept_code as descendant_concept_code,
  c2.concept_text as descendant_concept_text
  from ancestors a
  join concepts c1 on (c1.id = a.ancestor_id)
  join concepts c2 on (c2.id = a.descendant_id)
  order by c1.id, c2.id
);

drop view if exists mappings_view;
create view mappings_view as (
  select
  c1.id as c1_id,
  c1.vocabulary_id as c1_vocabulary_id,
  c1.concept_code as c1_concept_code,
  c1.concept_text as c1_concept_text,
  m.relationship_id,
  c2.id as c2_id,
  c2.vocabulary_id as c2_vocabulary_id,
  c2.concept_code as c2_concept_code,
  c2.concept_text as c2_concept_text
  from mappings m
  join concepts c1 on (c1.id = m.concept_1_id)
  join concepts c2 on (c2.id = m.concept_2_id)
  order by c1.id, c2.id
);
=end
    def ancestorize
      make_ancestors
      make_ancestors_view
      make_mappings_view
    end

    def make_ancestors
      first_ds = db[:mappings].select(Sequel[:concept_2_id].as(:ancestor_id), Sequel[:concept_2_id].as(:descendant_id))
      first_ds = first_ds.union(db[:mappings].select(Sequel[:concept_1_id].as(:ancestor_id), Sequel[:concept_1_id].as(:descendant_id)))

      recursive_ds = db[:annies].from_self(alias: :a)
        .join(:mappings, { Sequel[:m][:concept_2_id] => Sequel[:a][:ancestor_id] }, table_alias: :m)
        .select(Sequel[:a][:ancestor_id], Sequel[:m][:concept_1_id].as(:descendant_id))

      create_ds = db[:annies]
        .with_recursive(:annies, first_ds, recursive_ds, args: [:ancestor_id, :descendant_id], union_all: false)
        .order(:ancestor_id, :descendant_id)

      db.drop_table(:ancestors, cascade: true, if_exists: true)
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
