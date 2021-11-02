class RenameFields < ActiveRecord::Migration[6.1]
  def change
    rename_column :case_logs, :person_1_age, :AGE1
    rename_column :case_logs, :person_1_gender, :SEX1
    rename_column :case_logs, :tenant_ethnic_group, :ETHNIC
    rename_column :case_logs, :tenant_nationality, :NATIONAL
    rename_column :case_logs, :tenant_economic_status, :ECSTAT1
    rename_column :case_logs, :household_number_of_other_members, :HHMEMB

    rename_column :case_logs, :person_2_relationship, :RELAT2
    rename_column :case_logs, :person_2_age, :AGE2
    rename_column :case_logs, :person_2_gender, :SEX2
    rename_column :case_logs, :person_2_economic_status, :ECSTAT2

    rename_column :case_logs, :person_3_relationship, :RELAT3
    rename_column :case_logs, :person_3_age, :AGE3
    rename_column :case_logs, :person_3_gender, :SEX3
    rename_column :case_logs, :person_3_economic_status, :ECSTAT3

    rename_column :case_logs, :person_4_relationship, :RELAT4
    rename_column :case_logs, :person_4_age, :AGE4
    rename_column :case_logs, :person_4_gender, :SEX4
    rename_column :case_logs, :person_4_economic_status, :ECSTAT4

    rename_column :case_logs, :person_5_relationship, :RELAT5
    rename_column :case_logs, :person_5_age, :AGE5
    rename_column :case_logs, :person_5_gender, :SEX5
    rename_column :case_logs, :person_5_economic_status, :ECSTAT5

    rename_column :case_logs, :person_6_relationship, :RELAT6
    rename_column :case_logs, :person_6_age, :AGE6
    rename_column :case_logs, :person_6_gender, :SEX6
    rename_column :case_logs, :person_6_economic_status, :ECSTAT6

    rename_column :case_logs, :person_7_relationship, :RELAT7
    rename_column :case_logs, :person_7_age, :AGE7
    rename_column :case_logs, :person_7_gender, :SEX7
    rename_column :case_logs, :person_7_economic_status, :ECSTAT7

    rename_column :case_logs, :person_8_relationship, :RELAT8
    rename_column :case_logs, :person_8_age, :AGE8
    rename_column :case_logs, :person_8_gender, :SEX8
    rename_column :case_logs, :person_8_economic_status, :ECSTAT8

    rename_column :case_logs, :previous_housing_situation, :PREVTEN
    rename_column :case_logs, :homelessness, :HOMELESS
    rename_column :case_logs, :benefit_cap_spare_room_subsidy, :UNDEROCCUPATION_BENEFITCAP
    rename_column :case_logs, :armed_forces_injured, :RESERVIST
    rename_column :case_logs, :armed_forces_active, :LEFTREG
    rename_column :case_logs, :medical_conditions, :ILLNESS
    rename_column :case_logs, :pregnancy, :PREG_OCC

    rename_column :case_logs, :accessibility_requirements_fully_wheelchair_accessible_housing, :HousingNeeds_A
    rename_column :case_logs, :accessibility_requirements_wheelchair_access_to_essential_rooms, :HousingNeeds_B
    rename_column :case_logs, :accessibility_requirements_level_access_housing, :HousingNeeds_C
    rename_column :case_logs, :accessibility_requirements_other_disability_requirements, :HousingNeeds_F
    rename_column :case_logs, :accessibility_requirements_no_disability_requirements, :HousingNeeds_G
    rename_column :case_logs, :accessibility_requirements_do_not_know, :HousingNeeds_H

    rename_column :case_logs, :condition_effects_vision, :ILLNESS_TYPE_1
    rename_column :case_logs, :condition_effects_hearing, :ILLNESS_TYPE_2
    rename_column :case_logs, :condition_effects_mobility, :ILLNESS_TYPE_3
    rename_column :case_logs, :condition_effects_dexterity, :ILLNESS_TYPE_4
    rename_column :case_logs, :condition_effects_stamina, :ILLNESS_TYPE_8
    rename_column :case_logs, :condition_effects_learning, :ILLNESS_TYPE_5
    rename_column :case_logs, :condition_effects_memory, :ILLNESS_TYPE_6
    rename_column :case_logs, :condition_effects_mental_health, :ILLNESS_TYPE_7
    rename_column :case_logs, :condition_effects_social_or_behavioral, :ILLNESS_TYPE_9
    rename_column :case_logs, :condition_effects_other, :ILLNESS_TYPE_10

    rename_column :case_logs, :tenancy_start_date, :STARTDATE
    rename_column :case_logs, :starter_tenancy, :STARTERTENANCY
    rename_column :case_logs, :fixed_term_tenancy, :TENANCYLENGTH
    rename_column :case_logs, :tenancy_type, :TENANCY
    rename_column :case_logs, :other_tenancy_type, :TENANCYOTHER
    rename_column :case_logs, :letting_type, :LETTYPE
    rename_column :case_logs, :letting_provider, :LANDLORD
    rename_column :case_logs, :property_vacancy_reason, :RSNVAC
    rename_column :case_logs, :property_unit_type, :UNITTYPE_GN
    rename_column :case_logs, :property_number_of_bedrooms, :BEDS
    rename_column :case_logs, :property_number_of_times_relet, :OFFERED
    rename_column :case_logs, :property_wheelchair_accessible, :WCHAIR
    rename_column :case_logs, :net_income, :EARNINGS
    rename_column :case_logs, :net_income_frequency, :INCFREQ
    rename_column :case_logs, :net_income_uc_proportion, :BENEFITS
    rename_column :case_logs, :rent_frequency, :PERIOD
    rename_column :case_logs, :basic_rent, :BRENT
    rename_column :case_logs, :service_charge, :SCHARGE
    rename_column :case_logs, :personal_service_charge, :PSCHARGE
    rename_column :case_logs, :support_charge, :SUPCHARGE
    rename_column :case_logs, :total_charge, :TCHARGE
    rename_column :case_logs, :time_lived_in_la, :LAYEAR
    rename_column :case_logs, :time_on_la_waiting_list, :LAWAITLIST
    rename_column :case_logs, :reasonable_preference, :REASONPREF

    rename_column :case_logs, :reasonable_preference_reason_homeless, :RP_HOMELESS
    rename_column :case_logs, :reasonable_preference_reason_unsatisfactory_housing, :RP_INSAN_UNSAT
    rename_column :case_logs, :reasonable_preference_reason_medical_grounds, :RP_MEDWEL
    rename_column :case_logs, :reasonable_preference_reason_avoid_hardship, :RP_HARDSHIP
    rename_column :case_logs, :reasonable_preference_reason_do_not_know, :RP_DONTKNOW

    rename_column :case_logs, :cbl_letting, :CBL
    rename_column :case_logs, :chr_letting, :CHR
    rename_column :case_logs, :cap_letting, :CAP

  end
end
