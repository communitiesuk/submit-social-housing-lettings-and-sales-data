require "rails_helper"
require_relative "helpers"

RSpec.describe "validations" do
  before do
    sign_in user
  end

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
  let(:completed_without_declaration) do
    FactoryBot.create(
      :case_log,
      :completed,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
      status: 1,
      declaration: nil,
    )
  end
  let(:id) { case_log.id }

  describe "Question validation" do
    context "when the tenant age is invalid" do
      it "shows validation for under 0" do
        visit("/logs/#{id}/person-1-age")
        fill_in_number_question(empty_case_log.id, "age1", -5, "person-1-age")
        expect(page).to have_selector("#error-summary-title")
        expect(page).to have_selector("#case-log-age1-error")
        expect(page).to have_selector("#case-log-age1-field-error")
        expect(page).to have_title("Error")
      end

      it "shows validation for over 120" do
        visit("/logs/#{id}/person-1-age")
        fill_in_number_question(empty_case_log.id, "age1", 121, "person-1-age")
        expect(page).to have_selector("#error-summary-title")
        expect(page).to have_selector("#case-log-age1-error")
        expect(page).to have_selector("#case-log-age1-field-error")
        expect(page).to have_title("Error")
      end
    end
  end

  describe "date validation", js: true do
    def fill_in_date(case_log_id, question, day, month, year, path)
      visit("/logs/#{case_log_id}/#{path}")
      fill_in("#{question}_1i", with: year)
      fill_in("#{question}_2i", with: month)
      fill_in("#{question}_3i", with: day)
    end

    it "does not allow out of range dates to be submitted" do
      fill_in_date(id, "case_log_mrcdate", 3100, 12, 2000, "property-major-repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/logs/#{id}/property-major-repairs")

      fill_in_date(id, "case_log_mrcdate", 12, 1, 20_000, "property-major-repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/logs/#{id}/property-major-repairs")

      fill_in_date(id, "case_log_mrcdate", 13, 100, 2020, "property-major-repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/logs/#{id}/property-major-repairs")

      fill_in_date(id, "case_log_mrcdate", 21, 11, 2020, "property-major-repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/logs/#{id}/local-authority/check-answers")
    end

    it "does not allow non numeric inputs to be submitted" do
      fill_in_date(id, "case_log_mrcdate", "abc", "de", "ff", "property-major-repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/logs/#{id}/property-major-repairs")
    end

    it "does not allow partial inputs to be submitted" do
      fill_in_date(id, "case_log_mrcdate", 21, 12, nil, "property-major-repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/logs/#{id}/property-major-repairs")

      fill_in_date(id, "case_log_mrcdate", 12, nil, 2000, "property-major-repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/logs/#{id}/property-major-repairs")

      fill_in_date(id, "case_log_mrcdate", nil, 10, 2020, "property-major-repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/logs/#{id}/property-major-repairs")
    end

    it "allows valid inputs to be submitted" do
      fill_in_date(id, "case_log_mrcdate", 21, 11, 2020, "property-major-repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/logs/#{id}/local-authority/check-answers")
    end
  end

  describe "Soft Validation" do
    context "when a weekly net income is above the expected amount for the given economic status but below the hard max" do
      let(:case_log) do
        FactoryBot.create(
          :case_log,
          :in_progress,
          ecstat1: 1,
          owning_organisation: user.organisation,
          managing_organisation: user.organisation,
        )
      end
      let(:income_over_soft_limit) { 750 }
      let(:income_under_soft_limit) { 700 }

      it "prompts the user to confirm the value is correct with an interruption screen" do
        visit("/logs/#{case_log.id}/net-income")
        fill_in("case-log-earnings-field", with: income_over_soft_limit)
        choose("case-log-incfreq-0-field", allow_label_click: true)
        click_button("Save and continue")
        expect(page).to have_current_path("/logs/#{case_log.id}/net-income-value-check")
        expect(page).to have_content("Net income is outside the expected range based on the main tenant’s working situation")
        expect(page).to have_content("You told us the main tenant’s working situation is: Full-time – 30 hours or more")
        expect(page).to have_content("The household income you have entered is £750.00 every week")
        choose("case-log-net-income-value-check-0-field", allow_label_click: true)
        click_button("Save and continue")
        expect(page).to have_current_path("/logs/#{case_log.id}/net-income-uc-proportion")
      end

      it "returns the user to the previous question if they do not confirm the value as correct on the interruption screen" do
        visit("/logs/#{case_log.id}/net-income")
        fill_in("case-log-earnings-field", with: income_over_soft_limit)
        choose("case-log-incfreq-0-field", allow_label_click: true)
        click_button("Save and continue")
        choose("case-log-net-income-value-check-1-field", allow_label_click: true)
        click_button("Save and continue")
        expect(page).to have_current_path("/logs/#{case_log.id}/net-income")
      end
    end
  end

  describe "Submission validation" do
    context "when tenant has not seen the privacy notice" do
      it "shows a warning" do
        visit("/logs/#{completed_without_declaration.id}/declaration")
        click_button("Submit lettings log")
        expect(page).to have_content("You must show the DLUHC privacy notice to the tenant")
      end
    end

    context "when tenant has seen the privacy notice" do
      it "the log can be submitted" do
        completed_without_declaration.update!({ declaration: 1 })
        visit("/logs/#{completed_without_declaration.id}/declaration")
        click_button("Submit lettings log")
        expect(page).to have_current_path("/logs")
      end
    end
  end
end
