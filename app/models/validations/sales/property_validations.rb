module Validations::Sales::PropertyValidations
  def validate_postcodes_match_if_discounted_ownership(record)
    return unless record.saledate && !record.form.start_year_after_2024?
    return unless record.ppostcode_full.present? && record.postcode_full.present?

    if record.discounted_ownership_sale? && record.ppostcode_full != record.postcode_full
      joint_purchase_id = record.joint_purchase? ? "joint_purchase" : "not_joint_purchase"
      record.errors.add :postcode_full, I18n.t("validations.sales.property_information.postcode_full.postcode_must_match_previous.#{joint_purchase_id}")
      record.errors.add :ppostcode_full, I18n.t("validations.sales.property_information.ppostcode_full.postcode_must_match_previous.#{joint_purchase_id}")
      record.errors.add :ownershipsch, I18n.t("validations.sales.property_information.ownershipsch.postcode_must_match_previous.#{joint_purchase_id}")
      record.errors.add :uprn, I18n.t("validations.sales.property_information.uprn.postcode_must_match_previous.#{joint_purchase_id}")
    end
  end

  def validate_bedsit_number_of_beds(record)
    return unless record.proptype.present? && record.beds.present?

    if record.is_bedsit? && record.beds > 1
      record.errors.add :proptype, I18n.t("validations.sales.property_information.proptype.bedsits_have_max_one_bedroom")
      record.errors.add :beds, I18n.t("validations.sales.property_information.beds.bedsits_have_max_one_bedroom")
    end
  end

  def validate_uprn(record)
    return unless record.uprn

    return if record.uprn.match?(/^[0-9]{1,12}$/)

    record.errors.add :uprn, I18n.t("validations.sales.property_information.uprn.invalid")
  end
end
