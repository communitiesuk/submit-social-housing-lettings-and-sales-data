require "rails_helper"
require_relative "helpers"
require_relative "../../request_helper"

RSpec.describe "Form Page Routing" do
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
  let(:id) { case_log.id }

  before do
    RequestHelper.stub_http_requests
    allow_any_instance_of(CaseLogValidator).to receive(:validate_pregnancy).and_return(true)
    sign_in user
  end

  it "can route the user to a different page based on their answer on the current page", js: true do
    visit("/logs/#{id}/conditional-question")
    # using a question name that is already in the db to avoid
    # having to add a new column to the db for this test
    choose("case-log-preg-occ-yes-field", allow_label_click: true)
    click_button("Save and continue")
    expect(page).to have_current_path("/logs/#{id}/conditional-question-yes-page")
    click_link(text: "Back")
    expect(page).to have_current_path("/logs/#{id}/conditional-question")
    choose("case-log-preg-occ-no-field", allow_label_click: true)
    click_button("Save and continue")
    expect(page).to have_current_path("/logs/#{id}/conditional-question-no-page")
  end

  it "can route based on multiple conditions", js: true do
    visit("/logs/#{id}/person-1-gender")
    choose("case-log-sex1-female-field", allow_label_click: true)
    click_button("Save and continue")
    expect(page).to have_current_path("/logs/#{id}/household-number-of-other-members")
    visit("/logs/#{id}/conditional-question")
    choose("case-log-preg-occ-no-field", allow_label_click: true)
    click_button("Save and continue")
    expect(page).to have_current_path("/logs/#{id}/conditional-question-no-page")
    click_button("Save and continue")
    expect(page).to have_current_path("/logs/#{id}/conditional-question/check-answers")
  end

  context "when the answers are inferred", js: true do
    it "shows question if the answer could not be inferred" do
      visit("/logs/#{id}/property-postcode")
      fill_in("case-log-property-postcode-field", with: "PO5 3TE")
      click_button("Save and continue")
      expect(page).to have_current_path("/logs/#{id}/do-you-know-the-local-authority")
    end

    it "shows question if the answer could not be inferred from an empty input" do
      visit("/logs/#{id}/property-postcode")
      click_button("Save and continue")
      expect(page).to have_current_path("/logs/#{id}/do-you-know-the-local-authority")
    end

    it "does not show question if the answer could be inferred" do
      stub_request(:get, /api.postcodes.io/)
        .to_return(status: 200, body: "{\"status\":200,\"result\":{\"admin_district\":\"Manchester\"}}", headers: {})

      visit("/logs/#{id}/property-postcode")
      fill_in("case-log-property-postcode-field", with: "P0 5ST")
      click_button("Save and continue")
      expect(page).to have_current_path("/logs/#{id}/property-wheelchair-accessible")
    end
  end
end
