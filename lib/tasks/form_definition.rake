require "json"
require "json-schema"
# rubocop:disable Lint/ShadowingOuterLocalVariable
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

    puts path unless Rails.env.test?

    if JSON::Validator.validate(meta_schema, schema)
      puts "Schema Definition is Valid" unless Rails.env.test?
    else
      puts "Schema Definition in #{path} is not valid against draft4 json schema." unless Rails.env.test?
      next
    end

    path = Rails.root.join(args.path)
    file = File.open(path)
    form_definition = JSON.parse(file.read)

    puts path unless Rails.env.test?
    puts JSON::Validator.fully_validate(schema, form_definition, strict: true) unless Rails.env.test?

    begin
      JSON::Validator.validate!(schema, form_definition)
    rescue JSON::Schema::ValidationError => e
      e.message
    end
  end
end
