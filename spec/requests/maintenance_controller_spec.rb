require "rails_helper"

RSpec.describe MaintenanceController, type: :request do
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:user) { FactoryBot.create(:user) }
  let(:storage_service) { instance_double(Storage::S3Service) }

  before do
    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(storage_service).to receive(:configuration).and_return(OpenStruct.new(bucket_name: "core-test-collection-resources"))
    sign_in user
  end

  describe "when the service has moved" do
    before do
      allow(FeatureToggle).to receive(:service_moved?).and_return(true)
    end

    context "when a user visits a page other than the service moved page" do
      before do
        get "/service-unavailable"
      end

      it "redirects the user to the service moved page" do
        expect(response).to redirect_to(service_moved_path)
        follow_redirect!
        expect(page).to have_content("The URL for this service has changed")
      end

      it "the cookie banner is visible" do
        follow_redirect!
        expect(page).to have_content("We’d like to use analytics cookies so we can understand how you use the service and make improvements.")
      end
    end

    context "when a user visits the service moved page" do
      before do
        get "/service-moved"
      end

      it "keeps the user on the service moved page" do
        expect(response).not_to redirect_to(service_moved_path)
        expect(page).to have_content("The URL for this service has changed")
      end

      it "the cookie banner is visible" do
        expect(page).to have_content("We’d like to use analytics cookies so we can understand how you use the service and make improvements.")
      end
    end
  end

  describe "when the service is unavailable" do
    before do
      allow(FeatureToggle).to receive(:service_unavailable?).and_return(true)
    end

    context "when a user visits a page other than the service unavailable page" do
      before do
        get "/lettings-logs"
      end

      it "redirects the user to the service unavailable page" do
        expect(response).to redirect_to(service_unavailable_path)
        follow_redirect!
        expect(page).to have_content("Sorry, the service is unavailable")
      end

      it "the cookie banner is visible" do
        follow_redirect!
        expect(page).to have_content("We’d like to use analytics cookies so we can understand how you use the service and make improvements.")
      end
    end

    context "when a user visits the service unavailable page" do
      before do
        get "/service-unavailable"
      end

      it "keeps the user on the service unavailable page" do
        expect(response).not_to redirect_to(service_unavailable_path)
        expect(page).to have_content("Sorry, the service is unavailable")
      end

      it "the cookie banner is visible" do
        expect(page).to have_content("We’d like to use analytics cookies so we can understand how you use the service and make improvements.")
      end
    end
  end

  describe "when both the service_moved? and service_unavailable? feature toggles are on" do
    before do
      allow(FeatureToggle).to receive(:service_moved?).and_return(true)
      allow(FeatureToggle).to receive(:service_unavailable?).and_return(true)
    end

    context "when a user visits a page other than the service moved page" do
      before do
        get "/service-unavailable"
      end

      it "redirects the user to the service moved page" do
        expect(response).to redirect_to(service_moved_path)
        follow_redirect!
        expect(page).to have_content("The URL for this service has changed")
      end

      it "the cookie banner is visible" do
        follow_redirect!
        expect(page).to have_content("We’d like to use analytics cookies so we can understand how you use the service and make improvements.")
      end
    end

    context "when a user visits the service moved page" do
      before do
        get "/service-moved"
      end

      it "keeps the user on the service moved page" do
        expect(response).not_to redirect_to(service_moved_path)
        expect(page).to have_content("The URL for this service has changed")
      end

      it "the cookie banner is visible" do
        expect(page).to have_content("We’d like to use analytics cookies so we can understand how you use the service and make improvements.")
      end
    end
  end

  describe "when the service is available" do
    before do
      allow(FeatureToggle).to receive(:service_unavailable?).and_return(false)
    end

    context "when a user visits a page other than the service unavailable page" do
      before do
        get "/lettings-logs"
      end

      it "doesn't redirect the user to the service unavailable page" do
        expect(response).not_to redirect_to(service_unavailable_path)
        expect(page).to have_content("Create a new lettings log")
      end

      it "the cookie banner is visible" do
        expect(page).to have_content("We’d like to use analytics cookies so we can understand how you use the service and make improvements.")
      end
    end

    context "when a user visits the service unavailable page" do
      before do
        get "/service-unavailable"
      end

      it "redirects the user to the start page" do
        expect(response).to redirect_to(root_path)
      end

      it "the cookie banner is visible" do
        follow_redirect!
        expect(page).to have_content("We’d like to use analytics cookies so we can understand how you use the service and make improvements.")
      end
    end
  end
end
