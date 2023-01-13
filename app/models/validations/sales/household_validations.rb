module Validations::Sales::HouseholdValidations
  include Validations::SharedValidations

  def validate_number_of_other_people_living_in_the_property(record)
    return if record.hholdcount.blank?

    unless record.hholdcount >= 0 && record.hholdcount <= 4
      record.errors.add :hholdcount, I18n.t("validations.numeric.valid", field: "Number of other people living in the property", min: 0, max: 4)
    end
  end

  def validate_household_number_of_other_members(record)
    shared_validate_household_number_of_other_members(record, 6)
  end
end
