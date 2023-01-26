module Validations::Sales::SaleInformationValidations
  def validate_practical_completion_date_before_saledate(record)
    return if record.saledate.blank? || record.hodate.blank?

    unless record.saledate > record.hodate
      record.errors.add :hodate, I18n.t("validations.sale_information.hodate.must_be_before_exdate")
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

  def validate_exchange_date(record)
    return unless record.exdate && record.saledate

    if record.exdate > record.saledate
      record.errors.add :exdate, I18n.t("validations.sale_information.exdate.must_be_before_saledate")
      record.errors.add :saledate, I18n.t("validations.sale_information.saledate.must_be_after_exdate")
    end

    if record.saledate - record.exdate >= 1.year
      record.errors.add :exdate, I18n.t("validations.sale_information.exdate.must_be_less_than_1_year_from_saledate")
      record.errors.add :saledate, I18n.t("validations.sale_information.saledate.must_be_less_than_1_year_from_exdate")
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
