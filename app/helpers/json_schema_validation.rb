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

schema = {
  "$schema": "https://json-schema.org/draft/2020-12/schema",
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
      "properties": {
        "page_name": {
          "description": "",
          "type": "string"
        },
      }
    }
  }
}

begin

  # file = File.open("config/forms/2021_2022.json")
  file = File.open("spec/fixtures/forms/test_validator.json")
  data = JSON.parse(file.read)

  if JSON::Validator.validate!(schema, data)
    puts "Success"
  else
    puts "Validation failed"
  end

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
