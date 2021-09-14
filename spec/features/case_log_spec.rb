require "rails_helper"
RSpec.describe "Test Features" do
  let!(:case_log) { FactoryBot.create(:case_log) }
  let(:id) { case_log.id }
  let(:status) { case_log.status }

  it "displays a tasklist header" do
    visit("/case_logs/342351")
    expect(page).to have_content("Tasklist for log #{id}")
    expect(page).to have_content("This submission is #{status}")
  end

  it "has an edit form" do
    visit("/case_logs/new")
    expect(page).to have_field("age")
    expect(page).to have_button("Continue")
  end

  it "displays the household questions when you click into that section" do
    visit("/case_logs/#{id}")
    click_link("Household characteristics")
    expect(page).to have_field("case-log-tenant-code-field")
    click_button("Save and continue")
    expect(page).to have_field("case-log-tenant-age-field")
  end
end
