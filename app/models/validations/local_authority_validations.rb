module Validations::LocalAuthorityValidations
  include Constants::CaseLog
  POSTCODE_REGEXP = Validations::PropertyValidations::POSTCODE_REGEXP

  def validate_previous_accommodation_postcode(record)
    postcode = record.previous_postcode
    if record.previous_postcode_known == "Yes" && (postcode.blank? || !postcode.match(POSTCODE_REGEXP))
      error_message = I18n.t("validations.postcode")
      record.errors.add :previous_postcode, error_message
    end
  end
end
