require "rails_helper"

RSpec.describe "Form Page Routing" do
  let!(:case_log) { FactoryBot.create(:case_log, :in_progress) }
  let(:id) { case_log.id }

  before do
    allow_any_instance_of(CaseLogsController).to receive(:authenticate_user!).and_return(true)
    allow_any_instance_of(CaseLogValidator).to receive(:validate_pregnancy).and_return(true)
  end

  it "can route the user to a different page based on their answer on the current page", js: true do
    visit("case_logs/#{id}/conditional_question")
    # using a question name that is already in the db to avoid
    # having to add a new column to the db for this test
    choose("case-log-preg-occ-yes-field", allow_label_click: true)
    click_button("Save and continue")
    expect(page).to have_current_path("/case_logs/#{id}/conditional_question_yes_page")
    click_link(text: "Back")
    expect(page).to have_current_path("/case_logs/#{id}/conditional_question")
    choose("case-log-preg-occ-no-field", allow_label_click: true)
    click_button("Save and continue")
    expect(page).to have_current_path("/case_logs/#{id}/conditional_question_no_page")
  end

  it "can route based on multiple conditions", js: true do
    visit("/case_logs/#{id}/person_1_gender")
    choose("case-log-sex1-female-field", allow_label_click: true)
    click_button("Save and continue")
    expect(page).to have_current_path("/case_logs/#{id}/household_number_of_other_members")
    visit("/case_logs/#{id}/conditional_question")
    choose("case-log-preg-occ-no-field", allow_label_click: true)
    click_button("Save and continue")
    expect(page).to have_current_path("/case_logs/#{id}/conditional_question_no_page")
    click_button("Save and continue")
    expect(page).to have_current_path("/case_logs/#{id}/conditional_question/check_answers")
  end
end
