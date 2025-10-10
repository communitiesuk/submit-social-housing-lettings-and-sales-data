module Validations::Sales::PropertyValidations
  def validate_postcodes_match_if_discounted_ownership(record)
    return unless record.saledate && !record.form.start_year_2024_or_later?
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

  def validate_property_postcode(record)
    postcode = record.postcode_full
    return unless postcode

    if record.postcode_known? && (postcode.blank? || !postcode.match(POSTCODE_REGEXP))
      error_message = I18n.t("validations.sales.property_information.postcode_full.invalid")
      record.errors.add :postcode_full, :wrong_format, message: error_message
    end
  end

  def validate_la_in_england(record)
    return unless record.form.start_year_2025_or_later? && record.la.present?
    return if record.la.in?(LocalAuthority.england.pluck(:code))

    record.errors.add :la, I18n.t("validations.sales.property_information.la.not_in_england")
    record.errors.add :postcode_full, I18n.t("validations.sales.property_information.postcode_full.not_in_england")
    record.errors.add :uprn, I18n.t("validations.sales.property_information.uprn.not_in_england")
    record.errors.add :uprn_confirmation, I18n.t("validations.sales.property_information.uprn_confirmation.not_in_england")
    record.errors.add :uprn_selection, I18n.t("validations.sales.property_information.uprn_selection.not_in_england")
    if record.uprn.present?
      record.errors.add :saledate, :skip_bu_error, message: I18n.t("validations.sales.property_information.saledate.address_not_in_england")
    else
      record.errors.add :saledate, :skip_bu_error, message: I18n.t("validations.sales.property_information.saledate.postcode_not_in_england")
    end
  end

  def validate_la_is_active(record)
    return unless record.form.start_year_2025_or_later? && record.la.present? && record.startdate.present?

    la = LocalAuthority.england.find_by(code: record.la)

    # will be caught by the not in england validation
    return if la.nil?
    # only compare end date if it exists
    return if record.startdate >= la.start_date && (la.end_date.nil? || record.startdate <= la.end_date)

    record.errors.add :la, I18n.t("validations.sales.property_information.la.la_not_valid_for_date", la: la.name)
    record.errors.add :postcode_full, I18n.t("validations.sales.property_information.postcode_full.la_not_valid_for_date", la: la.name)
    record.errors.add :uprn, I18n.t("validations.sales.property_information.uprn.la_not_valid_for_date", la: la.name)
    record.errors.add :uprn_confirmation, I18n.t("validations.sales.property_information.uprn_confirmation.la_not_valid_for_date", la: la.name)
    record.errors.add :uprn_selection, I18n.t("validations.sales.property_information.uprn_selection.la_not_valid_for_date", la: la.name)
    record.errors.add :saledate, :skip_bu_error, message: I18n.t("validations.sales.property_information.saledate.la_not_valid_for_date", la: la.name)
  end
end
