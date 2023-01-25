module Validations::Sales::SaleInformationValidations
  def validate_deposit_range(record)
    return if record.deposit.blank?

    unless record.deposit >= 0 && record.deposit <= 999_999
      record.errors.add :deposit, "Cash deposit must be £0 - £999,999"
    end
  end

  def validate_practical_completion_date_before_exdate(record)
    return if record.exdate.blank? || record.hodate.blank?

    unless record.exdate > record.hodate
      record.errors.add :exdate, I18n.t("validations.sale_information.handover_exchange.exchange_after_handover")
      record.errors.add :hodate,I18n.t("validations.sale_information.handover_exchange.exchange_after_handover")
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
