module Validations::Sales::PropertyValidations
  def validate_postcodes_match_if_discounted_ownership(record)
    return unless record.ppostcode_full.present? && record.postcode_full.present?

    if record.discounted_ownership_sale? && record.ppostcode_full != record.postcode_full
      record.errors.add :postcode_full, I18n.t("validations.property.postcode.must_match_previous")
      record.errors.add :ppostcode_full, I18n.t("validations.property.postcode.must_match_previous")
    end
  end
end
