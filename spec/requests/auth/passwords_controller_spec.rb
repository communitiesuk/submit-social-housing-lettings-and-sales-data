require "rails_helper"
require_relative "../../support/devise"

RSpec.describe Auth::PasswordsController, type: :request do
  let(:params) { { user: { email: email } } }
  let(:page) { Capybara::Node::Simple.new(response.body) }

  context "when a password reset is requested for a valid email" do
    let(:user) { FactoryBot.create(:user) }
    let(:email) { user.email }

    it "redirects to the email sent page" do
      post "/users/password", params: params
      expect(response).to have_http_status(:redirect)
      follow_redirect!
      expect(response.body).to match(/Check your email/)
    end
  end

  context "when a password reset is requested with an email that doesn't exist in the system" do
    before do
      allow_any_instance_of(Auth::PasswordsController).to receive(:is_navigational_format?).and_return(false)
    end

    let(:email) { "madeup_email@test.com" }

    it "redirects to the email sent page anyway" do
      post "/users/password", params: params
      expect(response).to have_http_status(:redirect)
      follow_redirect!
      expect(response.body).to match(/Check your email/)
    end
  end

  context "when a password reset is requested the email" do
    let(:user) { FactoryBot.create(:user, last_sign_in_at: Time.zone.now) }
    let(:email) { user.email }

    it "should contain the correct email" do
      post "/users/password", params: params
      follow_redirect!
      email_ascii_content = ActionMailer::Base.deliveries.last.body.raw_source
      email_content = email_ascii_content.encode("ASCII", "UTF-8", undef: :replace)
      expect(email_content).to match(email)
    end
  end

  context "#Update - reset password" do
    let(:user) { FactoryBot.create(:user) }
    let(:token) { user.send(:set_reset_password_token) }
    let(:updated_password) { "updated_password_280" }
    let(:update_password_params) do
      {
        user:
          {
            reset_password_token: token,
            password: updated_password,
            password_confirmation: updated_password
          }
      }
    end
    let(:message) { "Your password has been changed successfully. You are now signed in" }

    it "changes the password" do
      expect { put "/users/password", params: update_password_params }
        .to change { user.reload.encrypted_password }
    end

    it "signs in" do
      put "/users/password", params: update_password_params
      follow_redirect!
      expect(page).to have_css("div", class: "govuk-notification-banner__heading", text: message)
    end
  end
end
