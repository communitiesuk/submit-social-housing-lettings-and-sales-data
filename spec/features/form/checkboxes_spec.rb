require "rails_helper"
require_relative "helpers"
require_relative "../../request_helper"

RSpec.describe "Checkboxes" do
  include Helpers
  let(:user) { FactoryBot.create(:user) }
  let(:lettings_log) do
    FactoryBot.create(
      :lettings_log,
      :in_progress,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
    )
  end
  let(:id) { lettings_log.id }

  before do
    RequestHelper.stub_http_requests
    sign_in user
  end

  context "when exclusive checkbox is selected", js: true do
    it "deselects all other checkboxes" do
      visit("/logs/#{id}/accessibility-requirements")
      page.check("lettings-log-accessibility-requirements-housingneeds-a-field", allow_label_click: true)
      click_button("Save and continue")

      lettings_log.reload
      expect(lettings_log["housingneeds_a"]).to eq(1)

      visit("/logs/#{id}/accessibility-requirements")
      page.check("lettings-log-accessibility-requirements-housingneeds-h-field", allow_label_click: true)
      click_button("Save and continue")

      lettings_log.reload
      expect(lettings_log["housingneeds_a"]).to eq(0)
      expect(lettings_log["housingneeds_h"]).to eq(1)
    end
  end

  context "when a checkbox question is submitted with invalid answers" do
    before do
      lettings_log.update!(illness: 100)
      allow(lettings_log).to receive(:update).and_return(false)
    end

    it "shows an error summary" do
      visit("/logs/#{id}/condition-effects")
      page.check("lettings-log-condition-effects-illness-type-1-field")
      page.check("lettings-log-condition-effects-illness-type-2-field")
      click_button("Save and continue")
      expect(page).to have_title("Error")
    end

    it "persists the original selections" do
      visit("/logs/#{id}/condition-effects")
      page.check("lettings-log-condition-effects-illness-type-1-field")
      page.check("lettings-log-condition-effects-illness-type-2-field")
      click_button("Save and continue")
      expect(page).to have_checked_field("lettings-log-condition-effects-illness-type-2-field")
    end
  end
end
