module Validations::Sales::PropertyInformationValidations
  # CLDC-858
  def validate_bedsit_has_one_room(record)
    if record.bedsit? && record.beds > 1
      record.errors.add(:beds, :non_bedsit_max)
    end
  end
end
