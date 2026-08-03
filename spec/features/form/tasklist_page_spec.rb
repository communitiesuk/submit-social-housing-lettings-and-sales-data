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
      assigned_to: user,
    )
  end
  let(:completed_lettings_log) do
    FactoryBot.create(
      :lettings_log,
      :completed,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
      assigned_to: user,
    )
  end
  let(:empty_lettings_log) do
    FactoryBot.create(
      :lettings_log,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
      assigned_to: user,
    )
  end
  let(:setup_completed_log) do
    FactoryBot.create(
      :lettings_log,
      :setup_completed,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
      assigned_to: user,
    )
  end
  let(:id) { lettings_log.id }
  let(:status) { lettings_log.status }

  before do
    sign_in user
  end

  it "shows if the section has not been started" do
    visit("/lettings-logs/#{empty_lettings_log.id}")
    expect(page).to have_content("This log has not been started.")
  end

  describe "completed subsection count" do
    it "shows number of completed sections if one section is completed" do
      visit("/lettings-logs/#{setup_completed_log.id}")
      expect(page).to have_content("1 of 7 subsections completed.")
    end
  end

  it "show skip link for next incomplete section" do
    visit("/lettings-logs/#{setup_completed_log.id}")
    expect(page).to have_link("Skip to next incomplete section", href: /#property-information/)
  end

  it "has a review section which has a button that allows the data inputter to review the lettings log" do
    visit("/lettings-logs/#{completed_lettings_log.id}")
    expect(page).to have_content("review and make changes to this log")
    click_link(text: "review and make changes to this log")
    expect(page).to have_current_path("/lettings-logs/#{completed_lettings_log.id}/review")
  end
end
