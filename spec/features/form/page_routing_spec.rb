require "rails_helper"
require_relative "helpers"

RSpec.describe "Form Page Routing" do
  include Helpers
  let(:user) { FactoryBot.create(:user) }
  let(:lettings_log) do
    FactoryBot.create(
      :lettings_log,
      :in_progress,
      created_by: user,
    )
  end
  let(:id) { lettings_log.id }
  let(:validator) { lettings_log._validators[nil].first }

  before do
    allow(lettings_log.form).to receive(:end_date).and_return(Time.zone.today + 1.day)
    allow(validator).to receive(:validate_pregnancy).and_return(true)
    sign_in user
  end

  context "with 21/22 logs" do
    around do |example|
      Timecop.freeze(Time.zone.local(2022, 1, 1)) do
        Singleton.__init__(FormHandler)
        example.run
      end
      Timecop.return
      Singleton.__init__(FormHandler)
    end

    it "can route the user to a different page based on their answer on the current page", js: true do
      visit("/lettings-logs/#{id}/conditional-question")
      # using a question name that is already in the db to avoid
      # having to add a new column to the db for this test
      choose("lettings-log-preg-occ-1-field", allow_label_click: true)
      click_button("Save and continue")
      expect(page).to have_current_path("/lettings-logs/#{id}/conditional-question-yes-page")
      click_link(text: "Back")
      expect(page).to have_current_path("/lettings-logs/#{id}/conditional-question")
      choose("lettings-log-preg-occ-2-field", allow_label_click: true)
      click_button("Save and continue")
      expect(page).to have_current_path("/lettings-logs/#{id}/conditional-question-no-page")
    end

    it "can route based on multiple conditions", js: true do
      visit("/lettings-logs/#{id}/person-1-gender")
      choose("lettings-log-sex1-f-field", allow_label_click: true)
      click_button("Save and continue")
      expect(page).to have_current_path("/lettings-logs/#{id}/person-1-working-situation")
      visit("/lettings-logs/#{id}/conditional-question")
      choose("lettings-log-preg-occ-2-field", allow_label_click: true)
      click_button("Save and continue")
      expect(page).to have_current_path("/lettings-logs/#{id}/conditional-question-no-page")
      choose("lettings-log-cbl-0-field", allow_label_click: true)
      click_button("Save and continue")
      expect(page).to have_current_path("/lettings-logs/#{id}/conditional-question/check-answers")
    end

    context "when the answers are inferred", js: true do
      it "shows question if the answer could not be inferred" do
        visit("/lettings-logs/#{id}/property-postcode")
        fill_in("lettings-log-postcode-full-field", with: "PO5 3TE")
        click_button("Save and continue")
        expect(page).to have_current_path("/lettings-logs/#{id}/do-you-know-the-local-authority")
      end

      it "shows question if the answer could not be inferred from an empty input" do
        visit("/lettings-logs/#{id}/property-postcode")
        click_button("Save and continue")
        expect(page).to have_current_path("/lettings-logs/#{id}/do-you-know-the-local-authority")
      end

      it "does not show question if the answer could be inferred" do
        stub_request(:get, /api.postcodes.io/)
          .to_return(status: 200, body: "{\"status\":200,\"result\":{\"admin_district\":\"Manchester\", \"codes\":{\"admin_district\": \"E08000003\"}}}", headers: {})

        visit("/lettings-logs/#{id}/property-postcode")
        fill_in("lettings-log-postcode-full-field", with: "P0 5ST")
        click_button("Save and continue")
        expect(page).to have_current_path("/lettings-logs/#{id}/property-wheelchair-accessible")
      end
    end

    context "when answer is invalid" do
      it "shows error with invalid value in the field" do
        visit("/lettings-logs/#{id}/property-postcode")
        fill_in("lettings-log-postcode-full-field", with: "fake_postcode")
        click_button("Save and continue")

        expect(page).to have_current_path("/lettings-logs/#{id}/property-postcode")
        expect(find("#lettings-log-postcode-full-field-error").value).to eq("fake_postcode")
      end

      it "does not reset the displayed date" do
        lettings_log.update!(startdate: "2021/10/13")
        visit("/lettings-logs/#{id}/tenancy-start-date")
        fill_in("lettings_log[startdate(1i)]", with: "202")
        fill_in("lettings_log[startdate(2i)]", with: "32")
        fill_in("lettings_log[startdate(3i)]", with: "0")
        click_button("Save and continue")

        expect(page).to have_current_path("/lettings-logs/#{id}/tenancy-start-date")
        expect(find_field("lettings_log[startdate(3i)]").value).to eq("13")
        expect(find_field("lettings_log[startdate(2i)]").value).to eq("10")
        expect(find_field("lettings_log[startdate(1i)]").value).to eq("2021")
      end

      it "does not reset the displayed date if it's empty" do
        lettings_log.update!(startdate: nil)
        visit("/lettings-logs/#{id}/tenancy-start-date")
        fill_in("lettings_log[startdate(1i)]", with: "202")
        fill_in("lettings_log[startdate(2i)]", with: "32")
        fill_in("lettings_log[startdate(3i)]", with: "0")
        click_button("Save and continue")

        expect(page).to have_current_path("/lettings-logs/#{id}/tenancy-start-date")
        expect(find_field("lettings_log[startdate(3i)]").value).to eq(nil)
        expect(find_field("lettings_log[startdate(2i)]").value).to eq(nil)
        expect(find_field("lettings_log[startdate(1i)]").value).to eq(nil)
      end
    end
  end

  context "when completing the setup section" do
    context "with a supported housing log" do
      let(:lettings_log) do
        FactoryBot.create(
          :lettings_log,
          owning_organisation: user.organisation,
          managing_organisation: user.organisation,
          created_by: user,
          needstype: 2,
        )
      end

      context "with a scheme with only 1 active location" do
        let(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
        let!(:active_location) { FactoryBot.create(:location, scheme:) }

        before do
          FactoryBot.create(:location, scheme:, startdate: Time.zone.today + 20.days)
          visit("/lettings-logs/#{lettings_log.id}/scheme")
          select(scheme.service_name, from: "lettings_log[scheme_id]")
          click_button("Save and continue")
        end

        it "does not route to the scheme location question" do
          expect(page).to have_current_path("/lettings-logs/#{lettings_log.id}/renewal")
        end

        it "infers the scheme location" do
          expect(lettings_log.reload.location_id).to eq(active_location.id)
        end
      end
    end
  end
end
