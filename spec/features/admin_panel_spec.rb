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
    end

    it "authenticates successfully" do
      expect(notify_client).to receive(:send_sms).with(
        hash_including(phone_number: admin.phone, template_id: mfa_template_id),
      )
      visit("/admin")
      fill_in("admin_user[email]", with: admin.email)
      fill_in("admin_user[password]", with: admin.password)
      click_button("Login")
      fill_in("code", with: otp)
      click_button("Submit")
      expect(page).to have_content("Dashboard")
      expect(page).to have_content("Two factor authentication successful.")
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
end
