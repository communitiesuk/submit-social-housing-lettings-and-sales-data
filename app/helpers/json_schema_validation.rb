require "json-schema"
require "json"

def get_all_form_paths(directories)
  form_paths = []
  directories.each do |directory|
    Dir.glob("#{directory}/*.json").each do |form_path|
      form_paths.push(form_path)
    end
  end
  form_paths
end

begin

  path = "config/forms/schema/generic.json"
  # path = "config/forms/schema/2021_2022.json"

  file = File.open(path)
  schema = JSON.parse(file.read)
  metaschema = JSON::Validator.validator_for_name("draft4").metaschema

  puts path

  if JSON::Validator.validate(metaschema, schema)
    puts "schema valid"
  else
    puts "schema not valid"
    return
  end

  # directories = ["config/forms", "spec/fixtures/forms"]
  directories = ["config/forms"]

  get_all_form_paths(directories).each do |path|
    puts path
    file = File.open(path)
    data = JSON.parse(file.read)

    puts JSON::Validator.validate(schema, data, :strict => true)

    puts JSON::Validator.fully_validate(schema, data, :strict => true)

    begin
      JSON::Validator.validate!(schema, data)
    rescue JSON::Schema::ValidationError => e
      e.message
    end
  end
end
