require "rails_helper"

RSpec.describe OrganisationsController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:organisation) { user.organisation }
  let(:headers) { { "Accept" => "text/html" } }

  before do
    sign_in user
    get "/organisations/#{organisation.id}", headers: headers, params: {}
  end

  it "shows the tab navigation" do
    expected_html = "<nav class=\"app-tab-navigation\""
    expect(response.body).to include(expected_html)
  end
end
