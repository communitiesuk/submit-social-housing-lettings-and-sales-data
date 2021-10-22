FactoryBot.define do
  factory :income_range do
    sequence(:id) { |i| i }
    trait :full_time do
      economic_status { "full_time" }
      soft_min { 143 }
      soft_max { 730 }
      hard_min { 90 }
      hard_max { 1230 }
    end
    trait :retired do
      economic_status { "retired" }
      soft_min { 50 }
      soft_max { 370 }
      hard_min { 10 }
      hard_max { 690 }
    end
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
  end
end
