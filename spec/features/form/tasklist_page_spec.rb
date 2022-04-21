require "rails_helper"
require_relative "helpers"

RSpec.describe "Task List" do
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
  let(:empty_case_log) do
    FactoryBot.create(
      :case_log,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
    )
  end
  let(:id) { case_log.id }
  let(:status) { case_log.status }

  before do
    sign_in user
  end

  it "shows if the section has not been started" do
    visit("/logs/#{empty_case_log.id}")
    expect(page).to have_content("This log has not been started.")
  end

  it "shows number of completed sections if one section is completed" do
    answer_all_questions_in_income_subsection(empty_case_log)
    visit("/logs/#{empty_case_log.id}")
    expect(page).to have_content("1 of 9 sections completed.")
  end

  it "show skip link for next incomplete section" do
    answer_all_questions_in_income_subsection(empty_case_log)
    visit("/logs/#{empty_case_log.id}")
    expect(page).to have_link("Skip to next incomplete section", href: /#household-characteristics/)
  end

  it "has a review section which has a button that allows the data inputter to review the case log" do
    visit("/logs/#{case_log.id}")
    expect(page).to have_content("Review your answers and submit this log to the Department of Levelling Up, Housing & Communities.")
    click_link(text: "Review lettings log")
    expect(page).to have_current_path("/logs/#{case_log.id}/review")
  end
end
