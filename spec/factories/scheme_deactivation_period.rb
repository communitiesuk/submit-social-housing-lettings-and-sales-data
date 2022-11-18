FactoryBot.define do
  factory :scheme_deactivation_period do
    deactivation_date { Time.zone.local(2022, 4, 1) }
    reactivation_date { nil }
  end
end
