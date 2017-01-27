require_relative 'loader'

module Loadmop
  module Loaders
    class VocabLoader < Loader

      private

      def files_of_interest
        %w'vocabulary relationship concept concept_ancestor concept_relationship concept_synonym drug_strength source_to_concept_map'.map do |f|
          Pathname.new(data_files_dir + "#{f.upcase}.csv")
        end.select{|f| f.exist?}
      end

      def postgres_copy_into_options
        {options: "DELIMITER e'\\t', QUOTE e'\"'"}
      end

      def ruby_csv_options
        {col_sep: "\t", quote_char: 0o377.chr}
      end

=begin
    def make_all_files
      split_dir = data_files_dir + 'split'
      split_dir.mkdir unless split_dir.exist?
      files = files_of_interest.map do |file|
        table_name = file.basename('.*').to_s.downcase.to_sym
        headers = db.from(table_name).columns
        dir = split_dir + table_name.to_s
        unless dir.exist?
          dir.mkdir
          Dir.chdir(dir) do
            puts "Splitting #{file}"
            #system("tail -n +2 #{file.expand_path}  | sed 's/\015//g' | split -a 5 -l #{lines_per_split}")
            system("tail -n +2 #{file.expand_path} | split -a 5 -l #{lines_per_split}")
          end
        end
        [table_name, headers, dir.children.sort]
      end
    end
=end

      def create_tables
        vocabulary_table = table_name(:vocabulary)
        concept_table = table_name(:concept)
        relationship_table = table_name(:relationship)

        create_schema_if_necessary
        db.create_table?(table_name(:vocabulary)) do
          Bignum :vocabulary_id, :primary_key=>true
          String :vocabulary_name, :null=>false
        end

=begin
      db.create_table?(table_name(:relationship)) do
        Bignum :relationship_id, :primary_key=>true
        String :relationship_name, :null=>false
        String :is_hierarchical, :size=>1, :fixed=>true
        String :defines_ancestry, :size=>1, :fixed=>true
        Bignum :reverse_relationship
      end
=end

        db.create_table?(table_name(:concept)) do
          Bignum :concept_id, :primary_key=>true
          String :concept_name, :null=>false
          BigDecimal :concept_level, :null=>false
          String :concept_class, :null=>false
          Bignum :vocabulary_id, :null=>false
          String :concept_code, :null=>false
          Date :valid_start_date, :null=>false
          Date :valid_end_date, :null=>false
          String :invalid_reason, :size=>1, :fixed=>true
        end

=begin
      db.create_table?(table_name(:concept_ancestor)) do
        Bignum :ancestor_concept_id
        Bignum :descendant_concept_id
        BigDecimal :min_levels_of_separation
        BigDecimal :max_levels_of_separation

        primary_key [:ancestor_concept_id, :descendant_concept_id]
      end

      db.create_table?(table_name(:concept_relationship)) do
        Bignum :concept_id_1
        Bignum :concept_id_2
        Bignum :relationship_id
        Date :valid_start_date, :null=>false
        Date :valid_end_date, :null=>false
        String :invalid_reason, :size=>1, :fixed=>true

        primary_key [:concept_id_1, :concept_id_2, :relationship_id]
      end

      db.create_table?(table_name(:concept_synonym)) do
        Bignum :concept_synonym_id, :primary_key=>true
        Bignum :concept_id, :null=>false
        String :concept_synonym_name, :null=>false
      end

      db.create_table?(table_name(:drug_approval)) do
        Bignum :ingredient_concept_id, :null => false
        Date :approval_date, :null => false
        String :approved_by, :null => false
      end

      db.create_table?(table_name(:drug_strength)) do
        Bignum :drug_concept_id, :null => false
        Bignum :ingredient_concept_id, :null => false
        BigDecimal :amount_value
        String :amount_unit
        BigDecimal :concentration_value
        String :concentration_enum_unit
        String :concentration_denom_unit
        Date :valid_start_date, :null => false
        Date :valid_end_date, :null => false
        String :invalid_reason
      end
=end

        db.create_table?(table_name(:source_to_concept_map)) do
          String :source_code, :null=>false
          Bignum :source_vocabulary_id
          String :source_code_description
          Bignum :target_concept_id
          Bignum :target_vocabulary_id, :null=>false
          String :mapping_type
          String :primary_map, :size=>1, :fixed=>true
          Date :valid_start_date, :null=>false
          Date :valid_end_date, :null=>false
          String :invalid_reason, :size=>1, :fixed=>true

          #primary_key [:source_code, :source_vocabulary_id, :target_concept_id, :valid_end_date]
        end
      end

      def do_index(*args)
        db.add_index(*args)
      rescue
        puts $!.message
        #nothing
      end

      def create_indexes
        do_index :concept, [:concept_code], name: "vocabulary_concept_concept_code_index"
        do_index :concept, [:concept_id], name: "con_conid"
        do_index :concept, [:vocabulary_id], name: "con_vocid"
        do_index :concept_ancestor, [:ancestor_concept_id], name: "conanc_ancconid"
        do_index :concept_ancestor, [:descendant_concept_id], name: "conanc_desconid"
        do_index :concept_relationship, [:relationship_id], name: "conrel_relid"
        do_index :relationship, [:relationship_id], name: "rel_relid"
        do_index :source_to_concept_map, [:source_code, :source_vocabulary_id], name: "soutoconmap_soucod_souvocid"
        do_index :source_to_concept_map, [:source_vocabulary_id], name: "soutoconmap_souvocid"
        do_index :source_to_concept_map, [:target_concept_id], name: "soutoconmap_tarconid"
        do_index :source_to_concept_map, [:target_vocabulary_id], name: "soutoconmap_tarvocid"
      end
    end
  end
end

