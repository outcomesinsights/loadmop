require "bundler/gem_tasks"
require "loadmop"
require "pathname"
require "psych"
require "shellb"
require "pry-byebug"
require "tmpdir"

def get_pg_url(args)
  args.url || ENV["PG_URL"] || "postgres://ryan:r@pg/lexicon"
end

def check_env(*keys)
  keys = keys.reject { |key| ENV.keys.include?(key) }
  raise("Missing ENV vars: #{keys.join(", ")}") unless keys.empty?
end

def download(url, dest_file)
  ShellB.new.run! do
    curl("-sSL", url) > dest_file
  end
end

CURRENT_BRANCH = ENV["TRAVIS_BRANCH"] || "chisel"

LEXICON_PG_URL = ENV["LEXICON_PG_URL"] || "postgres://ryan:r@lexicon/lexicon"

VOCAB_TABLES = %w(ancestors concepts mappings vocabularies)
LEXICON_TAG = "outcomesinsights/lexicon:#{CURRENT_BRANCH}.latest"

namespace :loadmop do
  %w[bundle curl docker git mv pigz psql tar touch unzip].each do |cmd|
    ShellB.def_system_command(cmd)
  end

  ShellB.alias_command("dc", "docker-compose")
  ShellB.alias_command("dump_it", "pg_dump", *%w[--clean --quote-all-identifiers --no-owner --no-privileges --if-exists])

  schemas_dir = Pathname.new("schemas")
  temp_dir = Pathname.new("/tmp")
  dropbox_deployment_dir = temp_dir + "dropbox_deployment"
  data_dir = temp_dir + "data"
  artifacts_dir = temp_dir + "artifacts"
  sql_schemas_dir = artifacts_dir + "sql"

  data_models = {
    gdm: {
      data_dir: data_dir,
      dir: schemas_dir + "gdm",
      schema_url: "http://schemas.gdm.jsaw.io",
      vocabs_url: "http://gdm.lexicon.csv.jsaw.io",
      synpuf250_url: "http://synpuf250.csv.zip.jsaw.io"
    }
  }
  dm = data_models[:gdm]
  dm[:schema_yml] = dm[:dir] + "schema.yml"
  dm[:known_tables] = dm[:dir] + "known_tables.txt"
  dm[:vocabs_tbz] = temp_dir + "vocabs.tbz"
  dm[:synpuf250_zip] = temp_dir + "synpuf250.zip"
  dm[:vocab_files] = %w[mappings.tsv concepts.tsv vocabularies.tsv].map { |file| dm[:data_dir] + file }
  dm[:sql_schemas_dir] = sql_schemas_dir + "gdm"
  dm[:schema_sql] = dm[:sql_schemas_dir] + "schema.sql"
  dm[:schema_with_data_sql] = dm[:sql_schemas_dir] + "test_data_for_#{CURRENT_BRANCH}.sql.gz"
  dm[:lexicon_schema_sql] = dm[:sql_schemas_dir] + "lexicon_schema.sql"
  dm[:lexicon_with_data_sql] = dm[:sql_schemas_dir] + "universal_vocabs_#{CURRENT_BRANCH}.sql.gz"
  dm[:additional_table_info] = {
    vocabularies: {
      category: :lexicon
    },
    concepts: {
      category: :lexicon,
      indexes: [
        [:vocabulary_id, [:lower, :concept_text]],
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
      directory dm[:data_dir] => dm[:synpuf250_zip] do |t, _|
        ShellB.new.run! do
          unzip t.source
          mv("250_sample_lexicon_vocabs", t.name)
        end
      end

      file dm[:synpuf250_zip] do |t, _|
        download(dm[:synpuf250_url], t.name)
      end

      file dm[:known_tables]

      file dm[:vocabs_tbz] => dm[:data_dir] do |t, _|
        download(dm[:vocabs_url], t.name)
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
        sh = ShellB.new
        sh.curl("-sSL", dm[:schema_url]) | sh.tar("jxv")
        sh.run!
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

      task :load, [:url] => [*dm[:vocab_files], *dm[:data_files], dm[:schema_yml]] do |t, args|
        # Remove the CSV files so we favor Lexicon's latest TSV files
        %w[concepts.csv vocabularies.csv mappings.csv].each do |n|
          p = dm[:data_dir] + n
          p.unlink if p.exist?
        end 
        Loadmop.create_complete_database(data_model_name, :lexicon, dm[:data_dir], url: get_pg_url(args), force: true)
        Loadmop.ancestorize(:lexicon, url: get_pg_url(args))
      end

      directory dm[:schema_sql].dirname
      directory dm[:lexicon_schema_sql].dirname

      file dm[:schema_sql], [:url] => [dm[:schema_sql].dirname] do |t, args|
        ShellB.new.run! do
          dump_it("--schema-only", get_pg_url(args)) > t.name
        end
      end

      file dm[:schema_with_data_sql], [:url] => [dm[:schema_with_data_sql].dirname] do |t, args|
        ShellB.new.run! do
          dump_it(get_pg_url(args)) | pigz > t.name
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

      task upload_artifacts: [dropbox_deployment_dir, dm[:schema_sql], dm[:schema_with_data_sql], dm[:lexicon_schema_sql], dm[:lexicon_with_data_sql]] do
        check_env("DROPBOX_OAUTH_BEARER")
        ShellB.new.run! do
          cd(dropbox_deployment_dir)
          bundle(*%w[install --gemfile], (dropbox_deployment_dir + "Gemfile").to_s)
          bundle(*%w[exec], "--gemfile=#{(dropbox_deployment_dir + "Gemfile").to_s}", *%w[ruby -Ilib bin/dropbox-deployment --debug --upload-path /Publicized/schemas/gdm --artifact-path], dm[:schema_sql])
          bundle(*%w[exec], "--gemfile=#{(dropbox_deployment_dir + "Gemfile").to_s}", *%w[ruby -Ilib bin/dropbox-deployment --debug --upload-path /Publicized/schemas/gdm --artifact-path], dm[:lexicon_schema_sql])
          bundle(*%w[exec], "--gemfile=#{(dropbox_deployment_dir + "Gemfile").to_s}", *%w[ruby -Ilib bin/dropbox-deployment --debug --upload-path /Publicized/universal_vocabs --artifact-path], dm[:lexicon_with_data_sql])
          bundle(*%w[exec], "--gemfile=#{(dropbox_deployment_dir + "Gemfile").to_s}", *%w[ruby -Ilib bin/dropbox-deployment --debug --upload-path /Publicized/universal_vocabs --artifact-path], dm[:schema_with_data_sql])
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

      task upload: [:upload_artifacts, :upload_lexicon_image]
    end
  end
end
