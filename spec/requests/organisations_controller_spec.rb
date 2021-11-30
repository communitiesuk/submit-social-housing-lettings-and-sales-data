require "rails_helper"

RSpec.describe OrganisationsController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:organisation) { user.organisation }
  let(:headers) { { "Accept" => "text/html" } }

  context "details tab" do
    before do
      sign_in user
      get "/organisations/#{organisation.id}", headers: headers, params: {}
    end

    it "shows the tab navigation" do
      expected_html = "<nav class=\"app-tab-navigation\""
      expect(response.body).to include(expected_html)
    end

    it "shows a summary list of org details" do
      expected_html = "<dl class=\"govuk-summary-list\""
      expect(response.body).to include(expected_html)
      expect(response.body).to include(organisation.name)
    end
  end

  context "users tab" do
    before do
      sign_in user
      get "/organisations/#{organisation.id}/users", headers: headers, params: {}
    end

    it "shows the tab navigation" do
      expected_html = "<nav class=\"app-tab-navigation\""
      expect(response.body).to include(expected_html)
    end

    it "shows a new user button" do
      expected_html = "<a class=\"govuk-button\""
      expect(response.body).to include(expected_html)
      expect(response.body).to include("Invite user")
    end

    it "shows a table of users" do
      expected_html = "<table class=\"govuk-table\""
      expect(response.body).to include(expected_html)
      expect(response.body).to include(user.email)
    end
  end
end
