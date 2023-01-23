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
      record.errors.add :type, "Social HomeBuy buyers should not have lived here before"
      record.errors.add :proplen, "Social HomeBuy or Rent to Buy buyers should not have lived here before"
    when 28, 29
      record.errors.add :type, "Rent to Buy buyers should not have lived here before"
      record.errors.add :proplen, "Rent to Buy buyers should not have lived here before"
    end
  end
end
