require "rails_helper"

RSpec.describe ContentController, type: :request do
  let(:headers) { { "Accept" => "text/html" } }
  let(:page) { Capybara::Node::Simple.new(response.body) }

  describe "when the service is available" do
    describe "render privacy notice content page" do
      before do
        get "/privacy-notice", headers:, params: {}
      end

      it "returns a 200" do
        expect(response).to have_http_status(:success)
      end

      it "returns the page" do
        expect(page).to have_title("Privacy notice")
      end
    end

    describe "render accessibility statement content page" do
      before do
        get "/accessibility-statement", headers:, params: {}
      end

      it "returns a 200" do
        expect(response).to have_http_status(:success)
      end

      it "returns the page" do
        expect(page).to have_title("Accessibility statement")
      end
    end

    describe "render data sharing agreement" do
      before do
        get "/data-sharing-agreement", headers:, params: {}
      end

      it "returns a 200" do
        expect(response).to have_http_status(:success)
      end

      it "returns the page" do
        expect(page).to have_title("Data sharing agreement")
      end
    end
  end

  describe "when the service is unavailable" do
    before do
      allow(FeatureToggle).to receive(:service_unavailable?).and_return(true)
    end

    describe "render privacy notice content page" do
      before do
        get "/privacy-notice", headers:, params: {}
      end

      it "returns a 200" do
        expect(response).to have_http_status(:success)
      end

      it "returns the page" do
        expect(page).to have_title("Privacy notice")
      end
    end

    describe "render accessibility statement content page" do
      before do
        get "/accessibility-statement", headers:, params: {}
      end

      it "returns a 200" do
        expect(response).to have_http_status(:success)
      end

      it "returns the page" do
        expect(page).to have_title("Accessibility statement")
      end
    end
  end
end
