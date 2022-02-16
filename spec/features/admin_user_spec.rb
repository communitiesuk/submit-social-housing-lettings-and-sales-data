require "rails_helper"

RSpec.describe "Admin Features" do
  let!(:admin_user) { FactoryBot.create(:admin_user, last_sign_in_at: Time.zone.now) }
  let(:notify_client) { instance_double(Notifications::Client) }
  let(:reset_password_token) { "MCDH5y6Km-U7CFPgAMVS" }
  let(:devise_notify_mailer) { DeviseNotifyMailer.new }

  before do
    allow(DeviseNotifyMailer).to receive(:new).and_return(devise_notify_mailer)
    allow(devise_notify_mailer).to receive(:notify_client).and_return(notify_client)
    allow(notify_client).to receive(:send_email).and_return(true)
    allow(Devise.token_generator).to receive(:generate).and_return(reset_password_token)
  end

  context "when the admin has forgotten their password" do
    it " is redirected to the reset password page when they click the reset password link" do
      visit("/admin")
      click_link("Forgot your password?")
      expect(page).to have_current_path("/admin/password/new")
    end

    it " is shown an error message if they submit without entering an email address" do
      visit("/admin/password/new")
      click_button("Reset My Password")
      expect(page).to have_selector("#error_explanation")
      expect(page).to have_content("can't be blank")
    end

    it " is redirected to admin login page after reset email is sent" do
      visit("/admin/password/new")
      fill_in("admin_user[email]", with: admin_user.email)
      click_button("Reset My Password")
      expect(page).to have_current_path("/admin/login")
    end

    it " is sent a reset password email via Notify" do
      expect(notify_client).to receive(:send_email).with(
        {
          email_address: admin_user.email,
          template_id: admin_user.reset_password_notify_template,
          personalisation: {
            name: admin_user.email,
            email: admin_user.email,
            organisation: "",
            link: "http://localhost:3000/admin/password/edit?reset_password_token=#{reset_password_token}",
          },
        },
      )
      visit("/admin/password/new")
      fill_in("admin_user[email]", with: admin_user.email)
      click_button("Reset My Password")
    end
  end
end
