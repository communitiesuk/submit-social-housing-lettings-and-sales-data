namespace :generate_lettings_documentation do
  desc "Generate documentation for hard lettings validations"
  task describe_lettings_validations: :environment do
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
    include Validations::SetupValidations
    include Validations::HouseholdValidations
    include Validations::PropertyValidations
    include Validations::FinancialValidations
    include Validations::TenancyValidations
    include Validations::DateValidations
    include Validations::LocalAuthorityValidations
    all_validation_methods = public_methods.select { |method| method.starts_with?("validate_") }
    all_methods = [Validations::SetupValidations,
                   Validations::HouseholdValidations,
                   Validations::PropertyValidations,
                   Validations::FinancialValidations,
                   Validations::TenancyValidations,
                   Validations::DateValidations,
                   Validations::LocalAuthorityValidations].map { |x| x.instance_methods + x.private_instance_methods }.flatten
    all_helper_methods = all_methods - all_validation_methods

    DocumentationGenerator.new.describe_hard_validations(client, all_validation_methods, all_helper_methods, "lettings")
  end

  desc "Generate documentation for soft lettings validations"
  task describe_soft_lettings_validations: :environment do
    include Validations::SoftValidations

    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

    all_helper_methods = Validations::SoftValidations.private_instance_methods
    all_validation_methods = Validations::SoftValidations.instance_methods

    DocumentationGenerator.new.describe_soft_validations(client, all_validation_methods, all_helper_methods, "lettings")
  end

  desc "Generate documentation for hard bu lettings validations"
  task describe_bu_lettings_validations: :environment do
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

    [[FormHandler.instance.forms[FormHandler.instance.form_name_from_start_year(2023, "lettings")], BulkUpload::Lettings::Year2023::RowParser],
     [FormHandler.instance.forms[FormHandler.instance.form_name_from_start_year(2024, "lettings")], BulkUpload::Lettings::Year2024::RowParser]].each do |form, row_parser_class|
      all_validation_methods = row_parser_class.private_instance_methods.select { |method| method.starts_with?("validate_") }

      all_helper_methods = row_parser_class.private_instance_methods(false) +  row_parser_class.instance_methods(false) - all_validation_methods

      field_mapping_for_errors = row_parser_class.new.send("field_mapping_for_errors")
      DocumentationGenerator.new.describe_bu_validations(client, form, row_parser_class, all_validation_methods, all_helper_methods, field_mapping_for_errors, "lettings")
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

      error_message = I18n.t("validations.shared.numeric.above_min", field:, min:)
      validation_name = "minimum"
      validation_description = "Field value is lower than the minimum value"

      if min && max
        validation_name = "range"
        error_message = I18n.t("validations.shared.numeric.within_range", field:, min:, max:)
        validation_description = "Field value is lower than the minimum value or higher than the maximum value"
      end

      if LogValidation.where(validation_name:, field:, log_type: "lettings").exists?

        Rails.logger.info("Validation #{validation_name} already exists for #{field}")
        next
      end

      LogValidation.create!(log_type: "lettings",
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
