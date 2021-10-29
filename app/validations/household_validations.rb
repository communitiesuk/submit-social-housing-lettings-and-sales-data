module HouseholdValidations
  # Validations methods need to be called 'validate_<page_name>' to run on model save
  # or 'validate_' to run on submit as well
  def validate_reasonable_preference(record)
    if record.homelessness == "No" && record.reasonable_preference == "Yes"
      record.errors.add :reasonable_preference, "Can not be Yes if Not Homeless immediately prior to this letting has been selected"
    elsif record.reasonable_preference == "Yes"
      if !record.reasonable_preference_reason_homeless && !record.reasonable_preference_reason_unsatisfactory_housing && !record.reasonable_preference_reason_medical_grounds && !record.reasonable_preference_reason_avoid_hardship && !record.reasonable_preference_reason_do_not_know
        record.errors.add :reasonable_preference_reason, "If reasonable preference is Yes, a reason must be given"
      end
    elsif record.reasonable_preference == "No"
      if record.reasonable_preference_reason_homeless || record.reasonable_preference_reason_unsatisfactory_housing || record.reasonable_preference_reason_medical_grounds || record.reasonable_preference_reason_avoid_hardship || record.reasonable_preference_reason_do_not_know
        record.errors.add :reasonable_preference_reason, "If reasonable preference is No, no reasons should be given"
      end
    end
  end

  def validate_other_reason_for_leaving_last_settled_home(record)
    validate_other_field(record, "reason_for_leaving_last_settled_home", "other_reason_for_leaving_last_settled_home")
  end

  def validate_reason_for_leaving_last_settled_home(record)
    if record.reason_for_leaving_last_settled_home == "Do not know" && record.benefit_cap_spare_room_subsidy != "Do not know"
      record.errors.add :benefit_cap_spare_room_subsidy, "must be do not know if tenant’s main reason for leaving is do not know"
    end
  end

  def validate_armed_forces_injured(record)
    if (record.armed_forces == "Yes - a regular" || record.armed_forces == "Yes - a reserve") && record.armed_forces_injured.blank?
      record.errors.add :armed_forces_injured, "You must answer the armed forces injury question if the tenant has served in the armed forces"
    end

    if (record.armed_forces == "No" || record.armed_forces == "Prefer not to say") && record.armed_forces_injured.present?
      record.errors.add :armed_forces_injured, "You must not answer the armed forces injury question if the tenant has not served in the armed forces or prefer not to say was chosen"
    end
  end

  def validate_armed_forces_active_response(record)
    if record.armed_forces == "Yes - a regular" && record.armed_forces_active.blank?
      record.errors.add :armed_forces_active, "You must answer the armed forces active question if the tenant has served as a regular in the armed forces"
    end

    if record.armed_forces != "Yes - a regular" && record.armed_forces_active.present?
      record.errors.add :armed_forces_active, "You must not answer the armed forces active question if the tenant has not served as a regular in the armed forces"
    end
  end

  def validate_household_pregnancy(record)
    if (record.pregnancy == "Yes" || record.pregnancy == "Prefer not to say") && !women_of_child_bearing_age_in_household(record)
      record.errors.add :pregnancy, "You must answer no as there are no female tenants aged 16-50 in the property"
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
    validate_person_age(record, 1)
  end

private

  def women_of_child_bearing_age_in_household(record)
    (1..8).any? do |n|
      next if record["person_#{n}_gender"].nil? || record["person_#{n}_age"].nil?

      record["person_#{n}_gender"] == "Female" && record["person_#{n}_age"] >= 16 && record["person_#{n}_age"] <= 50
    end
  end

  def validate_person_age(record, person_num)
    age = record.public_send("person_#{person_num}_age")
    return unless age

    if !age.is_a?(Integer) || age < 1 || age > 120
      record.errors.add "person_#{person_num}_age".to_sym, "Tenant age must be an integer between 0 and 120"
    end
  end

  def validate_person_age_matches_economic_status(record, person_num)
    age = record.public_send("person_#{person_num}_age")
    economic_status = record.public_send("person_#{person_num}_economic_status")
    return unless age && economic_status

    if age > 70 && economic_status != "Retired"
      record.errors.add "person_#{person_num}_economic_status", "Tenant #{person_num} must be retired if over 70"
    end
    if age < 16 && economic_status != "Child under 16"
      record.errors.add "person_#{person_num}_economic_status", "Tenant #{person_num} economic status must be Child under 16 if their age is under 16"
    end
  end

  def validate_person_age_matches_relationship(record, person_num)
    age = record.public_send("person_#{person_num}_age")
    relationship = record.public_send("person_#{person_num}_relationship")
    return unless age && relationship

    if age < 16 && relationship != "Child - includes young adult and grown-up"
      record.errors.add "person_#{person_num}_relationship", "Tenant #{person_num}'s relationship to tenant 1 must be Child if their age is under 16"
    end
  end

  def validate_person_age_and_relationship_matches_economic_status(record, person_num)
    age = record.public_send("person_#{person_num}_age")
    economic_status = record.public_send("person_#{person_num}_economic_status")
    relationship = record.public_send("person_#{person_num}_relationship")
    return unless age && economic_status && relationship

    if age >= 16 && age <= 19 && relationship == "Child - includes young adult and grown-up" && (economic_status != "Full-time student" || economic_status != "Prefer not to say")
      record.errors.add "person_#{person_num}_economic_status", "If age is between 16 and 19 - tenant #{person_num} must be a full time student or prefer not to say."
    end
  end

  def validate_person_age_and_gender_match_economic_status(record, person_num)
    age = record.public_send("person_#{person_num}_age")
    gender = record.public_send("person_#{person_num}_gender")
    economic_status = record.public_send("person_#{person_num}_economic_status")
    return unless age && economic_status && gender


    if gender == "Male" && economic_status == "Retired" && age < 65
      record.errors.add "person_#{person_num}_age", "Male tenant who is retired must be 65 or over"
    end
    if gender == "Female" && economic_status == "Retired" && age < 60
      record.errors.add "person_#{person_num}_age", "Female tenant who is retired must be 60 or over"
    end
  end

  def validate_partner_count(record)
    # TODO probably need to keep track of which specific field is wrong so we can highlight it in the UI
    partner_count = (2..8).select { |n| record.public_send("person_#{n}_relationship") == "Partner" }.count
    if partner_count > 1
      record.errors.add :base, "Number of partners cannot be greater than 1"
    end
  end
end
