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
      created_by: user,
    )
  end
  let(:completed_case_log) do
    FactoryBot.create(
      :case_log,
      :completed,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
      created_by: user,
    )
  end
  let(:empty_case_log) do
    FactoryBot.create(
      :case_log,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
      created_by: user,
    )
  end
  let(:setup_completed_log) do
    FactoryBot.create(
      :case_log,
      :about_completed,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
      startdate: Time.zone.local(2021, 5, 1),
      created_by: user,
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
    visit("/logs/#{setup_completed_log.id}")
    expect(page).to have_content("1 of 8 sections completed.")
  end

  it "show skip link for next incomplete section" do
    answer_all_questions_in_income_subsection(setup_completed_log)
    visit("/logs/#{setup_completed_log.id}")
    expect(page).to have_link("Skip to next incomplete section", href: /#household-characteristics/)
  end

  it "has a review section which has a button that allows the data inputter to review the case log" do
    visit("/logs/#{completed_case_log.id}")
    expect(page).to have_content("review and make changes to this log")
    click_link(text: "review and make changes to this log")
    expect(page).to have_current_path("/logs/#{completed_case_log.id}/review")
  end
end
