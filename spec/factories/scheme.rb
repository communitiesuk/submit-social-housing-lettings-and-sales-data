FactoryBot.define do
  factory :scheme do
    service_name { Faker::Lorem.characters(number: 16) }
    sensitive { Faker::Number.within(range: 0..1) }
    registered_under_care_act { 1 }
    support_type { [0, 2, 3, 4, 5].sample }
    scheme_type { 4 }
    arrangement_type { "D" }
    intended_stay { %w[M P S V X].sample }
    primary_client_group { %w[O H M L A G F B D E I S N R Q P X].sample }
    secondary_client_group { %w[O H M L A G F B D E I S N R Q P X].sample }
    has_other_client_group { 1 }
    owning_organisation { FactoryBot.create(:organisation) }
    confirmed { true }
    created_at { Time.zone.local(2021, 4, 1) }
    total_units { 2 }
    trait :export do
      sensitive { 1 }
      registered_under_care_act { 1 }
      support_type { 4 }
      scheme_type { 7 }
      intended_stay { "M" }
      primary_client_group { "G" }
      secondary_client_group { "M" }
      has_other_client_group { 1 }
    end

    trait :with_old_visible_id do
      old_visible_id { rand(9_999_999) }
    end
    trait :incomplete do
      confirmed { false }
      support_type { nil }
    end
    trait :duplicate do
      scheme_type { 4 }
      registered_under_care_act { 1 }
      primary_client_group { "O" }
      secondary_client_group { "H" }
      has_other_client_group { 1 }
      support_type { 2 }
      intended_stay { "M" }
    end
  end
end
