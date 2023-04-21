module Validations::LocalAuthorityValidations
  def validate_previous_accommodation_postcode(record)
    postcode = record.ppostcode_full
    if record.previous_postcode_known? && (postcode.blank? || !postcode.match(POSTCODE_REGEXP))
      record.errors.add :ppostcode_full, I18n.t("validations.postcode")
      record.errors.add :ppcodenk, I18n.t("validations.postcode")
    end
  end
end
