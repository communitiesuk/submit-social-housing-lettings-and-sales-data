require "rails_helper"

RSpec.describe LocationsController, type: :request do
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:user) { FactoryBot.create(:user, :support) }
  let!(:scheme) { FactoryBot.create(:scheme, organisation: user.organisation) }

  describe "#new" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        get "/schemes/1/location/new"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        get "/schemes/1/location/new"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let!(:scheme) { FactoryBot.create(:scheme, organisation: user.organisation) }

      before do
        sign_in user
        get "/schemes/#{scheme.id}/location/new"
      end

      it "returns a template for a new location" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("Add a location to this scheme")
      end
    end

    context "when signed in as a support user" do
      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        get "/schemes/#{scheme.id}/location/new"
      end

      it "returns a template for a new location" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("Add a location to this scheme")
      end
    end
  end

  describe "#create" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        post "/schemes/1/location/create"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        post "/schemes/1/location/create"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
