module Validations::SalesValidations
  # Validations methods need to be called 'validate_<page_name>' to run on model save
  # or 'validate_' to run on submit as well

  def validate_beds(record)
    # Integer(record.offered_before_type_cast)
    if record.beds.present? && !record.beds.to_i.between?(1, 9)
      record.errors.add :beds, "Number of bedrooms must be between 1 and 9"
    end 
  end

  def validate_beds_proptype(record)
      # Integer(record.offered_before_type_cast)
    if record.beds.present? && record.beds.to_i != 1 && record.proptype == 2
    record.errors.add :beds, "A bedsit can not have more than 1 bedroom"
    record.errors.add :proptype, "A bedsit can not have more than 1 bedroom"
    end
  end
end
