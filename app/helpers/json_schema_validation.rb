require "json-schema"
require "json"

# "form_type": "lettings",
#   "start_year": 2021,
#   "end_year": 2022,
#   "sections": {
#     "about_this_log": {
#       "label": "About this log",
#       "subsections": {
#         "about_this_log": {
#           "label": "About this log",
#           "pages": {
            # "tenant_code": {
            #   "header": "",
            #   "description": "",
            #   "questions": {
            #     "tenant_code": {
            #       "check_answer_label": "Tenant code",
            #       "header": "What is the tenant code?",
            #       "hint_text": "",
            #       "type": "text"
            #     }
            #   }
            # },
begin

  schema = {
    "$schema": "http://json-schema.org/draft-04/schema",
    "$id": "https://example.com/product.schema.json",
    "title": "Form",
    "description": "A form",
    "type": "object",
    "properties": {
      "form_type": {
        "description": "",
        "type": "string"
      },
      "start_year": {
        "description": "",
        "type": "int"
      },
      "end_year": {
        "description": "",
        "type": "int"
      },
      "sections": {
        "description": "",
        "type": "object",
        "patternProperties": {
          "^[0-9]+$": {
            "description": "",
            "type": "string"
          },
          "label": {
            "description": "",
            "type": "string"  
          },
          "subsections": {
            "type": "object"
          }
        }
      }
    }
  }

  metaschema = JSON::Validator.validator_for_name("draft4").metaschema
  # => true
  if JSON::Validator.validate(metaschema, schema)
    puts "schema valid"
  else
    puts "schema not valid"
    return
  end

  path = "spec/fixtures/forms/test_validator.json"
  # path = "config/forms/2021_2022.json"

  file = File.open(path)
  data = JSON.parse(file.read)

  puts JSON::Validator.validate(schema, data)

  puts JSON::Validator.fully_validate(schema, data, :strict => true)

  begin
    JSON::Validator.validate!(schema, data)
  rescue JSON::Schema::ValidationError => e
    e.message
  end

  # def get_all_form_paths
  #     form_paths = []
  #     directories = ["config/forms", "spec/fixtures/forms"]
  #     directories.each do |directory|
  #       Dir.glob("#{directory}/*.json").each do |form_path|
  #         form_path = form_path.sub(".json", "").split("/")[-1]
  #         form_paths.push(form_path)
  #       end
  #     end
  #     form_paths
  # end
end
