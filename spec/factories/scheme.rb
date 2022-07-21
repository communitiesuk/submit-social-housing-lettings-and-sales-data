FactoryBot.define do
  factory :scheme do
    service_name { Faker::Name.name }
    sensitive { Faker::Number.within(range: 0..1) }
    registered_under_care_act { 1 }
    support_type { [0, 2, 3, 4, 5].sample }
    scheme_type { 0 }
    intended_stay { %w[M P S V X].sample }
    primary_client_group { %w[O H M L A G F B D E I S N R Q P X].sample }
    secondary_client_group { %w[O H M L A G F B D E I S N R Q P X].sample }
    owning_organisation { FactoryBot.create(:organisation) }
    created_at { Time.zone.now }
    trait :export do
      sensitive { 1 }
      registered_under_care_act { 1 }
      support_type { 4 }
      scheme_type { 7 }
      intended_stay { "M" }
      primary_client_group { "G" }
      secondary_client_group { "M" }
    end
  end
end
