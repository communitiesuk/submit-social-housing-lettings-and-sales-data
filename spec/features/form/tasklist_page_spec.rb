require "rails_helper"
require_relative "helpers"

RSpec.describe "Task List" do
  include Helpers
  let(:user) { FactoryBot.create(:user) }
  let(:lettings_log) do
    FactoryBot.create(
      :lettings_log,
      :in_progress,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
      created_by: user,
      )
  end
  let(:completed_lettings_log) do
    FactoryBot.create(
      :lettings_log,
      :completed,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
      created_by: user,
      )
  end
  let(:empty_lettings_log) do
    FactoryBot.create(
      :lettings_log,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
      created_by: user,
      )
  end
  let(:setup_completed_log) do
    FactoryBot.create(
      :lettings_log,
      :about_completed,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
      created_by: user,
    )
  end
  let(:id) { lettings_log.id }
  let(:status) { lettings_log.status }

  before do
    allow(lettings_log.form).to receive(:end_date).and_return(Time.zone.today + 1.day)
    sign_in user
  end

  it "shows if the section has not been started" do
    visit("/lettings-logs/#{empty_lettings_log.id}")
    expect(page).to have_content("This log has not been started.")
  end

  it "shows number of completed sections if one section is completed" do
    visit("/lettings-logs/#{setup_completed_log.id}")
    expect(page).to have_content("1 of 8 sections completed.")
  end

  it "show skip link for next incomplete section" do
    answer_all_questions_in_income_subsection(setup_completed_log)
    visit("/lettings-logs/#{setup_completed_log.id}")
    expect(page).to have_link("Skip to next incomplete section", href: /#household-characteristics/)
  end

  it "has a review section which has a button that allows the data inputter to review the lettings log" do
    visit("/lettings-logs/#{completed_lettings_log.id}")
    expect(page).to have_content("review and make changes to this log")
    click_link(text: "review and make changes to this log")
    expect(page).to have_current_path("/lettings-logs/#{completed_lettings_log.id}/review")
  end
end
