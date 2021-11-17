module DateValidations
  def validate_property_major_repairs(record)
    date_valid?("mrcdate", record)
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
end
