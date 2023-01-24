module Validations::Sales::SaleInformationValidations
  def validate_deposit_range(record)
    return if record.deposit.blank?

    unless record.deposit >= 0 && record.deposit <= 999_999
      record.errors.add :deposit, "Cash deposit must be £0 - £999,999"
    end
  end

  def validate_practical_completion_date_before_saledate(record)
    return if record.saledate.blank? || record.hodate.blank?

    unless record.saledate > record.hodate
      record.errors.add :hodate, "Practical completion or handover date must be before exchange date"
    end
  end

  def validate_years_living_in_property_before_purchase(record)
    return unless record.proplen && record.proplen.nonzero?

    case record.type
    when 18
      record.errors.add :type, I18n.t("validations.sale_information.proplen.social_homebuy")
      record.errors.add :proplen, I18n.t("validations.sale_information.proplen.social_homebuy")
    when 28, 29
      record.errors.add :type, I18n.t("validations.sale_information.proplen.rent_to_buy")
      record.errors.add :proplen, I18n.t("validations.sale_information.proplen.rent_to_buy")
    end
  end
end
