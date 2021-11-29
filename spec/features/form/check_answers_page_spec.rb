require "rails_helper"
require_relative "helpers"

RSpec.describe "Form Check Answers Page" do
  include Helpers
  let(:user) { FactoryBot.create(:user) }
  let(:case_log) do
    FactoryBot.create(
      :case_log,
      :in_progress,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation
    )
  end
  let(:empty_case_log) do
    FactoryBot.create(
      :case_log,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation
    )
  end
  let(:id) { case_log.id }

  before do
    sign_in user
  end

  let(:subsection) { "household_characteristics" }
  let(:conditional_subsection) { "conditional_question" }

  context "when the user needs to check their answers for a subsection" do
    it "can be visited by URL" do
      visit("case_logs/#{id}/#{subsection}/check_answers")
      expect(page).to have_content("Check the answers you gave for #{subsection.tr('_', ' ')}")
    end

    let(:last_question_for_subsection) { "household_number_of_other_members" }
    it "redirects to the check answers page when answering the last question and clicking save and continue" do
      fill_in_number_question(id, "other_hhmemb", 0, last_question_for_subsection)
      expect(page).to have_current_path("/case_logs/#{id}/#{subsection}/check_answers")
    end

    it "has question headings based on the subsection" do
      visit("case_logs/#{id}/#{subsection}/check_answers")
      question_labels = ["Tenant code", "Tenant's age", "Tenant's gender", "Number of Other Household Members"]
      question_labels.each do |label|
        expect(page).to have_content(label)
      end
    end

    it "should display answers given by the user for the question in the subsection" do
      fill_in_number_question(empty_case_log.id, "age1", 28, "person_1_age")
      choose("case-log-sex1-non-binary-field")
      click_button("Save and continue")
      visit("/case_logs/#{empty_case_log.id}/#{subsection}/check_answers")
      expect(page).to have_content("28")
      expect(page).to have_content("Non-binary")
    end

    it "should have an answer link for questions missing an answer" do
      visit("case_logs/#{empty_case_log.id}/#{subsection}/check_answers")
      assert_selector "a", text: /Answer\z/, count: 4
      assert_selector "a", text: "Change", count: 0
      expect(page).to have_link("Answer", href: "/case_logs/#{empty_case_log.id}/person_1_age")
    end

    it "should have a change link for answered questions" do
      fill_in_number_question(empty_case_log.id, "age1", 28, "person_1_age")
      visit("/case_logs/#{empty_case_log.id}/#{subsection}/check_answers")
      assert_selector "a", text: /Answer\z/, count: 3
      assert_selector "a", text: "Change", count: 1
      expect(page).to have_link("Change", href: "/case_logs/#{empty_case_log.id}/person_1_age")
    end

    it "should have a change link for answered questions" do
      visit("/case_logs/#{empty_case_log.id}/household_needs/check_answers")
      assert_selector "a", text: /Answer\z/, count: 4
      assert_selector "a", text: "Change", count: 0
      visit("/case_logs/#{empty_case_log.id}/accessibility_requirements")
      check("case-log-accessibility-requirements-housingneeds-c-field")
      click_button("Save and continue")
      visit("/case_logs/#{empty_case_log.id}/household_needs/check_answers")
      assert_selector "a", text: /Answer\z/, count: 3
      assert_selector "a", text: "Change", count: 1
      expect(page).to have_link("Change", href: "/case_logs/#{empty_case_log.id}/accessibility_requirements")
    end

    it "should have a link pointing to the first question if no questions are answered" do
      visit("/case_logs/#{empty_case_log.id}/#{subsection}/check_answers")
      expect(page).to have_content("You answered 0 of 4 questions")
      expect(page).to have_link("Answer the missing questions", href: "/case_logs/#{empty_case_log.id}/tenant_code")
    end

    it "should have a link pointing to the next empty question if some questions are answered" do
      fill_in_number_question(empty_case_log.id, "earnings", 18_000, "net_income")

      visit("/case_logs/#{empty_case_log.id}/income_and_benefits/check_answers")
      expect(page).to have_content("You answered 1 of 4 questions")
      expect(page).to have_link("Answer the missing questions", href: "/case_logs/#{empty_case_log.id}/net_income")
    end

    it "should not display the missing answer questions link if all questions are answered" do
      answer_all_questions_in_income_subsection(empty_case_log)
      expect(page).to have_content("You answered all the questions")
      assert_selector "a", text: "Answer the missing questions", count: 0
    end

    it "does not display conditional questions that were not visited" do
      visit("case_logs/#{id}/#{conditional_subsection}/check_answers")
      question_labels = ["Has the condition been met?"]
      question_labels.each do |label|
        expect(page).to have_content(label)
      end

      excluded_question_labels = ["Has the next condition been met?", "Has the condition not been met?"]
      excluded_question_labels.each do |label|
        expect(page).not_to have_content(label)
      end
    end

    it "displays conditional question that were visited" do
      visit("/case_logs/#{id}/conditional_question")
      choose("case-log-preg-occ-no-field")
      click_button("Save and continue")
      visit("/case_logs/#{id}/#{conditional_subsection}/check_answers")
      question_labels = ["Has the condition been met?", "Has the condition not been met?"]
      question_labels.each do |label|
        expect(page).to have_content(label)
      end

      excluded_question_labels = ["Has the next condition been met?"]
      excluded_question_labels.each do |label|
        expect(page).not_to have_content(label)
      end
    end
  end
end
