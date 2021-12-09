require "rails_helper"
require_relative "helpers"

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
end
