require "rails_helper"
require_relative "helpers"

RSpec.describe "Form Review Page" do
  include Helpers
  let(:user) { FactoryBot.create(:user) }
  let(:completed_unsubmitted_case_log) do
    FactoryBot.create(
      :case_log,
      :completed,
      status: 1,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
    )
  end

  before do
    sign_in user
  end

  context "when the user wishes to review their case log" do
    it "the review page can be visited by URL" do
      visit("/logs/#{completed_unsubmitted_case_log.id}/review")
      expect(page).to have_content("Review lettings log")
    end

    it "the review page allows the user to submit a completed case log" do
      visit("/logs/#{completed_unsubmitted_case_log.id}/review")
      click_button("Submit lettings log")
      expect(page).to have_content("Success")
      expect(page).to have_content("Log #{completed_unsubmitted_case_log.id} has been submitted")
    end 
  end
end
