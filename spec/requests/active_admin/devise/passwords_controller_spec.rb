require "rails_helper"

RSpec.describe ActiveAdmin::Devise::PasswordsController, type: :request do
  let(:admin_user) { FactoryBot.create(:admin_user) }
  let(:headers) { { "Accept" => "text/html" } }
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:new_value) { "new-password" }
  let(:notify_client) { instance_double(Notifications::Client) }
  let(:devise_notify_mailer) { DeviseNotifyMailer.new }

  before do
    allow(DeviseNotifyMailer).to receive(:new).and_return(devise_notify_mailer)
    allow(devise_notify_mailer).to receive(:notify_client).and_return(notify_client)
    allow(notify_client).to receive(:send_email).and_return(true)
  end

  describe "reset password" do
    it "renders the user edit password view" do
      _raw, enc = Devise.token_generator.generate(AdminUser, :reset_password_token)
      get "/admin/password/edit?reset_password_token=#{enc}"
      expect(page).to have_css("h2", text: "DLUHC CORE Change your password")
    end

    context "when passwords entered don't match" do
      let(:raw) { admin_user.send_reset_password_instructions }
      let(:params) do
        {
          id: admin_user.id,
          admin_user: {
            password: new_value,
            password_confirmation: "something_else",
            reset_password_token: raw,
          },
        }
      end

      it "shows an error" do
        put "/admin/password", headers: headers, params: params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(page).to have_content("doesn't match Password")
      end
    end

    context "when passwords is reset" do
      let(:raw) { admin_user.send_reset_password_instructions }
      let(:params) do
        {
          id: admin_user.id,
          admin_user: {
            password: new_value,
            password_confirmation: new_value,
            reset_password_token: raw,
          },
        }
      end

      it "updates the password" do
        expect {
          put "/admin/password", headers: headers, params: params
          admin_user.reload
        }.to change(admin_user, :encrypted_password)
      end
    end
  end
end
