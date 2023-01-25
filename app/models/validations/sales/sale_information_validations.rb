module Validations::Sales::SaleInformationValidations
  def validate_pratical_completion_date_before_saledate(record)
    return if record.saledate.blank? || record.hodate.blank?

    unless record.saledate > record.hodate
      record.errors.add :hodate, "Practical completion or handover date must be before exchange date"
    end
  end

  def validate_exchange_and_completion_date(record)
    return unless record.exdate && record.saledate

    if record.exdate > record.saledate
      record.errors.add :exdate, I18n.t("validations.sale_information.completion_exchange.exchange_before_completion")
      record.errors.add :saledate, I18n.t("validations.sale_information.completion_exchange.completion_after_exchange")
    end

    if record.exdate < record.saledate - 1.year
      record.errors.add :exdate, I18n.t("validations.sale_information.completion_exchange.exchange_after_one_year_before_completion")
      record.errors.add :saledate, I18n.t("validations.sale_information.completion_exchange.completion_before_one_year_after_exchange")
    end
  end

  def validate_previous_property_unit_type(record)
    return unless record.fromprop && record.frombeds

    if record.frombeds != 1 && record.fromprop == 2
      record.errors.add :frombeds, I18n.t("validations.sale_information.previous_property_beds.property_type_bedsit")
      record.errors.add :fromprop, I18n.t("validations.sale_information.previous_property_type.property_type_bedsit")
    end
  end
end
