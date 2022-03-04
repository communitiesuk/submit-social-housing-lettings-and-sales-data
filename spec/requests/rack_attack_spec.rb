require "rails_helper"
require_relative "../support/devise"
require_relative "../support/rack_attack"
require "rack/attack"

describe "Rack::Attack" do
  let(:limit) { 5 }
  let(:under_limit) { limit / 2 }
  let(:over_limit) { limit + 1 }

  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:notify_client) { instance_double(Notifications::Client) }
  let(:devise_notify_mailer) { DeviseNotifyMailer.new }

  before do
    Rack::Attack.enabled = false
    allow(DeviseNotifyMailer).to receive(:new).and_return(devise_notify_mailer)
    allow(devise_notify_mailer).to receive(:notify_client).and_return(notify_client)
    allow(notify_client).to receive(:send_email).and_return(true)
  end

  context "when a regular user" do
    let(:params) { { user: { email: } } }

    context "when a password reset is requested for a valid email" do
      let(:user) { FactoryBot.create(:user) }
      let(:email) { user.email }

      it "does not throttle" do
        under_limit.times do
          post "/users/password", params: params
          follow_redirect!
        end
        expect(last_response.status).to eq(200)

        # post "/users/password", params: params
        # expect(response).to have_http_status(:redirect)
        # follow_redirect!
        # expect(response.body).to match(/Check your email/)
      end
    end
  end
end
