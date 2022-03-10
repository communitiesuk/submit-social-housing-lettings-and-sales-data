require "rails_helper"

RSpec.describe "User Lockout" do
  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:admin_user) }
  let(:attempt_number) { Devise.maximum_attempts }

  context "when login-in with the wrong user password up to a maximum number of attempts" do
    before do
      attempt_number.times do
        visit("/users/sign-in")
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
      attempt_number.times do
        visit("/admin/sign-in")
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
end
