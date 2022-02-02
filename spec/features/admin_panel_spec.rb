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
      click_button("Login")
      fill_in("code", with: otp)
      click_button("Submit")
      expect(page).to have_content("Dashboard")
      expect(page).to have_content("Two factor authentication successful.")
    end

    context "but it is more than 5 minutes old" do
      it "does not authenticate successfully" do
        click_button("Login")
        admin.update!(direct_otp_sent_at: 10.minutes.ago)
        fill_in("code", with: otp)
        click_button("Submit")
        expect(page).to have_content("Check your phone")
      end
    end
  end

  context "with an invalid 2FA code" do
    it "does not authenticate successfully" do
      visit("/admin")
      fill_in("admin_user[email]", with: admin.email)
      fill_in("admin_user[password]", with: admin.password)
      click_button("Login")
      fill_in("code", with: otp)
      click_button("Submit")
      expect(page).to have_content("Check your phone")
    end
  end

  context "when the 2FA code needs to be resent" do
    before do
      visit("/admin")
      fill_in("admin_user[email]", with: admin.email)
      fill_in("admin_user[password]", with: admin.password)
      click_button("Login")
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
end
