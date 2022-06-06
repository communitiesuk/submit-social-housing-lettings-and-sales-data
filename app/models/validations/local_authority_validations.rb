module Validations::LocalAuthorityValidations
  POSTCODE_REGEXP = Validations::PropertyValidations::POSTCODE_REGEXP

  def validate_previous_accommodation_postcode(record)
    postcode = record.ppostcode_full
    if record.previous_postcode_known? && (postcode.blank? || !postcode.match(POSTCODE_REGEXP))
      error_message = I18n.t("validations.postcode")
      record.errors.add :ppostcode_full, error_message
    end
  end
end
