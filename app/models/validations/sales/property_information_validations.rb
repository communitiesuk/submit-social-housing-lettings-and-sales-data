module Validations::Sales::PropertyInformationValidations
  def validate_property_postcode(record)
    postcode = record.postcode_full

    if record.postcode_known? && (postcode.blank? || !postcode.match(POSTCODE_REGEXP))
      error_message = I18n.t("validations.postcode")
      record.errors.add :postcode_full, error_message
    end
  end
end
