FactoryBot.define do
  factory :sales_log do
    created_by { FactoryBot.create(:user) }
    owning_organisation { created_by.organisation }
    created_at { Time.utc(2023, 2, 8, 16, 52, 15) }
    updated_at { Time.utc(2023, 2, 8, 16, 52, 15) }
    trait :in_progress do
      purchid { "PC123" }
      ownershipsch { 2 }
      type { 8 }
      jointpur { 2 }
      saledate { Time.utc(2023, 2, 2, 10, 36, 49) }
    end
    trait :shared_ownership do
      ownershipsch { 1 }
      type { 30 }
    end
    trait :privacy_notice_seen do
      privacynotice { 1 }
    end
    trait :saledate_today do
      saledate { Time.zone.today }
    end
    trait :shared_ownership_setup_complete do
      saledate_today
      ownershipsch { 1 }
      type { 30 }
      jointpur { 2 }
    end
    trait :outright_sale_setup_complete do
      saledate_today
      ownershipsch { 3 }
      type { 10 }
      companybuy { 2 }
      buylivein { 1 }
      jointpur { 2 }
    end
    trait :completed do
      ownershipsch { 2 }
      type { 8 }
      saledate { Time.utc(2023, 2, 2, 10, 36, 49) }
      jointpur { 1 }
      beds { 2 }
      jointmore { 1 }
      noint { 2 }
      privacynotice { 1 }
      age1_known { 0 }
      age1 { 30 }
      sex1 { "X" }
      national { 18 }
      buy1livein { 1 }
      relat2 { "P" }
      proptype { 1 }
      age2_known { 0 }
      age2 { 35 }
      builtype { 1 }
      ethnic { 3 }
      ethnic_group { 17 }
      sex2 { "X" }
      buy2livein { "1" }
      ecstat1 { "1" }
      ecstat2 { "1" }
      hholdcount { "1" }
      wheel { 1 }
      details_known_3 { 1 }
      age3_known { 0 }
      age3 { 14 }
      details_known_4 { 1 }
      age4_known { 0 }
      age4 { 18 }
      details_known_5 { 1 }
      age5_known { 0 }
      age5 { 40 }
      details_known_6 { 1 }
      age6_known { 0 }
      age6 { 40 }
      income1nk { 0 }
      income1 { 10_000 }
      inc1mort { 1 }
      income2nk { 0 }
      income2 { 10_000 }
      inc2mort { 1 }
      la_known { 1 }
      la { "E09000003" }
      savingsnk { 1 }
      prevown { 1 }
      prevshared { 2 }
      sex3 { "X" }
      sex4 { "X" }
      sex5 { "X" }
      sex6 { "X" }
      mortgage { 20_000 }
      ecstat3 { 9 }
      ecstat4 { 3 }
      ecstat5 { 2 }
      ecstat6 { 1 }
      disabled { 1 }
      deposit { 80_000 }
      cashdis { 1_000 }
      value { 110_000 }
      grant { 10_000 }
      proplen { 10 }
      pregyrha { 1 }
      pregla { 1 }
      pregother { 1 }
      pregghb { 1 }
      hhregres { 1 }
      hhregresstill { 4 }
      ppcodenk { 1 }
      prevten { 1 }
      previous_la_known { 0 }
      relat3 { "C" }
      relat4 { "X" }
      relat5 { "R" }
      relat6 { "R" }
      hb { 4 }
      mortgageused { 1 }
      wchair { 1 }
      armedforcesspouse { 5 }
      has_mscharge { 1 }
      mscharge { 100 }
      mortlen { 10 }
      pcodenk { 1 }
      is_la_inferred { false }
      mortgagelender { 5 }
      extrabor { 1 }
    end
  end
end
