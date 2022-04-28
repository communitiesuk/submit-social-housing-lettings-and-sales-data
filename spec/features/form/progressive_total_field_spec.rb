require "rails_helper"
require_relative "helpers"

RSpec.describe "Accessible Automcomplete" do
  include Helpers
  let(:user) { FactoryBot.create(:user) }
  let(:case_log) do
    FactoryBot.create(
      :case_log,
      :in_progress,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
    )
  end

  before do
    sign_in user
  end

  it "does not show when js is not enabled" do
    visit("/logs/#{case_log.id}/rent")
    expect(page).to have_selector("#tcharge_div", visible: :all)
  end

  it "does show when js is enabled and calculates the total", js: true do
    visit("/logs/#{case_log.id}/rent")
    expect(page).to have_selector("#tcharge_div")
    fill_in("case-log-brent-field", with: 5)
    expect(find("#case-log-tcharge-field").value).to eq("5.00")
    fill_in("case-log-pscharge-field", with: 3)
    expect(find("#case-log-tcharge-field").value).to eq("8.00")
  end

  it "total displays despite error message", js: true do
    visit("/logs/#{case_log.id}/rent")
    fill_in("case-log-brent-field", with: 500)
    fill_in("case-log-scharge-field", with: 50)
    fill_in("case-log-pscharge-field", with: 50)
    fill_in("case-log-supcharg-field", with: 5000)
    expect(find("#case-log-tcharge-field").value).to eq("5600.00")
    click_button("Save and continue")
    expect(page).to have_selector(".govuk-error-summary")
    fill_in("case-log-brent-field", with: 500)
    expect(find("#case-log-tcharge-field").value).to eq("500.00")
    fill_in("case-log-supcharg-field-error", with: 50)
    expect(find("#case-log-tcharge-field").value).to eq("550.00")
  end
end
