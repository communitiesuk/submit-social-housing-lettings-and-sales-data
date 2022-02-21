module Validations::SubmissionValidations
  # Validations methods need to be called 'validate_<page_name>' to run on model save
  # or 'validate_' to run on submit as well

  def validate_declaration(record)
    if record.declaration&.zero?
      record.errors.add :declaration, I18n.t("validations.declaration.missing")
    end
  end
end
