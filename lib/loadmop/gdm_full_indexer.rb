module Loadmop
  class GdmFullIndexer
    attr_reader :db, :options
    def initialize(db, options = {})
      @db = db
      @options = options
    end

    def index_it
      idents = (<<END).split("\n").map(&:split)
admission_details patient_id admission_date discharge_date admit_source_concept_id discharge_location_concept_id admission_type_concept_id
clinical_codes collection_id patient_id start_date end_date quantity seq_num provenance_concept_id clinical_code_source_value clinical_code_concept_id clinical_code_vocabulary_id measurement_detail_id drug_exposure_detail_id context_id
collections patient_id start_date end_date duration duration_unit_concept_id facility_id admission_detail_id collection_type_concept_id
concepts vocabulary_id concept_code
contexts collection_id patient_id start_date end_date facility_id care_site_type_concept_id pos_concept_id source_type_concept_id service_specialty_type_concept_id record_type_concept_id
contexts_practitioners context_id practitioner_id role_type_concept_id specialty_type_concept_id
costs context_id patient_id clinical_code_id currency_concept_id value value_type_concept_id
deaths patient_id date cause_concept_id cause_type_concept_id practitioner_id
drug_exposure_details patient_id refills days_supply number_per_day dose_form_concept_id dose_unit_concept_id route_concept_id dose_value strength_source_value ingredient_source_value drug_name_source_value
facilities facility_name facility_type_concept_id specialty_concept_id address_id
information_periods patient_id start_date end_date information_type_concept_id
mappings concept_1_id relationship_id concept_2_id
measurement_details patient_id result_as_number result_as_concept_id result_modifier_concept_id unit_concept_id normal_range_low normal_range_high normal_range_low_modifier_concept_id normal_range_high_modifier_concept_id
patient_details patient_id patient_detail_concept_id patient_detail_source_value patient_detail_vocabulary_id
patients gender_concept_id birth_date race_concept_id ethnicity_concept_id address_id practitioner_id patient_id_source_value
payer_reimbursements context_id patient_id clinical_code_id currency_concept_id
practitioners practitioner_name specialty_concept_id address_id birth_date gender_concept_id
vocabularies omopv4_vocabulary_id
END

      db.transaction do
        idents.each do |t, *cols|

          t = t.to_sym
          cols = cols.map(&:to_sym)
          known_cols = db[t].columns & cols
          unknown_cols = cols - known_cols
          puts "Skipping #{t}.#{unknown_cols}" unless unknown_cols.empty?

          known_cols.each do |c|
            puts "Indexing #{t}.#{c}..."
            begin
              db.add_index(t, c.to_sym)
            rescue
              puts "Error adding #{t}.#{c}"
              puts $!.message
            end
          end
        end
        db.add_index(:concepts, [:vocabulary_id, :concept_code])
      end
    end
  end
end
