FactoryBot.define do
  factory :merge_request do
    status { "incomplete" }
    merge_date { nil }
    has_helpdesk_ticket { true }
    helpdesk_ticket { "MSD-99999" }
    association :requesting_organisation, factory: :organisation
  end
end
