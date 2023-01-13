module Validations::Sales::PropertyValidations
  def validate_postcodes_match_if_discounted_ownership(record)
    return unless record.ppostcode_full.present? && record.postcode_full.present?

    if record.discounted_ownership_sale? && record.ppostcode_full != record.postcode_full
      record.errors.add :postcode_full, I18n.t("validations.property.postcode.must_match_previous")
      record.errors.add :ppostcode_full, I18n.t("validations.property.postcode.must_match_previous")
    end
  end

  def validate_property_unit_type(record)
    return if record.proptype.blank? || record.beds.blank?

    unless record.proptype != 2 || record.beds <= 1
      record.errors.add :proptype, I18n.t("validations.property.proptype.bedsits_have_max_one_bedroom")
    end
  end
end
