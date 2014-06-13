Sequel.migration do
  change do
    create_table(:care_site) do
      BigDecimal :care_site_id, :size=>[38], :null=>false
      BigDecimal :location_id, :size=>[38], :null=>false
      BigDecimal :organization_id, :size=>[38], :null=>false
      BigDecimal :place_of_service_concept_id, :size=>[38]
      String :care_site_source_value
      String :place_of_service_source_value, :null=>false
      BigDecimal :dataset_id, :size=>[4]
      
      primary_key [:care_site_id]
    end
    
    create_table(:cohort) do
      BigDecimal :cohort_id, :size=>[38], :null=>false
      BigDecimal :cohort_concept_id, :size=>[38], :null=>false
      Date :cohort_start_date, :null=>false
      Date :cohort_end_date
      BigDecimal :subject_id, :size=>[38], :null=>false
      String :stop_reason
      BigDecimal :dataset_id, :size=>[4]
      
      primary_key [:cohort_id]
    end
    
    create_table(:condition_era) do
      BigDecimal :condition_era_id, :size=>[38], :null=>false
      BigDecimal :person_id, :size=>[38], :null=>false
      BigDecimal :condition_concept_id, :size=>[38], :null=>false
      Date :condition_era_start_date, :null=>false
      Date :condition_era_end_date, :null=>false
      BigDecimal :condition_type_concept_id, :size=>[38], :null=>false
      BigDecimal :condition_occurrence_count, :size=>[4]
      BigDecimal :dataset_id, :size=>[4]
      
      primary_key [:condition_era_id]
    end
    
    create_table(:condition_occurrence) do
      BigDecimal :condition_occurrence_id, :size=>[38], :null=>false
      BigDecimal :person_id, :size=>[38], :null=>false
      BigDecimal :condition_concept_id, :size=>[38], :null=>false
      Date :condition_start_date, :null=>false
      Date :condition_end_date
      BigDecimal :condition_type_concept_id, :size=>[38], :null=>false
      String :stop_reason
      BigDecimal :associated_provider_id, :size=>[38]
      BigDecimal :visit_occurrence_id, :size=>[38]
      String :condition_source_value
      BigDecimal :dataset_id, :size=>[4]
      
      primary_key [:condition_occurrence_id]
    end
    
    create_table(:death) do
      BigDecimal :person_id, :size=>[38], :null=>false
      Date :death_date, :null=>false
      BigDecimal :death_type_concept_id, :size=>[38], :null=>false
      BigDecimal :cause_of_death_concept_id, :size=>[38]
      String :cause_of_death_source_value
      BigDecimal :dataset_id, :size=>[4]
      
      primary_key [:person_id]
    end
    
    create_table(:drug_cost) do
      BigDecimal :drug_cost_id, :size=>[38], :null=>false
      BigDecimal :drug_exposure_id, :size=>[38], :null=>false
      BigDecimal :paid_copay, :size=>[8, 2]
      BigDecimal :paid_coinsurance, :size=>[8, 2]
      BigDecimal :paid_toward_deductible, :size=>[8, 2]
      BigDecimal :paid_by_payer, :size=>[8, 2]
      BigDecimal :paid_by_coordination_benefits, :size=>[8, 2]
      BigDecimal :total_out_of_pocket, :size=>[8, 2]
      BigDecimal :total_paid, :size=>[8, 2]
      BigDecimal :ingredient_cost, :size=>[8, 2]
      BigDecimal :dispensing_fee, :size=>[8, 2]
      BigDecimal :average_wholesale_price, :size=>[8, 2]
      BigDecimal :payer_plan_period_id, :size=>[38]
      BigDecimal :dataset_id, :size=>[4]
      
      primary_key [:drug_cost_id]
    end
    
    create_table(:drug_era) do
      BigDecimal :drug_era_id, :size=>[38], :null=>false
      BigDecimal :person_id, :size=>[38], :null=>false
      BigDecimal :drug_concept_id, :size=>[38], :null=>false
      Date :drug_era_start_date, :null=>false
      Date :drug_era_end_date, :null=>false
      BigDecimal :drug_type_concept_id, :size=>[38], :null=>false
      BigDecimal :drug_exposure_count, :size=>[4]
      BigDecimal :dataset_id, :size=>[4]
      
      primary_key [:drug_era_id]
    end
    
    create_table(:drug_exposure) do
      BigDecimal :drug_exposure_id, :size=>[38], :null=>false
      BigDecimal :person_id, :size=>[38], :null=>false
      BigDecimal :drug_concept_id, :size=>[38], :null=>false
      Date :drug_exposure_start_date, :null=>false
      Date :drug_exposure_end_date
      BigDecimal :drug_type_concept_id, :size=>[38], :null=>false
      String :stop_reason
      BigDecimal :refills, :size=>[3]
      BigDecimal :quantity, :size=>[4]
      BigDecimal :days_supply, :size=>[4]
      String :sig
      BigDecimal :prescribing_provider_id, :size=>[38]
      BigDecimal :visit_occurrence_id, :size=>[38]
      BigDecimal :relevant_condition_concept_id, :size=>[38]
      String :drug_source_value
      BigDecimal :dataset_id, :size=>[4]
      
      primary_key [:drug_exposure_id]
    end
    
    create_table(:etl_batch) do
      BigDecimal :batch_id, :size=>[5], :null=>false
      BigDecimal :process_id, :size=>[5], :null=>false
      String :status, :null=>false
      BigDecimal :range_id, :size=>[5]
      
      primary_key [:batch_id, :process_id]
    end
    
    create_table(:etl_batch_list) do
      BigDecimal :batch_id, :size=>[5], :null=>false
      BigDecimal :batch_no, :size=>[5], :null=>false
      BigDecimal :dataset_id, :size=>[4], :null=>false
      
      primary_key [:batch_id]
    end
    
    create_table(:etl_care_site_lkp) do
      BigDecimal :care_site_id, :size=>[38], :null=>false
      BigDecimal :location_id, :size=>[38], :null=>false
      BigDecimal :place_of_service_source_value, :size=>[2], :null=>false
      BigDecimal :provider_source_value, :size=>[9], :null=>false
      
      primary_key [:location_id, :place_of_service_source_value, :provider_source_value]
    end
    
    create_table(:etl_care_site_lookup) do
      BigDecimal :care_site_id, :size=>[38], :null=>false
      BigDecimal :location_id, :size=>[38], :null=>false
      BigDecimal :place_of_service_source_value, :size=>[2], :null=>false
      BigDecimal :provider_source_value, :size=>[9], :null=>false
      BigDecimal :specialty_source_value, :size=>[3], :null=>false
      
      primary_key [:location_id, :place_of_service_source_value, :provider_source_value, :specialty_source_value]
    end
    
    create_table(:etl_dataset) do
      BigDecimal :dataset_id, :size=>[4], :null=>false
      Date :start_date, :null=>false
      Date :end_date, :null=>false
      
      primary_key [:dataset_id]
    end
    
    create_table(:etl_person_batch) do
      BigDecimal :person_id, :null=>false
      BigDecimal :batch_id, :size=>[5], :null=>false
      BigDecimal :dataset_id, :size=>[4], :null=>false
      
      primary_key [:person_id, :dataset_id]
    end
    
    create_table(:etl_process) do
      BigDecimal :process_id, :size=>[5], :null=>false
      String :process_name, :null=>false
      String :call_name, :null=>false
      BigDecimal :batches_in_range, :size=>[5], :null=>false
      
      primary_key [:process_id]
    end
    
    create_table(:etl_provider_lookup) do
      BigDecimal :provider_id, :size=>[38], :null=>false
      BigDecimal :location_id, :size=>[38], :null=>false
      BigDecimal :place_of_service_source_value, :size=>[2], :null=>false
      BigDecimal :provider_source_value, :size=>[9], :null=>false
      BigDecimal :specialty_source_value, :size=>[3], :null=>false
      
      primary_key [:location_id, :place_of_service_source_value, :provider_source_value, :specialty_source_value]
    end
    
    create_table(:etl_range) do
      BigDecimal :range_id, :size=>[5], :null=>false
      BigDecimal :run_id, :size=>[5], :null=>false
      BigDecimal :range_num, :size=>[5], :null=>false
      BigDecimal :start_batch, :size=>[5], :null=>false
      BigDecimal :end_batch, :size=>[5], :null=>false
      DateTime :start_time
      DateTime :end_time
      String :error_message
      BigDecimal :records
      
      primary_key [:range_id]
    end
    
    create_table(:etl_run) do
      BigDecimal :run_id, :size=>[5], :null=>false
      BigDecimal :process_id, :size=>[5], :null=>false
      BigDecimal :is_manual_range, :size=>[1], :null=>false
      DateTime :run_time, :null=>false
      BigDecimal :retry_failed, :size=>[1]
      BigDecimal :dataset_id, :size=>[4], :null=>false
      
      primary_key [:run_id]
    end
    
    create_table(:etl_vocab_cache) do
      String :source_code, :null=>false
      BigDecimal :target_concept_id, :size=>[8], :null=>false
      
      primary_key [:source_code]
    end
    
    create_table(:etl_vocab_cache_byvoc) do
      String :source_code, :null=>false
      BigDecimal :source_vocabulary_id, :size=>[38], :null=>false
      BigDecimal :target_concept_id, :size=>[8], :null=>false
      
      primary_key [:source_code, :source_vocabulary_id]
    end
    
    create_table(:location) do
      BigDecimal :location_id, :size=>[38], :null=>false
      String :address_1
      String :address_2
      String :city
      String :state, :size=>2, :fixed=>true
      String :zip
      String :county
      String :location_source_value
      BigDecimal :dataset_id, :size=>[4]
      
      primary_key [:location_id]
    end
    
    create_table(:observation) do
      BigDecimal :observation_id, :size=>[38], :null=>false
      BigDecimal :person_id, :size=>[38], :null=>false
      BigDecimal :observation_concept_id, :size=>[38], :null=>false
      Date :observation_date, :null=>false
      Date :observation_time
      BigDecimal :value_as_number, :size=>[14, 3]
      String :value_as_string
      BigDecimal :value_as_concept_id, :size=>[38]
      BigDecimal :unit_concept_id, :size=>[38]
      BigDecimal :range_low, :size=>[14, 3]
      BigDecimal :range_high, :size=>[14, 3]
      BigDecimal :observation_type_concept_id, :size=>[38], :null=>false
      BigDecimal :associated_provider_id, :size=>[38]
      BigDecimal :visit_occurrence_id, :size=>[38]
      BigDecimal :relevant_condition_concept_id, :size=>[38]
      String :observation_source_value
      String :units_source_value
      BigDecimal :dataset_id, :size=>[4]
      
      primary_key [:observation_id]
    end
    
    create_table(:observation_period) do
      BigDecimal :observation_period_id, :size=>[38], :null=>false
      BigDecimal :person_id, :size=>[38], :null=>false
      Date :observation_period_start_date, :null=>false
      Date :observation_period_end_date, :null=>false
      BigDecimal :dataset_id, :size=>[4]
      Date :prev_ds_period_end_date
      
      primary_key [:observation_period_id]
    end
    
    create_table(:observation_period_hist) do
      BigDecimal :observation_period_id, :size=>[38], :null=>false
      BigDecimal :dataset_id, :size=>[4], :null=>false
      Date :prev_ds_period_end_date
      
      primary_key [:observation_period_id, :dataset_id]
    end
    
    create_table(:omop_etl_gen_map) do
      BigDecimal :gen_ancestor_concept_id, :size=>[38]
      BigDecimal :gen_person_id, :size=>[38], :null=>false
      Date :gen_start_date, :null=>false
      Date :gen_end_date
      BigDecimal :gen_descendant_concept_id, :size=>[38], :null=>false
    end
    
    create_table(:organization) do
      BigDecimal :organization_id, :size=>[38], :null=>false
      BigDecimal :place_of_service_concept_id, :size=>[38]
      BigDecimal :location_id, :size=>[38]
      String :organization_source_value, :null=>false
      String :place_of_service_source_value
      BigDecimal :dataset_id, :size=>[4]
      
      primary_key [:organization_id]
    end
    
    create_table(:payer_plan_period) do
      BigDecimal :payer_plan_period_id, :size=>[38], :null=>false
      BigDecimal :person_id, :size=>[38], :null=>false
      Date :payer_plan_period_start_date, :null=>false
      Date :payer_plan_period_end_date, :null=>false
      String :payer_source_value
      String :plan_source_value
      String :family_source_value
      BigDecimal :dataset_id, :size=>[4]
      Date :prev_ds_period_end_date
      
      primary_key [:payer_plan_period_id]
    end
    
    create_table(:payer_plan_period_hist) do
      BigDecimal :payer_plan_period_id, :size=>[38], :null=>false
      BigDecimal :dataset_id, :size=>[4], :null=>false
      Date :prev_ds_period_end_date
      
      primary_key [:payer_plan_period_id, :dataset_id]
    end
    
    create_table(:person) do
      BigDecimal :person_id, :size=>[38], :null=>false
      BigDecimal :gender_concept_id, :size=>[38], :null=>false
      BigDecimal :year_of_birth, :size=>[4], :null=>false
      BigDecimal :month_of_birth, :size=>[2]
      BigDecimal :day_of_birth, :size=>[2]
      BigDecimal :race_concept_id, :size=>[38]
      BigDecimal :ethnicity_concept_id, :size=>[38]
      BigDecimal :location_id, :size=>[38]
      BigDecimal :provider_id, :size=>[38]
      BigDecimal :care_site_id, :size=>[38]
      String :person_source_value
      String :gender_source_value
      String :race_source_value
      String :ethnicity_source_value
      BigDecimal :dataset_id, :size=>[4], :null=>false
      
      primary_key [:person_id]
    end
    
    create_table(:procedure_cost) do
      BigDecimal :procedure_cost_id, :size=>[38], :null=>false
      BigDecimal :procedure_occurrence_id, :size=>[38], :null=>false
      BigDecimal :paid_copay, :size=>[8, 2]
      BigDecimal :paid_coinsurance, :size=>[8, 2]
      BigDecimal :paid_toward_deductible, :size=>[8, 2]
      BigDecimal :paid_by_payer, :size=>[8, 2]
      BigDecimal :paid_by_coordination_benefits, :size=>[8, 2]
      BigDecimal :total_out_of_pocket, :size=>[8, 2]
      BigDecimal :total_paid, :size=>[8, 2]
      BigDecimal :disease_class_concept_id, :size=>[38]
      BigDecimal :revenue_code_concept_id, :size=>[38]
      BigDecimal :payer_plan_period_id, :size=>[38]
      String :disease_class_source_value
      String :revenue_code_source_value
      BigDecimal :dataset_id, :size=>[4]
      
      primary_key [:procedure_cost_id]
    end
    
    create_table(:procedure_occurrence) do
      BigDecimal :procedure_occurrence_id, :size=>[38], :null=>false
      BigDecimal :person_id, :size=>[38], :null=>false
      BigDecimal :procedure_concept_id, :size=>[38], :null=>false
      Date :procedure_date, :null=>false
      BigDecimal :procedure_type_concept_id, :size=>[38], :null=>false
      BigDecimal :associated_provider_id, :size=>[38]
      BigDecimal :visit_occurrence_id, :size=>[38]
      BigDecimal :relevant_condition_concept_id, :size=>[38]
      String :procedure_source_value
      BigDecimal :dataset_id, :size=>[4]
      
      primary_key [:procedure_occurrence_id]
    end
    
    create_table(:provider) do
      BigDecimal :provider_id, :size=>[38], :null=>false
      String :npi
      String :dea
      BigDecimal :specialty_concept_id, :size=>[38]
      BigDecimal :care_site_id, :size=>[38], :null=>false
      String :provider_source_value, :null=>false
      String :specialty_source_value
      BigDecimal :dataset_id, :size=>[4]
      
      primary_key [:provider_id]
    end
    
    create_table(:tmp_provider_2007) do
      BigDecimal :provider_id, :size=>[38], :null=>false
      String :npi
      String :dea
      BigDecimal :specialty_concept_id, :size=>[38]
      BigDecimal :care_site_id, :size=>[38], :null=>false
      String :provider_source_value, :null=>false
      String :specialty_source_value
      BigDecimal :dataset_id, :size=>[4]
    end
    
    create_table(:truven_source_to_concept_map) do
      String :source_code, :null=>false
      BigDecimal :source_vocabulary_id, :size=>[38], :null=>false
      String :source_code_description
      BigDecimal :target_concept_id, :size=>[38], :null=>false
      BigDecimal :target_vocabulary_id, :size=>[38], :null=>false
      String :mapping_type
      String :primary_map, :size=>1, :fixed=>true
      Date :valid_start_date
      Date :valid_end_date, :null=>false
      String :invalid_reason, :size=>1, :fixed=>true
      
      primary_key [:source_code, :source_vocabulary_id, :target_vocabulary_id]
    end
    
    create_table(:visit_occurrence) do
      BigDecimal :visit_occurrence_id, :size=>[38], :null=>false
      BigDecimal :person_id, :size=>[38], :null=>false
      Date :visit_start_date, :null=>false
      Date :visit_end_date, :null=>false
      BigDecimal :place_of_service_concept_id, :size=>[38], :null=>false
      BigDecimal :care_site_id, :size=>[38]
      String :place_of_service_source_value
      BigDecimal :dataset_id, :size=>[4]
      
      primary_key [:visit_occurrence_id]
    end
  end
end
