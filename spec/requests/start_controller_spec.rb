require "rails_helper"

RSpec.describe StartController, type: :request do
  let(:user) { create(:user) }
  let(:headers) { { "Accept" => "text/html" } }
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:notify_client) { instance_double(Notifications::Client) }
  let(:devise_notify_mailer) { DeviseNotifyMailer.new }

  before do
    allow(DeviseNotifyMailer).to receive(:new).and_return(devise_notify_mailer)
    allow(devise_notify_mailer).to receive(:notify_client).and_return(notify_client)
    allow(notify_client).to receive(:send_email).and_return(true)
  end

  describe "GET" do
    context "when the user is not signed in" do
      it "routes user to the start in page" do
        get "/", headers: headers, params: {}
        expect(path).to include("/")
        expect(page).to have_content("Start now")
      end
    end

    context "when the user is signed in" do
      before do
        sign_in user
      end

      it "routes user to the home page" do
        get "/", headers:, params: {}
        expect(page).to have_content("Welcome back")
      end
    end
  end

  describe "guidance page" do
    context "when the user is not signed in" do
      it "routes user to the guidance page" do
        get "/guidance", headers:, params: {}
        expect(page).to have_content("Guidance for submitting social housing lettings and sales data")
      end
    end

    context "when the user is signed in" do
      before do
        sign_in user
      end

      it "routes user to the guidance page" do
        get "/guidance", headers:, params: {}
        expect(page).to have_content("Guidance for submitting social housing lettings and sales data")
      end
    end
  end
end
