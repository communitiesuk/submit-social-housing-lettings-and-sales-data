module Validations::DateValidations
  def validate_property_major_repairs(record)
    date_valid?("mrcdate", record)
    if record["startdate"].present? && record["mrcdate"].present? && record["startdate"] < record["mrcdate"]
      record.errors.add :mrcdate, "Major repairs date must be before the tenancy start date"
    end

    if is_rsnvac_first_let?(record) && record["mrcdate"].present?
      record.errors.add :mrcdate, "Major repairs date must not be completed if the tenancy is first let"
    end

    if record["mrcdate"].present? && record["startdate"].present? && record["startdate"].to_date - record["mrcdate"].to_date > 730
      record.errors.add :mrcdate, "Major repairs cannot be more than 730 days before the tenancy start date"
    end
  end

  def validate_property_void_date(record)
    if record["property_void_date"].present? && record["startdate"].present? && record["startdate"].to_date - record["property_void_date"].to_date > 3650
      record.errors.add :property_void_date, "Void date cannot be more than 730 days before the tenancy start date"
    end

    if record["property_void_date"].present? && record["startdate"].present? && record["startdate"].to_date < record["property_void_date"].to_date
      record.errors.add :property_void_date, "Void date must be before the tenancy start date"
    end

    if record["property_void_date"].present? && record["mrcdate"].present? && record["mrcdate"].to_date < record["property_void_date"].to_date
      record.errors.add :property_void_date, "Void date must be after the major repair date if a major repair date has been provided"
    end
  end

  def validate_startdate(record)
    date_valid?("startdate", record)
  end

  def validate_sale_completion_date(record)
    date_valid?("sale_completion_date", record)
  end

private

  def date_valid?(question, record)
    if record[question].is_a?(ActiveSupport::TimeWithZone) && record[question].year.zero?
      record.errors.add question, "Please enter a valid date"
    end
  end

  def is_rsnvac_first_let?(record)
    record["rsnvac"] == "First let of newbuild property" ||
      record["rsnvac"] == "First let of conversion/rehabilitation/acquired property" ||
      record["rsnvac"] == "First let of leased property"
  end
end
