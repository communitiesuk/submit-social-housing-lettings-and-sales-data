FactoryBot.define do
  factory :admin_user do
    sequence(:email) { |i| "admin#{i}@example.com" }
    password { "pAssword1" }
    phone { "07563867654" }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
  end
end
