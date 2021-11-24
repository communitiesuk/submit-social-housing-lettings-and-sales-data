require "rails_helper"

RSpec.describe "Task List" do
  let!(:case_log) { FactoryBot.create(:case_log, :in_progress) }
  let!(:empty_case_log) { FactoryBot.create(:case_log) }
  let(:id) { case_log.id }
  let(:status) { case_log.status }

  before do
    allow_any_instance_of(CaseLogsController).to receive(:authenticate_user!).and_return(true)
  end

  def fill_in_number_question(case_log_id, question, value, path)
    visit("/case_logs/#{case_log_id}/#{path}")
    fill_in("case-log-#{question.to_s.dasherize}-field", with: value)
    click_button("Save and continue")
  end

  def answer_all_questions_in_income_subsection(case_log)
    visit("/case_logs/#{case_log.id}/net_income")
    fill_in("case-log-earnings-field", with: 18_000)
    choose("case-log-incfreq-yearly-field")
    click_button("Save and continue")
    choose("case-log-benefits-all-field")
    click_button("Save and continue")
    choose("case-log-hb-prefer-not-to-say-field")
    click_button("Save and continue")
  end

  it "displays a tasklist header" do
    visit("/case_logs/#{id}")
    expect(page).to have_content("Tasklist for log #{id}")
    expect(page).to have_content("This submission is #{status.humanize.downcase}")
  end

  it "displays a section status" do
    visit("/case_logs/#{empty_case_log.id}")

    assert_selector ".govuk-tag", text: /Not started/, count: 8
    assert_selector ".govuk-tag", text: /Completed/, count: 0
    assert_selector ".govuk-tag", text: /Cannot start yet/, count: 1
  end

  it "shows the correct status if one section is completed" do
    answer_all_questions_in_income_subsection(empty_case_log)
    visit("/case_logs/#{empty_case_log.id}")

    assert_selector ".govuk-tag", text: /Not started/, count: 7
    assert_selector ".govuk-tag", text: /Completed/, count: 1
    assert_selector ".govuk-tag", text: /Cannot start yet/, count: 1
  end

  it "skips to the first section if no answers are completed" do
    visit("/case_logs/#{empty_case_log.id}")
    expect(page).to have_link("Skip to next incomplete section", href: /#household_characteristics/)
  end

  it "shows the number of completed sections if no sections are completed" do
    visit("/case_logs/#{empty_case_log.id}")
    expect(page).to have_content("You've completed 0 of 9 sections.")
  end

  it "shows the number of completed sections if one section is completed" do
    answer_all_questions_in_income_subsection(empty_case_log)
    visit("/case_logs/#{empty_case_log.id}")
    expect(page).to have_content("You've completed 1 of 9 sections.")
  end
end
