FactoryBot.define do
  factory :user do
    email { "test@example.com" }
    password { "pAssword1" }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
  end
end
