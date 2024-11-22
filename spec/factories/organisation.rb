FactoryBot.define do
  factory :organisation do
    name { "MHCLG" }
    address_line1 { "2 Marsham Street" }
    address_line2 { "London" }
    provider_type { "LA" }
    housing_registration_no { "1234" }
    postcode { "SW1P 4DF" }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
    holds_own_stock { true }

    transient do
      with_dsa { true }
    end

    transient do
      rent_periods { [] }
    end

    after(:create) do |organisation, evaluator|
      evaluator.rent_periods.each do |rent_period|
        organisation.organisation_rent_periods << build(:organisation_rent_period, rent_period:)
      end
    end

    after(:create) do |org, evaluator|
      if evaluator.with_dsa && !org.data_protection_confirmed?
        create(
          :data_protection_confirmation,
          organisation: org,
          data_protection_officer: org.users.any? ? org.users.first : create(:user, :data_protection_officer, organisation: org, with_dsa: false),
        )
      end
    end

    trait :with_old_visible_id do
      old_visible_id { rand(9_999_999).to_s }
    end

    trait :prp do
      provider_type { "PRP" }
    end
    trait :la do
      provider_type { "LA" }
    end

    trait :holds_own_stock do
      holds_own_stock { true }
    end
    trait :does_not_own_stock do
      holds_own_stock { false }
    end

    trait :without_dpc do
      transient do
        with_dsa { false }
      end

      data_protection_confirmation { nil }
    end

    trait :if_unique do
      initialize_with { Organisation.find_or_create_by(name:) }
    end
  end

  factory :organisation_rent_period do
    organisation
    rent_period { 2 }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
  end
end
