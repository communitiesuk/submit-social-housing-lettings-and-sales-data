require "rails_helper"

RSpec.describe MaintenanceController, type: :request do
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in user
  end

  describe "when maintenance mode is enabled" do
    before do
      allow(FeatureToggle).to receive(:maintenance_mode_enabled?).and_return(true)
    end

    context "when a user visits a page other than the maintenance page" do
      it "redirects the user to the maintenance page" do
        get "/lettings-logs"
        expect(response).to redirect_to(service_unavailable_path)
        follow_redirect!
        expect(page).to have_content("Sorry, the service is unavailable")
      end
    end

    context "when a user visits the maintenance page" do
      it "keeps the user on the maintenance page" do
        get "/service-unavailable"
        expect(response).not_to redirect_to(service_unavailable_path)
        expect(page).to have_content("Sorry, the service is unavailable")
      end
    end
  end

  describe "when maintenance mode is disabled" do
    before do
      allow(FeatureToggle).to receive(:maintenance_mode_enabled?).and_return(false)
    end

    context "when a user visits a page other than the maintenance page" do
      it "doesn't redirect the user to the maintenance page" do
        get "/lettings-logs"
        expect(response).not_to redirect_to(service_unavailable_path)
        expect(page).to have_content("Create a new lettings log")
      end
    end

    context "when a user visits the maintenance page" do
      it "redirects the user to the start page" do
        get "/service-unavailable"
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
