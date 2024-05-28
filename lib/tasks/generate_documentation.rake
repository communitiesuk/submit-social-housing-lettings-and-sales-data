namespace :generate_documentation do
  desc "Generate documentation for hard lettings validations"
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
                   Validations::LocalAuthorityValidations].map { |x| x.instance_methods + x.private_instance_methods }.flatten
    all_helper_methods = all_methods - validation_methods

    validation_methods.each do |meth|
      if Validation.where(validation_name: meth.to_s, bulk_upload_specific: false).exists?
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
                              description: "Comma separated list of any other models (other than log) that were used in this validation. These are possible models (only add a value to this field if other validation models are one of these models): User, Organisation, Scheme, Location, Organisation_relationship, LaRentRange. Only leave this blank if no other models were used in this validation.",
                            },
                          },
                          required: %w[case_description errors validation_type other_validated_models],
                        },
                      },
                    },
                    required: %w[description cases],
                  },
                },
              },
            ],
            tool_choice: { type: "function", function: { name: "create_documentation_for_given_validation" } },
          },
        )
      rescue StandardError => e
        Rails.logger.error("Failed to describe #{meth}")
        Rails.logger.error("Error #{e.message}")
        sleep(5)
        next
      end

      begin
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
      rescue StandardError => e
        Rails.logger.error("Failed to save #{meth}")
        Rails.logger.error("Error #{e.message}")
      end
    end
  end

  desc "Generate documentation for soft lettings validations"
  task describe_soft_lettings_validations: :environment do
    include Validations::SoftValidations

    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

    current_form = FormHandler.instance.forms["current_lettings"]
    previous_form = FormHandler.instance.forms["previous_lettings"]

    all_helper_methods = Validations::SoftValidations.private_instance_methods

    # describe all soft validations
    validation_descriptions = {}
    Validations::SoftValidations.instance_methods.each do |meth|
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
                You are given a method that contains a validation. Describe what given method does, be very explicit about all the different validation cases (be specific about the years for which these validations would run, which values would be invalid or which values are required, look at private helper methods to understand what is being checked in more detail).
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
                      validation_type: {
                        type: :string,
                        enum: %w[presence format minimum maximum range inclusion length other],
                        description: "The type of validation that is being performed. This should be one of the following: presence (validates that the question is answered), format (validates that the answer format is valid), minimum (validates that entered value is more than minimum allowed value), maximum (validates that entered value is less than maximum allowed value), range (values must be between two values), inclusion (validates that the values that are not allowed arent selected), length (validates the length of the answer), other",
                      },
                      other_validated_models: {
                        type: :string,
                        description: "Comma separated list of any other models (other than log) that were used in this validation. These are possible models (only add a value to this field if other validation models are one of these models): User, Organisation, Scheme, Location, Organisation_relationship, LaRentRange. Only leave this blank if no other models were used in this validation.",
                      },
                    },
                    required: %w[description validation_type other_validated_models],
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

      validation_descriptions[meth.to_s] = result
    end

    # add a validation for each interruption screen page for both forms
    [current_form, previous_form].each do |form|
      interruption_screen_pages = form.pages.select { |page| page.questions.first.type == "interruption_screen" }
      interruption_screen_pages_grouped_by_question = interruption_screen_pages.group_by { |page| page.questions.first.id }
      interruption_screen_pages_grouped_by_question.each do |_question_id, pages|
        pages.map do |page|
          subsection_pages = form.subsection_for_page(page).pages
          page_index = subsection_pages.index(page)
          page_the_validation_applied_to = subsection_pages[page_index - 1]

          loop do
            break unless page_the_validation_applied_to.questions.first.type == "interruption_screen"

            page_index -= 1
            page_the_validation_applied_to = subsection_pages[page_index - 1]
          end

          validation_depends_on_hash = page.depends_on.each_with_object({}) do |depends_on, result|
            depends_on.each do |key, value|
              if validation_descriptions.include?(key)
                result[key] = value
              end
            end
          end

          if validation_depends_on_hash.empty?
            Rails.logger.info("No validation description found for #{page.questions.first.id}")
            next
          end

          if Validation.where(validation_name: validation_depends_on_hash.keys.first, field: page_the_validation_applied_to.questions.first.id, from: form.start_date).exists?
            Rails.logger.info("Validation #{validation_depends_on_hash.keys.first} already exists for #{page_the_validation_applied_to.questions.first.id} for start year #{form.start_date.year}")
            next
          end

          result = validation_descriptions[validation_depends_on_hash.keys.first]

          informative_text = page.informative_text
          if informative_text.present? && !(informative_text.is_a? String)
            informative_text = I18n.t(page.informative_text["translation"])
          end

          title_text = page.title_text
          if title_text.present? && !(title_text.is_a? String)
            title_text = I18n.t(page.title_text["translation"])
          end

          error_message = [title_text, informative_text, page.questions.first.hint_text].compact.join("\n")

          case_info = page.depends_on.first.values.first ? "Provided values fulfill the description" : "Provided values do not fulfill the description"
          Validation.create!(log_type: "lettings",
                             validation_name: validation_depends_on_hash.keys.first.to_s,
                             description: result["description"],
                             field: page_the_validation_applied_to.questions.first.id,
                             error_message:,
                             case: case_info,
                             section: form.get_question(page_the_validation_applied_to.questions.first.id, nil)&.subsection&.id,
                             from: form.start_date,
                             to: form.start_date + 1.year,
                             validation_type: result["validation_type"],
                             hard_soft: "soft",
                             other_validated_models: result["other_validated_models"])

          Rails.logger.info("******** described #{validation_depends_on_hash.keys.first} for #{page_the_validation_applied_to.questions.first.id} ********")
        end
      end
    end
  end

  desc "Generate documentation for hard bu lettings validations"
  task describe_bu_lettings_validations: :environment do
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
    en_yml = File.read("./config/locales/en.yml")

    [[FormHandler.instance.forms[FormHandler.instance.form_name_from_start_year(2023, "lettings")], BulkUpload::Lettings::Year2023::RowParser],
     [FormHandler.instance.forms[FormHandler.instance.form_name_from_start_year(2024, "lettings")], BulkUpload::Lettings::Year2024::RowParser]].each do |form, row_parser_class|
      validation_methods = row_parser_class.private_instance_methods.select { |method| method.starts_with?("validate_") }

      all_helper_methods = row_parser_class.private_instance_methods(false) +  row_parser_class.instance_methods(false) - validation_methods

      field_mapping_for_errors = row_parser_class.new.send("field_mapping_for_errors")
      validation_methods.each do |meth|
        if Validation.where(validation_name: meth.to_s, bulk_upload_specific: true, from: form.start_date).exists?
          Rails.logger.info("Validation #{meth} already exists for #{form.start_date.year}")
          next
        end

        validation_source = row_parser_class.instance_method(meth).source
        helper_methods_source = all_helper_methods.map { |helper_method|
          if validation_source.include?(helper_method.to_s)
            row_parser_class.instance_method(helper_method).source
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
                              validation_type: {
                                type: :string,
                                enum: %w[presence format minimum maximum range inclusion length other],
                                description: "The type of validation that is being performed. This should be one of the following: presence (validates that the question is answered), format (validates that the answer format is valid), minimum (validates that entered value is more than minimum allowed value), maximum (validates that entered value is less than maximum allowed value), range (values must be between two values), inclusion (validates that the values that are not allowed arent selected), length (validates the length of the answer), other",
                              },
                              other_validated_models: {
                                type: :string,
                                description: "Comma separated list of any other models (other than log) that were used in this validation. These are possible models (only add a value to this field if other validation models are one of these models): User, Organisation, Scheme, Location, Organisation_relationship, LaRentRange. Only leave this blank if no other models were used in this validation.",
                              },
                            },
                            required: %w[case_description errors validation_type other_validated_models],
                          },
                        },
                      },
                      required: %w[description cases],
                    },
                  },
                },
              ],
              tool_choice: { type: "function", function: { name: "create_documentation_for_given_validation" } },
            },
          )
        rescue StandardError => e
          Rails.logger.error("Failed to describe #{meth}")
          Rails.logger.error("Error #{e.message}")
          sleep(5)
          next
        end

        begin
          result = JSON.parse(response.dig("choices", 0, "message", "tool_calls", 0, "function", "arguments"))

          result["cases"].each do |case_info|
            case_info["errors"].each do |error|
              error_fields = field_mapping_for_errors.select { |_key, values| values.include?(error["field"].to_sym) }.keys
              error_fields = [error["field"]] if error_fields.empty?
              error_fields.each do |error_field|
                Validation.create!(log_type: "lettings",
                                   validation_name: meth.to_s,
                                   description: result["description"],
                                   field: error_field,
                                   error_message: error["error_message"],
                                   case: case_info["case_description"],
                                   section: form.get_question(error_field, nil)&.subsection&.id,
                                   from: form.start_date,
                                   to: form.start_date + 1.year,
                                   validation_type: case_info["validation_type"],
                                   hard_soft: "hard",
                                   other_validated_models: case_info["other_validated_models"],
                                   bulk_upload_specific: true)
              end
            end
          end

          Rails.logger.info("******** described #{meth} ********")
        rescue StandardError => e
          Rails.logger.error("Failed to save #{meth}")
          Rails.logger.error("Error #{e.message}")
        end
      end
    end
  end

  desc "Generate documentation for lettings numeric validations"
  task add_numeric_lettings_validations: :environment do
    form = FormHandler.instance.forms["current_lettings"]

    form.numeric_questions.each do |question|
      next unless question.min || question.max

      field = question.id
      min = [question.prefix, question.min].join("") if question.min
      max = [question.prefix, question.max].join("") if question.max

      error_message = I18n.t("validations.numeric.above_min", field:, min:)
      validation_name = "minimum"
      validation_description = "Field value is lower than the minimum value"

      if min && max
        validation_name = "range"
        error_message = I18n.t("validations.numeric.within_range", field:, min:, max:)
        validation_description = "Field value is lower than the minimum value or higher than the maximum value"
      end

      if Validation.where(validation_name:, field:).exists?

        Rails.logger.info("Validation #{validation_name} already exists for #{field}")
        next
      end

      Validation.create!(log_type: "lettings",
                         validation_name:,
                         description: validation_description,
                         field:,
                         error_message:,
                         case: validation_description,
                         section: form.get_question(field, nil)&.subsection&.id,
                         validation_type: validation_name,
                         hard_soft: "hard")
    end
  end
end
