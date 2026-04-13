require "rails_helper"
require_relative "helpers"

RSpec.describe "validations" do
  let(:user) { FactoryBot.create(:user) }
  let(:lettings_log) do
    FactoryBot.create(
      :lettings_log,
      :setup_completed,
      assigned_to: user,
      renewal: 0,
      first_time_property_let_as_social_housing: 0,
      unitletas: 1,
      rsnvac: 9
    )
  end
  let(:id) { lettings_log.id }

  before do
    sign_in user
  end

  include Helpers
  include CollectionTimeHelper

  describe "Question validation" do
    context "when the tenant age is invalid" do
      it "shows validation for under 0" do
        fill_in_number_question(id, "age1", -5, "lead-tenant-age")
        expect(page).to have_selector(".govuk-error-summary__title")
        expect(page).to have_selector("#lettings-log-age1-error")
        expect(page).to have_selector("#lettings-log-age1-field-error")
        expect(page).to have_title("Error")
      end

      it "shows validation for over 120" do
        fill_in_number_question(id, "age1", 121, "lead-tenant-age")
        expect(page).to have_selector(".govuk-error-summary__title")
        expect(page).to have_selector("#lettings-log-age1-error")
        expect(page).to have_selector("#lettings-log-age1-field-error")
        expect(page).to have_title("Error")
      end
    end
  end

  describe "date validation", :js do
    def fill_in_date(lettings_log_id, question, day, month, year, path)
      visit("/lettings-logs/#{lettings_log_id}/#{path}")
      choose("lettings-log-majorrepairs-1-field", allow_label_click: true)
      fill_in("lettings_log[#{question}]", with: [day, month, year].join("/"))
    end

    it "does not allow out of range dates to be submitted" do
      fill_in_date(id, "mrcdate", 3100, 12, current_collection_start_year, "property-major-repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/lettings-logs/#{id}/property-major-repairs")

      fill_in_date(id, "mrcdate", 12, 1, 20_000, "property-major-repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/lettings-logs/#{id}/property-major-repairs")

      fill_in_date(id, "mrcdate", 13, 100, current_collection_start_year, "property-major-repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/lettings-logs/#{id}/property-major-repairs")
    end

    it "does not allow non numeric inputs to be submitted" do
      fill_in_date(id, "mrcdate", "abc", "de", "ff", "property-major-repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/lettings-logs/#{id}/property-major-repairs")
    end

    it "does not allow partial inputs to be submitted" do
      fill_in_date(id, "mrcdate", 21, 12, nil, "property-major-repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/lettings-logs/#{id}/property-major-repairs")

      fill_in_date(id, "mrcdate", 12, nil, current_collection_start_year, "property-major-repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/lettings-logs/#{id}/property-major-repairs")

      fill_in_date(id, "mrcdate", nil, 10, current_collection_start_year, "property-major-repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/lettings-logs/#{id}/property-major-repairs")
    end

    it "allows valid inputs to be submitted" do
      valid_mcrdate = lettings_log.startdate - 1.day
      fill_in_date(id, "mrcdate", valid_mcrdate.day, valid_mcrdate.month, valid_mcrdate.year, "property-major-repairs")
      click_button("Save and continue")
      expect(page).to have_current_path("/lettings-logs/#{id}/property-information/check-answers")
    end
  end

  describe "Soft Validation" do
    context "when a weekly net income is above the expected amount for the given economic status but below the hard max" do
      let(:lettings_log) do
        FactoryBot.create(
          :lettings_log,
          :in_progress,
          hhmemb: 1,
          ecstat1: 1,
          assigned_to: user,
          net_income_known: 0,
        )
      end
      let(:income_over_soft_limit) { 750 }
      let(:income_under_soft_limit) { 700 }

      before do
        visit("/lettings-logs/#{lettings_log.id}/income-amount")
        fill_in("lettings-log-earnings-field", with: income_over_soft_limit)
        choose("lettings-log-incfreq-1-field", allow_label_click: true)
        click_button("Save and continue")
      end

      it "prompts the user to confirm the value is correct with an interruption screen" do
        expect(page).to have_current_path("/lettings-logs/#{lettings_log.id}/net-income-value-check")
        expect(page).to have_content("You told us that the household’s income is £750.00 weekly")
        expect(page).to have_content("This is higher than we would expect for the household’s working situation.")
        expect(page).not_to have_button("Save changes")
        click_button("Confirm and continue")
        expect(page).to have_current_path("/lettings-logs/#{lettings_log.id}/housing-benefit")
      end

      it "allows to fix the questions that trigger the soft validation" do
        expect(page).to have_current_path("/lettings-logs/#{lettings_log.id}/net-income-value-check")
        expect(page).to have_link("Change", href: "/lettings-logs/#{lettings_log.id}/income-amount?referrer=interruption_screen").twice
        expect(page).to have_link("Change", href: "/lettings-logs/#{lettings_log.id}/lead-tenant-working-situation?referrer=interruption_screen")
        expect(page).to have_current_path("/lettings-logs/#{lettings_log.id}/net-income-value-check")
        click_link("Change", href: "/lettings-logs/#{lettings_log.id}/income-amount?referrer=interruption_screen", match: :first)
        expect(page).to have_current_path("/lettings-logs/#{lettings_log.id}/income-amount?referrer=interruption_screen")
        fill_in("lettings-log-earnings-field", with: income_under_soft_limit)
        choose("lettings-log-incfreq-1-field", allow_label_click: true)
        click_button("Save and continue")
        expect(page).to have_current_path("/lettings-logs/#{lettings_log.id}/net-income-value-check")
        expect(page).not_to have_content("You told us that the household’s income is £750.00 weekly")
        expect(page).to have_css(".govuk-notification-banner.govuk-notification-banner--success")
      end

      it "allows to fix the questions from different sections" do
        expect(page).to have_current_path("/lettings-logs/#{lettings_log.id}/net-income-value-check")
        expect(page).to have_link("Change", href: "/lettings-logs/#{lettings_log.id}/income-amount?referrer=interruption_screen").twice
        expect(page).to have_link("Change", href: "/lettings-logs/#{lettings_log.id}/lead-tenant-working-situation?referrer=interruption_screen")
        expect(page).to have_current_path("/lettings-logs/#{lettings_log.id}/net-income-value-check")
        click_link("Change", href: "/lettings-logs/#{lettings_log.id}/lead-tenant-working-situation?referrer=interruption_screen")
        expect(page).to have_current_path("/lettings-logs/#{lettings_log.id}/lead-tenant-working-situation?referrer=interruption_screen")
        choose("lettings-log-ecstat1-10-field", allow_label_click: true)
        click_button("Save and continue")
        expect(page).to have_current_path("/lettings-logs/#{lettings_log.id}/net-income-value-check")
        expect(page).to have_css(".govuk-notification-banner.govuk-notification-banner--success")
      end

      it "returns the user back to the check_your_answers after fixing a validation from check_your_answers" do
        lettings_log.update!(earnings: income_under_soft_limit, incfreq: 1, net_income_value_check: 1)
        visit("/lettings-logs/#{lettings_log.id}/income-and-benefits/check-answers")
        click_link("Change", href: "/lettings-logs/#{lettings_log.id}/income-amount?referrer=check_answers", match: :first)
        expect(page).to have_current_path("/lettings-logs/#{lettings_log.id}/income-amount?referrer=check_answers")
        fill_in("lettings-log-earnings-field", with: income_over_soft_limit)
        click_button("Save changes")
        expect(page).to have_current_path("/lettings-logs/#{lettings_log.id}/net-income-value-check?referrer=check_answers")
        click_link("Change", href: "/lettings-logs/#{lettings_log.id}/income-amount?referrer=interruption_screen", match: :first)
        expect(page).to have_current_path("/lettings-logs/#{lettings_log.id}/income-amount?referrer=interruption_screen")
        fill_in("lettings-log-earnings-field", with: income_under_soft_limit)
        click_button("Save and continue")
        expect(page).to have_current_path("/lettings-logs/#{lettings_log.id}/net-income-value-check?referrer=check_answers")
        click_button("Confirm and continue")
        expect(page).to have_current_path("/lettings-logs/#{lettings_log.id}/income-and-benefits/check-answers")
      end
    end
  end
end
