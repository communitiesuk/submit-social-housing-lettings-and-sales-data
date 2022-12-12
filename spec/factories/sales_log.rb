FactoryBot.define do
  factory :sales_log do
    created_by { FactoryBot.create(:user) }
    owning_organisation { created_by.organisation }
    managing_organisation { created_by.organisation }
    created_at { Time.utc(2022, 2, 8, 16, 52, 15) }
    updated_at { Time.utc(2022, 2, 8, 16, 52, 15) }
    trait :in_progress do
      purchid { "PC123" }
      ownershipsch { 2 }
      type { 8 }
      saledate { Time.utc(2022, 2, 2, 10, 36, 49) }
    end
    trait :completed do
      purchid { "PC123" }
      ownershipsch { 2 }
      type { 8 }
      saledate { Time.utc(2022, 2, 2, 10, 36, 49) }
      companybuy { 1 }
      jointpur { 1 }
      beds { 2 }
      jointmore { 1 }
      noint { 2 }
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
      ethnic_group { 12 }
      sex2 { "X" }
      buy2livein { "1" }
      ecstat1 { "1" }
      ecstat2 { "1" }
      hholdcount { "1" }
      wheel { 1 }
      details_known_1 { 1 }
      age3_known { 0 }
      age3 { 40 }
      details_known_2 { 1 }
      age4_known { 0 }
      age4 { 40 }
      details_known_3 { 1 }
      age5_known { 0 }
      age5 { 40 }
      details_known_4 { 1 }
      age6_known { 0 }
      age6 { 40 }
      income1nk { 0 }
      income1 { 10_000 }
      inc1mort { 1 }
      income2nk { 0 }
      income2 { 10_000 }
      la_known { "1" }
      la { "E09000003" }
      savingsnk { 1 }
      prevown { 1 }
      sex3 { "X" }
    end
  end
end
