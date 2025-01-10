class DocumentationGenerator
  include Validations::Sales::SetupValidations
  include Validations::Sales::HouseholdValidations
  include Validations::Sales::PropertyValidations
  include Validations::Sales::FinancialValidations
  include Validations::Sales::SaleInformationValidations
  include Validations::SharedValidations
  include Validations::LocalAuthorityValidations
  include Validations::SoftValidations
  include Validations::Sales::SoftValidations

  def describe_hard_validations(client, all_validation_methods, all_helper_methods, log_type)
    form = FormHandler.instance.forms["current_#{log_type}"]

    all_validation_methods.each do |meth|
      if LogValidation.where(validation_name: meth.to_s, bulk_upload_specific: false, log_type:).exists?
        Rails.logger.info("Validation #{meth} already exists")
        next
      end

      validation = method(meth)
      validation_source = validation.source
      file_path = validation.source_location[0]
      helper_methods_source = all_helper_methods.map { |helper_method|
        if validation_source.include?(helper_method.to_s)
          method(helper_method).source
        end
      }.compact.join("\n")

      response = describe_hard_validation(client, meth, validation_source, helper_methods_source, form, file_path)
      next unless response

      begin
        result = JSON.parse(response.dig("choices", 0, "message", "tool_calls", 0, "function", "arguments"))

        save_hard_validation(result, meth, form, log_type)
      rescue StandardError => e
        Rails.logger.error("Failed to save #{meth} for #{form.start_date.year}")
        Rails.logger.error("Error #{e.message}")
      end
    end
  end

  def describe_bu_validations(client, form, row_parser_class, all_validation_methods, all_helper_methods, field_mapping_for_errors, log_type)
    all_validation_methods.each do |meth|
      if LogValidation.where(validation_name: meth.to_s, bulk_upload_specific: true, from: form.start_date, log_type:).exists?
        Rails.logger.info("Validation #{meth} already exists for #{form.start_date.year}")
        next
      end
      validation = row_parser_class.instance_method(meth)
      validation_source = validation.source
      helper_methods_source = all_helper_methods.map { |helper_method|
        if validation_source.include?(helper_method.to_s)
          row_parser_class.instance_method(helper_method).source
        end
      }.compact.join("\n")

      response = describe_hard_validation(client, meth, validation_source, helper_methods_source, form, validation.source_location[0])
      next unless response

      begin
        result = JSON.parse(response.dig("choices", 0, "message", "tool_calls", 0, "function", "arguments"))

        save_bu_validation(result, meth, form, log_type, field_mapping_for_errors)
      rescue StandardError => e
        Rails.logger.error("Failed to save #{meth} for #{form.start_date.year}")
        Rails.logger.error("Error #{e.message}")
      end
    end
  end

  def describe_soft_validations(client, all_validation_methods, all_helper_methods, log_type)
    validation_descriptions = {}
    all_validation_methods[0..5].each do |meth|
      validation_source = method(meth).source
      helper_methods_source = all_helper_methods.map { |helper_method|
        if validation_source.include?(helper_method.to_s)
          method(helper_method).source
        end
      }.compact.join("\n")

      response = soft_validation_description(client, meth, validation_source, helper_methods_source)
      next unless response

      result = JSON.parse(response.dig("choices", 0, "message", "tool_calls", 0, "function", "arguments"))

      validation_descriptions[meth.to_s] = result
    end

    current_form = FormHandler.instance.forms["current_#{log_type}"]
    previous_form = FormHandler.instance.forms["previous_#{log_type}"]

    [current_form, previous_form].each do |form|
      interruption_screen_pages = form.pages.select { |page| page.questions.first.type == "interruption_screen" }
      interruption_screen_pages_grouped_by_question = interruption_screen_pages.group_by { |page| page.questions.first.id }
      interruption_screen_pages_grouped_by_question.each do |_question_id, pages|
        pages.map do |page|
          save_soft_validation(form, page, validation_descriptions, log_type)
        end
      end
    end
  end

private

  def describe_hard_validation(client, meth, validation_source, helper_methods_source, form, file_path)
    en_yml = File.read(translation_file_path(form, file_path))

    begin
      client.chat(
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
      Rails.logger.error("Failed to describe #{meth} for #{form.start_date.year}")
      Rails.logger.error("Error #{e.message}")
      sleep(15)
      false
    end
  end

  def soft_validation_description(client, meth, validation_source, helper_methods_source)
    client.chat(
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
    Rails.logger.error("Failed to describe #{meth}")
    Rails.logger.error("Error #{e.message}")
    sleep(15)
    false
  end

  def save_hard_validation(result, meth, form, log_type)
    result["cases"].each do |case_info|
      case_info["errors"].each do |error|
        LogValidation.create!(log_type:,
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

  def save_bu_validation(result, meth, form, log_type, field_mapping_for_errors)
    result["cases"].each do |case_info|
      case_info["errors"].each do |error|
        error_fields = field_mapping_for_errors.select { |_key, values| values.include?(error["field"].to_sym) }.keys
        error_fields = [error["field"]] if error_fields.empty?
        error_fields.each do |error_field|
          LogValidation.create!(log_type:,
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

    Rails.logger.info("******** described #{meth} for #{form.start_date.year} ********")
  end

  def save_soft_validation(form, page, validation_descriptions, log_type)
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
      Rails.logger.error("No validation description found for #{page.questions.first.id}")
      return
    end

    if LogValidation.where(validation_name: validation_depends_on_hash.keys.first, field: page_the_validation_applied_to.questions.first.id, from: form.start_date, log_type:).exists?
      Rails.logger.info("Validation #{validation_depends_on_hash.keys.first} already exists for #{page_the_validation_applied_to.questions.first.id} for start year #{form.start_date.year}")
      return
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
    LogValidation.create!(log_type:,
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

  TRANSLATION_FILE_MAPPINGS = {
    "property" => "property_information",
  }.freeze

  def translation_file_path(form, file_path)
    return "./config/locales/validations/#{form.type}/#{form.start_date.year}/bulk_upload.en.yml" if file_path.include?("bulk_upload")
      
    file_name = file_path.split("/").last.gsub("_validations.rb", "")
    translation_file_name = TRANSLATION_FILE_MAPPINGS[file_name] || file_name

    file_path = "./config/locales/validations/#{form.type}/#{translation_file_name}.en.yml"
    return file_path if File.exist?(file_path)

    shared_file_path = "./config/locales/validations/#{translation_file_name}.en.yml"
    return shared_file_path if File.exist?(shared_file_path)
    
    "./config/locales/en.yml"
  end
end
