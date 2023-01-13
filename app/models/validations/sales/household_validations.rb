module Validations::Sales::HouseholdValidations
  include Validations::SharedValidations

  def validate_number_of_other_people_living_in_the_property(record)
    return if record.hholdcount.blank?

    unless record.hholdcount >= 0 && record.hholdcount <= 4
      record.errors.add :hholdcount, I18n.t("validations.numeric.valid", field: "Number of other people living in the property", min: 0, max: 4)
    end
  end

  def validate_household_number_of_other_members(record)
    (2..6).each do |n|
      validate_person_age_matches_relationship(record, n)
      shared_validate_person_age_and_relationship_matches_economic_status(record, n)
    end
    shared_validate_partner_count(record, 6)
  end

private

  def validate_person_age_matches_relationship(record, person_num)
    age = record.public_send("age#{person_num}")
    relationship = record.public_send("relat#{person_num}")
    return unless age && relationship

    if age < 16 && person_is_partner?(relationship)
      record.errors.add "relat#{person_num}", I18n.t("validations.household.relat.partner_under_16", person_num:)
    elsif age >= 20 && person_is_child?(relationship)
      record.errors.add "relat#{person_num}", I18n.t("validations.household.relat.child_over_20", person_num:)
    end
  end

  def person_is_partner?(relationship)
    relationship == "P"
  end

  def person_is_child?(relationship)
    relationship == "C"
  end
end
