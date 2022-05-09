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
    validate_other_field(record, 20, :reason, :reasonother)

    if record.is_reason_permanently_decanted? && record.referral.present? && !record.is_internal_transfer?
      record.errors.add :referral, I18n.t("validations.household.referral.reason_permanently_decanted")
      record.errors.add :reason, I18n.t("validations.household.reason.not_internal_transfer")
    end
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
    all_options = [record.housingneeds_a, record.housingneeds_b, record.housingneeds_c, record.housingneeds_f, record.housingneeds_g, record.housingneeds_h]
    if all_options.count(1) > 1
      mobility_accessibility_options = [record.housingneeds_a, record.housingneeds_b, record.housingneeds_c]
      unless all_options.count(1) == 2 && record.housingneeds_f == 1 && mobility_accessibility_options.any? { |x| x == 1 }
        record.errors.add :accessibility_requirements, I18n.t("validations.household.housingneeds_a.one_or_two_choices")
      end
    end
  end

  def validate_condition_effects(record)
    all_options = [record.illness_type_1, record.illness_type_2, record.illness_type_3, record.illness_type_4, record.illness_type_5, record.illness_type_6, record.illness_type_7, record.illness_type_8, record.illness_type_9, record.illness_type_10]
    if all_options.count(1) >= 1 && household_no_illness?(record)
      record.errors.add :condition_effects, I18n.t("validations.household.condition_effects.no_choices")
    end
  end

  def validate_previous_housing_situation(record)
    if record.is_relet_to_temp_tenant? && !record.previous_tenancy_was_temporary?
      record.errors.add :prevten, I18n.t("validations.household.prevten.non_temp_accommodation")
    end

    if record.age1.present? && record.age1 > 19 && record.previous_tenancy_was_foster_care?
      record.errors.add :prevten, I18n.t("validations.household.prevten.over_20_foster_care")
      record.errors.add :age1, I18n.t("validations.household.age.lead.over_20")
    end

    if record.sex1 == "M" && record.previous_tenancy_was_refuge?
      record.errors.add :prevten, I18n.t("validations.household.prevten.male_refuge")
      record.errors.add :sex1, I18n.t("validations.household.gender.male_refuge")
    end

    # 3  Private Sector Tenancy
    # 4  Tied housing or rented with job
    # 7  Direct access hostel
    # 9  Residential care home
    # 10 Hospital
    # 13 Children's home / Foster Care
    # 14 Bed and breakfast
    # 19 Rough Sleeping
    # 21 Refuge
    # 23 Mobile home / Caravan
    # 24 Home Office Asylum Support
    # 25 Other
    # 26 Owner Occupation
    # 27 Owner occupation (low-cost home ownership)
    # 28 Living with Friends or Family
    # 29 Prison / Approved Probation Hostel
    if record.is_internal_transfer? && [3, 4, 7, 9, 10, 13, 14, 19, 21, 23, 24, 25, 26, 27, 28, 29].include?(record.prevten)
      label = record.form.get_question("prevten", record).present? ? record.form.get_question("prevten", record).label_from_value(record.prevten) : ""
      record.errors.add :prevten, I18n.t("validations.household.prevten.internal_transfer", prevten: label)
      record.errors.add :referral, I18n.t("validations.household.referral.prevten_invalid", prevten: label)
    end
  end

  def validate_referral(record)
    if record.is_internal_transfer? && record.owning_organisation.provider_type == "PRP" && record.is_prevten_la_general_needs?
      record.errors.add :referral, I18n.t("validations.household.referral.la_general_needs.internal_transfer")
      record.errors.add :prevten, I18n.t("validations.household.prevten.la_general_needs.internal_transfer")
    end

    if record.owning_organisation.provider_type == "LA" && record.local_housing_referral?
      record.errors.add :referral, I18n.t("validations.household.referral.prp.local_housing_referral")
    end
  end

  def validate_prevloc(record)
    if record.previous_la_known? && record.prevloc.blank?
      record.errors.add :prevloc, I18n.t("validations.household.previous_la_known")
    end
  end

