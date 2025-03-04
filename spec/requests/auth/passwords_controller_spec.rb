require "rails_helper"
require_relative "../../support/devise"

RSpec.describe Auth::PasswordsController, type: :request do
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:notify_client) { instance_double(Notifications::Client) }
  let(:devise_notify_mailer) { DeviseNotifyMailer.new }
  let(:storage_service) { instance_double(Storage::S3Service, get_file_metadata: nil) }

  before do
    allow(DeviseNotifyMailer).to receive(:new).and_return(devise_notify_mailer)
    allow(devise_notify_mailer).to receive(:notify_client).and_return(notify_client)
    allow(notify_client).to receive(:send_email).and_return(true)
    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(storage_service).to receive(:configuration).and_return(OpenStruct.new(bucket_name: "core-test-collection-resources"))
  end

  context "when a regular user" do
    let(:params) { { user: { email: } } }

    context "when a password reset is requested for a valid email" do
      let(:user) { FactoryBot.create(:user) }
      let(:email) { user.email }

      it "redirects to the email sent page" do
        post "/account/password", params: params
        expect(response).to have_http_status(:redirect)
        follow_redirect!
        expect(response.body).to match(/Check your email/)
      end
    end

    context "when a password reset is requested with an email that doesn't exist in the system" do
      before do
        allow(Devise.navigational_formats).to receive(:include?).and_return(false)
      end

      let(:email) { "madeup_email@test.com" }

      it "redirects to the email sent page anyway" do
        post "/account/password", params: params
        expect(response).to have_http_status(:redirect)
        follow_redirect!
        expect(response.body).to match(/Check your email/)
      end
    end

    describe "#Update - reset password" do
      let(:user) { FactoryBot.create(:user) }
      let(:token) { user.send(:set_reset_password_token) }
      let(:updated_password) { "updated_password_280" }
      let(:update_password_params) do
        {
          user:
            {
              reset_password_token: token,
              password: updated_password,
              password_confirmation: updated_password,
            },
        }
      end
      let(:message) { I18n.t("devise.passwords.updated") }

      it "changes the password" do
        expect { put "/account/password", params: update_password_params }
          .to(change { user.reload.encrypted_password })
      end

      it "after password change, the user is signed in" do
        put "/account/password", params: update_password_params
        # Devise redirects once after re-sign in with new password and then root redirects as well.
        follow_redirect!
        expect(page).to have_css("p", class: "govuk-notification-banner__heading", text: message)
      end

      context "when the user had been locked out" do
        let(:user) { create(:user, locked_at: Time.zone.now, failed_attempts: 5) }

        it "after password change, unlocks the user account and signs them in" do
          put "/account/password", params: update_password_params
          follow_redirect!
          user.reload
          expect(user.locked_at).to be_nil
          expect(user.failed_attempts).to be 0
          expect(page).to have_content("Welcome back, #{user.name}")
        end
      end
    end
  end

  context "when a customer support user" do
    let(:support_user) { FactoryBot.create(:user, :support) }

    describe "reset password" do
      let(:new_value) { "new-password" }

      before do
        allow(DeviseNotifyMailer).to receive(:notify_client).and_return(notify_client)
        allow(notify_client).to receive(:send_email).and_return(true)
      end

      it "renders the user edit password view" do
        _raw, enc = Devise.token_generator.generate(User, :reset_password_token)
        get "/account/password/edit?reset_password_token=#{enc}?confirmation=true"
        expect(page).to have_css("h1", text: "Reset your password")
      end

      context "when passwords entered don't match" do
        let(:raw) { support_user.send_reset_password_instructions }
        let(:params) do
          {
            id: support_user.id,
            user: {
              password: new_value,
              password_confirmation: "something_else",
              reset_password_token: raw,
            },
          }
        end

        it "shows an error on the same page" do
          put "/account/password", headers: headers, params: params
          expect(response).to have_http_status(:unprocessable_content)
          expect(page).to have_css("h1", text: "Reset your password")
          expect(page).to have_content("passwords you entered do not match")
        end
      end

      context "when passwords is reset" do
        let(:raw) { support_user.send_reset_password_instructions }
        let(:params) do
          {
            id: support_user.id,
            user: {
              password: new_value,
              password_confirmation: new_value,
              reset_password_token: raw,
            },
          }
        end

        it "updates the password" do
          expect {
            put "/account/password", headers: headers, params: params
            support_user.reload
          }.to change(support_user, :encrypted_password)
        end

        it "sends you to the 2FA page and does not allow bypassing 2FA code" do
          put "/account/password", headers: headers, params: params
          expect(response).to redirect_to("/account/two-factor-authentication")
          get "/lettings-logs", headers: headers
          expect(response).to redirect_to("/account/two-factor-authentication")
        end

        it "triggers an email" do
          expect(notify_client).to receive(:send_email)
          put "/account/password", headers:, params:
        end
      end
    end
  end

  context "when a password is reset" do
    let(:email) { nil }

    it "does not error if the email is nil or not in the params" do
      expect { get account_password_reset_confirmation_path(email:) }.not_to raise_error
    end
  end
end
