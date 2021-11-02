ActiveAdmin.register CaseLog do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  permit_params do
    permitted = [:status, :tenant_code, :person_1_age, :person_1_gender, :tenant_ethnic_group, :tenant_nationality, :previous_housing_situation, :armed_forces, :person_1_economic_status, :household_number_of_other_members, :person_2_relationship, :person_2_age, :person_2_gender, :person_2_economic_status, :person_3_relationship, :person_3_age, :person_3_gender, :person_3_economic_status, :person_4_relationship, :person_4_age, :person_4_gender, :person_4_economic_status, :person_5_relationship, :person_5_age, :person_5_gender, :person_5_economic_status, :person_6_relationship, :person_6_age, :person_6_gender, :person_6_economic_status, :person_7_relationship, :person_7_age, :person_7_gender, :person_7_economic_status, :person_8_relationship, :person_8_age, :person_8_gender, :person_8_economic_status, :homelessness, :reason_for_leaving_last_settled_home, :benefit_cap_spare_room_subsidy, :armed_forces_active, :armed_forces_injured, :armed_forces_partner, :medical_conditions, :pregnancy, :accessibility_requirements, :condition_effects, :tenancy_code, :tenancy_start_date, :starter_tenancy, :fixed_term_tenancy, :tenancy_type, :letting_type, :letting_provider, :property_location, :previous_postcode, :property_relet, :property_vacancy_reason, :property_reference, :property_unit_type, :property_building_type, :property_number_of_bedrooms, :property_void_date, :property_major_repairs, :property_major_repairs_date, :property_number_of_times_relet, :property_wheelchair_accessible, :net_income, :net_income_frequency, :net_income_uc_proportion, :housing_benefit, :rent_frequency, :basic_rent, :service_charge, :personal_service_charge, :support_charge, :total_charge, :outstanding_amount, :time_lived_in_la, :time_on_la_waiting_list, :previous_la, :property_postcode, :reasonable_preference, :reasonable_preference_reason, :cbl_letting, :chr_letting, :cap_letting, :outstanding_rent_or_charges, :other_reason_for_leaving_last_settled_home, :accessibility_requirements_fully_wheelchair_accessible_housing, :accessibility_requirements_wheelchair_access_to_essential_rooms, :accessibility_requirements_level_access_housing, :accessibility_requirements_other_disability_requirements, :accessibility_requirements_no_disability_requirements, :accessibility_requirements_do_not_know, :accessibility_requirements_prefer_not_to_say, :condition_effects_vision, :condition_effects_hearing, :condition_effects_mobility, :condition_effects_dexterity, :condition_effects_stamina, :condition_effects_learning, :condition_effects_memory, :condition_effects_mental_health, :condition_effects_social_or_behavioral, :condition_effects_other, :condition_effects_prefer_not_to_say, :reasonable_preference_reason_homeless, :reasonable_preference_reason_unsatisfactory_housing, :reasonable_preference_reason_medical_grounds, :reasonable_preference_reason_avoid_hardship, :reasonable_preference_reason_do_not_know, :other_tenancy_type, :override_net_income_validation, :net_income_known]
    permitted
  end

  index do
    selectable_column
    id_column
    column :created_at
    column :updated_at
    column :status
    column :tenant_code
    column :property_postcode
    actions
  end
end
