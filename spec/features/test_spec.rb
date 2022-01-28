require "rails_helper"
RSpec.describe "Test Features" do
  it "Displays the name of the app" do
    visit("/")
    expect(page).to have_content("Submit social housing lettings and sales data (CORE)")
  end

  it "Responds to a health check" do
    visit("/health")
    expect(page).to have_http_status(204)
  end
end
