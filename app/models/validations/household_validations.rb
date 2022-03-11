module Validations::HouseholdValidations
  include Validations::SharedValidations

  # Validations methods need to be called 'validate_<page_name>' to run on model save
  # or 'validate_' to run on submit as well
  def validate_reasonable_preference(record)
    if record.is_not_homeless? && record.rp_homeless == 1
      record.errors.add :reasonable_preference_reason, I18n.t("validations.household.reasonpref.not_homeless")
      record.errors.add :homeless, I18n.t("validations.household.homeless.reasonpref.not_homeless")
    end
    if !record.given_reasonable_preference? && [record.rp_homeless, record.rp_insan_unsat, record.rp_medwel, record.rp_hardship, record.rp_dontknow].any? { |a| a == 1 }
      record.errors.add :reasonable_preference_reason, I18n.t("validations.household.reasonable_preference_reason.reason_not_required")
    end
  end

  def validate_reason_for_leaving_last_settled_home(record)
    if record.reason == 32 && record.underoccupation_benefitcap != 4
      record.errors.add :underoccupation_benefitcap, I18n.t("validations.household.underoccupation_benefitcap.dont_know_required")
      record.errors.add :reason, I18n.t("validations.household.underoccupation_benefitcap.dont_know_required")
    end
    validate_other_field(record, 31, :reason, :other_reason_for_leaving_last_settled_home)
  end

  def validate_armed_forces(record)
    if (record.armed_forces_no? || record.armed_forces_refused?) && record.reservist.present?
      record.errors.add :reservist, I18n.t("validations.household.reservist.injury_not_required")
    end
    if !record.armed_forces_regular? && record.leftreg.present?
      record.errors.add :leftreg, I18n.t("validations.household.leftreg.question_not_required")
    end
  end

  def validate_pregnancy(record)
    if (record.has_pregnancy? || record.pregnancy_refused?) && !women_of_child_bearing_age_in_household(record)
      record.errors.add :preg_occ, I18n.t("validations.household.preg_occ.no_female")
    end
  end

  def validate_household_number_of_other_members(record)
    (2..8).each do |n|
      validate_person_age_matches_economic_status(record, n)
      validate_person_age_matches_relationship(record, n)
      validate_person_age_and_gender_match_economic_status(record, n)
      validate_person_age_and_relationship_matches_economic_status(record, n)
    end
    validate_partner_count(record)
  end

  def validate_person_1_economic(record)
    validate_person_age_matches_economic_status(record, 1)
  end

  def validate_accessibility_requirements(record)
    all_options = [record.housingneeds_a, record.housingneeds_b, record.housingneeds_c, record.housingneeds_f, record.housingneeds_g, record.housingneeds_h, record.accessibility_requirements_prefer_not_to_say]
    if all_options.count(1) > 1
      mobility_accessibility_options = [record.housingneeds_a, record.housingneeds_b, record.housingneeds_c]
      unless all_options.count(1) == 2 && record.housingneeds_f == 1 && mobility_accessibility_options.any? { |x| x == 1 }
        record.errors.add :accessibility_requirements, I18n.t("validations.household.housingneeds_a.one_or_two_choices")
      end
    end
  end

  def validate_previous_housing_situation(record)
    if record.is_relet_to_temp_tenant? && !record.previous_tenancy_was_temporary?
      record.errors.add :prevten, I18n.t("validations.household.prevten.non_temp_accommodation")
    end
  end

  def validate_referral(record)
    if record.is_internal_transfer? && record.is_assessed_homeless?
      record.errors.add :referral, I18n.t("validations.household.referral.assessed_homeless")
      record.errors.add :homeless, I18n.t("validations.household.homeless.assessed.internal_transfer")
    end

    if record.is_internal_transfer? && record.is_other_homeless?
      record.errors.add :referral, I18n.t("validations.household.referral.other_homeless")
      record.errors.add :homeless, I18n.t("validations.household.homeless.other.internal_transfer")
    end
  end

  def validate_prevloc(record)
    if record.previous_la_known? && record.prevloc.blank?
      record.errors.add :prevloc, I18n.t("validations.household.previous_la_known")
    end
  end

private

  def women_of_child_bearing_age_in_household(record)
    (1..8).any? do |n|
      next if record["sex#{n}"].nil? || record["age#{n}"].nil?

      (record["sex#{n}"]) == "F" && record["age#{n}"] >= 16 && record["age#{n}"] <= 50
    end
  end

  def validate_person_age_matches_economic_status(record, person_num)
    age = record.public_send("age#{person_num}")
    economic_status = record.public_send("ecstat#{person_num}")
    return unless age && economic_status

    if age > 70 && economic_status != 4
      record.errors.add "ecstat#{person_num}", I18n.t("validations.household.ecstat.retired_over_70", person_num:)
    end
    if age < 16 && economic_status != 8
      record.errors.add "ecstat#{person_num}", I18n.t("validations.household.ecstat.child_under_16", person_num:)
    end
  end

  def validate_person_age_matches_relationship(record, person_num)
    age = record.public_send("age#{person_num}")
    relationship = record.public_send("relat#{person_num}")
    return unless age && relationship

    if age < 16 && relationship != 1
      record.errors.add "relat#{person_num}", I18n.t("validations.household.relat.child_under_16", person_num:)
    end
  end

  def validate_person_age_and_relationship_matches_economic_status(record, person_num)
    age = record.public_send("age#{person_num}")
    economic_status = record.public_send("ecstat#{person_num}")
    relationship = record.public_send("relat#{person_num}")
    return unless age && economic_status && relationship

    if age >= 16 && age <= 19 && relationship == 1 && (economic_status != 6 && economic_status != 10)
      record.errors.add "ecstat#{person_num}", I18n.t("validations.household.ecstat.student_16_19", person_num:)
    end
  end

  def validate_person_age_and_gender_match_economic_status(record, person_num)
    age = record.public_send("age#{person_num}")
    gender = record.public_send("sex#{person_num}")
    economic_status = record.public_send("ecstat#{person_num}")
    return unless age && economic_status && gender

    if gender == "M" && economic_status == 4 && age < 65
      record.errors.add "age#{person_num}", I18n.t("validations.household.age.retired_male")
    end
    if gender == "F" && economic_status == 4 && age < 60
      record.errors.add "age#{person_num}", I18n.t("validations.household.age.retired_female")
    end
  end

  def validate_partner_count(record)
    partner_count = (2..8).count { |n| record.public_send("relat#{n}")&.zero? }
    if partner_count > 1
      record.errors.add :base, I18n.t("validations.household.relat.one_partner")
    end
  end
end
