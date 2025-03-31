module Validations::LocalAuthorityValidations
  def validate_previous_accommodation_postcode(record)
    postcode = record.ppostcode_full
    return unless postcode

    if record.previous_postcode_known? && (postcode.blank? || !postcode.match(POSTCODE_REGEXP))
      error_message = I18n.t("validations.postcode")
      record.errors.add :ppostcode_full, :wrong_format, message: error_message
    end
  end
end
