namespace :generate_documentation do
  desc "Import lettings address data from a csv file"
  task describe_lettings_validations: :environment do
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
    en_yml = File.read("./config/locales/en.yml")

    include Validations::SetupValidations
    include Validations::HouseholdValidations
    include Validations::PropertyValidations
    include Validations::FinancialValidations
    include Validations::TenancyValidations
    include Validations::DateValidations
    include Validations::LocalAuthorityValidations
    form = FormHandler.instance.forms["current_lettings"]

    validation_methods = public_methods.select { |method| method.starts_with?("validate_") }

    all_methods = [Validations::SetupValidations,
                   Validations::HouseholdValidations,
                   Validations::PropertyValidations,
                   Validations::FinancialValidations,
                   Validations::TenancyValidations,
                   Validations::DateValidations,
                   Validations::LocalAuthorityValidations].map(&:instance_methods).flatten
    all_helper_methods = all_methods - validation_methods

    validation_methods.each do |meth|
      if Validation.where(validation_name: meth.to_s).exists?
        Rails.logger.info("Validation #{meth} already exists")
        next
      end

      validation_source = method(meth).source
      helper_methods_source = all_helper_methods.map { |helper_method|
        if validation_source.include?(helper_method.to_s)
          method(helper_method).source
        end
      }.compact.join("\n")

      begin
        response = client.chat(
          parameters: {
            model: "gpt-3.5-turbo",
            messages: [
              {
                role: "system",
                content: "You write amazing documentation, as a senior technical writer. Your audience is non-technical team members. You have been asked to document the validations in a Rails application. The application collects social housing data for different collection years. There are validations on different fields, sometimes the validations depend on several fields.
    Describe what given validation does, be very explicit about all the different validation cases (be specific about the years for which these validations would run, which values would be invalid or which values are required, look at private helper methods to understand what is being checked in more detail). Quote the error messages that would be added in each case exactly. Here is the translation file for validation messages: #{en_yml}.
    You should create `create_documentation_for_given_validation` method. Call it once, and include the documentation for given validation.",
              },
              {
                role: "user",
                content: "Describe #{meth} validation in detail. Here is the content of the validation:

    #{validation_source}
    Look at these helper methods where needed to understand what is being checked in more detail: #{helper_methods_source}",
              },
            ],
            tools: [
              {
                type: "function",
                function: {
                  name: "create_documentation_for_given_validation",
                  description: "Use this function to save the complete documentation, covering given validation in the provided code.",
                  parameters: {
                    type: :object,
                    properties: {
                      description: {
                        type: :string,
                        description: "A human-readbale description of the validation",
                      },
                      conditions: {
                        type: :array,
                        description: "A list of conditions that must be met for this validation to run, in human-readable text (not code)",
                        items: {
                          type: :string,
                          description: "A single condition (write this in a human-readable way)",
                        },
                      },
                      cases: {
                        type: :array,
                        description: "A list of cases that this validation triggers on, each with specific details",
                        items: {
                          type: :object,
                          description: "Information about a single case that triggers this validation",
                          properties: {
                            case_description: {
                              type: :string,
                              description: "A human-readable description of the case in which this validation triggers",
                            },
                            errors: {
                              type: :array,
                              description: "The error messages that would be added if this case triggers the validation",
                              items: {
                                type: :object,
                                description: "Information about a single error message for a specific field",
                                properties: {
                                  error_message: {
                                    type: :string,
                                    description: "A single error message",
                                  },
                                  field: {
                                    type: :string,
                                    description: "The field that the error message would be added to.",
                                  },
                                },
                                required: %w[error_message field],
                              },
                            },
                            from: {
                              type: :number,
                              description: "the year from which the validation starts. If this validation runs for logs with a startdate after a certain year, specify that year here, only if it is not specified in the validation method, leave this field blank",
                            },
                            to: {
                              type: :number,
                              description: "the year in which the validation ends. If this validation runs for logs with a startdate before a certain year, specify that year here, only if it is not specified in the validation method, leave this field blank",
                            },
                            validation_type: {
                              type: :string,
                              enum: %w[presence format minimum maximum range inclusion length other],
                              description: "The type of validation that is being performed. This should be one of the following: presence (validates that the question is answered), format (validates that the answer format is valid), minimum (validates that entered value is more than minimum allowed value), maximum (validates that entered value is less than maximum allowed value), range (values must be between two values), inclusion (validates that the values that are not allowed arent selected), length (validates the length of the answer), other",
                            },
                            other_validated_models: {
                              type: :string,
                              description: "Comma separated list of any other models (other than log) that were used in this validation. These are possible models: user, organisation, scheme, location, organisation_relationship. Only leave this blank if no other models were used in this validation.",
                            },
                          },
                          required: %w[case_description errors validation_type other_validated_models],
                        },
                      },
                    },
                    required: %w[validation_name description conditions cases],
                  },
                },
              },
            ],
            tool_choice: { type: "function", function: { name: "create_documentation_for_given_validation" } },
          },
        )
      rescue StandardError => e
        Rails.logger.info("Failed to describe #{meth}")
        Rails.logger.info("Error #{e.message}")
        sleep(5)
        next
      end

      result = JSON.parse(response.dig("choices", 0, "message", "tool_calls", 0, "function", "arguments"))

      result["cases"].each do |case_info|
        case_info["errors"].each do |error|
          Validation.create!(log_type: "lettings",
                             validation_name: meth.to_s,
                             description: result["description"],
                             field: error["field"],
                             error_message: error["error_message"],
                             case: case_info["case_description"],
                             section: form.get_question(error["field"], nil)&.subsection&.id,
                             from: case_info["from"] || "",
                             to: case_info["to"] || "",
                             validation_type: case_info["validation_type"],
                             hard_soft: "hard", 
                            other_validated_models: case_info["other_validated_models"])
        end
      end

      Rails.logger.info("******** described #{meth} ********")
    end
  end
end
