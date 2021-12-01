require "rails_helper"
RSpec.describe "Test Features" do
  it "Displays the name of the app" do
    visit("/")
    expect(page).to have_content("Log social housing lettings and sales (CORE)")
  end

  it "Links to the About page" do
    visit("/")
    click_link("About")
    expect(current_path).to eql("/about")
    expect(page).to have_content("About")
  end
end
