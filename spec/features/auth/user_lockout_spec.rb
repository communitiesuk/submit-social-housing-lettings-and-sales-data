require "rails_helper"

RSpec.describe "User Lockout" do
  let(:user) { FactoryBot.create(:user) }
  let(:max_login_attempts) { Devise.maximum_attempts }
  let(:max_2fa_attempts) { Devise.max_login_attempts }
  let(:notify_client) { instance_double(Notifications::Client) }

  context "when login-in with the wrong user password up to a maximum number of attempts" do
    before do
      visit("/account/sign-in")
      max_login_attempts.times do
        fill_in("user[email]", with: user.email)
        fill_in("user[password]", with: "wrong_password")
        click_button("Sign in")
      end
    end

    it "locks the user account" do
      visit("/account/sign-in")
      fill_in("user[email]", with: user.email)
      fill_in("user[password]", with: user.password)
      click_button("Sign in")
      expect(page).to have_http_status(:unprocessable_entity)
      expect(page).to have_content(I18n.t("devise.failure.locked"))
    end
  end
end
