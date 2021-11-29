ActiveAdmin.register CaseLog do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  permit_params do
    permitted = %i[status
                   tenant_code
                   age1
                   sex1
                   tenant_ethnic_group
                   tenant_nationality
                   previous_housing_situation
                   armedforces
                   ecstat1
                   other_hhmemb
                   relat2
                   age2
                   sex2
                   ecstat2
                   relat3
                   age3
                   sex3
                   ecstat3
                   relat4
                   age4
                   sex4
                   ecstat4
                   relat5
                   age5
                   sex5
                   ecstat5
                   relat6
                   age6
                   sex6
                   ecstat6
                   relat7
                   age7
                   person_7_gender
                   ecstat7
                   relat8
                   age8
                   sex8
                   ecstat8
                   homelessness
                   reason
                   benefit_cap_spare_room_subsidy
                   armed_forces_active
                   armed_forces_injured
                   medical_conditions
                   pregnancy
                   accessibility_requirements
                   condition_effects
                   tenancy_code
                   tenancy_start_date
                   starter_tenancy
                   fixed_term_tenancy
                   tenancy_type
                   letting_type
                   letting_provider
                   la
                   previous_postcode
                   property_relet
                   property_vacancy_reason
                   property_reference
                   property_unit_type
                   property_building_type
                   property_number_of_bedrooms
                   property_void_date
                   majorrepairs
                   mrcdate
                   property_wheelchair_accessible
                   net_income
                   net_income_frequency
                   net_income_uc_proportion
                   hb
                   rent_frequency
                   basic_rent
                   service_charge
                   personal_service_charge
                   support_charge
                   total_charge
                   tshortfall
                   time_lived_in_la
                   time_on_la_waiting_list
                   prevloc
                   property_postcode
                   reasonable_preference
                   reasonable_preference_reason
                   cbl_letting
                   chr_letting
                   cap_letting
                   hbrentshortfall
                   other_reason
                   accessibility_requirements_fully_wheelchair_accessible_housing
                   accessibility_requirements_wheelchair_access_to_essential_rooms
                   accessibility_requirements_level_access_housing
                   accessibility_requirements_other_disability_requirements
                   accessibility_requirements_no_disability_requirements
                   accessibility_requirements_do_not_know
                   accessibility_requirements_prefer_not_to_say
                   condition_effects_vision
                   condition_effects_hearing
                   condition_effects_mobility
                   condition_effects_dexterity
                   condition_effects_stamina
                   condition_effects_learning
                   condition_effects_memory
                   condition_effects_mental_health
                   condition_effects_social_or_behavioral
                   condition_effects_other
                   condition_effects_prefer_not_to_say
                   reasonable_preference_reason_homeless
                   reasonable_preference_reason_unsatisfactory_housing
                   reasonable_preference_reason_medical_grounds
                   reasonable_preference_reason_avoid_hardship
                   reasonable_preference_reason_do_not_know
                   other_tenancy_type
                   override_net_income_validation
                   net_income_known
                   owning_organisation_id
                   managing_organisation_id]
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
    column :owning_organisation
    column :managing_organisation
    actions
  end
end
