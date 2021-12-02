module Validations::PropertyValidations
  # Validations methods need to be called 'validate_<page_name>' to run on model save
  # or 'validate_' to run on submit as well
  def validate_property_number_of_times_relet(record)
    if record.offered && !/^[1-9]$|^0[1-9]$|^1[0-9]$|^20$/.match?(record.offered.to_s)
      record.errors.add :offered, "Property number of times relet must be between 0 and 20"
    end
  end
end
