FactoryBot.define do
  factory :case_log do
    owning_organisation { FactoryBot.create(:organisation) }
    managing_organisation { FactoryBot.create(:organisation) }
    trait :about_completed do
      renewal { 0 }
      needstype { 1 }
      rent_type { 1 }
      startdate { Time.zone.local(2022, 5, 1) }
    end
    trait :in_progress do
      status { 1 }
      tenant_code { "TH356" }
      postcode_full { "PO5 3TE" }
      ppostcode_full { "SW2 6HI" }
      age1 { 17 }
      age2 { 19 }
    end
    trait :soft_validations_triggered do
      status { 1 }
      ecstat1 { 1 }
      earnings { 750 }
      incfreq { 0 }
    end
    trait :conditional_section_complete do
      tenant_code { "TH356" }
      age1 { 34 }
      sex1 { "M" }
      ethnic { 2 }
      national { 4 }
      ecstat1 { 2 }
      hhmemb { 1 }
    end
    trait :completed do
      status { 2 }
      tenant_code { "BZ737" }
      postcode { "NW1 7TY" }
      age1 { 35 }
      sex1 { "F" }
      ethnic { 2 }
      national { 4 }
      prevten { 6 }
      ecstat1 { 0 }
      hhmemb { 2 }
      relat2 { "P" }
      age2 { 32 }
      sex2 { "M" }
      ecstat2 { 6 }
      homeless { 1 }
      underoccupation_benefitcap { 0 }
      leftreg { 1 }
      reservist { 0 }
      illness { 0 }
      preg_occ { 1 }
      tenancy_code { "BZ757" }
      startertenancy { 0 }
      tenancylength { 5 }
      tenancy { 3 }
      landlord { 1 }
      ppostcode_full { "SE2 6RT" }
      rsnvac { 7 }
      unittype_gn { 2 }
      beds { 3 }
      property_void_date { "03/11/2019" }
      vday { 3 }
      vmonth { 11 }
      vyear { 2019 }
      offered { 2 }
      wchair { 1 }
      earnings { 68 }
      incfreq { 0 }
      benefits { 1 }
      period { 2 }
      brent { 200 }
      scharge { 50 }
      pscharge { 40 }
      supcharg { 35 }
      tcharge { 325 }
      layear { 2 }
      waityear { 1 }
      postcode_full { "NW1 5TY" }
      reasonpref { 1 }
      cbl { 1 }
      chr { 1 }
      cap { 0 }
      other_reason_for_leaving_last_settled_home { nil }
      housingneeds_a { 1 }
      housingneeds_b { 0 }
      housingneeds_c { 0 }
      housingneeds_f { 0 }
      housingneeds_g { 0 }
      housingneeds_h { 0 }
      accessibility_requirements_prefer_not_to_say { 0 }
      illness_type_1 { 0 }
      illness_type_2 { 1 }
      illness_type_3 { 0 }
      illness_type_4 { 0 }
      illness_type_8 { 0 }
      illness_type_5 { 0 }
      illness_type_6 { 0 }
      illness_type_7 { 0 }
      illness_type_9 { 0 }
      illness_type_10 { 0 }
      rp_homeless { 0 }
      rp_insan_unsat { 1 }
      rp_medwel { 0 }
      rp_hardship { 0 }
      rp_dontknow { 0 }
      tenancyother { nil }
      net_income_value_check { nil }
      net_income_known { 1 }
      property_owner_organisation { "Test" }
      property_manager_organisation { "Test" }
      renewal { 0 }
      rent_type { 1 }
      needstype { 1 }
      purchaser_code { 798_794 }
      reason { 4 }
      propcode { "123" }
      majorrepairs { 1 }
      la { "E09000003" }
      prevloc { "E07000105" }
      hb { 6 }
      hbrentshortfall { 0 }
      tshortfall { 12 }
      postcod2 { "w3" }
      property_relet { 0 }
      mrcdate { Time.utc(2020, 5, 0o5, 10, 36, 49) }
      mrcday { mrcdate.day }
      mrcmonth { mrcdate.month }
      mrcyear { mrcdate.year }
      incref { 0 }
      sale_completion_date { nil }
      startdate { Time.utc(2022, 2, 2, 10, 36, 49) }
      armedforces { 0 }
      builtype { 1 }
      unitletas { 2 }
      has_benefits { 1 }
      is_carehome { 0 }
      letting_in_sheltered_accommodation { 0 }
      la_known { 1 }
      declaration { 1 }
    end
    created_at { Time.utc(2022, 2, 8, 16, 52, 15) }
    updated_at { Time.utc(2022, 2, 8, 16, 52, 15) }
  end
end
