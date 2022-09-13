FactoryBot.define do
  factory :sales_log do
    created_by { FactoryBot.create(:user) }
    owning_organisation { created_by.organisation }
    managing_organisation { created_by.organisation }
    created_at { Time.utc(2022, 2, 8, 16, 52, 15) }
    updated_at { Time.utc(2022, 2, 8, 16, 52, 15) }
    trait :completed do
      saledate { Time.utc(2022, 2, 2, 10, 36, 49) }
    end
  end
end
