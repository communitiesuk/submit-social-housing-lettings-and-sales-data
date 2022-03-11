require "rails_helper"

RSpec.describe "User Lockout" do
  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:admin_user) }
  let(:max_login_attempts) { Devise.maximum_attempts }
  let(:max_2fa_attempts) { Devise.max_login_attempts }
  let(:notify_client) { instance_double(Notifications::Client) }

  context "when login-in with the wrong user password up to a maximum number of attempts" do
    before do
      visit("/users/sign-in")
      max_login_attempts.times do
        fill_in("user[email]", with: user.email)
        fill_in("user[password]", with: "wrong_password")
        click_button("Sign in")
      end
    end

    it "locks the user account" do
      visit("/users/sign-in")
      fill_in("user[email]", with: user.email)
      fill_in("user[password]", with: user.password)
      click_button("Sign in")
      expect(page).to have_http_status(:unprocessable_entity)
      expect(page).to have_content("Your account is locked.")
    end
  end

  context "when login-in with the wrong admin password up to a maximum number of attempts" do
    before do
      visit("/admin/sign-in")
      max_login_attempts.times do
        fill_in("admin_user[email]", with: admin.email)
        fill_in("admin_user[password]", with: "wrong_password")
        click_button("Sign in")
      end
    end

    it "locks the admin account" do
      visit("/admin/sign-in")
      fill_in("admin_user[email]", with: admin.email)
      fill_in("admin_user[password]", with: admin.password)
      click_button("Sign in")
      expect(page).to have_http_status(:unprocessable_entity)
      expect(page).to have_content("Your account is locked.")
    end
  end

  context "when login-in with the right admin password and incorrect 2FA token up to a maximum number of attempts" do
    before do
      allow(Sms).to receive(:notify_client).and_return(notify_client)
      allow(notify_client).to receive(:send_sms).and_return(true)

      visit("/admin/sign-in")
      fill_in("admin_user[email]", with: admin.email)
      fill_in("admin_user[password]", with: admin.password)
      click_button("Sign in")

      max_2fa_attempts.times do
        fill_in("code", with: "random")
        click_button("Submit")
      end
    end

    it "locks the admin account" do
      visit("/admin/sign-in")
      fill_in("admin_user[email]", with: admin.email)
      fill_in("admin_user[password]", with: admin.password)
      click_button("Sign in")
      expect(page).to have_http_status(:unprocessable_entity)
      expect(page).to have_content(I18n.t("devise.two_factor_authentication.account_locked"))
    end
  end
end
