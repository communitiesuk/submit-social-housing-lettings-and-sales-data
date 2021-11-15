require "json"
require "json-schema"

def get_all_form_paths(directories)
  form_paths = []
  directories.each do |directory|
    Dir.glob("#{directory}/*.json").each do |form_path|
      form_paths.push(form_path)
    end
  end
  form_paths
end

namespace :form_definition do
  desc "Validate all JSON against Generic Form Schema"

  task validate_all: :environment do
    directories = ["config/forms", "spec/fixtures/forms"]
    paths = get_all_form_paths(directories)

    paths.each do |path|
      Rake::Task["form_definition:validate"].reenable
      Rake::Task["form_definition:validate"].invoke(path)
    end
  end

  desc "Validate Single JSON against Generic Form Schema"

  task :validate, %i[path] => :environment do |_task, args|
    path = Rails.root.join("config/forms/schema/generic.json")
    file = File.open(path)
    schema = JSON.parse(file.read)
    meta_schema = JSON::Validator.validator_for_name("draft4").metaschema

    puts path

    if JSON::Validator.validate(meta_schema, schema)
      puts "Schema Definition is Valid"
    else
      puts "Schema Definition in #{path} is not valid against draft4 json schema."
      next
    end

    path = Rails.root.join(args.path)
    file = File.open(path)
    form_definition = JSON.parse(file.read)

    puts path
    puts JSON::Validator.fully_validate(schema, form_definition, strict: true)

    begin
      JSON::Validator.validate!(schema, form_definition)
    rescue JSON::Schema::ValidationError => e
      e.message
    end
  end
end
