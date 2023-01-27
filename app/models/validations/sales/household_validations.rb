module Validations::Sales::HouseholdValidations
  include Validations::SharedValidations

  def validate_number_of_other_people_living_in_the_property(record)
    return if record.hholdcount.blank?

    unless record.hholdcount >= 0 && record.hholdcount <= 4
      record.errors.add :hholdcount, I18n.t("validations.numeric.within_range", field: "Number of other people living in the property", min: 0, max: 4)
    end
  end

  def validate_household_number_of_other_members(record)
    (2..6).each do |n|
      validate_person_age_matches_relationship(record, n)
      validate_person_age_and_relationship_matches_economic_status(record, n)
      validate_person_age_matches_economic_status(record, n)
    end
    shared_validate_partner_count(record, 6)
  end

  def validate_buyers_age_for_old_persons_shared_ownership(record)
    if record.old_persons_shared_ownership?
      if record.joint_purchase? && ages_unknown_or_under_64?(record, [1, 2])
        record.errors.add :age1, I18n.t("validations.household.old_persons_shared_ownership")
        record.errors.add :age2, I18n.t("validations.household.old_persons_shared_ownership")
        record.errors.add :type, I18n.t("validations.household.old_persons_shared_ownership")
      end
      if record.not_joint_purchase? && ages_unknown_or_under_64?(record, [1])
        record.errors.add :age1, I18n.t("validations.household.old_persons_shared_ownership")
        record.errors.add :type, I18n.t("validations.household.old_persons_shared_ownership")
      end
    end
  end

  def validate_previous_postcode(record)
    return unless record.postcode_full && record.ppostcode_full && record.discounted_ownership_sale?

    unless record.postcode_full == record.ppostcode_full
      record.errors.add :postcode_full, I18n.t("validations.household.postcode.discounted_ownership")
      record.errors.add :ppostcode_full, I18n.t("validations.household.postcode.discounted_ownership")
    end
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

    age_between_16_19 = age.between?(16, 19)
    student = person_is_fulltime_student?(economic_status)
    child = person_is_child?(relationship)

    if age_between_16_19 && student && !child
      record.errors.add "age#{person_num}", I18n.t("validations.household.age.student_16_19.cannot_be_16_19.student_not_child")
      record.errors.add "ecstat#{person_num}", I18n.t("validations.household.ecstat.student_16_19.cannot_be_student.16_19_not_child")
      record.errors.add "relat#{person_num}", I18n.t("validations.household.relat.student_16_19.must_be_child")
    end

    if age_between_16_19 && !student && child
      record.errors.add "age#{person_num}", I18n.t("validations.household.age.student_16_19.cannot_be_16_19.child_not_student")
      record.errors.add "ecstat#{person_num}", I18n.t("validations.household.ecstat.student_16_19.must_be_student")
      record.errors.add "relat#{person_num}", I18n.t("validations.household.relat.student_16_19.cannot_be_child.16_19_not_student")
    end

    if !age_between_16_19 && student && child
      record.errors.add "age#{person_num}", I18n.t("validations.household.age.student_16_19.must_be_16_19")
      record.errors.add "ecstat#{person_num}", I18n.t("validations.household.ecstat.student_16_19.cannot_be_student.child_not_16_19")
      record.errors.add "relat#{person_num}", I18n.t("validations.household.relat.student_16_19.cannot_be_child.student_not_16_19")
    end
  end

  def validate_person_age_matches_economic_status(record, person_num)
    age = record.public_send("age#{person_num}")
    economic_status = record.public_send("ecstat#{person_num}")
    return unless age && economic_status

    if age < 16 && !tenant_is_economic_child?(economic_status)
      record.errors.add "ecstat#{person_num}", I18n.t("validations.household.ecstat.child_under_16", person_num:)
      record.errors.add "age#{person_num}", I18n.t("validations.household.age.child_under_16", person_num:)
    end
    if tenant_is_economic_child?(economic_status) && age > 16
      record.errors.add "ecstat#{person_num}", I18n.t("validations.household.ecstat.child_over_16", person_num:)
      record.errors.add "age#{person_num}", I18n.t("validations.household.age.child_over_16", person_num:)
    end
  end

  def person_is_partner?(relationship)
    relationship == "P"
  end

  def person_is_fulltime_student?(economic_status)
    economic_status == 7
  end

  def person_is_child?(relationship)
    relationship == "C"
  end

  def tenant_is_economic_child?(economic_status)
    economic_status == 9
  end

  def ages_unknown_or_under_64?(record, person_indexes)
    person_indexes.all? { |person_num| record["age#{person_num}"].present? && record["age#{person_num}"] < 64 || record["age#{person_num}_known"] == 1 }
  end
end
