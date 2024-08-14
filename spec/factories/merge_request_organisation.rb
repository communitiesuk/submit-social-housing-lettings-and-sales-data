FactoryBot.define do
  factory :merge_request_organisation do
    association :merging_organisation, factory: :organisation
    association :merge_request, factory: :merge_request
  end
end
