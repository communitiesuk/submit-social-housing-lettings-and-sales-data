require "rails_helper"

RSpec.describe "Admin Panel" do
  let!(:admin) { FactoryBot.create(:admin_user) }
  let(:notify_client) { instance_double(Notifications::Client) }
  let(:mfa_template_id) { AdminUser::MFA_SMS_TEMPLATE_ID }
  let(:otp) { "999111" }

  before do
    allow(Sms).to receive(:notify_client).and_return(notify_client)
    allow(notify_client).to receive(:send_sms).and_return(true)
  end

  it "shows the admin sign in page" do
    visit("/admin")
    expect(page).to have_current_path("/admin/sign-in")
    expect(page).to have_content("CORE Admin Sign in")
  end

  context "with a valid 2FA code" do
    before do
      allow(SecureRandom).to receive(:random_number).and_return(otp)
      visit("/admin")
      fill_in("admin_user[email]", with: admin.email)
      fill_in("admin_user[password]", with: admin.password)
    end

    it "authenticates successfully" do
      expect(notify_client).to receive(:send_sms).with(
        hash_including(phone_number: admin.phone, template_id: mfa_template_id),
      )
      click_button("Sign in")
      fill_in("code", with: otp)
      click_button("Submit")
      expect(page).to have_content("Dashboard")
      expect(page).to have_content("Two factor authentication successful.")
    end

    context "but it is more than 15 minutes old" do
      it "does not authenticate successfully" do
        click_button("Sign in")
        admin.update!(direct_otp_sent_at: 16.minutes.ago)
        fill_in("code", with: otp)
        click_button("Submit")
        expect(page).to have_content("Check your phone")
        expect(page).to have_http_status(:unprocessable_entity)
        expect(page).to have_title("Error")
        expect(page).to have_selector("#error-summary-title")
      end
    end
  end

  context "with an invalid 2FA code" do
    it "does not authenticate successfully" do
      visit("/admin")
      fill_in("admin_user[email]", with: admin.email)
      fill_in("admin_user[password]", with: admin.password)
      click_button("Sign in")
      fill_in("code", with: otp)
      click_button("Submit")
      expect(page).to have_content("Check your phone")
      expect(page).to have_http_status(:unprocessable_entity)
      expect(page).to have_title("Error")
      expect(page).to have_selector("#error-summary-title")
    end
  end

  context "when the 2FA code needs to be resent" do
    before do
      visit("/admin")
      fill_in("admin_user[email]", with: admin.email)
      fill_in("admin_user[password]", with: admin.password)
      click_button("Sign in")
    end

    it "displays the resend view" do
      click_link("Not received a text message?")
      expect(page).to have_button("Resend security code")
    end

    it "send a new OTP code and redirects back to the 2FA view" do
      click_link("Not received a text message?")
      expect { click_button("Resend security code") }.to(change { admin.reload.direct_otp })
      expect(page).to have_current_path("/admin/two-factor-authentication")
    end
  end

  context "when logging out and in again" do
    before do
      allow(SecureRandom).to receive(:random_number).and_return(otp)
    end

    it "requires the 2FA code on each login" do
      visit("/admin")
      fill_in("admin_user[email]", with: admin.email)
      fill_in("admin_user[password]", with: admin.password)
      click_button("Sign in")
      fill_in("code", with: otp)
      click_button("Submit")
      click_link("Logout")
      visit("/admin")
      fill_in("admin_user[email]", with: admin.email)
      fill_in("admin_user[password]", with: admin.password)
      click_button("Sign in")
      expect(page).to have_content("Check your phone")
    end
  end

  context "when the admin has forgotten their password" do
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

    it " is redirected to the reset password page when they click the reset password link" do
      visit("/admin")
      click_link("reset your password")
      expect(page).to have_current_path("/admin/password/new")
    end

    it " is shown an error message if they submit without entering an email address" do
      visit("/admin/password/new")
      click_button("Send email")
      expect(page).to have_selector("#error-summary-title")
      expect(page).to have_selector("#user-email-field-error")
      expect(page).to have_title("Error")
    end

    it " is redirected to admin login page after reset email is sent" do
      visit("/admin/password/new")
      fill_in("admin_user[email]", with: admin_user.email)
      click_button("Send email")
      expect(page).to have_content("Check your email")
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
      click_button("Send email")
    end
  end
end
