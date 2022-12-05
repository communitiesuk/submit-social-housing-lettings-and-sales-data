require "rails_helper"
require_relative "helpers"

RSpec.describe "Accessible Automcomplete" do
  include Helpers
  let(:user) { FactoryBot.create(:user) }
  let(:lettings_log) do
    FactoryBot.create(
      :lettings_log,
      :in_progress,
      created_by: user,
    )
  end

  before do
    allow(lettings_log.form).to receive(:end_date).and_return(Time.zone.today + 1.day)
    sign_in user
  end

  it "does not show when js is not enabled" do
    visit("/lettings-logs/#{lettings_log.id}/rent")
    expect(page).to have_selector("#tcharge_div", visible: :all)
  end

  it "does show when js is enabled and calculates the total", js: true do
    visit("/lettings-logs/#{lettings_log.id}/rent")
    expect(page).to have_selector("#tcharge_div")
    fill_in("lettings-log-brent-field", with: 5)
    expect(find("#lettings-log-tcharge-field").value).to eq("5.00")
    fill_in("lettings-log-pscharge-field", with: 3)
    expect(find("#lettings-log-tcharge-field").value).to eq("8.00")
  end

  it "total displays despite error message", js: true do
    visit("/lettings-logs/#{lettings_log.id}/rent")
    choose("lettings-log-period-1-field", allow_label_click: true)
    fill_in("lettings-log-brent-field", with: 500)
    fill_in("lettings-log-scharge-field", with: 50)
    fill_in("lettings-log-pscharge-field", with: 50)
    fill_in("lettings-log-supcharg-field", with: 5000)
    expect(find("#lettings-log-tcharge-field").value).to eq("5600.00")
    click_button("Save and continue")
    expect(page).to have_selector(".govuk-error-summary")
    fill_in("lettings-log-scharge-field", with: nil)
    fill_in("lettings-log-pscharge-field", with: nil)
    fill_in("lettings-log-supcharg-field-error", with: nil)
    fill_in("lettings-log-brent-field", with: 500)
    expect(find("#lettings-log-tcharge-field").value).to eq("500.00")
    fill_in("lettings-log-supcharg-field-error", with: 50)
    expect(find("#lettings-log-tcharge-field").value).to eq("550.00")
  end
end
