FactoryBot.define do
  factory :csv_download do
    download_type { "lettings" }
    user { create(:user) }
    organisation { user.organisation }
    filename { "lettings.csv" }
    expiration_time { 24.hours.to_i }
  end
end
