require "rails_helper"

RSpec.describe CookiesController, type: :request do
  let(:headers) { { "Accept" => "text/html" } }
  let(:page) { Capybara::Node::Simple.new(response.body) }

  describe "when maintenance mode is disabled" do
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

  describe "when maintenance mode is enabled" do
    before do
      allow(FeatureToggle).to receive(:maintenance_mode_enabled?).and_return(true)
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
