module HouseholdValidations
  # Validations methods need to be called 'validate_<page_name>' to run on model save
  # or 'validate_' to run on submit as well
  def validate_reasonable_preference(record)
    if record.homeless == "No" && record.reasonpref == "Yes"
      record.errors.add :reasonpref, "Can not be Yes if Not Homeless immediately prior to this letting has been selected"
    elsif record.reasonpref == "Yes"
      if !record.rp_homeless && !record.rp_insan_unsat && !record.rp_medwel && !record.rp_hardship && !record.rp_dontknow
        record.errors.add :reasonable_preference_reason, "If reasonable preference is Yes, a reason must be given"
      end
    elsif record.reasonpref == "No"
      if record.rp_homeless || record.rp_insan_unsat || record.rp_medwel || record.rp_hardship || record.rp_dontknow
        record.errors.add :reasonable_preference_reason, "If reasonable preference is No, no reasons should be given"
      end
    end
  end

  def validate_other_reason_for_leaving_last_settled_home(record)
    validate_other_field(record, "reason", "other_reason_for_leaving_last_settled_home")
  end

  def validate_reason_for_leaving_last_settled_home(record)
    if record.reason == "Do not know" && record.underoccupation_benefitcap != "Do not know"
      record.errors.add :underoccupation_benefitcap, "must be do not know if tenant’s main reason for leaving is do not know"
    end
  end

  def validate_armed_forces_injured(record)
    if (record.armed_forces == "Yes - a regular" || record.armed_forces == "Yes - a reserve") && record.reservist.blank?
      record.errors.add :reservist, "You must answer the armed forces injury question if the tenant has served in the armed forces"
    end

    if (record.armed_forces == "No" || record.armed_forces == "Prefer not to say") && record.reservist.present?
      record.errors.add :reservist, "You must not answer the armed forces injury question if the tenant has not served in the armed forces or prefer not to say was chosen"
    end
  end

  def validate_armed_forces_active_response(record)
    if record.armed_forces == "Yes - a regular" && record.leftreg.blank?
      record.errors.add :leftreg, "You must answer the armed forces active question if the tenant has served as a regular in the armed forces"
    end

    if record.armed_forces != "Yes - a regular" && record.leftreg.present?
      record.errors.add :leftreg, "You must not answer the armed forces active question if the tenant has not served as a regular in the armed forces"
    end
  end

  def validate_pregnancy(record)
    if (record.preg_occ == "Yes" || record.preg_occ == "Prefer not to say") && !women_of_child_bearing_age_in_household(record)
      record.errors.add :preg_occ, "You must answer no as there are no female tenants aged 16-50 in the property"
    end
  end

  def validate_household_number_of_other_members(record)
    (2..8).each do |n|
      validate_person_age(record, n)
      validate_person_age_matches_economic_status(record, n)
      validate_person_age_matches_relationship(record, n)
      validate_person_age_and_gender_match_economic_status(record, n)
      validate_person_age_and_relationship_matches_economic_status(record, n)
    end
    validate_partner_count(record)
  end

  def validate_person_1_age(record)
    return unless record.age1

    if !record.age1.is_a?(Integer) || record.age1 < 16 || record.age1 > 120
      record.errors.add "age1", "Tenant age must be an integer between 16 and 120"
    end
  end

  def validate_person_1_economic(record)
    validate_person_age_matches_economic_status(record, 1)
  end

  def validate_shared_housing_rooms(record)
    unless record.unittype_gn.nil?
      if record.unittype_gn == "Bed-sit" && record.beds != 1
        record.errors.add :unittype_gn, "A bedsit can only have one bedroom"
      end

      if !record.other_hhmemb.nil? && record.other_hhmemb.positive? && (record.unittype_gn.include?("Shared") && !record.beds.to_i.between?(1, 7))
        record.errors.add :unittype_gn, "A shared house must have 1 to 7 bedrooms"
      end

      if record.unittype_gn.include?("Shared") && !record.beds.to_i.between?(1, 3)
        record.errors.add :unittype_gn, "A shared house with less than two tenants must have 1 to 3 bedrooms"
      end
    end
  end

private

  def women_of_child_bearing_age_in_household(record)
    (1..8).any? do |n|
      next if record["sex#{n}"].nil? || record["age#{n}"].nil?

      record["sex#{n}"] == "Female" && record["age#{n}"] >= 16 && record["age#{n}"] <= 50
    end
  end

  def validate_person_age(record, person_num)
    age = record.public_send("age#{person_num}")
    return unless age

    if !age.is_a?(Integer) || age < 1 || age > 120
      record.errors.add "age#{person_num}".to_sym, "Tenant age must be an integer between 0 and 120"
    end
  end

  def validate_person_age_matches_economic_status(record, person_num)
    age = record.public_send("age#{person_num}")
    economic_status = record.public_send("ecstat#{person_num}")
    return unless age && economic_status

    if age > 70 && economic_status != "Retired"
      record.errors.add "ecstat#{person_num}", "Tenant #{person_num} must be retired if over 70"
    end
    if age < 16 && economic_status != "Child under 16"
      record.errors.add "ecstat#{person_num}", "Tenant #{person_num} economic status must be Child under 16 if their age is under 16"
    end
  end

  def validate_person_age_matches_relationship(record, person_num)
    age = record.public_send("age#{person_num}")
    relationship = record.public_send("relat#{person_num}")
    return unless age && relationship

    if age < 16 && relationship != "Child - includes young adult and grown-up"
      record.errors.add "relat#{person_num}", "Tenant #{person_num}'s relationship to tenant 1 must be Child if their age is under 16"
    end
  end

  def validate_person_age_and_relationship_matches_economic_status(record, person_num)
    age = record.public_send("age#{person_num}")
    economic_status = record.public_send("ecstat#{person_num}")
    relationship = record.public_send("relat#{person_num}")
    return unless age && economic_status && relationship

    if age >= 16 && age <= 19 && relationship == "Child - includes young adult and grown-up" && (economic_status != "Full-time student" || economic_status != "Prefer not to say")
      record.errors.add "ecstat#{person_num}", "If age is between 16 and 19 - tenant #{person_num} must be a full time student or prefer not to say."
    end
  end

  def validate_person_age_and_gender_match_economic_status(record, person_num)
    age = record.public_send("age#{person_num}")
    gender = record.public_send("sex#{person_num}")
    economic_status = record.public_send("ecstat#{person_num}")
    return unless age && economic_status && gender

    if gender == "Male" && economic_status == "Retired" && age < 65
      record.errors.add "age#{person_num}", "Male tenant who is retired must be 65 or over"
    end
    if gender == "Female" && economic_status == "Retired" && age < 60
      record.errors.add "age#{person_num}", "Female tenant who is retired must be 60 or over"
    end
  end

  def validate_partner_count(record)
    # TODO: probably need to keep track of which specific field is wrong so we can highlight it in the UI
    partner_count = (2..8).count { |n| record.public_send("relat#{n}") == "Partner" }
    if partner_count > 1
      record.errors.add :base, "Number of partners cannot be greater than 1"
    end
  end
end
