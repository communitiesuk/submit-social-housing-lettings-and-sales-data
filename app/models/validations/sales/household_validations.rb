module Validations::Sales::HouseholdValidations
  include Validations::SharedValidations

  def validate_household_number_of_other_members(record)
    (2..6).each do |n|
      validate_person_age_matches_relationship(record, n)
      validate_person_age_and_relationship_matches_economic_status(record, n)
      validate_person_age_matches_economic_status(record, n)
      validate_child_12_years_younger(record, n)
    end
    shared_validate_partner_count(record, 6)
  end

  def validate_previous_postcode(record)
    return unless record.postcode_full && record.ppostcode_full && record.discounted_ownership_sale?

    unless record.postcode_full == record.ppostcode_full
      record.errors.add :postcode_full, :postcodes_not_matching, message: I18n.t("validations.household.postcode.discounted_ownership")
      record.errors.add :ppostcode_full, :postcodes_not_matching, message: I18n.t("validations.household.postcode.discounted_ownership")
    end
  end

  def validate_buyers_living_in_property(record)
    return unless record.form.start_date.year >= 2023

    if record.buyers_will_live_in? && record.buyer_one_will_not_live_in_property? && record.buyer_two_will_not_live_in_property?
      record.errors.add :buylivein, I18n.t("validations.household.buylivein.buyers_will_live_in_property_values_inconsistent_setup")
      record.errors.add :buy1livein, I18n.t("validations.household.buylivein.buyers_will_live_in_property_values_inconsistent")
      record.errors.add :buy2livein, I18n.t("validations.household.buylivein.buyers_will_live_in_property_values_inconsistent")
    end
  end

  def validate_buyer1_previous_tenure(record)
    return unless record.saledate && record.form.start_year_after_2024?
    return unless record.discounted_ownership_sale? && record.prevten

    if [3, 4, 5, 6, 7, 9, 0].include?(record.prevten)
      record.errors.add :prevten, I18n.t("validations.household.prevten.invalid_for_discounted_sale")
      record.errors.add :ownershipsch, I18n.t("validations.household.prevten.invalid_for_discounted_sale")
    end
  end

private

  def validate_person_age_matches_relationship(record, person_num)
    age = record.public_send("age#{person_num}")
    relationship = record.public_send("relat#{person_num}")
    return unless age && relationship

    if age < 16 && !relationship_is_child_other_or_refused?(relationship)
      record.errors.add "age#{person_num}", I18n.t("validations.household.age.child_under_16_relat_sales", person_num:)
      record.errors.add "relat#{person_num}", I18n.t("validations.household.relat.child_under_16_sales", person_num:)
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
    economic_status_refused = person_economic_status_refused?(economic_status)
    child = person_is_child?(relationship)

    if age_between_16_19 && !(student || economic_status_refused) && child
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

    if age < 16 && !economic_status_is_child_other_or_refused?(economic_status)
      record.errors.add "ecstat#{person_num}", I18n.t("validations.household.ecstat.child_under_16", person_num:)
      record.errors.add "age#{person_num}", I18n.t("validations.household.age.child_under_16_ecstat", person_num:)
    end
    if person_is_economic_child?(economic_status) && age > 16
      record.errors.add "ecstat#{person_num}", I18n.t("validations.household.ecstat.child_over_16", person_num:)
      record.errors.add "age#{person_num}", I18n.t("validations.household.age.child_over_16", person_num:)
    end
  end

  def validate_child_12_years_younger(record, person_num)
    buyer_1_age = record.public_send("age1")
    person_age = record.public_send("age#{person_num}")
    relationship = record.public_send("relat#{person_num}")
    return unless buyer_1_age && person_age && relationship

    if person_age > buyer_1_age - 12 && person_is_child?(relationship)
      record.errors.add "age1", I18n.t("validations.household.age.child_12_years_younger")
      record.errors.add "age#{person_num}", I18n.t("validations.household.age.child_12_years_younger")
      record.errors.add "relat#{person_num}", I18n.t("validations.household.age.child_12_years_younger")
    end
  end

  def person_is_fulltime_student?(economic_status)
    economic_status == 7
  end

  def person_is_economic_child?(economic_status)
    economic_status == 9
  end

  def person_economic_status_refused?(economic_status)
    economic_status == 10
  end

  def economic_status_is_child_other_or_refused?(economic_status)
    [9, 0, 10].include?(economic_status)
  end

  def person_is_partner?(relationship)
    relationship == "P"
  end

  def person_is_child?(relationship)
    relationship == "C"
  end

  def relationship_is_child_other_or_refused?(relationship)
    %w[C X R].include?(relationship)
  end
end
