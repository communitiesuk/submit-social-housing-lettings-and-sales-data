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
      validate_person_age_and_relationship_matches_economic_status(record, n)
    end
    shared_validate_partner_count(record, 6)
  end

private

  def validate_person_age_matches_relationship(record, person_num)
    age = record.public_send("age#{person_num}")
    relationship = record.public_send("relat#{person_num}")
    return unless age && relationship

    if age < 16 && person_is_partner?(relationship)
      record.errors.add "age#{person_num}", I18n.t("validations.household.age.partner_under_16")
      record.errors.add "relat#{person_num}", I18n.t("validations.household.relat.partner_under_16")
    elsif age >= 20 && person_is_child?(relationship)
      record.errors.add "age#{person_num}", I18n.t("validations.household.age.child_over_20")
      record.errors.add "relat#{person_num}", I18n.t("validations.household.relat.child_over_20")
    end
  end

  def validate_person_age_and_relationship_matches_economic_status(record, person_num)
    age = record.public_send("age#{person_num}")
    economic_status = record.public_send("ecstat#{person_num}")
    relationship = record.public_send("relat#{person_num}")
    return unless age && economic_status && relationship

    if age >= 16 && age <= 19 && person_is_fulltime_student?(economic_status) && !person_is_child?(relationship)
      record.errors.add "age#{person_num}", I18n.t("validations.household.age.student_16_19")
      record.errors.add "ecstat#{person_num}", I18n.t("validations.household.ecstat.student_16_19")
      record.errors.add "relat#{person_num}", I18n.t("validations.household.relat.student_16_19")
    end
  end

  def person_is_partner?(relationship)
    relationship == "P"
  end

  def person_is_fulltime_student?(economic_status)
    economic_status == 7
  end

  def person_economic_status_refused?(economic_status)
    economic_status == 10
  end

  def person_is_child?(relationship)
    relationship == "C"
  end
end
