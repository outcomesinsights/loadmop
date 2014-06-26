Sequel.migration do
  change do
    create_table(:care_site, :ignore_index_errors=>true) do
      Bignum :care_site_id, :null=>false
      Bignum :location_id, :null=>false
      Bignum :organization_id, :null=>false
      Bignum :place_of_service_concept_id
      String :care_site_source_value, :size=>50
      String :place_of_service_source_value, :size=>50, :null=>false

      primary_key [:care_site_id]
    end

    create_table(:cohort, :ignore_index_errors=>true) do
      Bignum :cohort_id, :null=>false
      Bignum :cohort_concept_id, :null=>false
      Date :cohort_start_date, :null=>false
      Date :cohort_end_date
      Bignum :subject_id, :null=>false
      String :stop_reason, :size=>20

      primary_key [:cohort_id]
    end

    create_table(:location, :ignore_index_errors=>true) do
      Bignum :location_id, :null=>false
      String :address_1, :size=>50
      String :address_2, :size=>50
      String :city, :size=>50
      String :state, :size=>2, :fixed=>true
      String :zip, :size=>9
      String :county, :size=>20
      String :location_source_value, :size=>50

      primary_key [:location_id]
    end

    create_table(:provider, :ignore_index_errors=>true) do
      Bignum :provider_id, :null=>false
      String :npi, :size=>20
      String :dea, :size=>20
      Bignum :specialty_concept_id
      Bignum :care_site_id, :null=>false
      String :provider_source_value, :size=>50, :null=>false
      String :specialty_source_value, :size=>50

      primary_key [:provider_id]
    end

    create_table(:organization, :ignore_index_errors=>true) do
      Bignum :organization_id, :null=>false
      Bignum :place_of_service_concept_id
      foreign_key :location_id, :location, :type=>Bignum, :key=>[:location_id]
      String :organization_source_value, :size=>50, :null=>false
      String :place_of_service_source_value, :size=>50

      primary_key [:organization_id]
    end

    create_table(:person, :ignore_index_errors=>true) do
      Bignum :person_id, :null=>false
      Bignum :gender_concept_id, :null=>false
      Integer :year_of_birth, :null=>false
      Integer :month_of_birth
      Integer :day_of_birth
      Bignum :race_concept_id
      Bignum :ethnicity_concept_id
      foreign_key :location_id, :location, :type=>Bignum, :key=>[:location_id]
      foreign_key :provider_id, :provider, :type=>Bignum, :key=>[:provider_id]
      Bignum :care_site_id
      String :person_source_value, :size=>50
      String :gender_source_value, :size=>50
      String :race_source_value, :size=>50
      String :ethnicity_source_value, :size=>50

      primary_key [:person_id]
    end

    create_table(:condition_era, :ignore_index_errors=>true) do
      Bignum :condition_era_id, :null=>false
      foreign_key :person_id, :person, :type=>Bignum, :null=>false, :key=>[:person_id]
      Bignum :condition_concept_id, :null=>false
      Date :condition_era_start_date, :null=>false
      Date :condition_era_end_date, :null=>false
      Bignum :condition_type_concept_id, :null=>false
      Integer :condition_occurrence_count

      primary_key [:condition_era_id]
    end

    create_table(:condition_occurrence, :ignore_index_errors=>true) do
      Bignum :condition_occurrence_id, :null=>false
      foreign_key :person_id, :person, :type=>Bignum, :null=>false, :key=>[:person_id]
      Bignum :condition_concept_id, :null=>false
      Date :condition_start_date, :null=>false
      Date :condition_end_date
      Bignum :condition_type_concept_id, :null=>false
      String :stop_reason, :size=>20
      Bignum :associated_provider_id
      Bignum :visit_occurrence_id
      String :condition_source_value, :size=>50

      primary_key [:condition_occurrence_id]
    end

    create_table(:death, :ignore_index_errors=>true) do
      foreign_key :person_id, :person, :type=>Bignum, :null=>false, :key=>[:person_id]
      Date :death_date, :null=>false
      Bignum :death_type_concept_id, :null=>false
      Bignum :cause_of_death_concept_id
      String :cause_of_death_source_value, :size=>50

      primary_key [:person_id]
    end

    create_table(:drug_era, :ignore_index_errors=>true) do
      Bignum :drug_era_id, :null=>false
      foreign_key :person_id, :person, :type=>Bignum, :null=>false, :key=>[:person_id]
      Bignum :drug_concept_id, :null=>false
      Date :drug_era_start_date, :null=>false
      Date :drug_era_end_date, :null=>false
      Bignum :drug_type_concept_id, :null=>false
      Integer :drug_exposure_count

      primary_key [:drug_era_id]
    end

    create_table(:drug_exposure, :ignore_index_errors=>true) do
      Bignum :drug_exposure_id, :null=>false
      foreign_key :person_id, :person, :type=>Bignum, :null=>false, :key=>[:person_id]
      Bignum :drug_concept_id, :null=>false
      Date :drug_exposure_start_date, :null=>false
      Date :drug_exposure_end_date
      Bignum :drug_type_concept_id, :null=>false
      String :stop_reason, :size=>20
      Integer :refills
      Integer :quantity
      Integer :days_supply
      String :sig, :size=>500
      Bignum :prescribing_provider_id
      Bignum :visit_occurrence_id
      Bignum :relevant_condition_concept_id
      String :drug_source_value, :size=>50

      primary_key [:drug_exposure_id]
    end

    create_table(:observation, :ignore_index_errors=>true) do
      Bignum :observation_id, :null=>false
      foreign_key :person_id, :person, :type=>Bignum, :null=>false, :key=>[:person_id]
      Bignum :observation_concept_id, :null=>false
      Date :observation_date, :null=>false
      Date :observation_time
      Float :value_as_number
      String :value_as_string, :size=>60
      Bignum :value_as_concept_id
      Bignum :unit_concept_id
      Float :range_low
      Float :range_high
      Bignum :observation_type_concept_id, :null=>false
      Bignum :associated_provider_id
      Bignum :visit_occurrence_id
      Bignum :relevant_condition_concept_id
      String :observation_source_value, :size=>50
      String :units_source_value, :size=>50

      primary_key [:observation_id]
    end

    create_table(:observation_period, :ignore_index_errors=>true) do
      Bignum :observation_period_id, :null=>false
      foreign_key :person_id, :person, :type=>Bignum, :null=>false, :key=>[:person_id]
      Date :observation_period_start_date, :null=>false
      Date :observation_period_end_date, :null=>false
      Date :prev_ds_period_end_date

      primary_key [:observation_period_id]
    end

    create_table(:payer_plan_period, :ignore_index_errors=>true) do
      Bignum :payer_plan_period_id, :null=>false
      foreign_key :person_id, :person, :type=>Bignum, :null=>false, :key=>[:person_id]
      Date :payer_plan_period_start_date, :null=>false
      Date :payer_plan_period_end_date, :null=>false
      String :payer_source_value, :size=>50
      String :plan_source_value, :size=>50
      String :family_source_value, :size=>50
      Date :prev_ds_period_end_date

      primary_key [:payer_plan_period_id]
    end

    create_table(:procedure_occurrence, :ignore_index_errors=>true) do
      Bignum :procedure_occurrence_id, :null=>false
      foreign_key :person_id, :person, :type=>Bignum, :null=>false, :key=>[:person_id]
      Bignum :procedure_concept_id, :null=>false
      Date :procedure_date, :null=>false
      Bignum :procedure_type_concept_id, :null=>false
      Bignum :associated_provider_id
      Bignum :visit_occurrence_id
      Bignum :relevant_condition_concept_id
      String :procedure_source_value, :size=>50

      primary_key [:procedure_occurrence_id]
    end

    create_table(:visit_occurrence, :ignore_index_errors=>true) do
      Bignum :visit_occurrence_id, :null=>false
      foreign_key :person_id, :person, :type=>Bignum, :null=>false, :key=>[:person_id]
      Date :visit_start_date, :null=>false
      Date :visit_end_date, :null=>false
      Bignum :place_of_service_concept_id, :null=>false
      Bignum :care_site_id
      String :place_of_service_source_value, :size=>50

      primary_key [:visit_occurrence_id]
    end

    create_table(:drug_cost, :ignore_index_errors=>true) do
      Bignum :drug_cost_id, :null=>false
      foreign_key :drug_exposure_id, :drug_exposure, :type=>Bignum, :null=>false, :key=>[:drug_exposure_id]
      Float :paid_copay
      Float :paid_coinsurance
      Float :paid_toward_deductible
      Float :paid_by_payer
      Float :paid_by_coordination_benefits
      Float :total_out_of_pocket
      Float :total_paid
      Float :ingredient_cost
      Float :dispensing_fee
      Float :average_wholesale_price
      Bignum :payer_plan_period_id

      primary_key [:drug_cost_id]
    end

    create_table(:procedure_cost, :ignore_index_errors=>true) do
      Bignum :procedure_cost_id, :null=>false
      foreign_key :procedure_occurrence_id, :procedure_occurrence, :type=>Bignum, :null=>false, :key=>[:procedure_occurrence_id]
      Float :paid_copay
      Float :paid_coinsurance
      Float :paid_toward_deductible
      Float :paid_by_payer
      Float :paid_by_coordination_benefits
      Float :total_out_of_pocket
      Float :total_paid
      Bignum :disease_class_concept_id
      Bignum :revenue_code_concept_id
      Bignum :payer_plan_period_id
      String :disease_class_source_value, :size=>50
      String :revenue_code_source_value, :size=>50

      primary_key [:procedure_cost_id]
    end
  end
end
