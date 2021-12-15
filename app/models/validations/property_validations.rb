module Validations::PropertyValidations
  # Validations methods need to be called 'validate_<page_name>' to run on model save
  # or 'validate_' to run on submit as well
  include Constants::CaseLog
  def validate_property_number_of_times_relet(record)
    if record.offered && !/^[1-9]$|^0[1-9]$|^1[0-9]$|^20$/.match?(record.offered.to_s)
      record.errors.add :offered, "Property number of times relet must be between 0 and 20"
    end
  end

  def validate_la(record)
    if record.la.present? && !LONDON_BOROUGHS.include?(record.la) && (record.rent_type == "London Affordable rent" || record.rent_type == "London living rent")
      record.errors.add :la, "Local authority has to be in London"
    end
  end

  def validate_unitletas(record)
    if record.unitletas.present? && (record.rsnvac == "First let of newbuild property" || record.rsnvac == "First let of conversion/rehabilitation/acquired property" || record.rsnvac == "First let of leased property")
      record.errors.add :unitletas, "Can not be completed if it is the first let of the property"
    end
  end
end
