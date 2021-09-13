require "rails_helper"
RSpec.describe "Test Features" do
  it "Displays the name of the app" do
    visit("/case_logs/new")
    expect(page).to have_field("age")
    expect(page).to have_button("Continue")
  end
end
