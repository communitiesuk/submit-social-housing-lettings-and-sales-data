module Validations::DateValidations
  def validate_property_major_repairs(record)
    date_valid?("mrcdate", record)
    if record["startdate"].present? && record["mrcdate"].present? && record["startdate"] < record["mrcdate"]
      record.errors.add :mrcdate, I18n.t("validations.property.mrcdate.before_tenancy_start")
    end

    if is_rsnvac_first_let?(record) && record["mrcdate"].present?
      record.errors.add :mrcdate, I18n.t("validations.property.mrcdate.not_first_let")
    end

    if record["mrcdate"].present? && record["startdate"].present? && record["startdate"].to_date - record["mrcdate"].to_date > 730
      record.errors.add :mrcdate, I18n.t("validations.property.mrcdate.730_days_before_tenancy_start")
    end
  end

  def validate_property_void_date(record)
    if record["property_void_date"].present? && record["startdate"].present? && record["startdate"].to_date - record["property_void_date"].to_date > 3650
      record.errors.add :property_void_date, I18n.t("validations.property.void_date.ten_years_before_tenancy_start")
    end

    if record["property_void_date"].present? && record["startdate"].present? && record["startdate"].to_date < record["property_void_date"].to_date
      record.errors.add :property_void_date, I18n.t("validations.property.void_date.before_tenancy_start")
    end

    if record["property_void_date"].present? && record["mrcdate"].present? && record["mrcdate"].to_date < record["property_void_date"].to_date
      record.errors.add :property_void_date, I18n.t("validations.property.void_date.after_mrcdate")
    end
  end

  def validate_startdate(record)
    return unless record.startdate && date_valid?("startdate", record)

    if record.startdate < Time.zone.local(2021, 0o4, 0o1) || record.startdate > Time.zone.local(2023, 0o6, 30)
      record.errors.add :startdate, I18n.t("validations.date.outside_collection_window")
    end
  end

  def validate_sale_completion_date(record)
    date_valid?("sale_completion_date", record)
  end

private

  def date_valid?(question, record)
    if record[question].is_a?(ActiveSupport::TimeWithZone) && record[question].year.zero?
      record.errors.add question, I18n.t("validations.date.invalid_date")
      false
    else
      true
    end
  end

  def is_rsnvac_first_let?(record)
    record["rsnvac"] == "First let of new-build property" ||
      record["rsnvac"] == "First let of conversion, rehabilitation or acquired property" ||
      record["rsnvac"] == "First let of leased property"
  end
end
