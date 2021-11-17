module DateValidations
  def validate_property_major_repairs(record)
    if record.mrcdate.is_a?(ActiveSupport::TimeWithZone) && record.mrcdate.year.zero?
      record.errors.add :mrcdate, "Please enter a valid date"
    end
  end
end
