Sequel.migration do
  change do
    alter_table(:care_site) do
      add_index [:location_id, :organization_id, :place_of_service_source_value], :name=>:care_site_location_id_organization_id_place_of_service_sour_key, :unique=>true, :ignore_add_index_errors=>true
      add_index [:care_site_id], :name=>:carsit_carsitid, :ignore_add_index_errors=>true
      add_index [:location_id], :name=>:carsit_locid, :ignore_add_index_errors=>true
      add_index [:organization_id], :name=>:carsit_orgid, :ignore_add_index_errors=>true
      add_index [:place_of_service_concept_id], :name=>:carsit_plaofserconid, :ignore_add_index_errors=>true
      add_index [:location_id, :organization_id, :place_of_service_source_value, :care_site_id], :name=>:idx_care_site_org_sources, :ignore_add_index_errors=>true
    end

    alter_table(:cohort) do
      add_index [:cohort_concept_id], :name=>:coh_cohconid, :ignore_add_index_errors=>true
      add_index [:cohort_id], :name=>:coh_cohid, :ignore_add_index_errors=>true
      add_index [:subject_id], :name=>:coh_subid, :ignore_add_index_errors=>true
    end

    alter_table(:location) do
      add_index [:location_id], :name=>:loc_locid, :ignore_add_index_errors=>true
      add_index [:zip, :county], :name=>:location_zip_county_key, :unique=>true, :ignore_add_index_errors=>true
    end

    alter_table(:provider) do
      add_index [:provider_source_value, :specialty_source_value, :provider_id, :care_site_id], :name=>:idx_provider_lkp, :ignore_add_index_errors=>true
      add_index [:care_site_id], :name=>:pro_carsitid, :ignore_add_index_errors=>true
      add_index [:provider_id], :name=>:pro_proid, :ignore_add_index_errors=>true
      add_index [:specialty_concept_id], :name=>:pro_speconid, :ignore_add_index_errors=>true
    end

    alter_table(:organization) do
      add_index [:location_id], :name=>:org_locid, :ignore_add_index_errors=>true
      add_index [:organization_id], :name=>:org_orgid, :ignore_add_index_errors=>true
      add_index [:place_of_service_concept_id], :name=>:org_plaofserconid, :ignore_add_index_errors=>true
    end

    alter_table(:person) do
      add_index [:care_site_id], :name=>:per_carsitid, :ignore_add_index_errors=>true
      add_index [:ethnicity_concept_id], :name=>:per_ethconid, :ignore_add_index_errors=>true
      add_index [:gender_concept_id], :name=>:per_genconid, :ignore_add_index_errors=>true
      add_index [:location_id], :name=>:per_locid, :ignore_add_index_errors=>true
      add_index [:person_id], :name=>:per_perid, :ignore_add_index_errors=>true
      add_index [:provider_id], :name=>:per_proid, :ignore_add_index_errors=>true
      add_index [:race_concept_id], :name=>:per_racconid, :ignore_add_index_errors=>true
    end

    alter_table(:condition_era) do
      add_index [:condition_concept_id], :name=>:conera_conconid, :ignore_add_index_errors=>true
      add_index [:condition_era_id], :name=>:conera_coneraid, :ignore_add_index_errors=>true
      add_index [:condition_type_concept_id], :name=>:conera_contypconid, :ignore_add_index_errors=>true
      add_index [:person_id], :name=>:conera_perid, :ignore_add_index_errors=>true
    end

    alter_table(:condition_occurrence) do
      add_index [:condition_concept_id], :name=>:cci, :ignore_add_index_errors=>true
      add_index [:associated_provider_id], :name=>:conocc_assproid, :ignore_add_index_errors=>true
      add_index [:condition_concept_id], :name=>:conocc_conconid, :ignore_add_index_errors=>true
      add_index [:condition_occurrence_id], :name=>:conocc_conoccid, :ignore_add_index_errors=>true
      add_index [:condition_source_value], :name=>:conocc_consouval, :ignore_add_index_errors=>true
      add_index [:condition_type_concept_id], :name=>:conocc_contypconid, :ignore_add_index_errors=>true
      add_index [:person_id], :name=>:conocc_perid, :ignore_add_index_errors=>true
      add_index [:visit_occurrence_id], :name=>:conocc_visoccid, :ignore_add_index_errors=>true
      add_index [:visit_occurrence_id], :name=>:voi, :ignore_add_index_errors=>true
    end

    alter_table(:death) do
      add_index [:cause_of_death_concept_id], :name=>:dea_cauofdeaconid, :ignore_add_index_errors=>true
      add_index [:death_type_concept_id], :name=>:dea_deatypconid, :ignore_add_index_errors=>true
      add_index [:person_id], :name=>:dea_perid, :ignore_add_index_errors=>true
    end

    alter_table(:drug_era) do
      add_index [:drug_concept_id], :name=>:druera_druconid, :ignore_add_index_errors=>true
      add_index [:drug_era_id], :name=>:druera_drueraid, :ignore_add_index_errors=>true
      add_index [:drug_type_concept_id], :name=>:druera_drutypconid, :ignore_add_index_errors=>true
      add_index [:person_id], :name=>:druera_perid, :ignore_add_index_errors=>true
    end

    alter_table(:drug_exposure) do
      add_index [:drug_concept_id], :name=>:druexp_druconid, :ignore_add_index_errors=>true
      add_index [:drug_exposure_id], :name=>:druexp_druexpid, :ignore_add_index_errors=>true
      add_index [:drug_type_concept_id], :name=>:druexp_drutypconid, :ignore_add_index_errors=>true
      add_index [:person_id], :name=>:druexp_perid, :ignore_add_index_errors=>true
      add_index [:prescribing_provider_id], :name=>:druexp_preproid, :ignore_add_index_errors=>true
      add_index [:relevant_condition_concept_id], :name=>:druexp_relconconid, :ignore_add_index_errors=>true
      add_index [:visit_occurrence_id], :name=>:druexp_visoccid, :ignore_add_index_errors=>true
    end

    alter_table(:observation) do
      add_index [:associated_provider_id], :name=>:obs_assproid, :ignore_add_index_errors=>true
      add_index [:observation_concept_id], :name=>:obs_obsconid, :ignore_add_index_errors=>true
      add_index [:observation_id], :name=>:obs_obsid, :ignore_add_index_errors=>true
      add_index [:observation_type_concept_id], :name=>:obs_obstypconid, :ignore_add_index_errors=>true
      add_index [:person_id], :name=>:obs_perid, :ignore_add_index_errors=>true
      add_index [:relevant_condition_concept_id], :name=>:obs_relconconid, :ignore_add_index_errors=>true
      add_index [:unit_concept_id], :name=>:obs_uniconid, :ignore_add_index_errors=>true
      add_index [:value_as_concept_id], :name=>:obs_valasconid, :ignore_add_index_errors=>true
      add_index [:visit_occurrence_id], :name=>:obs_visoccid, :ignore_add_index_errors=>true
    end

    alter_table(:observation_period) do
      add_index [:person_id, :observation_period_start_date, :observation_period_end_date], :name=>:idx_observation_period_lkp, :ignore_add_index_errors=>true
      add_index [:observation_period_id], :name=>:obsper_obsperid, :ignore_add_index_errors=>true
      add_index [:person_id], :name=>:obsper_perid, :ignore_add_index_errors=>true
    end

    alter_table(:payer_plan_period) do
      add_index [:person_id, :plan_source_value, :payer_plan_period_start_date, :payer_plan_period_end_date], :name=>:idx_payer_plan_period_lkp, :ignore_add_index_errors=>true
      add_index [:payer_plan_period_id], :name=>:payplaper_payplaperid, :ignore_add_index_errors=>true
      add_index [:person_id], :name=>:payplaper_perid, :ignore_add_index_errors=>true
    end

    alter_table(:procedure_occurrence) do
      add_index [:associated_provider_id], :name=>:proocc_assproid, :ignore_add_index_errors=>true
      add_index [:person_id], :name=>:proocc_perid, :ignore_add_index_errors=>true
      add_index [:procedure_concept_id], :name=>:proocc_proconid, :ignore_add_index_errors=>true
      add_index [:procedure_occurrence_id], :name=>:proocc_prooccid, :ignore_add_index_errors=>true
      add_index [:procedure_source_value], :name=>:proocc_prosouval, :ignore_add_index_errors=>true
      add_index [:procedure_type_concept_id], :name=>:proocc_protypconid, :ignore_add_index_errors=>true
      add_index [:relevant_condition_concept_id], :name=>:proocc_relconconid, :ignore_add_index_errors=>true
      add_index [:visit_occurrence_id], :name=>:proocc_visoccid, :ignore_add_index_errors=>true
    end

    alter_table(:visit_occurrence) do
      add_index [:person_id, :visit_start_date, :place_of_service_concept_id], :name=>:visit_occurrence_person_id_visit_start_date_place_of_servic_key, :ignore_add_index_errors=>true
      add_index [:care_site_id], :name=>:visocc_carsitid, :ignore_add_index_errors=>true
      add_index [:person_id], :name=>:visocc_perid, :ignore_add_index_errors=>true
      add_index [:place_of_service_concept_id], :name=>:visocc_plaofserconid, :ignore_add_index_errors=>true
      add_index [:visit_occurrence_id], :name=>:visocc_visoccid, :ignore_add_index_errors=>true
    end

    alter_table(:drug_cost) do
      add_index [:drug_cost_id], :name=>:drucos_drucosid, :ignore_add_index_errors=>true
      add_index [:drug_exposure_id], :name=>:drucos_druexpid, :ignore_add_index_errors=>true
      add_index [:payer_plan_period_id], :name=>:drucos_payplaperid, :ignore_add_index_errors=>true
    end

    alter_table(:procedure_cost) do
      add_index [:disease_class_concept_id], :name=>:procos_disclaconid, :ignore_add_index_errors=>true
      add_index [:payer_plan_period_id], :name=>:procos_payplaperid, :ignore_add_index_errors=>true
      add_index [:procedure_cost_id], :name=>:procos_procosid, :ignore_add_index_errors=>true
      add_index [:procedure_occurrence_id], :name=>:procos_prooccid, :ignore_add_index_errors=>true
      add_index [:revenue_code_concept_id], :name=>:procos_revcodconid, :ignore_add_index_errors=>true
    end
  end
end
