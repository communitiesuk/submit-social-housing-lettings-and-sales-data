module HouseholdValidations
  # Validations methods need to be called 'validate_' to run on model save
  def validate_person_1_age(record)
    if record.person_1_age && !/^[1-9][0-9]?$|^120$/.match?(record.person_1_age.to_s)
      record.errors.add :person_1_age, "Tenant age must be between 0 and 120"
    end
  end

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

  def validate_shared_housing_rooms(record)
    unless record.property_unit_type.nil?
      if record.property_unit_type == "Bed-sit" && record.property_number_of_bedrooms != 1
        record.errors.add :property_unit_type, "A bedsit can only have one bedroom"
      end

      unless record.household_number_of_other_members.nil?
        if record.household_number_of_other_members > 0
          if record.property_unit_type.include?("Shared") && !record.property_number_of_bedrooms.to_i.between?(1, 7)
            record.errors.add :property_unit_type, "A shared house must have 1 to 7 bedrooms"
          end
        end
      end

      if record.property_unit_type.include?("Shared")  && !record.property_number_of_bedrooms.to_i.between?(1, 3)
        record.errors.add :property_unit_type, "A shared house with less than two tenants must have 1 to 3 bedrooms"
      end
    end
  end

private

  def women_of_child_bearing_age_in_household(record)
    (1..8).any? do |n|
      next if record["person_#{n}_gender"].nil? || record["person_#{n}_age"].nil?

      record["person_#{n}_gender"] == "Female" && record["person_#{n}_age"] >= 16 && record["person_#{n}_age"] <= 50
    end
  end
end
