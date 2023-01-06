FactoryBot.define do
  factory :organisation do
    name { "DLUHC" }
    address_line1 { "2 Marsham Street" }
    address_line2 { "London" }
    provider_type { "LA" }
    housing_registration_no { "1234" }
    postcode { "SW1P 4DF" }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
    holds_own_stock { true }
    old_visible_id { rand(9_999_999).to_s }
  end

  factory :organisation_rent_period do
    organisation
    rent_period { 2 }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
  end
end
