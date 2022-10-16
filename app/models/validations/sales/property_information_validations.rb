module Validations::Sales::PropertyInformationValidations
  # Error must be defined for both :proptype and :beds
  # to ensure the appropriate error is shown when selecting
  # property type and number of rooms
  def validate_bedsit_has_one_room(record)
    if record.bedsit? && record.beds > 1
      record.errors.add(:proptype, :bedsit_max)
      record.errors.add(:beds, :bedsit_max)
    end
  end
end
