require "json-schema"
require "json"

# "form_type": "lettings",
#start_year": 2021,
#end_year": 2022,
#sections": {
#  about_this_log": {
#    label": "About this log",
#    subsections": {
#      about_this_log": {
#        label": "About this log",
#        pages": {
#         "tenant_code": {
#             header": "",
#             description": "",
#             questions": {
#               tenant_code": {
#                 check_answer_label": "Tenant code", 
#                 header": "What is the tenant code?",
#                 hint_text": "",
#                 type": "text"
#                 }
#               }
#             }

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

  # path = "config/forms/schema/generic.json"
  path = "config/forms/schema/2021_2022.json"

  file = File.open(path)
  schema = JSON.parse(file.read)
  metaschema = JSON::Validator.validator_for_name("draft4").metaschema

  if JSON::Validator.validate(metaschema, schema)
    puts "schema valid"
  else
    puts "schema not valid"
    return
  end

  path = "spec/fixtures/forms/test_validator.json"
  # path = "config/forms/2021_2022.json"

  directories = ["config/forms", "spec/fixtures/forms"]

  get_all_form_paths(directories).each do |path|
    puts path
    file = File.open(path)
    data = JSON.parse(file.read)

    puts JSON::Validator.validate(schema, data)

    puts JSON::Validator.fully_validate(schema, data, :strict => true)

    begin
      JSON::Validator.validate!(schema, data)
    rescue JSON::Schema::ValidationError => e
      e.message
    end
  end
end
