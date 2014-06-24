Sequel.migration do
  change do
    create_table(:concept) do
      Bignum :concept_id, :null=>false
      String :concept_name, :null=>false
      BigDecimal :concept_level, :null=>false
      String :concept_class, :null=>false
      Bignum :vocabulary_id, :null=>false
      String :concept_code, :null=>false
      Date :valid_start_date, :null=>false
      Date :valid_end_date, :null=>false
      String :invalid_reason, :size=>1, :fixed=>true

      primary_key [:concept_id]
    end

    create_table(:concept_ancestor) do
      Bignum :ancestor_concept_id, :null=>false
      Bignum :descendant_concept_id, :null=>false
      BigDecimal :min_levels_of_separation
      BigDecimal :max_levels_of_separation

      primary_key [:ancestor_concept_id, :descendant_concept_id]
    end

    create_table(:concept_relationship) do
      Bignum :concept_id_1, :null=>false
      Bignum :concept_id_2, :null=>false
      Bignum :relationship_id, :null=>false
      Date :valid_start_date, :null=>false
      Date :valid_end_date, :null=>false
      String :invalid_reason, :size=>1, :fixed=>true

      primary_key [:concept_id_1, :concept_id_2, :relationship_id]
    end

    create_table(:concept_synonym) do
      Bignum :concept_synonym_id, :null=>false
      Bignum :concept_id, :null=>false
      String :concept_synonym_name, :null=>false

      primary_key [:concept_synonym_id]
    end

    create_table(:drug_approval) do
      Bignum :ingredient_concept_id, :null => false
      Date :approval_date, :null => false
      String :approved_by, :null => false
    end

    create_table(:drug_strength) do
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

    create_table(:relationship) do
      Bignum :relationship_id, :null=>false
      String :relationship_name, :null=>false
      String :is_hierarchical, :size=>1, :fixed=>true
      String :defines_ancestry, :size=>1, :fixed=>true
      Bignum :reverse_relationship

      primary_key [:relationship_id]
    end

    create_table(:source_to_concept_map) do
      String :source_code, :null=>false
      Bignum :source_vocabulary_id, :null=>false
      String :source_code_description
      Bignum :target_concept_id, :null=>false
      Bignum :target_vocabulary_id, :null=>false
      String :mapping_type
      String :primary_map, :size=>1, :fixed=>true
      Date :valid_start_date, :null=>false
      Date :valid_end_date, :null=>false
      String :invalid_reason, :size=>1, :fixed=>true

      primary_key [:source_code, :source_vocabulary_id, :target_concept_id, :valid_end_date]
    end

    create_table(:vocabulary) do
      Bignum :vocabulary_id, :null=>false
      String :vocabulary_name, :null=>false

      primary_key [:vocabulary_id]
    end
  end
end
