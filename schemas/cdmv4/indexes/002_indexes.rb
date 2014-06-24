# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 1) do
  add_index "care_site", ["care_site_id"], name: "carsit_carsitid", using: :btree
  add_index "care_site", ["location_id", "organization_id", "place_of_service_source_value", "care_site_id"], name: "idx_care_site_org_sources", using: :btree
  add_index "care_site", ["location_id", "organization_id", "place_of_service_source_value"], name: "care_site_location_id_organization_id_place_of_service_sour_key", unique: true, using: :btree
  add_index "care_site", ["location_id"], name: "carsit_locid", using: :btree
  add_index "care_site", ["organization_id"], name: "carsit_orgid", using: :btree
  add_index "care_site", ["place_of_service_concept_id"], name: "carsit_plaofserconid", using: :btree
  add_index "cohort", ["cohort_concept_id"], name: "coh_cohconid", using: :btree
  add_index "cohort", ["cohort_id"], name: "coh_cohid", using: :btree
  add_index "cohort", ["subject_id"], name: "coh_subid", using: :btree
  add_index "condition_era", ["condition_concept_id"], name: "conera_conconid", using: :btree
  add_index "condition_era", ["condition_era_id"], name: "conera_coneraid", using: :btree
  add_index "condition_era", ["condition_type_concept_id"], name: "conera_contypconid", using: :btree
  add_index "condition_era", ["person_id"], name: "conera_perid", using: :btree
  add_index "condition_occurrence", ["associated_provider_id"], name: "conocc_assproid", using: :btree
  add_index "condition_occurrence", ["condition_concept_id"], name: "conocc_conconid", using: :btree
  add_index "condition_occurrence", ["condition_occurrence_id"], name: "conocc_conoccid", using: :btree
  add_index "condition_occurrence", ["condition_source_value"], name: "conocc_consouval", using: :btree
  add_index "condition_occurrence", ["condition_type_concept_id"], name: "conocc_contypconid", using: :btree
  add_index "condition_occurrence", ["person_id"], name: "conocc_perid", using: :btree
  add_index "condition_occurrence", ["visit_occurrence_id"], name: "conocc_visoccid", using: :btree
  add_index "death", ["cause_of_death_concept_id"], name: "dea_cauofdeaconid", using: :btree
  add_index "death", ["death_type_concept_id"], name: "dea_deatypconid", using: :btree
  add_index "death", ["person_id"], name: "dea_perid", using: :btree
  add_index "drug_cost", ["drug_cost_id"], name: "drucos_drucosid", using: :btree
  add_index "drug_cost", ["drug_exposure_id"], name: "drucos_druexpid", using: :btree
  add_index "drug_cost", ["payer_plan_period_id"], name: "drucos_payplaperid", using: :btree
  add_index "drug_era", ["drug_concept_id"], name: "druera_druconid", using: :btree
  add_index "drug_era", ["drug_era_id"], name: "druera_drueraid", using: :btree
  add_index "drug_era", ["drug_type_concept_id"], name: "druera_drutypconid", using: :btree
  add_index "drug_era", ["person_id"], name: "druera_perid", using: :btree
  add_index "drug_exposure", ["drug_concept_id"], name: "druexp_druconid", using: :btree
  add_index "drug_exposure", ["drug_exposure_id"], name: "druexp_druexpid", using: :btree
  add_index "drug_exposure", ["drug_type_concept_id"], name: "druexp_drutypconid", using: :btree
  add_index "drug_exposure", ["person_id"], name: "druexp_perid", using: :btree
  add_index "drug_exposure", ["prescribing_provider_id"], name: "druexp_preproid", using: :btree
  add_index "drug_exposure", ["relevant_condition_concept_id"], name: "druexp_relconconid", using: :btree
  add_index "drug_exposure", ["visit_occurrence_id"], name: "druexp_visoccid", using: :btree
  add_index "location", ["location_id"], name: "loc_locid", using: :btree
  add_index "location", ["zip", "county"], name: "location_zip_county_key", unique: true, using: :btree
  add_index "observation", ["associated_provider_id"], name: "obs_assproid", using: :btree
  add_index "observation", ["observation_concept_id"], name: "obs_obsconid", using: :btree
  add_index "observation", ["observation_id"], name: "obs_obsid", using: :btree
  add_index "observation", ["observation_type_concept_id"], name: "obs_obstypconid", using: :btree
  add_index "observation", ["person_id"], name: "obs_perid", using: :btree
  add_index "observation", ["relevant_condition_concept_id"], name: "obs_relconconid", using: :btree
  add_index "observation", ["unit_concept_id"], name: "obs_uniconid", using: :btree
  add_index "observation", ["value_as_concept_id"], name: "obs_valasconid", using: :btree
  add_index "observation", ["visit_occurrence_id"], name: "obs_visoccid", using: :btree
  add_index "observation_period", ["observation_period_id"], name: "obsper_obsperid", using: :btree
  add_index "observation_period", ["person_id", "observation_period_start_date", "observation_period_end_date"], name: "idx_observation_period_lkp", using: :btree
  add_index "observation_period", ["person_id"], name: "obsper_perid", using: :btree
  add_index "organization", ["location_id"], name: "org_locid", using: :btree
  add_index "organization", ["organization_id"], name: "org_orgid", using: :btree
  add_index "organization", ["place_of_service_concept_id"], name: "org_plaofserconid", using: :btree
  add_index "payer_plan_period", ["payer_plan_period_id"], name: "payplaper_payplaperid", using: :btree
  add_index "payer_plan_period", ["person_id", "plan_source_value", "payer_plan_period_start_date", "payer_plan_period_end_date"], name: "idx_payer_plan_period_lkp", using: :btree
  add_index "payer_plan_period", ["person_id"], name: "payplaper_perid", using: :btree
  add_index "person", ["care_site_id"], name: "per_carsitid", using: :btree
  add_index "person", ["ethnicity_concept_id"], name: "per_ethconid", using: :btree
  add_index "person", ["gender_concept_id"], name: "per_genconid", using: :btree
  add_index "person", ["location_id"], name: "per_locid", using: :btree
  add_index "person", ["person_id"], name: "per_perid", using: :btree
  add_index "person", ["provider_id"], name: "per_proid", using: :btree
  add_index "person", ["race_concept_id"], name: "per_racconid", using: :btree
  add_index "procedure_cost", ["disease_class_concept_id"], name: "procos_disclaconid", using: :btree
  add_index "procedure_cost", ["payer_plan_period_id"], name: "procos_payplaperid", using: :btree
  add_index "procedure_cost", ["procedure_cost_id"], name: "procos_procosid", using: :btree
  add_index "procedure_cost", ["procedure_occurrence_id"], name: "procos_prooccid", using: :btree
  add_index "procedure_cost", ["revenue_code_concept_id"], name: "procos_revcodconid", using: :btree
  add_index "procedure_occurrence", ["associated_provider_id"], name: "proocc_assproid", using: :btree
  add_index "procedure_occurrence", ["person_id"], name: "proocc_perid", using: :btree
  add_index "procedure_occurrence", ["procedure_concept_id"], name: "proocc_proconid", using: :btree
  add_index "procedure_occurrence", ["procedure_occurrence_id"], name: "proocc_prooccid", using: :btree
  add_index "procedure_occurrence", ["procedure_source_value"], name: "proocc_prosouval", using: :btree
  add_index "procedure_occurrence", ["procedure_type_concept_id"], name: "proocc_protypconid", using: :btree
  add_index "procedure_occurrence", ["relevant_condition_concept_id"], name: "proocc_relconconid", using: :btree
  add_index "procedure_occurrence", ["visit_occurrence_id"], name: "proocc_visoccid", using: :btree
  add_index "provider", ["care_site_id"], name: "pro_carsitid", using: :btree
  add_index "provider", ["provider_id"], name: "pro_proid", using: :btree
  add_index "provider", ["provider_source_value", "specialty_source_value", "provider_id", "care_site_id"], name: "idx_provider_lkp", using: :btree
  add_index "provider", ["specialty_concept_id"], name: "pro_speconid", using: :btree
  add_index "visit_occurrence", ["person_id"], name: "visocc_perid", using: :btree
  add_index "visit_occurrence", ["place_of_service_concept_id"], name: "visocc_plaofserconid", using: :btree
  add_index "visit_occurrence", ["visit_occurrence_id"], name: "visocc_visoccid", using: :btree
end