private

  def household_no_illness?(record)
    record.illness != 1
  end

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

    if age > 70 && !tenant_is_retired?(economic_status)
      record.errors.add "ecstat#{person_num}", I18n.t("validations.household.ecstat.retired_over_70", person_num:)
      record.errors.add "age#{person_num}", I18n.t("validations.household.age.retired_over_70", person_num:)
    end
    if age < 16 && !tenant_is_economic_child?(economic_status)
      record.errors.add "ecstat#{person_num}", I18n.t("validations.household.ecstat.child_under_16", person_num:)
      record.errors.add "age#{person_num}", I18n.t("validations.household.age.child_under_16", person_num:)
    end
    if tenant_is_economic_child?(economic_status) && age > 16
      record.errors.add "ecstat#{person_num}", I18n.t("validations.household.ecstat.child_over_16", person_num:)
      record.errors.add "age#{person_num}", I18n.t("validations.household.age.child_over_16", person_num:)
    end
  end

  def validate_person_age_matches_relationship(record, person_num)
    age = record.public_send("age#{person_num}")
    relationship = record.public_send("relat#{person_num}")
    return unless age && relationship

    if age < 16 && !tenant_is_child?(relationship)
      record.errors.add "relat#{person_num}", I18n.t("validations.household.relat.child_under_16", person_num:)
      record.errors.add "age#{person_num}", I18n.t("validations.household.age.child_under_16_relat", person_num:)
    end
  end

  def validate_person_age_and_relationship_matches_economic_status(record, person_num)
    age = record.public_send("age#{person_num}")
    economic_status = record.public_send("ecstat#{person_num}")
    relationship = record.public_send("relat#{person_num}")
    return unless age && economic_status && relationship

    if age >= 16 && age <= 19 && tenant_is_child?(relationship) && (!tenant_is_fulltime_student?(economic_status) && !tenant_economic_status_refused?(economic_status))
      record.errors.add "ecstat#{person_num}", I18n.t("validations.household.ecstat.student_16_19", person_num:)
      record.errors.add "age#{person_num}", I18n.t("validations.household.age.student_16_19", person_num:)
      record.errors.add "relat#{person_num}", I18n.t("validations.household.relat.student_16_19", person_num:)
    end
  end

  def validate_person_age_and_gender_match_economic_status(record, person_num)
    age = record.public_send("age#{person_num}")
    gender = record.public_send("sex#{person_num}")
    economic_status = record.public_send("ecstat#{person_num}")
    return unless age && economic_status && gender

    if gender == "M" && tenant_is_retired?(economic_status) && age < 65
      record.errors.add "age#{person_num}", I18n.t("validations.household.age.retired_male")
      record.errors.add "sex#{person_num}", I18n.t("validations.household.gender.retired_male")
      record.errors.add "ecstat#{person_num}", I18n.t("validations.household.ecstat.retired_male")
    end
    if gender == "F" && tenant_is_retired?(economic_status) && age < 60
      record.errors.add "age#{person_num}", I18n.t("validations.household.age.retired_female")
      record.errors.add "sex#{person_num}", I18n.t("validations.household.gender.retired_female")
      record.errors.add "ecstat#{person_num}", I18n.t("validations.household.ecstat.retired_female")
    end
  end

  def validate_partner_count(record)
    partner_count = (2..8).count { |n| tenant_is_partner?(record["relat#{n}"]) }
    if partner_count > 1
      record.errors.add :base, I18n.t("validations.household.relat.one_partner")
    end
  end

  def tenant_is_retired?(economic_status)
    economic_status == 5
  end

  def tenant_is_economic_child?(economic_status)
    economic_status == 9
  end

  def tenant_is_fulltime_student?(economic_status)
    economic_status == 7
  end

  def tenant_economic_status_refused?(economic_status)
    economic_status == 10
  end

  def tenant_is_partner?(relationship)
    relationship == "P"
  end

  def tenant_is_child?(relationship)
    relationship == "C"
  end
end
