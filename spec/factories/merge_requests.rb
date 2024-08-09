FactoryBot.define do
  factory :merge_request do
    status { "incomplete" }
    merge_date { nil }
    association :requesting_organisation, factory: :organisation
  end
end
