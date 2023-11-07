require "rails_helper"

RSpec.describe CookiesController, type: :request do
  let(:headers) { { "Accept" => "text/html" } }
  let(:page) { Capybara::Node::Simple.new(response.body) }

  describe "when the service is available" do
    describe "render cookies page" do
      before do
        get "/cookies", headers:, params: {}
      end

      it "returns a 200" do
        expect(response).to have_http_status(:success)
      end

      it "returns the page" do
        expect(page).to have_title("Cookies")
      end
    end
  end

  describe "when the service has moved" do
    before do
      allow(FeatureToggle).to receive(:service_moved?).and_return(true)
    end

    describe "render cookies page" do
      before do
        get "/cookies", headers:, params: {}
      end

      it "returns a 200" do
        expect(response).to have_http_status(:success)
      end

      it "returns the page" do
        expect(page).to have_title("Cookies")
      end
    end
  end

  describe "when the service is unavailable" do
    before do
      allow(FeatureToggle).to receive(:service_unavailable?).and_return(true)
    end

    describe "render cookies page" do
      before do
        get "/cookies", headers:, params: {}
      end

      it "returns a 200" do
        expect(response).to have_http_status(:success)
      end

      it "returns the page" do
        expect(page).to have_title("Cookies")
      end
    end
  end
end
