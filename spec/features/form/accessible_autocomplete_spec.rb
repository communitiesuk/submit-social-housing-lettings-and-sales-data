require "rails_helper"
require_relative "helpers"
require_relative "../../request_helper"

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
    RequestHelper.stub_http_requests
    sign_in user
  end

  it "allows type ahead filtering", js: true do
    visit("/logs/#{case_log.id}/accessible-select")
    find("#case-log-la-field").click.native.send_keys("T", "h", "a", "n", :down, :enter)
    expect(find("#case-log-la-field").value).to eq("Thanet")
  end

  it "maintains enhancement state across back navigation", js: true do
    visit("/logs/#{case_log.id}/accessible-select")
    find("#case-log-la-field").click.native.send_keys("T", "h", "a", "n", :down, :enter)
    click_button("Save and continue")
    click_link(text: "Back")
    expect(page).to have_selector("input", class: "autocomplete__input", count: 1)
  end

  it "has a disabled null option" do
    visit("/logs/#{case_log.id}/accessible-select")
    expect(page).to have_select("case-log-la-field", disabled_options: ["Select an option"])
  end
end
