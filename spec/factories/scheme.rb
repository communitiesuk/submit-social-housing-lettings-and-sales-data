FactoryBot.define do
  factory :scheme do
    code { Faker::Name.initials(number: 4) }
    service { Faker::Name.name_with_middle }
    managing_agent { Faker::Company.name }
    created_at { Time.zone.now }
  end
end
