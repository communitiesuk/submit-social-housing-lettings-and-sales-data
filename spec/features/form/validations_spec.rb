require "rails_helper"
require_relative "helpers"

RSpec.describe "validations" do
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

  before do
    sign_in user
  end

  describe "Question validation" do
    context "given an invalid tenant age" do
      it " of less than 0 it shows validation" do
        visit("/case_logs/#{id}/person_1_age")
        fill_in_number_question(empty_case_log.id, "age1", -5, "person_1_age")
        expect(page).to have_selector("#error-summary-title")
        expect(page).to have_selector("#case-log-age1-error")
        expect(page).to have_selector("#case-log-age1-field-error")
      end

      it " of greater than 120 it shows validation" do
        visit("/case_logs/#{id}/person_1_age")
        fill_in_number_question(empty_case_log.id, "age1", 121, "person_1_age")
        expect(page).to have_selector("#error-summary-title")
        expect(page).to have_selector("#case-log-age1-error")
        expect(page).to have_selector("#case-log-age1-field-error")
      end
    end
  end

  describe "date validation", js: true do
    def fill_in_date(case_log_id, question, day, month, year, path)
      visit("/case_logs/#{case_log_id}/#{path}")
      fill_in("#{question}_1i", with: year)
      fill_in("#{question}_2i", with: month)
      fill_in("#{question}_3i", with: day)
    end

    it "does not allow out of range dates to be submitted" do
      fill_in_date(id, "case_log_mrcdate", 3100, 12, 2000, "property_major_repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/case_logs/#{id}/property_major_repairs")

      fill_in_date(id, "case_log_mrcdate", 12, 1, 20_000, "property_major_repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/case_logs/#{id}/property_major_repairs")

      fill_in_date(id, "case_log_mrcdate", 13, 100, 2020, "property_major_repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/case_logs/#{id}/property_major_repairs")

      fill_in_date(id, "case_log_mrcdate", 21, 11, 2020, "property_major_repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/case_logs/#{id}/local_authority/check_answers")
    end

    it "does not allow non numeric inputs to be submitted" do
      fill_in_date(id, "case_log_mrcdate", "abc", "de", "ff", "property_major_repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/case_logs/#{id}/property_major_repairs")
    end

    it "does not allow partial inputs to be submitted" do
      fill_in_date(id, "case_log_mrcdate", 21, 12, nil, "property_major_repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/case_logs/#{id}/property_major_repairs")

      fill_in_date(id, "case_log_mrcdate", 12, nil, 2000, "property_major_repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/case_logs/#{id}/property_major_repairs")

      fill_in_date(id, "case_log_mrcdate", nil, 10, 2020, "property_major_repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/case_logs/#{id}/property_major_repairs")
    end

    it "allows valid inputs to be submitted" do
      fill_in_date(id, "case_log_mrcdate", 21, 11, 2020, "property_major_repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/case_logs/#{id}/local_authority/check_answers")
    end
  end

  describe "Soft Validation" do
    context "given a weekly net income that is above the expected amount for the given economic status but below the hard max" do
      let(:case_log) do
        FactoryBot.create(
          :case_log,
          :in_progress,
          ecstat1: "Full-time - 30 hours or more",
          owning_organisation: user.organisation,
          managing_organisation: user.organisation,
        )
      end
      let(:income_over_soft_limit) { 750 }
      let(:income_under_soft_limit) { 700 }

      it "prompts the user to confirm the value is correct", js: true do
        visit("/case_logs/#{case_log.id}/net_income")
        fill_in("case-log-earnings-field", with: income_over_soft_limit)
        choose("case-log-incfreq-weekly-field", allow_label_click: true)
        click_button("Save and continue")
        expect(page).to have_content("Are you sure this is correct?")
        check("case-log-override-net-income-validation-override-net-income-validation-field", allow_label_click: true)
        click_button("Save and continue")
        expect(page).to have_current_path("/case_logs/#{case_log.id}/net_income_uc_proportion")
      end

      it "does not require confirming the value if the value is amended" do
        visit("/case_logs/#{case_log.id}/net_income")
        fill_in("case-log-earnings-field", with: income_over_soft_limit)
        choose("case-log-incfreq-weekly-field", allow_label_click: true)
        click_button("Save and continue")
        fill_in("case-log-earnings-field", with: income_under_soft_limit)
        click_button("Save and continue")
        expect(page).to have_current_path("/case_logs/#{case_log.id}/net_income_uc_proportion")
        case_log.reload
        expect(case_log.override_net_income_validation).to be_nil
      end

      it "clears the confirmation question if the amount was amended and the page is returned to using the back button", js: true do
        visit("/case_logs/#{case_log.id}/net_income")
        fill_in("case-log-earnings-field", with: income_over_soft_limit)
        choose("case-log-incfreq-weekly-field", allow_label_click: true)
        click_button("Save and continue")
        fill_in("case-log-earnings-field", with: income_under_soft_limit)
        click_button("Save and continue")
        click_link(text: "Back")
        expect(page).to have_no_content("Are you sure this is correct?")
      end

      it "does not clear the confirmation question if the page is returned to using the back button and the amount is still over the soft limit", js: true do
        visit("/case_logs/#{case_log.id}/net_income")
        fill_in("case-log-earnings-field", with: income_over_soft_limit)
        choose("case-log-incfreq-weekly-field", allow_label_click: true)
        click_button("Save and continue")
        check("case-log-override-net-income-validation-override-net-income-validation-field", allow_label_click: true)
        click_button("Save and continue")
        click_link(text: "Back")
        expect(page).to have_content("Are you sure this is correct?")
      end
    end
  end
end
