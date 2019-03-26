Sequel.migration do
  change do
    create_table(:attribute_definition) do
      Integer :attribute_definition_id, :null=>false
      String :attribute_name, :size=>255, :null=>false
      String :attribute_description, :text=>true
      Integer :attribute_type_concept_id, :null=>false
      String :attribute_syntax, :text=>true
    end
    
    create_table(:care_site) do
      Integer :care_site_id, :null=>false
      String :care_site_name, :size=>255
      Integer :place_of_service_concept_id
      Integer :location_id
      String :care_site_source_value, :size=>50
      String :place_of_service_source_value, :size=>50
    end
    
    create_table(:cdm_source) do
      String :cdm_source_name, :size=>255, :null=>false
      String :cdm_source_abbreviation, :size=>25
      String :cdm_holder, :size=>255
      String :source_description, :text=>true
      String :source_documentation_reference, :size=>255
      String :cdm_etl_reference, :size=>255
      Date :source_release_date
      Date :cdm_release_date
      String :cdm_version, :size=>10
      String :vocabulary_version, :size=>20
    end
    
    create_table(:cohort) do
      Integer :cohort_definition_id, :null=>false
      Integer :subject_id, :null=>false
      Date :cohort_start_date, :null=>false
      Date :cohort_end_date, :null=>false
    end
    
    create_table(:cohort_attribute) do
      Integer :cohort_definition_id, :null=>false
      Date :cohort_start_date, :null=>false
      Date :cohort_end_date, :null=>false
      Integer :subject_id, :null=>false
      Integer :attribute_definition_id, :null=>false
      BigDecimal :value_as_number
      Integer :value_as_concept_id
    end
    
    create_table(:cohort_definition) do
      Integer :cohort_definition_id, :null=>false
      String :cohort_definition_name, :size=>255, :null=>false
      String :cohort_definition_description, :text=>true
      Integer :definition_type_concept_id, :null=>false
      String :cohort_definition_syntax, :text=>true
      Integer :subject_concept_id, :null=>false
      Date :cohort_initiation_date
    end
    
    create_table(:concept) do
      Integer :concept_id, :null=>false
      String :concept_name, :size=>255, :null=>false
      String :domain_id, :size=>20, :null=>false
      String :vocabulary_id, :size=>20, :null=>false
      String :concept_class_id, :size=>20, :null=>false
      String :standard_concept, :size=>1
      String :concept_code, :size=>50, :null=>false
      Date :valid_start_date, :null=>false
      Date :valid_end_date, :null=>false
      String :invalid_reason, :size=>1
    end
    
    create_table(:concept_ancestor) do
      Integer :ancestor_concept_id, :null=>false
      Integer :descendant_concept_id, :null=>false
      Integer :min_levels_of_separation, :null=>false
      Integer :max_levels_of_separation, :null=>false
    end
    
    create_table(:concept_class) do
      String :concept_class_id, :size=>20, :null=>false
      String :concept_class_name, :size=>255, :null=>false
      Integer :concept_class_concept_id, :null=>false
    end
    
    create_table(:concept_relationship) do
      Integer :concept_id_1, :null=>false
      Integer :concept_id_2, :null=>false
      String :relationship_id, :size=>20, :null=>false
      Date :valid_start_date, :null=>false
      Date :valid_end_date, :null=>false
      String :invalid_reason, :size=>1
    end
    
    create_table(:concept_synonym) do
      Integer :concept_id, :null=>false
      String :concept_synonym_name, :size=>1000, :null=>false
      Integer :language_concept_id, :null=>false
    end
    
    create_table(:condition_era) do
      Integer :condition_era_id, :null=>false
      Integer :person_id, :null=>false
      Integer :condition_concept_id, :null=>false
      Date :condition_era_start_date, :null=>false
      Date :condition_era_end_date, :null=>false
      Integer :condition_occurrence_count
    end
    
    create_table(:condition_occurrence) do
      Integer :condition_occurrence_id, :null=>false
      Integer :person_id, :null=>false
      Integer :condition_concept_id, :null=>false
      Date :condition_start_date, :null=>false
      DateTime :condition_start_datetime, :null=>false
      Date :condition_end_date
      DateTime :condition_end_datetime
      Integer :condition_type_concept_id, :null=>false
      String :stop_reason, :size=>20
      Integer :provider_id
      Integer :visit_occurrence_id
      String :condition_source_value, :size=>50
      Integer :condition_source_concept_id
      String :condition_status_source_value, :size=>50
      Integer :condition_status_concept_id
    end
    
    create_table(:cost) do
      Integer :cost_id, :null=>false
      Integer :cost_event_id, :null=>false
      String :cost_domain_id, :size=>20, :null=>false
      Integer :cost_type_concept_id, :null=>false
      Integer :currency_concept_id
      BigDecimal :total_charge
      BigDecimal :total_cost
      BigDecimal :total_paid
      BigDecimal :paid_by_payer
      BigDecimal :paid_by_patient
      BigDecimal :paid_patient_copay
      BigDecimal :paid_patient_coinsurance
      BigDecimal :paid_patient_deductible
      BigDecimal :paid_by_primary
      BigDecimal :paid_ingredient_cost
      BigDecimal :paid_dispensing_fee
      Integer :payer_plan_period_id
      BigDecimal :amount_allowed
      Integer :revenue_code_concept_id
      String :reveue_code_source_value, :size=>50
      Integer :drg_concept_id
      String :drg_source_value, :size=>3
    end
    
    create_table(:death) do
      Integer :person_id, :null=>false
      Date :death_date, :null=>false
      DateTime :death_datetime
      Integer :death_type_concept_id, :null=>false
      Integer :cause_concept_id
      String :cause_source_value, :size=>50
      Integer :cause_source_concept_id
    end
    
    create_table(:device_exposure) do
      Integer :device_exposure_id, :null=>false
      Integer :person_id, :null=>false
      Integer :device_concept_id, :null=>false
      Date :device_exposure_start_date, :null=>false
      DateTime :device_exposure_start_datetime, :null=>false
      Date :device_exposure_end_date
      DateTime :device_exposure_end_datetime
      Integer :device_type_concept_id, :null=>false
      String :unique_device_id, :size=>50
      Integer :quantity
      Integer :provider_id
      Integer :visit_occurrence_id
      String :device_source_value, :size=>100
      Integer :device_source_concept_id
    end
    
    create_table(:domain) do
      String :domain_id, :size=>20, :null=>false
      String :domain_name, :size=>255, :null=>false
      Integer :domain_concept_id, :null=>false
    end
    
    create_table(:dose_era) do
      Integer :dose_era_id, :null=>false
      Integer :person_id, :null=>false
      Integer :drug_concept_id, :null=>false
      Integer :unit_concept_id, :null=>false
      BigDecimal :dose_value, :null=>false
      Date :dose_era_start_date, :null=>false
      Date :dose_era_end_date, :null=>false
    end
    
    create_table(:drug_era) do
      Integer :drug_era_id, :null=>false
      Integer :person_id, :null=>false
      Integer :drug_concept_id, :null=>false
      Date :drug_era_start_date, :null=>false
      Date :drug_era_end_date, :null=>false
      Integer :drug_exposure_count
      Integer :gap_days
    end
    
    create_table(:drug_exposure) do
      Integer :drug_exposure_id, :null=>false
      Integer :person_id, :null=>false
      Integer :drug_concept_id, :null=>false
      Date :drug_exposure_start_date, :null=>false
      DateTime :drug_exposure_start_datetime, :null=>false
      Date :drug_exposure_end_date, :null=>false
      DateTime :drug_exposure_end_datetime
      Date :verbatim_end_date
      Integer :drug_type_concept_id, :null=>false
      String :stop_reason, :size=>20
      Integer :refills
      BigDecimal :quantity
      Integer :days_supply
      String :sig, :text=>true
      Integer :route_concept_id
      String :lot_number, :size=>50
      Integer :provider_id
      Integer :visit_occurrence_id
      String :drug_source_value, :size=>50
      Integer :drug_source_concept_id
      String :route_source_value, :size=>50
      String :dose_unit_source_value, :size=>50
    end
    
    create_table(:drug_strength) do
      Integer :drug_concept_id, :null=>false
      Integer :ingredient_concept_id, :null=>false
      BigDecimal :amount_value
      Integer :amount_unit_concept_id
      BigDecimal :numerator_value
      Integer :numerator_unit_concept_id
      BigDecimal :denominator_value
      Integer :denominator_unit_concept_id
      Integer :box_size
      Date :valid_start_date, :null=>false
      Date :valid_end_date, :null=>false
      String :invalid_reason, :size=>1
    end
    
    create_table(:fact_relationship) do
      Integer :domain_concept_id_1, :null=>false
      Integer :fact_id_1, :null=>false
      Integer :domain_concept_id_2, :null=>false
      Integer :fact_id_2, :null=>false
      Integer :relationship_concept_id, :null=>false
    end
    
    create_table(:location) do
      Integer :location_id, :null=>false
      String :address_1, :size=>50
      String :address_2, :size=>50
      String :city, :size=>50
      String :state, :size=>2
      String :zip, :size=>9
      String :county, :size=>20
      String :location_source_value, :size=>50
    end
    
    create_table(:measurement) do
      Integer :measurement_id, :null=>false
      Integer :person_id, :null=>false
      Integer :measurement_concept_id, :null=>false
      Date :measurement_date, :null=>false
      DateTime :measurement_datetime
      Integer :measurement_type_concept_id, :null=>false
      Integer :operator_concept_id
      BigDecimal :value_as_number
      Integer :value_as_concept_id
      Integer :unit_concept_id
      BigDecimal :range_low
      BigDecimal :range_high
      Integer :provider_id
      Integer :visit_occurrence_id
      String :measurement_source_value, :size=>50
      Integer :measurement_source_concept_id
      String :unit_source_value, :size=>50
      String :value_source_value, :size=>50
    end
    
    create_table(:note) do
      Integer :note_id, :null=>false
      Integer :person_id, :null=>false
      Date :note_date, :null=>false
      DateTime :note_datetime
      Integer :note_type_concept_id, :null=>false
      Integer :note_class_concept_id, :null=>false
      String :note_title, :size=>250
      String :note_text, :text=>true, :null=>false
      Integer :encoding_concept_id, :null=>false
      Integer :language_concept_id, :null=>false
      Integer :provider_id
      Integer :visit_occurrence_id
      String :note_source_value, :size=>50
    end
    
    create_table(:note_nlp) do
      Bignum :note_nlp_id, :null=>false
      Integer :note_id, :null=>false
      Integer :section_concept_id
      String :snippet, :size=>250
      String :offset, :size=>250
      String :lexical_variant, :size=>250, :null=>false
      Integer :note_nlp_concept_id
      Integer :note_nlp_source_concept_id
      String :nlp_system, :size=>250
      Date :nlp_date, :null=>false
      DateTime :nlp_datetime
      String :term_exists, :size=>1
      String :term_temporal, :size=>50
      String :term_modifiers, :size=>2000
    end
    
    create_table(:observation) do
      Integer :observation_id, :null=>false
      Integer :person_id, :null=>false
      Integer :observation_concept_id, :null=>false
      Date :observation_date, :null=>false
      DateTime :observation_datetime
      Integer :observation_type_concept_id, :null=>false
      BigDecimal :value_as_number
      String :value_as_string, :size=>60
      Integer :value_as_concept_id
      Integer :qualifier_concept_id
      Integer :unit_concept_id
      Integer :provider_id
      Integer :visit_occurrence_id
      String :observation_source_value, :size=>50
      Integer :observation_source_concept_id
      String :unit_source_value, :size=>50
      String :qualifier_source_value, :size=>50
    end
    
    create_table(:observation_period) do
      Integer :observation_period_id, :null=>false
      Integer :person_id, :null=>false
      Date :observation_period_start_date, :null=>false
      Date :observation_period_end_date, :null=>false
      Integer :period_type_concept_id, :null=>false
    end
    
    create_table(:payer_plan_period) do
      Integer :payer_plan_period_id, :null=>false
      Integer :person_id, :null=>false
      Date :payer_plan_period_start_date, :null=>false
      Date :payer_plan_period_end_date, :null=>false
      String :payer_source_value, :size=>50
      String :plan_source_value, :size=>50
      String :family_source_value, :size=>50
    end
    
    create_table(:person) do
      Integer :person_id, :null=>false
      Integer :gender_concept_id, :null=>false
      Integer :year_of_birth, :null=>false
      Integer :month_of_birth
      Integer :day_of_birth
      DateTime :birth_datetime
      Integer :race_concept_id, :null=>false
      Integer :ethnicity_concept_id, :null=>false
      Integer :location_id
      Integer :provider_id
      Integer :care_site_id
      String :person_source_value, :size=>50
      String :gender_source_value, :size=>50
      Integer :gender_source_concept_id
      String :race_source_value, :size=>50
      Integer :race_source_concept_id
      String :ethnicity_source_value, :size=>50
      Integer :ethnicity_source_concept_id
    end
    
    create_table(:procedure_occurrence) do
      Integer :procedure_occurrence_id, :null=>false
      Integer :person_id, :null=>false
      Integer :procedure_concept_id, :null=>false
      Date :procedure_date, :null=>false
      DateTime :procedure_datetime, :null=>false
      Integer :procedure_type_concept_id, :null=>false
      Integer :modifier_concept_id
      Integer :quantity
      Integer :provider_id
      Integer :visit_occurrence_id
      String :procedure_source_value, :size=>50
      Integer :procedure_source_concept_id
      String :qualifier_source_value, :size=>50
    end
    
    create_table(:provider) do
      Integer :provider_id, :null=>false
      String :provider_name, :size=>255
      String :npi, :size=>20
      String :dea, :size=>20
      Integer :specialty_concept_id
      Integer :care_site_id
      Integer :year_of_birth
      Integer :gender_concept_id
      String :provider_source_value, :size=>50
      String :specialty_source_value, :size=>50
      Integer :specialty_source_concept_id
      String :gender_source_value, :size=>50
      Integer :gender_source_concept_id
    end
    
    create_table(:relationship) do
      String :relationship_id, :size=>20, :null=>false
      String :relationship_name, :size=>255, :null=>false
      String :is_hierarchical, :size=>1, :null=>false
      String :defines_ancestry, :size=>1, :null=>false
      String :reverse_relationship_id, :size=>20, :null=>false
      Integer :relationship_concept_id, :null=>false
    end
    
    create_table(:source_to_concept_map) do
      String :source_code, :size=>50, :null=>false
      Integer :source_concept_id, :null=>false
      String :source_vocabulary_id, :size=>20, :null=>false
      String :source_code_description, :size=>255
      Integer :target_concept_id, :null=>false
      String :target_vocabulary_id, :size=>20, :null=>false
      Date :valid_start_date, :null=>false
      Date :valid_end_date, :null=>false
      String :invalid_reason, :size=>1
    end
    
    create_table(:specimen) do
      Integer :specimen_id, :null=>false
      Integer :person_id, :null=>false
      Integer :specimen_concept_id, :null=>false
      Integer :specimen_type_concept_id, :null=>false
      Date :specimen_date, :null=>false
      DateTime :specimen_datetime
      BigDecimal :quantity
      Integer :unit_concept_id
      Integer :anatomic_site_concept_id
      Integer :disease_status_concept_id
      String :specimen_source_id, :size=>50
      String :specimen_source_value, :size=>50
      String :unit_source_value, :size=>50
      String :anatomic_site_source_value, :size=>50
      String :disease_status_source_value, :size=>50
    end
    
    create_table(:visit_occurrence) do
      Integer :visit_occurrence_id, :null=>false
      Integer :person_id, :null=>false
      Integer :visit_concept_id, :null=>false
      Date :visit_start_date, :null=>false
      DateTime :visit_start_datetime
      Date :visit_end_date, :null=>false
      DateTime :visit_end_datetime
      Integer :visit_type_concept_id, :null=>false
      Integer :provider_id
      Integer :care_site_id
      String :visit_source_value, :size=>50
      Integer :visit_source_concept_id
      Integer :admitting_source_concept_id
      String :admitting_source_value, :size=>50
      Integer :discharge_to_concept_id
      String :discharge_to_source_value, :size=>50
      Integer :preceding_visit_occurrence_id
    end
    
    create_table(:vocabulary) do
      String :vocabulary_id, :size=>20, :null=>false
      String :vocabulary_name, :size=>255, :null=>false
      String :vocabulary_reference, :size=>255
      String :vocabulary_version, :size=>255
      Integer :vocabulary_concept_id, :null=>false
    end
  end
end
