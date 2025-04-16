FactoryBot.define do
  factory :organisation_name_change do
    association :organisation
    name { "#{Faker::Name.name} Housing Org" }
    immediate_change { true }
    startdate { Time.zone.now }
    change_type { :user_change }

    trait :future_change do
      immediate_change { false }
      startdate { 5.days.from_now }
    end

    trait :merge_change do
      change_type { :merge }
    end
  end
end
