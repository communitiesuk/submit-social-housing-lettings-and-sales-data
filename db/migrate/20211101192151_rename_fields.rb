class RenameFields < ActiveRecord::Migration[6.1]
  def change
    rename_column :case_logs, :person_1_age, :age1
    rename_column :case_logs, :person_1_gender, :sex1
    rename_column :case_logs, :tenant_ethnic_group, :ethnic
    rename_column :case_logs, :tenant_nationality, :national
    rename_column :case_logs, :person_1_economic_status, :ecstat1
    rename_column :case_logs, :household_number_of_other_members, :hhmemb

    rename_column :case_logs, :person_2_relationship, :relat2
    rename_column :case_logs, :person_2_age, :age2
    rename_column :case_logs, :person_2_gender, :sex2
    rename_column :case_logs, :person_2_economic_status, :ecstat2

    rename_column :case_logs, :person_3_relationship, :relat3
    rename_column :case_logs, :person_3_age, :age3
    rename_column :case_logs, :person_3_gender, :sex3
    rename_column :case_logs, :person_3_economic_status, :ecstat3

    rename_column :case_logs, :person_4_relationship, :relat4
    rename_column :case_logs, :person_4_age, :age4
    rename_column :case_logs, :person_4_gender, :sex4
    rename_column :case_logs, :person_4_economic_status, :ecstat4

    rename_column :case_logs, :person_5_relationship, :relat5
    rename_column :case_logs, :person_5_age, :age5
    rename_column :case_logs, :person_5_gender, :sex5
    rename_column :case_logs, :person_5_economic_status, :ecstat5

    rename_column :case_logs, :person_6_relationship, :relat6
    rename_column :case_logs, :person_6_age, :age6
    rename_column :case_logs, :person_6_gender, :sex6
    rename_column :case_logs, :person_6_economic_status, :ecstat6

    rename_column :case_logs, :person_7_relationship, :relat7
    rename_column :case_logs, :person_7_age, :age7
    rename_column :case_logs, :person_7_gender, :sex7
    rename_column :case_logs, :person_7_economic_status, :ecstat7

    rename_column :case_logs, :person_8_relationship, :relat8
    rename_column :case_logs, :person_8_age, :age8
    rename_column :case_logs, :person_8_gender, :sex8
    rename_column :case_logs, :person_8_economic_status, :ecstat8

    rename_column :case_logs, :previous_housing_situation, :prevten
    rename_column :case_logs, :homelessness, :homeless
    rename_column :case_logs, :benefit_cap_spare_room_subsidy, :underoccupation_benefitcap
    rename_column :case_logs, :armed_forces_injured, :reservist
    rename_column :case_logs, :armed_forces_active, :leftreg
    rename_column :case_logs, :medical_conditions, :illness
    rename_column :case_logs, :pregnancy, :preg_occ

    rename_column :case_logs, :accessibility_requirements_fully_wheelchair_accessible_housing, :housingneeds_a
    rename_column :case_logs, :accessibility_requirements_wheelchair_access_to_essential_rooms, :housingneeds_b
    rename_column :case_logs, :accessibility_requirements_level_access_housing, :housingneeds_c
    rename_column :case_logs, :accessibility_requirements_other_disability_requirements, :housingneeds_f
    rename_column :case_logs, :accessibility_requirements_no_disability_requirements, :housingneeds_g
    rename_column :case_logs, :accessibility_requirements_do_not_know, :housingneeds_h

    rename_column :case_logs, :condition_effects_vision, :illness_type_1
    rename_column :case_logs, :condition_effects_hearing, :illness_type_2
    rename_column :case_logs, :condition_effects_mobility, :illness_type_3
    rename_column :case_logs, :condition_effects_dexterity, :illness_type_4
    rename_column :case_logs, :condition_effects_stamina, :illness_type_8
    rename_column :case_logs, :condition_effects_learning, :illness_type_5
    rename_column :case_logs, :condition_effects_memory, :illness_type_6
    rename_column :case_logs, :condition_effects_mental_health, :illness_type_7
    rename_column :case_logs, :condition_effects_social_or_behavioral, :illness_type_9
    rename_column :case_logs, :condition_effects_other, :illness_type_10

    rename_column :case_logs, :tenancy_start_date, :startdate
    rename_column :case_logs, :starter_tenancy, :startertenancy
    rename_column :case_logs, :fixed_term_tenancy, :tenancylength
    rename_column :case_logs, :tenancy_type, :tenancy
    rename_column :case_logs, :other_tenancy_type, :tenancyother
    rename_column :case_logs, :letting_type, :lettype
    rename_column :case_logs, :letting_provider, :landlord
    rename_column :case_logs, :property_vacancy_reason, :rsnvac
    rename_column :case_logs, :property_unit_type, :unittype_gn
    rename_column :case_logs, :property_number_of_bedrooms, :beds
    rename_column :case_logs, :property_number_of_times_relet, :offered
    rename_column :case_logs, :property_wheelchair_accessible, :wchair
    rename_column :case_logs, :net_income, :earnings
    rename_column :case_logs, :net_income_frequency, :incfreq
    rename_column :case_logs, :net_income_uc_proportion, :benefits
    rename_column :case_logs, :rent_frequency, :period
    rename_column :case_logs, :basic_rent, :brent
    rename_column :case_logs, :service_charge, :scharge
    rename_column :case_logs, :personal_service_charge, :pscharge
    rename_column :case_logs, :support_charge, :supcharge
    rename_column :case_logs, :total_charge, :tcharge
    rename_column :case_logs, :time_lived_in_la, :layear
    rename_column :case_logs, :time_on_la_waiting_list, :lawaitlist
    rename_column :case_logs, :reasonable_preference, :reasonpref

    rename_column :case_logs, :reasonable_preference_reason_homeless, :rp_homeless
    rename_column :case_logs, :reasonable_preference_reason_unsatisfactory_housing, :rp_insan_unsat
    rename_column :case_logs, :reasonable_preference_reason_medical_grounds, :rp_medwel
    rename_column :case_logs, :reasonable_preference_reason_avoid_hardship, :rp_hardship
    rename_column :case_logs, :reasonable_preference_reason_do_not_know, :rp_dontknow

    rename_column :case_logs, :cbl_letting, :cbl
    rename_column :case_logs, :chr_letting, :chr
    rename_column :case_logs, :cap_letting, :cap
  end
end
