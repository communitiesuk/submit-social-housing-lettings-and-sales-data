module PropertyValidations
  # Validations methods need to be called 'validate_' to run on model save
  def validate_property_number_of_times_relet(record)
    if record.property_number_of_times_relet && !/^[1-9]$|^0[1-9]$|^1[0-9]$|^20$/.match?(record.property_number_of_times_relet.to_s)
      record.errors.add :property_number_of_times_relet, "Must be between 0 and 20"
    end
  end
end
