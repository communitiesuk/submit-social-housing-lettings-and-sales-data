require "json-schema"
require "json"

# "form_type": "lettings",
#   "start_year": 2021,
#   "end_year": 2022,
#   "sections": {
#   "about_this_log": {
#     "label": "About this log",
#     "subsections": {
#     "about_this_log": {
#       "label": "About this log",
#       "pages": {
      # "tenant_code": {
      #   "header": "",
      #   "description": "",
      #   "questions": {
      #   "tenant_code": {
      #     "check_answer_label": "Tenant code",
      #     "header": "What is the tenant code?",
      #     "hint_text": "",
      #     "type": "text"
      #   }
      #   }
      # },
begin

  schema = {
  "$schema": "http://json-schema.org/draft-04/schema",
  "$id": "http://example.com/example.json",
  "type": "object",
  "title": "The root schema",
  "description": "The root schema comprises the entire JSON document.",
  "default": {},
  "examples": [
    {
      "form_type": "lettings",
      "start_year": 2021,
      "end_year": 2022,
      "sections": {
        "household": {
          "label": "About the household",
          "subsections": {
            "household_characteristics": {
              "label": "Household characteristics",
              "pages": {
                "tenant_code": {
                  "questions": {
                    "tenant_code": {
                      "check_answer_label": "Tenant code",
                      "header": "What is the tenant code?",
                      "type": "text"
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  ],
  "required": [
    "form_type",
    "start_year",
    "end_year",
    "sections"
  ],
  "properties": {
    "form_type": {
      "$id": "#/properties/form_type",
      "type": "string",
      "title": "The form_type schema",
      "description": "An explanation about the purpose of this instance.",
      "default": "",
      "examples": [
        "lettings"
      ]
    },
    "start_year": {
      "$id": "#/properties/start_year",
      "type": "integer",
      "title": "The start_year schema",
      "description": "An explanation about the purpose of this instance.",
      "default": 0,
      "examples": [
        2021
      ]
    },
    "end_year": {
      "$id": "#/properties/end_year",
      "type": "integer",
      "title": "The end_year schema",
      "description": "An explanation about the purpose of this instance.",
      "default": 0,
      "examples": [
        2022
      ]
    },
    "sections": {
      "$id": "#/properties/sections",
      "type": "object",
      "title": "The sections schema",
      "description": "An explanation about the purpose of this instance.",
      "default": {},
      "examples": [
        {
          "household": {
            "label": "About the household",
            "subsections": {
              "household_characteristics": {
                "label": "Household characteristics",
                "pages": {
                  "tenant_code": {
                    "questions": {
                      "tenant_code": {
                        "check_answer_label": "Tenant code",
                        "header": "What is the tenant code?",
                        "type": "text"
                      }
                    }
                  }
                }
              }
            }
          }
        }
      ],
      "required": [
        "household"
      ],
      "properties": {
        "household": {
          "$id": "#/properties/sections/properties/household",
          "type": "object",
          "title": "The household schema",
          "description": "An explanation about the purpose of this instance.",
          "default": {},
          "examples": [
            {
              "label": "About the household",
              "subsections": {
                "household_characteristics": {
                  "label": "Household characteristics",
                  "pages": {
                    "tenant_code": {
                      "questions": {
                        "tenant_code": {
                          "check_answer_label": "Tenant code",
                          "header": "What is the tenant code?",
                          "type": "text"
                        }
                      }
                    }
                  }
                }
              }
            }
          ],
          "required": [
            "label",
            "subsections"
          ],
          "properties": {
            "label": {
              "$id": "#/properties/sections/properties/household/properties/label",
              "type": "string",
              "title": "The label schema",
              "description": "An explanation about the purpose of this instance.",
              "default": "",
              "examples": [
                "About the household"
              ]
            },
            "subsections": {
              "$id": "#/properties/sections/properties/household/properties/subsections",
              "type": "object",
              "title": "The subsections schema",
              "description": "An explanation about the purpose of this instance.",
              "default": {},
              "examples": [
                {
                  "household_characteristics": {
                    "label": "Household characteristics",
                    "pages": {
                      "tenant_code": {
                        "questions": {
                          "tenant_code": {
                            "check_answer_label": "Tenant code",
                            "header": "What is the tenant code?",
                            "type": "text"
                          }
                        }
                      }
                    }
                  }
                }
              ],
              "required": [
                "household_characteristics"
              ],
              "properties": {
                "household_characteristics": {
                  "$id": "#/properties/sections/properties/household/properties/subsections/properties/household_characteristics",
                  "type": "object",
                  "title": "The household_characteristics schema",
                  "description": "An explanation about the purpose of this instance.",
                  "default": {},
                  "examples": [
                    {
                      "label": "Household characteristics",
                      "pages": {
                        "tenant_code": {
                          "questions": {
                            "tenant_code": {
                              "check_answer_label": "Tenant code",
                              "header": "What is the tenant code?",
                              "type": "text"
                            }
                          }
                        }
                      }
                    }
                  ],
                  "required": [
                    "label",
                    "pages"
                  ],
                  "properties": {
                    "label": {
                      "$id": "#/properties/sections/properties/household/properties/subsections/properties/household_characteristics/properties/label",
                      "type": "string",
                      "title": "The label schema",
                      "description": "An explanation about the purpose of this instance.",
                      "default": "",
                      "examples": [
                        "Household characteristics"
                      ]
                    },
                    "pages": {
                      "$id": "#/properties/sections/properties/household/properties/subsections/properties/household_characteristics/properties/pages",
                      "type": "object",
                      "title": "The pages schema",
                      "description": "An explanation about the purpose of this instance.",
                      "default": {},
                      "examples": [
                        {
                          "tenant_code": {
                            "questions": {
                              "tenant_code": {
                                "check_answer_label": "Tenant code",
                                "header": "What is the tenant code?",
                                "type": "text"
                              }
                            }
                          }
                        }
                      ],
                      "required": [
                        "tenant_code"
                      ],
                      "properties": {
                        "tenant_code": {
                          "$id": "#/properties/sections/properties/household/properties/subsections/properties/household_characteristics/properties/pages/properties/tenant_code",
                          "type": "object",
                          "title": "The tenant_code schema",
                          "description": "An explanation about the purpose of this instance.",
                          "default": {},
                          "examples": [
                            {
                              "questions": {
                                "tenant_code": {
                                  "check_answer_label": "Tenant code",
                                  "header": "What is the tenant code?",
                                  "type": "text"
                                }
                              }
                            }
                          ],
                          "required": [
                            "questions"
                          ],
                          "properties": {
                            "questions": {
                              "$id": "#/properties/sections/properties/household/properties/subsections/properties/household_characteristics/properties/pages/properties/tenant_code/properties/questions",
                              "type": "object",
                              "title": "The questions schema",
                              "description": "An explanation about the purpose of this instance.",
                              "default": {},
                              "examples": [
                                {
                                  "tenant_code": {
                                    "check_answer_label": "Tenant code",
                                    "header": "What is the tenant code?",
                                    "type": "text"
                                  }
                                }
                              ],
                              "required": [
                                "tenant_code"
                              ],
                              "properties": {
                                "tenant_code": {
                                  "$id": "#/properties/sections/properties/household/properties/subsections/properties/household_characteristics/properties/pages/properties/tenant_code/properties/questions/properties/tenant_code",
                                  "type": "object",
                                  "title": "The tenant_code schema",
                                  "description": "An explanation about the purpose of this instance.",
                                  "default": {},
                                  "examples": [
                                    {
                                      "check_answer_label": "Tenant code",
                                      "header": "What is the tenant code?",
                                      "type": "text"
                                    }
                                  ],
                                  "required": [
                                    "check_answer_label",
                                    "header",
                                    "type"
                                  ],
                                  "properties": {
                                    "check_answer_label": {
                                      "$id": "#/properties/sections/properties/household/properties/subsections/properties/household_characteristics/properties/pages/properties/tenant_code/properties/questions/properties/tenant_code/properties/check_answer_label",
                                      "type": "string",
                                      "title": "The check_answer_label schema",
                                      "description": "An explanation about the purpose of this instance.",
                                      "default": "",
                                      "examples": [
                                        "Tenant code"
                                      ]
                                    },
                                    "header": {
                                      "$id": "#/properties/sections/properties/household/properties/subsections/properties/household_characteristics/properties/pages/properties/tenant_code/properties/questions/properties/tenant_code/properties/header",
                                      "type": "string",
                                      "title": "The header schema",
                                      "description": "An explanation about the purpose of this instance.",
                                      "default": "",
                                      "examples": [
                                        "What is the tenant code?"
                                      ]
                                    },
                                    "type": {
                                      "$id": "#/properties/sections/properties/household/properties/subsections/properties/household_characteristics/properties/pages/properties/tenant_code/properties/questions/properties/tenant_code/properties/type",
                                      "type": "string",
                                      "title": "The type schema",
                                      "description": "An explanation about the purpose of this instance.",
                                      "default": "",
                                      "examples": [
                                        "text"
                                      ]
                                    }
                                  },
                                  "additionalProperties": true
                                }
                              },
                              "additionalProperties": true
                            }
                          },
                          "additionalProperties": true
                        }
                      },
                      "additionalProperties": true
                    }
                  },
                  "additionalProperties": true
                }
              },
              "additionalProperties": true
            }
          },
          "additionalProperties": true
        }
      },
      "additionalProperties": true
    }
  },
  "additionalProperties": true
}

  metaschema = JSON::Validator.validator_for_name("draft4").metaschema

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
  #   form_paths = []
  #   directories = ["config/forms", "spec/fixtures/forms"]
  #   directories.each do |directory|
  #     Dir.glob("#{directory}/*.json").each do |form_path|
  #     form_path = form_path.sub(".json", "").split("/")[-1]
  #     form_paths.push(form_path)
  #     end
  #   end
  #   form_paths
  # end
end
