module Validations::Sales::SaleInformationValidations
  def validate_deposit_range(record)
    return if record.deposit.blank?

    unless record.deposit >= 0 && record.deposit <= 999_999
      record.errors.add :deposit, "Cash deposit must be £0 - £999,999"
    end
  end

  def validate_pratical_completion_date_before_saledate(record)
    return if record.saledate.blank? || record.hodate.blank?

    unless record.saledate > record.hodate
      record.errors.add :hodate, "Practical completion or handover date must be before exchange date"
    end
  end

  def validate_exchange_date(record)
    return unless record.exdate && record.saledate

    record.errors.add(:exdate, I18n.t("validations.sale_information.exdate.must_be_before_saledate")) if record.exdate > record.saledate

    return if (record.saledate.to_date - record.exdate.to_date).to_i / 365 < 1

    record.errors.add(:exdate, I18n.t("validations.sale_information.exdate.must_be_less_than_1_year_from_saledate")) if record.exdate < record.saledate
  end

  def validate_previous_property_unit_type(record)
    return unless record.fromprop && record.frombeds

    if record.frombeds != 1 && record.fromprop == 2
      record.errors.add :frombeds, I18n.t("validations.sale_information.previous_property_beds.property_type_bedsit")
      record.errors.add :fromprop, I18n.t("validations.sale_information.previous_property_type.property_type_bedsit")
    end
  end
end
