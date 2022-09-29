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
      jointpur { 1 }
      beds { 2 }
      jointmore { 1 }
      age1_known { 0 }
      age1 { 30 }
      sex1 { "X" }
      buy1livein { 1 }
      relat2 { "P" }
      proptype { 1 }
      age2_known { 0 }
      age2 { 35 }
    end
  end
end
