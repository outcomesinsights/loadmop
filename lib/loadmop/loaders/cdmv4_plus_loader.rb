require_relative 'loader'

module Loadmop
  class CDMv4PlusLoader < Loader

    private

    def files_of_interest
      ordered_file_names.map { |name| data_files_dir + name }.select(&:exist?)
    end

    def ordered_tables
      %w(
        location
        organization
        care_site
        provider
        person
        death
        observation_period
        payer_plan_period
        visit_occurrence
        condition_occurrence
        drug_exposure
        drug_cost
        procedure_occurrence
        procedure_cost
        observation
        cohort
        condition_era
        drug_era
      )
    end

    def ordered_file_names
      ordered_tables.map { |f| f + '.csv' }
    end

    def create_tables
      create_schema_if_necessary
      location_table = table_name(:location)
      provider_table = table_name(:provider)
      person_table = table_name(:person)
      drug_exposure_table = table_name(:drug_exposure)
      procedure_occurrence_table = table_name(:procedure_occurrence)
      db.create_table?(table_name(:care_site), :ignore_index_errors=>true) do
        Bignum :care_site_id, :primary_key=>true
        Bignum :location_id, :null=>false
        Bignum :organization_id, :null=>false
        Bignum :place_of_service_concept_id
        Bignum :place_of_service_source_vocabulary_id
        String :care_site_source_value, :size=>50
        String :place_of_service_source_value, :size=>50, :null=>false
      end

      db.create_table?(table_name(:cohort), :ignore_index_errors=>true) do
        Bignum :cohort_id, :primary_key=>true
        Bignum :cohort_concept_id, :null=>false
        Date :cohort_start_date, :null=>false
        Date :cohort_end_date
        Bignum :subject_id, :null=>false
        String :stop_reason, :size=>20
      end

      db.create_table?(table_name(:location), :ignore_index_errors=>true) do
        Bignum :location_id, :primary_key=>true
        String :address_1, :size=>50
        String :address_2, :size=>50
        String :city, :size=>50
        String :state, :size=>2, :fixed=>true
        String :zip, :size=>9
        String :county, :size=>20
        String :location_source_value, :size=>50
      end

      db.create_table?(table_name(:provider), :ignore_index_errors=>true) do
        Bignum :provider_id, :primary_key=>true
        String :npi, :size=>20
        String :dea, :size=>20
        Bignum :specialty_concept_id
        Bignum :specialty_source_vocabulary_id
        Bignum :care_site_id
        String :provider_source_value, :size=>50, :null=>false
        String :specialty_source_value, :size=>50
      end

      db.create_table?(table_name(:organization), :ignore_index_errors=>true) do
        Bignum :organization_id, :primary_key=>true
        Bignum :place_of_service_concept_id
        Bignum :place_of_service_source_vocabulary_id
        foreign_key :location_id, location_table, :type=>Bignum
        String :organization_source_value, :size=>50, :null=>false
        String :place_of_service_source_value, :size=>50
      end

      db.create_table?(table_name(:person), :ignore_index_errors=>true) do
        Bignum :person_id, :primary_key=>true
        Bignum :gender_concept_id, :null=>false
        Bignum :gender_source_vocabulary_id
        Integer :year_of_birth, :null=>false
        Integer :month_of_birth
        Integer :day_of_birth
        Bignum :race_concept_id
        Bignum :race_source_vocabulary_id
        Bignum :ethnicity_concept_id
        Bignum :ethnicity_source_vocabulary_id
        foreign_key :location_id, location_table, :type=>Bignum
        foreign_key :provider_id, provider_table, :type=>Bignum
        Bignum :care_site_id
        String :person_source_value, :size=>50
        String :gender_source_value, :size=>50
        String :race_source_value, :size=>50
        String :ethnicity_source_value, :size=>50
      end

      db.create_table?(table_name(:condition_era), :ignore_index_errors=>true) do
        Bignum :condition_era_id, :primary_key=>true
        foreign_key :person_id, person_table, :type=>Bignum, :null=>false
        Bignum :condition_concept_id, :null=>false
        Bignum :condition_source_vocabulary_id
        Date :condition_era_start_date, :null=>false
        Date :condition_era_end_date, :null=>false
        Bignum :condition_type_concept_id, :null=>false
        Integer :condition_occurrence_count
      end

      db.create_table?(table_name(:condition_occurrence), :ignore_index_errors=>true) do
        Bignum :condition_occurrence_id, :primary_key=>true
        foreign_key :person_id, person_table, :type=>Bignum, :null=>false
        Bignum :condition_concept_id, :null=>false
        Bignum :condition_source_vocabulary_id
        Date :condition_start_date, :null=>false
        Date :condition_end_date
        Bignum :condition_type_concept_id, :null=>false
        String :stop_reason, :size=>20
        Bignum :associated_provider_id
        Bignum :visit_occurrence_id
        String :condition_source_value, :size=>50
      end

      db.create_table?(table_name(:death), :ignore_index_errors=>true) do
        foreign_key :person_id, person_table, :type=>Bignum, :primary_key=>true
        Date :death_date, :null=>false
        Bignum :death_type_concept_id, :null=>false
        Bignum :death_type_source_vocabulary_id
        Bignum :cause_of_death_concept_id
        Bignum :cause_of_death_source_vocabulary_id
        String :cause_of_death_source_value, :size=>50
      end

      db.create_table?(table_name(:drug_era), :ignore_index_errors=>true) do
        Bignum :drug_era_id, :primary_key=>true
        foreign_key :person_id, person_table, :type=>Bignum, :null=>false
        Bignum :drug_concept_id, :null=>false
        Bignum :drug_source_vocabulary_id
        Date :drug_era_start_date, :null=>false
        Date :drug_era_end_date, :null=>false
        Bignum :drug_type_concept_id, :null=>false
        Integer :drug_exposure_count
      end

      db.create_table?(table_name(:drug_exposure), :ignore_index_errors=>true) do
        Bignum :drug_exposure_id, :primary_key=>true
        foreign_key :person_id, person_table, :type=>Bignum, :null=>false
        Bignum :drug_concept_id, :null=>false
        Bignum :drug_source_vocabulary_id
        Date :drug_exposure_start_date, :null=>false
        Date :drug_exposure_end_date
        Bignum :drug_type_concept_id
        String :stop_reason, :size=>20
        Integer :refills
        Float :quantity
        Integer :days_supply
        String :sig, :size=>500
        Bignum :prescribing_provider_id
        Bignum :visit_occurrence_id
        Bignum :relevant_condition_concept_id
        String :drug_source_value, :size=>50
      end

      db.create_table?(table_name(:observation), :ignore_index_errors=>true) do
        Bignum :observation_id, :primary_key=>true
        foreign_key :person_id, person_table, :type=>Bignum, :null=>false
        Bignum :observation_concept_id, :null=>false
        Bignum :observation_source_vocabulary_id
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
      end

      db.create_table?(table_name(:observation_period), :ignore_index_errors=>true) do
        Bignum :observation_period_id, :primary_key=>true
        foreign_key :person_id, person_table, :type=>Bignum, :null=>false
        Date :observation_period_start_date, :null=>false
        Date :observation_period_end_date, :null=>false
        Date :prev_ds_period_end_date
      end

      db.create_table?(table_name(:payer_plan_period), :ignore_index_errors=>true) do
        Bignum :payer_plan_period_id, :primary_key=>true
        foreign_key :person_id, person_table, :type=>Bignum, :null=>false
        Date :payer_plan_period_start_date, :null=>false
        Date :payer_plan_period_end_date, :null=>false
        String :payer_source_value, :size=>50
        String :plan_source_value, :size=>50
        String :family_source_value, :size=>50
        Date :prev_ds_period_end_date
      end

      db.create_table?(table_name(:procedure_occurrence), :ignore_index_errors=>true) do
        Bignum :procedure_occurrence_id, :primary_key=>true
        foreign_key :person_id, person_table, :type=>Bignum, :null=>false
        Bignum :procedure_concept_id, :null=>false
        Bignum :procedure_source_vocabulary_id
        Date :procedure_date, :null=>false
        Bignum :procedure_type_concept_id, :null=>false
        Bignum :associated_provider_id
        Bignum :visit_occurrence_id
        Bignum :relevant_condition_concept_id
        String :procedure_source_value, :size=>50
      end

      db.create_table?(table_name(:visit_occurrence), :ignore_index_errors=>true) do
        Bignum :visit_occurrence_id, :primary_key=>true
        foreign_key :person_id, person_table, :type=>Bignum, :null=>false
        Date :visit_start_date, :null=>false
        Date :visit_end_date, :null=>false
        Bignum :place_of_service_concept_id
        Bignum :place_of_service_source_vocabulary_id
        Bignum :care_site_id
        String :place_of_service_source_value, :size=>50
        String :visit_occurrence_type_id, :size=>50
      end

      db.create_table?(table_name(:drug_cost), :ignore_index_errors=>true) do
        Bignum :drug_cost_id, :primary_key=>true
        foreign_key :drug_exposure_id, drug_exposure_table, :type=>Bignum, :null=>false
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
      end

      db.create_table?(table_name(:procedure_cost), :ignore_index_errors=>true) do
        Bignum :procedure_cost_id, :primary_key=>true
        foreign_key :procedure_occurrence_id, procedure_occurrence_table, :type=>Bignum
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
      end
    end

    def create_indexes
      db.alter_table(table_name(:care_site)) do
        add_index [:location_id, :organization_id, :place_of_service_source_value], :name=>:care_site_location_id_organization_id_place_of_service_sour_key, :unique=>true, :ignore_add_index_errors=>true
        add_index [:care_site_id], :name=>:carsit_carsitid, :ignore_add_index_errors=>true
        add_index [:location_id], :name=>:carsit_locid, :ignore_add_index_errors=>true
        add_index [:organization_id], :name=>:carsit_orgid, :ignore_add_index_errors=>true
        add_index [:place_of_service_concept_id], :name=>:carsit_plaofserconid, :ignore_add_index_errors=>true
        add_index [:location_id, :organization_id, :place_of_service_source_value, :care_site_id], :name=>:idx_care_site_org_sources, :ignore_add_index_errors=>true
      end

      db.alter_table(table_name(:cohort)) do
        add_index [:cohort_concept_id], :name=>:coh_cohconid, :ignore_add_index_errors=>true
        add_index [:cohort_id], :name=>:coh_cohid, :ignore_add_index_errors=>true
        add_index [:subject_id], :name=>:coh_subid, :ignore_add_index_errors=>true
      end

      db.alter_table(table_name(:location)) do
        add_index [:location_id], :name=>:loc_locid, :ignore_add_index_errors=>true
        add_index [:zip, :county], :name=>:location_zip_county_key, :unique=>true, :ignore_add_index_errors=>true
      end

      db.alter_table(table_name(:provider)) do
        add_index [:provider_source_value, :specialty_source_value, :provider_id, :care_site_id], :name=>:idx_provider_lkp, :ignore_add_index_errors=>true
        add_index [:care_site_id], :name=>:pro_carsitid, :ignore_add_index_errors=>true
        add_index [:provider_id], :name=>:pro_proid, :ignore_add_index_errors=>true
        add_index [:specialty_concept_id], :name=>:pro_speconid, :ignore_add_index_errors=>true
      end

      db.alter_table(table_name(:organization)) do
        add_index [:location_id], :name=>:org_locid, :ignore_add_index_errors=>true
        add_index [:organization_id], :name=>:org_orgid, :ignore_add_index_errors=>true
        add_index [:place_of_service_concept_id], :name=>:org_plaofserconid, :ignore_add_index_errors=>true
      end

      db.alter_table(table_name(:person)) do
        add_index [:care_site_id], :name=>:per_carsitid, :ignore_add_index_errors=>true
        add_index [:ethnicity_concept_id], :name=>:per_ethconid, :ignore_add_index_errors=>true
        add_index [:gender_concept_id], :name=>:per_genconid, :ignore_add_index_errors=>true
        add_index [:location_id], :name=>:per_locid, :ignore_add_index_errors=>true
        add_index [:person_id], :name=>:per_perid, :ignore_add_index_errors=>true
        add_index [:provider_id], :name=>:per_proid, :ignore_add_index_errors=>true
        add_index [:race_concept_id], :name=>:per_racconid, :ignore_add_index_errors=>true
      end

      db.alter_table(table_name(:condition_era)) do
        add_index [:condition_concept_id], :name=>:conera_conconid, :ignore_add_index_errors=>true
        add_index [:condition_era_id], :name=>:conera_coneraid, :ignore_add_index_errors=>true
        add_index [:condition_type_concept_id], :name=>:conera_contypconid, :ignore_add_index_errors=>true
        add_index [:person_id], :name=>:conera_perid, :ignore_add_index_errors=>true
      end

      db.alter_table(table_name(:condition_occurrence)) do
        add_index [:condition_concept_id], :name=>:cci, :ignore_add_index_errors=>true
        add_index [:condition_source_vocabulary_id, :condition_source_value], :name=>:cci_source_value, :ignore_add_index_errors=>true
        add_index [:associated_provider_id], :name=>:conocc_assproid, :ignore_add_index_errors=>true
        add_index [:condition_occurrence_id], :name=>:conocc_conoccid, :ignore_add_index_errors=>true
        add_index [:condition_source_value], :name=>:conocc_consouval, :ignore_add_index_errors=>true
        add_index [:condition_type_concept_id], :name=>:conocc_contypconid, :ignore_add_index_errors=>true
        add_index [:person_id], :name=>:conocc_perid, :ignore_add_index_errors=>true
        add_index [:visit_occurrence_id], :name=>:conocc_visoccid, :ignore_add_index_errors=>true
        add_index [:visit_occurrence_id], :name=>:voi, :ignore_add_index_errors=>true
      end

      db.alter_table(table_name(:death)) do
        add_index [:cause_of_death_concept_id], :name=>:dea_cauofdeaconid, :ignore_add_index_errors=>true
        add_index [:death_type_concept_id], :name=>:dea_deatypconid, :ignore_add_index_errors=>true
        add_index [:person_id], :name=>:dea_perid, :ignore_add_index_errors=>true
      end

      db.alter_table(table_name(:drug_era)) do
        add_index [:drug_concept_id], :name=>:druera_druconid, :ignore_add_index_errors=>true
        add_index [:drug_era_id], :name=>:druera_drueraid, :ignore_add_index_errors=>true
        add_index [:drug_type_concept_id], :name=>:druera_drutypconid, :ignore_add_index_errors=>true
        add_index [:person_id], :name=>:druera_perid, :ignore_add_index_errors=>true
      end

      db.alter_table(table_name(:drug_exposure)) do
        add_index [:drug_concept_id], :name=>:druexp_druconid, :ignore_add_index_errors=>true
        add_index [:drug_source_vocabulary_id, :drug_source_value], :name=>:druexp_druconid_source_value, :ignore_add_index_errors=>true
        add_index [:drug_exposure_id], :name=>:druexp_druexpid, :ignore_add_index_errors=>true
        add_index [:drug_type_concept_id], :name=>:druexp_drutypconid, :ignore_add_index_errors=>true
        add_index [:person_id], :name=>:druexp_perid, :ignore_add_index_errors=>true
        add_index [:prescribing_provider_id], :name=>:druexp_preproid, :ignore_add_index_errors=>true
        add_index [:relevant_condition_concept_id], :name=>:druexp_relconconid, :ignore_add_index_errors=>true
        add_index [:visit_occurrence_id], :name=>:druexp_visoccid, :ignore_add_index_errors=>true
      end

      db.alter_table(table_name(:observation)) do
        add_index [:associated_provider_id], :name=>:obs_assproid, :ignore_add_index_errors=>true
        add_index [:observation_concept_id], :name=>:obs_obsconid, :ignore_add_index_errors=>true
        add_index [:observation_source_vocabulary_id, :observation_source_value], :name=>:obs_obsconid_source_value, :ignore_add_index_errors=>true
        add_index [:observation_id], :name=>:obs_obsid, :ignore_add_index_errors=>true
        add_index [:observation_type_concept_id], :name=>:obs_obstypconid, :ignore_add_index_errors=>true
        add_index [:person_id], :name=>:obs_perid, :ignore_add_index_errors=>true
        add_index [:relevant_condition_concept_id], :name=>:obs_relconconid, :ignore_add_index_errors=>true
        add_index [:unit_concept_id], :name=>:obs_uniconid, :ignore_add_index_errors=>true
        add_index [:value_as_concept_id], :name=>:obs_valasconid, :ignore_add_index_errors=>true
        add_index [:visit_occurrence_id], :name=>:obs_visoccid, :ignore_add_index_errors=>true
      end

      db.alter_table(table_name(:observation_period)) do
        add_index [:person_id, :observation_period_start_date, :observation_period_end_date], :name=>:idx_observation_period_lkp, :ignore_add_index_errors=>true
        add_index [:observation_period_id], :name=>:obsper_obsperid, :ignore_add_index_errors=>true
        add_index [:person_id], :name=>:obsper_perid, :ignore_add_index_errors=>true
      end

      db.alter_table(table_name(:payer_plan_period)) do
        add_index [:person_id, :plan_source_value, :payer_plan_period_start_date, :payer_plan_period_end_date], :name=>:idx_payer_plan_period_lkp, :ignore_add_index_errors=>true
        add_index [:payer_plan_period_id], :name=>:payplaper_payplaperid, :ignore_add_index_errors=>true
        add_index [:person_id], :name=>:payplaper_perid, :ignore_add_index_errors=>true
      end

      db.alter_table(table_name(:procedure_occurrence)) do
        add_index [:associated_provider_id], :name=>:proocc_assproid, :ignore_add_index_errors=>true
        add_index [:person_id], :name=>:proocc_perid, :ignore_add_index_errors=>true
        add_index [:procedure_concept_id], :name=>:proocc_proconid, :ignore_add_index_errors=>true
        add_index [:procedure_source_vocabulary_id, :procedure_source_value], :name=>:proocc_proconid_source_value, :ignore_add_index_errors=>true
        add_index [:procedure_occurrence_id], :name=>:proocc_prooccid, :ignore_add_index_errors=>true
        add_index [:procedure_source_value], :name=>:proocc_prosouval, :ignore_add_index_errors=>true
        add_index [:procedure_type_concept_id], :name=>:proocc_protypconid, :ignore_add_index_errors=>true
        add_index [:relevant_condition_concept_id], :name=>:proocc_relconconid, :ignore_add_index_errors=>true
        add_index [:visit_occurrence_id], :name=>:proocc_visoccid, :ignore_add_index_errors=>true
      end

      db.alter_table(table_name(:visit_occurrence)) do
        add_index [:person_id, :visit_start_date, :place_of_service_concept_id], :name=>:visit_occurrence_person_id_visit_start_date_place_of_servic_key, :ignore_add_index_errors=>true
        add_index [:care_site_id], :name=>:visocc_carsitid, :ignore_add_index_errors=>true
        add_index [:person_id], :name=>:visocc_perid, :ignore_add_index_errors=>true
        add_index [:place_of_service_concept_id], :name=>:visocc_plaofserconid, :ignore_add_index_errors=>true
        add_index [:place_of_service_source_vocabulary_id, :place_of_service_source_value], :name=>:visocc_plaofserconid_source_value, :ignore_add_index_errors=>true
        add_index [:visit_occurrence_id], :name=>:visocc_visoccid, :ignore_add_index_errors=>true
      end

      db.alter_table(table_name(:drug_cost)) do
        add_index [:drug_cost_id], :name=>:drucos_drucosid, :ignore_add_index_errors=>true
        add_index [:drug_exposure_id], :name=>:drucos_druexpid, :ignore_add_index_errors=>true
        add_index [:payer_plan_period_id], :name=>:drucos_payplaperid, :ignore_add_index_errors=>true
      end

      db.alter_table(table_name(:procedure_cost)) do
        add_index [:disease_class_concept_id], :name=>:procos_disclaconid, :ignore_add_index_errors=>true
        add_index [:payer_plan_period_id], :name=>:procos_payplaperid, :ignore_add_index_errors=>true
        add_index [:procedure_cost_id], :name=>:procos_procosid, :ignore_add_index_errors=>true
        add_index [:procedure_occurrence_id], :name=>:procos_prooccid, :ignore_add_index_errors=>true
        add_index [:revenue_code_concept_id], :name=>:procos_revcodconid, :ignore_add_index_errors=>true
      end
    end
  end
end

