FactoryBot.define do
  factory :csv_download do
    download_type { "lettings" }
    user { create(:user) }
    organisation { user.organisation }
    filename { "lettings.csv" }
  end
end
