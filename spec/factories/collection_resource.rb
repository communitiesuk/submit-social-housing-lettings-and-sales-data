FactoryBot.define do
  factory :collection_resource, class: "CollectionResource" do
    resource_type { "paper_form" }
    display_name { "lettings log for tenants (2021 to 2022)" }
    short_display_name { "Paper Form" }
    year { 2024 }
    log_type { "lettings" }
    download_filename { "24_25_lettings_paper_form.pdf" }
    trait(:additional) do
      resource_type { nil }
      display_name { "lettings additional resource (2024 to 2025)" }
      short_display_name { "additional resource" }
      year { 2024 }
      log_type { "lettings" }
      download_filename { "additional.pdf" }
      mandatory { false }
    end
  end
end
