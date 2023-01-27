module Validations::Sales::PropertyValidations
  def validate_postcodes_match_if_discounted_ownership(record)
    return unless record.ppostcode_full.present? && record.postcode_full.present?

    if record.discounted_ownership_sale? && record.ppostcode_full != record.postcode_full
      record.errors.add :postcode_full, I18n.t("validations.property.postcode.must_match_previous")
      record.errors.add :ppostcode_full, I18n.t("validations.property.postcode.must_match_previous")
    end
  end

  def validate_bedroom_number(record)
    return unless record.beds

    unless record.beds.between?(1, 9)
      record.errors.add :beds, I18n.t("validations.property.beds.1_9")
    end
  end
end
