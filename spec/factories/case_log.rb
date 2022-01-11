FactoryBot.define do
  factory :case_log do
    owning_organisation { FactoryBot.create(:organisation) }
    managing_organisation { FactoryBot.create(:organisation) }
    trait :about_completed do
      gdpr_acceptance { "Yes" }
      sale_or_letting { "Letting" }
      tenant_same_property_renewal { "No" }
      needstype { 1 }
      rent_type { 1 }
      startdate { Time.zone.local(2022, 5, 1) }
      year { 2022 }
    end
    trait :in_progress do
      status { 1 }
      tenant_code { "TH356" }
      property_postcode { "PO5 3TE" }
      previous_postcode { "SW2 6HI" }
      age1 { "17" }
    end
    trait :soft_validations_triggered do
      status { 1 }
      ecstat1 { "Full-time - 30 hours or more" }
      earnings { 750 }
      incfreq { "Weekly" }
    end
    trait :conditional_section_complete do
      tenant_code { "TH356" }
      age1 { 34 }
      sex1 { "M" }
      ethnic { 2 }
      national { 4 }
      ecstat1 { 2 }
      other_hhmemb { 0 }
    end
    trait :completed do
      status { 2 }
      tenant_code { "BZ737" }
      postcode { "NW1 7TY" }
      age1 { 35 }
      sex1 { "F" }
      ethnic { 2 }
      national { 4 }
      prevten { "Private sector tenancy" }
      ecstat1 { 2 }
      other_hhmemb { 1 }
      hhmemb { 2 }
      relat2 { "Partner" }
      age2 { 32 }
      sex2 { "Male" }
      ecstat2 { "Not seeking work" }
      homeless { "Yes - other homelessness" }
      underoccupation_benefitcap { "No" }
      leftreg { "No - they left up to 5 years ago" }
      reservist { "No" }
      illness { "Yes" }
      preg_occ { "No" }
      accessibility_requirements { "No" }
      condition_effects { "dummy" }
      tenancy_code { "BZ757" }
      startertenancy { "No" }
      tenancylength { 5 }
      tenancy { "Secure (including flexible)" }
      lettype { "Affordable Rent General needs LA" }
      landlord { "This landlord" }
      previous_postcode { "SE2 6RT" }
      rsnvac { "Tenant abandoned property" }
      unittype_gn { "House" }
      beds { 3 }
      property_void_date { "03/11/2019" }
      offered { 2 }
      wchair { "Yes" }
      earnings { 68 }
      benefits { "Some" }
      period { "Fortnightly" }
      brent { 200 }
      scharge { 50 }
      pscharge { 40 }
      supcharg { 35 }
      tcharge { 325 }
      layear { "1 to 2 years" }
      lawaitlist { "Less than 1 year" }
      property_postcode { "NW1 5TY" }
      reasonpref { "Yes" }
      reasonable_preference_reason { "dummy" }
      cbl { "Yes" }
      chr { "Yes" }
      cap { "No" }
      other_reason_for_leaving_last_settled_home { nil }
      housingneeds_a { "Yes" }
      housingneeds_b { "No" }
      housingneeds_c { "No" }
      housingneeds_f { "No" }
      housingneeds_g { "No" }
      housingneeds_h { "No" }
      accessibility_requirements_prefer_not_to_say { 0 }
      illness_type_1 { "No" }
      illness_type_2 { "Yes" }
      illness_type_3 { "No" }
      illness_type_4 { "No" }
      illness_type_8 { "No" }
      illness_type_5 { "No" }
      illness_type_6 { "No" }
      illness_type_7 { "No" }
      illness_type_9 { "No" }
      illness_type_10 { "No" }
      rp_homeless { "Yes" }
      rp_insan_unsat { "No" }
      rp_medwel { "No" }
      rp_hardship { "No" }
      rp_dontknow { "No" }
      discarded_at { nil }
      tenancyother { nil }
      override_net_income_validation { nil }
      net_income_known { "Yes – the household has a weekly income" }
      gdpr_acceptance { "Yes" }
      gdpr_declined { "No" }
      property_owner_organisation { "Test" }
      property_manager_organisation { "Test" }
      sale_or_letting { "Letting" }
      tenant_same_property_renewal { 1 }
      rent_type { 1 }
      intermediate_rent_product_name { 2 }
      needstype { 1 }
      purchaser_code { 798_794 }
      reason { "Permanently decanted from another property owned by this landlord" }
      propcode { "123" }
      majorrepairs { "Yes" }
      la { "Barnet" }
      prevloc { "Ashford" }
      hb { 1 }
      hbrentshortfall { "Yes" }
      tshortfall { 12 }
      postcod2 { "w3" }
      ppostc1 { "w3" }
      ppostc2 { "w3" }
      property_relet { "No" }
      mrcdate { Time.zone.now }
      mrcday { 5 }
      mrcmonth { 5 }
      mrcyear { 2020 }
      incref { 0 }
      sale_completion_date { nil }
      startdate { Time.zone.now }
      day { Time.zone.now.day }
      month { Time.zone.now.month }
      year { 2021 }
      armedforces { 1 }
      builtype { 1 }
      unitletas { 2 }
    end
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
  end
end
