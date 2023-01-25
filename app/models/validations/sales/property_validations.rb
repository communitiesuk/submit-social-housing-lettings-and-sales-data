module Validations::Sales::PropertyValidations
  def validate_postcodes_match_if_discounted_ownership(record)
    return unless record.ppostcode_full.present? && record.postcode_full.present?

    if record.discounted_ownership_sale? && record.ppostcode_full != record.postcode_full
      record.errors.add :postcode_full, I18n.t("validations.property.postcode.must_match_previous")
      record.errors.add :ppostcode_full, I18n.t("validations.property.postcode.must_match_previous")
    end
  end

  def validate_bedsit_number_of_beds(record)
    return if record.is_bedsit?.blank? || record.beds.blank?

    if record.is_bedsit? && record.beds > 1
      record.errors.add :proptype, I18n.t("validations.property.proptype.bedsits_have_max_one_bedroom")
      record.errors.add :beds, I18n.t("validations.property.beds.bedsits_have_max_one_bedroom")
    end
  end
end
