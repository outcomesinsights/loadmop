
Sequel.migration do
  change do
    puts "Adding indexes"
    def do_index(*args)
      puts args.inspect
      add_index(*args)
    rescue
      puts $!.message
      #nothing
    end
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
