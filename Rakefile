require "bundler/gem_tasks"
require "loadmop"
require "pathname"
require "psych"
require "shellb"
require "tmpdir"

def get_pg_url(args)
  args.url || ENV["PG_URL"] || "postgres://ryan:r@pg/lexicon"
end

def check_env(*keys)
  keys = keys.reject { |key| ENV.keys.include?(key) }
  raise("Missing ENV vars: #{keys.join(", ")}") unless keys.empty?
end

CURRENT_BRANCH = ENV["TRAVIS_BRANCH"] || "chisel"

LEXICON_PG_URL = ENV["LEXICON_PG_URL"] || "postgres://ryan:r@lexicon/lexicon"

VOCAB_TABLES = %w(ancestors concepts mappings vocabularies)
LEXICON_TAG = "outcomesinsights/lexicon:#{CURRENT_BRANCH}.latest"

namespace :loadmop do
  %w[bundle curl docker git mv pigz psql tar touch].each do |cmd|
    ShellB.def_system_command(cmd)
  end

  ShellB.alias_command("dc", "docker-compose")
  ShellB.alias_command("dump_it", "pg_dump", *%w[--clean --quote-all-identifiers --no-owner --no-privileges --if-exists])

  schemas_dir = Pathname.new("schemas")
  temp_dir = Pathname.new("/tmp")
  dropbox_deployment_dir = temp_dir + "dropbox_deployment"
  vocabs_dir = temp_dir + "vocabs"
  artifacts_dir = temp_dir + "artifacts"
  sql_schemas_dir = artifacts_dir + "sql"

  data_models = {
    gdm: {
      vocabs_dir: vocabs_dir,
      dir: schemas_dir + "gdm",
      schema_url: "http://gdm.schema.yml.jsaw.io",
      vocabs_url: "http://gdm.lexicon.csv.jsaw.io"
    }
  }
  dm = data_models[:gdm]
  dm[:schema_yml] = dm[:dir] + "schema.yml"
  dm[:known_tables] = dm[:dir] + "known_tables.txt"
  dm[:vocabs_tbz] = dm[:vocabs_dir] + "vocabs.tbz"
  dm[:vocab_files] = %w[mappings.tsv concepts.tsv vocabularies.tsv].map { |file| dm[:vocabs_dir] + file }
  dm[:sql_schemas_dir] = sql_schemas_dir + "gdm"
  dm[:schema_sql] = dm[:sql_schemas_dir] + "schema.sql"
  dm[:lexicon_schema_sql] = dm[:sql_schemas_dir] + "lexicon_schema.sql"
  dm[:lexicon_with_data_sql] = dm[:sql_schemas_dir] + "universal_vocabs_#{CURRENT_BRANCH}.sql.gz"
  dm[:additional_table_info] = {
    vocabularies: {
      category: :lexicon
    },
    concepts: {
      category: :lexicon,
      indexes: [
        [:vocabulary_id, :concept_code]
      ]
    },
    ancestors: {
      category: :lexicon
    },
    mappings: {
      category: :lexicon
    }
  }

  data_models.each do |data_model_name, dm|
    namespace data_model_name do
      directory dm[:dir]
      directory dm[:vocabs_dir]

      file dm[:known_tables]

      file dm[:vocabs_tbz] => dm[:vocabs_dir] do |t, _|
        ShellB.new.run! do
          curl("-sSL", dm[:vocabs_url]) > t.name
        end
      end

      dm[:vocab_files].each do |file|
        file file => dm[:vocabs_tbz] do |t, _|
          ShellB.new.run! do
            tar("xjvf", t.source, file.basename)
            mv(file.basename, t.name)
            touch(t.name)
          end
        end
      end

      file dm[:schema_yml] => dm[:dir] do |t, _|
        Rake::Task["loadmop:#{data_model_name}:download_schema"].invoke
      end

      task :download_schema => dm[:dir] do 
        ShellB.new.run! do
          curl("-sSL", dm[:schema_url]) > dm[:schema_yml].to_s
        end
      end

      task update: [ dm[:schema_yml], dm[:known_tables] ] do |t, _|
        schema = Psych.load(File.read(t.source))
        known_tables = dm[:known_tables].readlines.map(&:chomp).map(&:to_sym)
        unknown_tables = schema.keys - known_tables
        raise "Unknown tables #{unknown_tables.join(", ")} in #{t.source}" unless unknown_tables.empty?
        schema = schema.map do |table_name, table_info|
          [table_name, table_info.merge(dm[:additional_table_info][table_name] || {})]
        end.to_h
        dm[:schema_yml].write(schema.to_yaml)
      end

      task :load_lexicon, [:url] => [*dm[:vocab_files], dm[:schema_yml]] do |t, args|
        Loadmop.create_complete_database(data_model_name, :lexicon, dm[:vocabs_dir], url: get_pg_url(args), force: true)
        Loadmop.ancestorize(:lexicon, url: get_pg_url(args))
      end

      directory dm[:schema_sql].dirname
      directory dm[:lexicon_schema_sql].dirname

      file dm[:schema_sql], [:url] => [dm[:schema_sql].dirname] do |t, args|
        ShellB.new.run! do
          dump_it("--schema-only", get_pg_url(args)) > t.name
        end
      end

      file dm[:lexicon_schema_sql], [:url] => [dm[:lexicon_schema_sql].dirname] do |t, args|
        ShellB.new.run! do
          dump_it("--schema-only", *(VOCAB_TABLES.flat_map { |t| ["--table", t] }), get_pg_url(args)) > t.name
        end
      end

      file dm[:lexicon_with_data_sql], [:url] => [dm[:lexicon_schema_sql].dirname] do |t, args|
        ShellB.new.run! do
          dump_it(*(VOCAB_TABLES.flat_map { |t| ["--table", t] }), get_pg_url(args)) | pigz > t.name
        end
      end

      task pgdocker: :make_pgnet do |t, _|
        ShellB.new.run! { dc("up", "-d") }
        sleep 10
      end

      task upload_artifacts: [dropbox_deployment_dir, dm[:schema_sql], dm[:lexicon_schema_sql], dm[:lexicon_with_data_sql]] do
        check_env("DROPBOX_OAUTH_BEARER")
        ShellB.new.run! do
          cd(dropbox_deployment_dir)
          bundle(*%w[install --gemfile], (dropbox_deployment_dir + "Gemfile").to_s)
          bundle(*%w[exec], "--gemfile=#{(dropbox_deployment_dir + "Gemfile").to_s}", *%w[ruby -Ilib bin/dropbox-deployment --debug --upload-path /Publicized/schemas/gdm --artifact-path], dm[:schema_sql])
          bundle(*%w[exec], "--gemfile=#{(dropbox_deployment_dir + "Gemfile").to_s}", *%w[ruby -Ilib bin/dropbox-deployment --debug --upload-path /Publicized/schemas/gdm --artifact-path], dm[:lexicon_schema_sql])
          bundle(*%w[exec], "--gemfile=#{(dropbox_deployment_dir + "Gemfile").to_s}", *%w[ruby -Ilib bin/dropbox-deployment --debug --upload-path /Publicized/universal_vocabs --artifact-path], dm[:lexicon_with_data_sql])
        end
      end

      task create_lexicon_image: dm[:lexicon_with_data_sql] do |t, _|
        ShellB.new.run! do
          pigz("--decompress", "--stdout", t.source) | psql(LEXICON_PG_URL)
          container_id = `docker ps | grep loadmop_lexicon | awk '{ print $1 }'`.chomp
          dc("stop", "lexicon")
          docker("commit", container_id, LEXICON_TAG)
        end
      end

      directory dropbox_deployment_dir do |t, _|
        ShellB.new.run! do
          git(*%w[clone --branch cli https://github.com/outcomesinsights/dropbox-deployment.git], t.name)
        end
      end

      task upload_lexicon_image: :create_lexicon_image do
        check_env("DOCKER_HUB_USER", "DOCKER_HUB_PASSWORD")
        ShellB.new.run! do
          docker("login", "--username=#{ENV["DOCKER_HUB_USER"]}", "--password=#{ENV["DOCKER_HUB_PASSWORD"]}")
          docker("push", LEXICON_TAG)
        end
      end

      task upload: [:upload_lexicon_image, :upload_artifacts]
    end
  end
end
