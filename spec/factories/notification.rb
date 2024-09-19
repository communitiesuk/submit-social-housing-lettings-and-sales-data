FactoryBot.define do
  factory :notification do
    title { "Notification title" }
    link_text { "Link text" }
    page_content { "Some html content" }
    start_date { Time.zone.yesterday }
    end_date { Time.zone.tomorrow }
    show_on_unauthenticated_pages { false }
    show_additional_page { true }
  end
end
