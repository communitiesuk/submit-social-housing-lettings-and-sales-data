require "rails_helper"
require_relative "helpers"

RSpec.describe "Form Review Page" do
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
  let(:completed_case_log) do
    FactoryBot.create(
      :case_log,
      :completed,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
    )
  end

  before do
    sign_in user
  end

  context "when the user wishes to review their case log" do
    it "the review page can be visited by URL" do
      visit("/logs/#{completed_case_log.id}/review")
      expect(page).to have_content("Review lettings log")
    end

    it "the review page allows the user to submit a completed case log" do
      visit("/logs/#{completed_case_log.id}/review")
      click_button("Submit lettings log")
      expect(page).to have_current_path("/logs")
      expect(page).to have_content("Success")
      expect(page).to have_content("Log #{completed_case_log.id} has been submitted")
    end
    
    it "the review page displays an error message if all mandatory questions have not been completed when submitting" do
      visit("/logs/#{case_log.id}/review")
      click_button("Submit lettings log")
      expect(page).to have_current_path("/logs/#{case_log.id}/review")
      expect(page).to have_content("All mandatory fields have not been completed, please refer to section status")
    end
  end
end
