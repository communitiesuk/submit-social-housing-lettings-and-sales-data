module Validations::LocalAuthorityValidations

  POSTCODE_REGEXP = Validations::PropertyValidations::POSTCODE_REGEXP

  def validate_previous_accommodation_postcode(record)
    postcode = record.previous_postcode
    if postcode.present? && !postcode.match(POSTCODE_REGEXP)
      error_message = "Enter a postcode in the correct format, for example AA1 1AA"
      record.errors.add :previous_postcode, error_message
    end
  end
end
