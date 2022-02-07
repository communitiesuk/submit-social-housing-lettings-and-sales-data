require "rails_helper"
require_relative "helpers"

RSpec.describe "Form Check Answers Page" do
  include Helpers
  let(:user) { FactoryBot.create(:user) }
  let(:subsection) { "household-characteristics" }
  let(:conditional_subsection) { "conditional-question" }
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
  let(:completed_case_log) do
    FactoryBot.create(
      :case_log,
      :completed,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
    )
  end
  let(:id) { case_log.id }

  before do
    sign_in user
  end

  context "when the user needs to check their answers for a subsection" do
    let(:last_question_for_subsection) { "propcode" }

    it "can be visited by URL" do
      visit("/logs/#{id}/#{subsection}/check-answers")
      expect(page).to have_content("#{subsection.tr('-', ' ').humanize} Check your answers")
    end

    it "redirects to the check answers page when answering the last question and clicking save and continue" do
      fill_in_number_question(id, "propcode", 0, last_question_for_subsection)
      expect(page).to have_current_path("/logs/#{id}/#{subsection}/check-answers")
    end

    it "has question headings based on the subsection" do
      visit("/logs/#{id}/#{subsection}/check-answers")
      question_labels = ["Tenant code", "Tenant’s age", "Tenant’s gender", "Number of Other Household Members"]
      question_labels.each do |label|
        expect(page).to have_content(label)
      end
    end

    it "displays answers given by the user for the question in the subsection" do
      fill_in_number_question(empty_case_log.id, "age1", 28, "person-1-age")
      choose("case-log-sex1-non-binary-field")
      click_button("Save and continue")
      visit("/logs/#{empty_case_log.id}/#{subsection}/check-answers")
      expect(page).to have_content("28")
      expect(page).to have_content("Non-binary")
    end

    # Regex explanation: match the string "Answer" but not if it's follow by "the missing questions"
    # This way only the links in the table will get picked up
    it "has an answer link for questions missing an answer" do
      visit("/logs/#{empty_case_log.id}/#{subsection}/check-answers")
      assert_selector "a", text: /Answer (?!the missing questions)/, count: 4
      assert_selector "a", text: "Change", count: 0
      expect(page).to have_link("Answer", href: "/logs/#{empty_case_log.id}/person-1-age")
    end

    it "has a change link for answered questions" do
      fill_in_number_question(empty_case_log.id, "age1", 28, "person-1-age")
      visit("/logs/#{empty_case_log.id}/#{subsection}/check-answers")
      assert_selector "a", text: /Answer (?!the missing questions)/, count: 3
      assert_selector "a", text: "Change", count: 1
      expect(page).to have_link("Change", href: "/logs/#{empty_case_log.id}/person-1-age")
    end

    it "updates the change/answer link when answers get updated" do
      visit("/logs/#{empty_case_log.id}/household-needs/check-answers")
      assert_selector "a", text: /Answer (?!the missing questions)/, count: 5
      assert_selector "a", text: "Change", count: 0
      visit("/logs/#{empty_case_log.id}/accessibility-requirements")
      check("case-log-accessibility-requirements-housingneeds-c-field")
      click_button("Save and continue")
      visit("/logs/#{empty_case_log.id}/household-needs/check-answers")
      assert_selector "a", text: /Answer (?!the missing questions)/, count: 4
      assert_selector "a", text: "Change", count: 1
      expect(page).to have_link("Change", href: "/logs/#{empty_case_log.id}/accessibility-requirements")
    end

    it "does not display conditional questions that were not visited" do
      visit("/logs/#{id}/#{conditional_subsection}/check-answers")
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
      visit("/logs/#{id}/conditional-question")
      choose("case-log-preg-occ-no-field", allow_label_click: true)
      click_button("Save and continue")
      visit("/logs/#{id}/#{conditional_subsection}/check-answers")
      question_labels = ["Has the condition been met?", "Has the condition not been met?"]
      question_labels.each do |label|
        expect(page).to have_content(label)
      end

      excluded_question_labels = ["Has the next condition been met?"]
      excluded_question_labels.each do |label|
        expect(page).not_to have_content(label)
      end
    end

    context "when the user wants to bypass the tasklist page from check answers" do
      let(:section_completed_case_log) do
        FactoryBot.create(
          :case_log,
          :in_progress,
          owning_organisation: user.organisation,
          managing_organisation: user.organisation,
          tenant_code: "123",
          age1: 35,
          sex1: "Male",
          other_hhmemb: 0,
        )
      end

      let(:next_section_in_progress_case_log) do
        FactoryBot.create(
          :case_log,
          :in_progress,
          owning_organisation: user.organisation,
          managing_organisation: user.organisation,
          tenant_code: "123",
          age1: 35,
          sex1: "Male",
          other_hhmemb: 0,
          armedforces: "No",
          illness: "No",
        )
      end

      let(:skip_section_case_log) do
        FactoryBot.create(
          :case_log,
          :in_progress,
          owning_organisation: user.organisation,
          managing_organisation: user.organisation,
          tenant_code: "123",
          age1: 35,
          sex1: "Male",
          other_hhmemb: 0,
          armedforces: "No",
          illness: "No",
          housingneeds_h: "Yes",
          la: "York",
          illness_type_1: "Yes",
        )
      end

      let(:cycle_sections_case_log) do
        FactoryBot.create(
          :case_log,
          :in_progress,
          owning_organisation: user.organisation,
          managing_organisation: user.organisation,
          tenant_code: nil,
          age1: nil,
          layear: "1 to 2 years",
          lawaitlist: "Less than 1 year",
          property_postcode: "NW1 5TY",
          reason: "Permanently decanted from another property owned by this landlord",
          previous_postcode: "SE2 6RT",
          mrcdate: Time.zone.parse("03/11/2019"),
        )
      end

      it "they can click a button to move onto the first page of the next (not started) incomplete section" do
        visit("/logs/#{section_completed_case_log.id}/household-characteristics/check-answers")
        click_link("Save and go to next incomplete section")
        expect(page).to have_current_path("/logs/#{section_completed_case_log.id}/armed-forces")
      end

      it "they can click a button to move onto the check answers page of the next (in progress) incomplete section" do
        visit("/logs/#{next_section_in_progress_case_log.id}/household-characteristics/check-answers")
        click_link("Save and go to next incomplete section")
        expect(page).to have_current_path("/logs/#{next_section_in_progress_case_log.id}/household-needs/check-answers")
      end

      it "they can click a button to skip sections until the next incomplete section" do
        visit("/logs/#{skip_section_case_log.id}/household-characteristics/check-answers")
        click_link("Save and go to next incomplete section")
        expect(page).to have_current_path("/logs/#{skip_section_case_log.id}/tenancy-code")
      end

      it "they can click a button to cycle around to the next incomplete section" do
        visit("/logs/#{cycle_sections_case_log.id}/declaration/check-answers")
        click_link("Save and go to next incomplete section")
        expect(page).to have_current_path("/logs/#{cycle_sections_case_log.id}/tenant-code")
      end

      it "they can click a button to move to the submission section when all sections have been completed", js: true do
        visit("/logs/#{completed_case_log.id}/local-authority/check-answers")
        click_link("Save and go to submit")
        expect(page).to have_current_path("/logs/#{completed_case_log.id}/declaration")
      end
    end
  end
end
