require "rails_helper"
require_relative "helpers"

RSpec.describe "Lettings Log Check Answers Page" do
  include Helpers
  include CollectionTimeHelper

  let(:user) { FactoryBot.create(:user) }
  let(:subsection) { "household-needs" }
  let(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
  let(:location) { FactoryBot.create(:location, scheme:, mobility_type: "N", startdate: current_collection_start_date) }

  let(:lettings_log) do
    FactoryBot.create(
      :lettings_log,
      :in_progress,
      assigned_to: user,
      needstype: 2,
      scheme:,
      location:,
    )
  end
  let(:empty_lettings_log) do
    FactoryBot.create(
      :lettings_log,
      :setup_completed,
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
      startdate: current_collection_start_date,
    )
  end
  let(:id) { lettings_log.id }

  before do
    sign_in user
  end

  context "when the user needs to check their answers for a subsection" do
    let(:last_question_for_subsection) { "health-conditions" }

    it "can be visited by URL" do
      visit("/lettings-logs/#{id}/#{subsection}/check-answers")
      expect(page).to have_content("#{subsection.tr('-', ' ').humanize} Check your answers")
    end

    it "redirects to the check answers page when answering the last question and clicking save and continue" do
      fill_in_radio_question(id, "illness", "2", last_question_for_subsection)
      expect(page).to have_current_path("/lettings-logs/#{id}/#{subsection}/check-answers")
    end

    it "has question headings based on the subsection" do
      visit("/lettings-logs/#{id}/#{subsection}/check-answers")
      question_labels = ["Household links to UK armed forces", "Anybody in household pregnant", "Anybody with disabled access needs", "Anybody in household with physical or mental health condition"]
      question_labels.each do |label|
        expect(page).to have_content(label)
      end
    end

    it "displays answers given by the user for the question in the subsection" do
      fill_in_radio_question(id, "armedforces", "3", "armed-forces")
      fill_in_radio_question(id, "illness", "2", "health-conditions")
      visit("/lettings-logs/#{id}/#{subsection}/check-answers")
      expect(page).to have_content("No")
      expect(page).to have_content("Person prefers not to say")
    end

    it "has an answer link with the check_answers_new_answer referrer for questions missing an answer" do
      visit("/lettings-logs/#{id}/#{subsection}/check-answers?referrer=check_answers")
      assert_selector "a", text: "Change", count: 0
      expect(page).to have_link("Tell us if there are any household links to UK armed forces", href: "/lettings-logs/#{id}/armed-forces?referrer=check_answers_new_answer")
    end

    it "has a change link for answered question" do
      fill_in_radio_question(id, "armedforces", "2", "armed-forces")
      visit("/lettings-logs/#{id}/#{subsection}/check-answers")
      assert_selector "a", text: "Change", count: 1
      expect(page).to have_link("Change", href: "/lettings-logs/#{id}/armed-forces?referrer=check_answers")
    end

    it "updates the add change link when answers get answered" do
      visit("/lettings-logs/#{id}/household-needs/check-answers")
      assert_selector "a", text: "Change", count: 0
      fill_in_radio_question(id, "armedforces", "2", "armed-forces")
      visit("/lettings-logs/#{id}/household-needs/check-answers")
      assert_selector "a", text: "Change", count: 1
      expect(page).to have_link("Change", href: "/lettings-logs/#{id}/armed-forces?referrer=check_answers")
    end

    it "does not group questions into summary cards if the questions in the subsection don't have a check_answers_card_number attribute" do
      visit("/lettings-logs/#{completed_lettings_log.id}/household-needs/check-answers")
      assert_selector ".govuk-summary-card__title", count: 0
    end

    context "when the user is checking their answers for the household characteristics subsection" do
      it "they see a separate summary card for each member of the household" do
        visit("/lettings-logs/#{completed_lettings_log.id}/household-characteristics/check-answers")
        assert_selector ".govuk-summary-card__title", text: "Lead tenant", count: 1
        assert_selector ".govuk-summary-card__title", text: "Person 2", count: 1
      end
    end

    context "when viewing setup section answers" do
      before do
        FactoryBot.create(:location, scheme:, startdate: current_collection_start_date)
      end

      it "displays inferred postcode with the location id" do
        lettings_log.update!(location:)
        visit("/lettings-logs/#{id}/setup/check-answers")
        expect(page).to have_content(location.name)
      end

      it "displays inferred postcode with the location_admin_district" do
        lettings_log.update!(location:)
        visit("/lettings-logs/#{id}/setup/check-answers")
        expect(page).to have_content(location.location_admin_district)
      end
    end

    context "when the user changes their answer from check answer page" do
      it "routes back to check answers" do
        fill_in_radio_question(id, "armedforces", "2", "armed-forces")
        visit("/lettings-logs/#{id}/household-needs/check-answers")
        first("a", text: /Change/).click
        choose("lettings-log-armedforces-3-field")
        click_button("Save changes")
        expect(page).to have_current_path("/lettings-logs/#{id}/household-needs/check-answers")
      end
    end

    context "when the user wants to bypass the tasklist page from check answers" do
      let(:section_completed_lettings_log) do
        FactoryBot.create(
          :lettings_log,
          :in_progress,
          assigned_to: user,
          tenancycode: "123",
          age1: 35,
          sex1: "M",
          hhmemb: 1,
        )
      end

      let(:next_section_in_progress_lettings_log) do
        FactoryBot.create(
          :lettings_log,
          :in_progress,
          assigned_to: user,
          tenancycode: "123",
          age1: 35,
          sex1: "M",
          hhmemb: 1,
          armedforces: 3,
          illness: 1,
        )
      end

      let(:skip_section_lettings_log) do
        FactoryBot.create(
          :lettings_log,
          :in_progress,
          assigned_to: user,
          tenancycode: "123",
          age1: 35,
          sex1: "M",
          hhmemb: 1,
          armedforces: 3,
          preg_occ: 2,
          housingneeds: 2,
          illness: 1,
          illness_type_1: 1,
          layear: 2,
          waityear: 7,
          reason: 4,
          prevten: 6,
          homeless: 1,
          ppostcode_full: "SE2 6RT",
          previous_la_known: 1,
          prevloc: "E07000105",
          reasonpref: 1,
          cbl: 0,
          chr: 1,
          cap: 0,
          accessible_register: 0,
          referral_type: 1,
        )
      end

      let(:cycle_sections_lettings_log) do
        FactoryBot.create(
          :lettings_log,
          :in_progress,
          assigned_to: user,
          needstype: 1,
          tenancycode: nil,
          hhmemb: nil,
          age1: nil,
          age2: nil,
          layear: 2,
          waityear: 1,
          postcode_full: "NW1 5TY",
          reason: 4,
          ppostcode_full: "SE2 6RT",
          mrcdate: Time.zone.parse("03/11/2019"),
          renewal: 0,
        )
      end

      it "they can click a button to move onto the first page of the next (not started) incomplete section" do
        visit("/lettings-logs/#{section_completed_lettings_log.id}/household-characteristics/check-answers")
        click_link("Save and go to next incomplete section")
        expect(page).to have_current_path("/lettings-logs/#{section_completed_lettings_log.id}/armed-forces")
      end

      it "they can click a button to move onto the check answers page of the next (in progress) incomplete section" do
        visit("/lettings-logs/#{next_section_in_progress_lettings_log.id}/household-characteristics/check-answers")
        click_link("Save and go to next incomplete section")
        expect(page).to have_current_path("/lettings-logs/#{next_section_in_progress_lettings_log.id}/household-needs/check-answers")
      end

      it "they can click a button to skip sections until the next incomplete section" do
        visit("/lettings-logs/#{skip_section_lettings_log.id}/household-characteristics/check-answers")
        click_link("Save and go to next incomplete section")
        expect(page).to have_current_path("/lettings-logs/#{skip_section_lettings_log.id}/household-situation/check-answers")
      end

      it "they can click a button to cycle around to the next incomplete section" do
        visit("/lettings-logs/#{cycle_sections_lettings_log.id}/income-and-benefits/check-answers")
        click_link("Save and go to next incomplete section")
        expect(page).to have_current_path("/lettings-logs/#{cycle_sections_lettings_log.id}/property-information/check-answers")
      end
    end
  end
end
