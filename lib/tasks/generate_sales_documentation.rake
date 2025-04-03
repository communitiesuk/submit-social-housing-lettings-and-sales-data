namespace :generate_sales_documentation do
  desc "Generate documentation for hard sales validations"
  task :describe_sales_validations, %i[year] => :environment do |_task, args|
    form_year = args[:year]&.to_i
    raise "Usage: rake generate_sales_documentation:describe_sales_validations['year']" if form_year.blank?

    form = FormHandler.instance.forms[FormHandler.instance.form_name_from_start_year(form_year, "sales")]
    raise "No form found for given year" if form.blank?

    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

    documentation_generator = DocumentationGenerator.new
    validation_classes = [Validations::Sales::SetupValidations,
                          Validations::Sales::HouseholdValidations,
                          Validations::Sales::PropertyValidations,
                          Validations::Sales::FinancialValidations,
                          Validations::Sales::SaleInformationValidations,
                          Validations::SharedValidations,
                          Validations::LocalAuthorityValidations]
    all_validation_methods, all_helper_methods = documentation_generator.validation_and_helper_methods(validation_classes)
    documentation_generator.describe_hard_validations(client, form, all_validation_methods, all_helper_methods, "sales")
  end

  desc "Generate documentation for soft sales validations"
  task :describe_soft_sales_validations, %i[year] => :environment do |_task, args|
    form_year = args[:year]&.to_i
    raise "Usage: rake generate_sales_documentation:describe_soft_sales_validations['year']" if form_year.blank?

    form = FormHandler.instance.forms[FormHandler.instance.form_name_from_start_year(form_year, "sales")]
    raise "No form found for given year" if form.blank?

    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
    documentation_generator = DocumentationGenerator.new
    all_helper_methods, all_validation_methods = documentation_generator.get_soft_sales_methods

    documentation_generator.describe_soft_validations(client, form, all_validation_methods, all_helper_methods, "sales")
  end

  desc "Generate documentation for hard bu sales validations"
  task :describe_bu_sales_validations, %i[year] => :environment do |_task, args|
    form_year = args[:year]&.to_i
    raise "Usage: rake generate_sales_documentation:describe_bu_sales_validations['year']" if form_year.blank?

    form = FormHandler.instance.forms[FormHandler.instance.form_name_from_start_year(form_year, "sales")]
    raise "No form found for given year" if form.blank?

    row_parser_class = "BulkUpload::Sales::Year#{form_year}::RowParser".constantize
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
    all_validation_methods = row_parser_class.private_instance_methods.select { |method| method.starts_with?("validate_") }
    all_helper_methods = row_parser_class.private_instance_methods(false) +  row_parser_class.instance_methods(false) - all_validation_methods
    field_mapping_for_errors = row_parser_class.new.send("field_mapping_for_errors")

    DocumentationGenerator.new.describe_bu_validations(client, form, row_parser_class, all_validation_methods, all_helper_methods, field_mapping_for_errors, "sales")
  end

  desc "Generate documentation for sales numeric validations"
  task :add_numeric_sales_validations, %i[year] => :environment do |_task, args|
    form_year = args[:year]&.to_i
    raise "Usage: rake generate_sales_documentation:add_numeric_sales_validations['year']" if form_year.blank?

    form = FormHandler.instance.forms[FormHandler.instance.form_name_from_start_year(form_year, "sales")]
    raise "No form found for given year" if form.blank?

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

      if LogValidation.where(validation_name:, field:, log_type: "sales").exists?

        Rails.logger.info("Validation #{validation_name} already exists for #{field}")
        next
      end

      LogValidation.create!(log_type: "sales",
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
