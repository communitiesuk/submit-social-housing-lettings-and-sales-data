require "rails_helper"
RSpec.describe "Test Features" do
  it "Displays the name of the app" do
    visit("/")
    expect(page).to have_content("Log social housing lettings and sales (CORE)")
  end
end
