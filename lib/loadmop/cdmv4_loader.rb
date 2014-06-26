require_relative 'loader'

module Loadmop
  class CDMv4Loader < Loader

    attr :options, :data_files_dir

    def initialize(data_files_dir, options = {})
      @data_files_dir = Pathname.new(data_files_dir)
      @options = options
      @schemas_dir = 'schemas/cdmv4'
      set_schema_if_necessary
    end

    private

    def files
      ordered_file_names.map { |name| data_files_dir + name }.select(&:exist?)
    end

    def set_schema_if_necessary
      return unless adapter == 'postgres'
      return unless options[:schema]
      db.create_schema(options[:schema], if_not_exists: true)
      db.execute("SET search_path TO #{options[:schema]}")
    end

    def ordered_tables
      %w(
        person
        visit_occurrence
        condition_occurrence
        procedure_occurrence
        procedure_cost
        observation
        observation_period
        payer_plan_period
        drug_exposure
        drug_cost
        location
        organization
        provider
        care_site
        condition_era
        death
        cohort
      )
    end

    def ordered_file_names
      ordered_tables.map { |f| f + '.csv' }
    end
  end
end
