require "rails_helper"
RSpec.describe "User Features" do
  let!(:user) { FactoryBot.create(:user) }
  context "A user navigating to case logs" do
    it " is required to log in" do
      visit("/case_logs")
      expect(page).to have_current_path("/users/sign_in")
    end

    it " is redirected to case logs after signing in" do
      visit("/case_logs")
      fill_in("user_email", with: "test@example.com")
      fill_in("user_password", with: "pAssword1")
      click_button("Sign in")
      expect(page).to have_current_path("/case_logs")
    end
  end

  context "A user who has forgotten their password" do
    it " is redirected to the reset password page when they click the reset password link" do
      visit("/case_logs")
      click_link("reset your password")
      expect(page).to have_current_path("/users/password/new")
    end
  end
end
