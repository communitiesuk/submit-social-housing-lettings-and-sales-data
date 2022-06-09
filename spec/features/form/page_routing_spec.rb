require "rails_helper"
require_relative "helpers"

RSpec.describe "Form Page Routing" do
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
  let(:id) { case_log.id }
  let(:validator) { case_log._validators[nil].first }

  before do
    allow(validator).to receive(:validate_pregnancy).and_return(true)
    sign_in user
  end

  it "can route the user to a different page based on their answer on the current page", js: true do
    visit("/logs/#{id}/conditional-question")
    # using a question name that is already in the db to avoid
    # having to add a new column to the db for this test
    choose("case-log-preg-occ-1-field", allow_label_click: true)
    click_button("Save and continue")
    expect(page).to have_current_path("/logs/#{id}/conditional-question-yes-page")
    click_link(text: "Back")
    expect(page).to have_current_path("/logs/#{id}/conditional-question")
    choose("case-log-preg-occ-2-field", allow_label_click: true)
    click_button("Save and continue")
    expect(page).to have_current_path("/logs/#{id}/conditional-question-no-page")
  end

  it "can route based on multiple conditions", js: true do
    visit("/logs/#{id}/person-1-gender")
    choose("case-log-sex1-f-field", allow_label_click: true)
    click_button("Save and continue")
    expect(page).to have_current_path("/logs/#{id}/person-1-working-situation")
    visit("/logs/#{id}/conditional-question")
    choose("case-log-preg-occ-2-field", allow_label_click: true)
    click_button("Save and continue")
    expect(page).to have_current_path("/logs/#{id}/conditional-question-no-page")
    click_button("Save and continue")
    expect(page).to have_current_path("/logs/#{id}/conditional-question/check-answers")
  end

  context "when a page is dependent on the current user's role" do
    let(:case_log) do
      FactoryBot.create(
        :case_log,
        :in_progress,
        owning_organisation: user.organisation,
        managing_organisation: user.organisation,
        is_previous_la_inferred: false,
      )
    end

    context "when the user has the required role" do
      it "routes to the page" do
        visit("/logs/#{id}/property-postcode")
        click_button("Save and continue")
        expect(page).to have_current_path("/logs/#{id}/do-you-know-the-local-authority")
      end
    end

    context "when the user does not have the required role" do
      let(:support_user) { FactoryBot.create(:user, :support, organisation: user.organisation) }
      let(:devise_notify_mailer) { DeviseNotifyMailer.new }
      let(:notify_client) { instance_double(Notifications::Client) }
      let(:otp) { "999111" }

      before do
        allow(DeviseNotifyMailer).to receive(:new).and_return(devise_notify_mailer)
        allow(devise_notify_mailer).to receive(:notify_client).and_return(notify_client)
        allow(notify_client).to receive(:send_email).and_return(true)
        allow(SecureRandom).to receive(:random_number).and_return(otp)
        click_link("Sign out")
        visit("/account/sign-in")
        sign_in support_user
        fill_in("code", with: otp)
        click_button("Submit")
      end

      it "does not route to the page" do
        visit("/logs/#{id}/property-postcode")
        click_button("Save and continue")
        expect(page).to have_current_path("/logs/#{id}/property-wheelchair-accessible")
      end
    end
  end

  context "when the answers are inferred" do
    it "shows question if the answer could not be inferred" do
      visit("/logs/#{id}/property-postcode")
      fill_in("case-log-postcode-full-field", with: "PO5 3TE")
      click_button("Save and continue")
      expect(page).to have_current_path("/logs/#{id}/do-you-know-the-local-authority")
    end

    it "shows question if the answer could not be inferred from an empty input" do
      visit("/logs/#{id}/property-postcode")
      click_button("Save and continue")
      expect(page).to have_current_path("/logs/#{id}/do-you-know-the-local-authority")
    end

    it "does not show question if the answer could be inferred" do
      stub_request(:get, /api.postcodes.io/)
        .to_return(status: 200, body: "{\"status\":200,\"result\":{\"admin_district\":\"Manchester\", \"codes\":{\"admin_district\": \"E08000003\"}}}", headers: {})

      visit("/logs/#{id}/property-postcode")
      fill_in("case-log-postcode-full-field", with: "P0 5ST")
      click_button("Save and continue")
      expect(page).to have_current_path("/logs/#{id}/property-wheelchair-accessible")
    end
  end
end
