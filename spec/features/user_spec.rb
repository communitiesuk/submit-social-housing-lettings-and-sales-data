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
      fill_in("user_email", with: user.email)
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

    it " is redirected to check your email page after submitting an email on the reset password page" do
      visit("/users/password/new")
      fill_in("user_email", with: user.email)
      click_button("Send email")
      expect(page).to have_content("Check your email")
    end

    it " is shown their email on the password reset confirmation page" do
      visit("/users/password/new")
      fill_in("user_email", with: user.email)
      click_button("Send email")
      expect(page).to have_content(user.email)
    end

    it " is shown the reset password confirmation page even if their email doesn't exist in the system" do
      visit("/users/password/new")
      fill_in("user_email", with: "idontexist@example.com")
      click_button("Send email")
      expect(page).to have_current_path("/confirmations/reset?email=idontexist%40example.com")
    end

    it " is sent a reset password email" do
      visit("/users/password/new")
      fill_in("user_email", with: user.email)
      expect { click_button("Send email") }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it " is shown the password reset confirmation page and successful flash message shows" do
      visit("/users/password/new")
      fill_in("user_email", with: user.email)
      click_button("Send email")
      expect(page).to have_css ".govuk-notification-banner.govuk-notification-banner--success"
    end
  end

  context "If user not logged in" do
    it "'Your account' link does not display" do
      visit("/case_logs")
      expect(page).to have_no_link("Your account")
    end

    it "tries to access account page, redirects to log in page" do
      visit("/users/account")
      expect(page).to have_content("Sign in to your account to submit CORE data")
    end
  end

  context "Your Account " do
    before(:each) do
      visit("/case_logs")
      fill_in("user_email", with: user.email)
      fill_in("user_password", with: "pAssword1")
      click_button("Sign in")
    end

    it "shows 'Your account' link in navigation if logged in and redirect to correct page" do
      visit("/case_logs")
      expect(page).to have_link("Your account")
      click_link("Your account")
      expect(page).to have_current_path("/users/account")
    end

    it "main page is present and accessible" do
      visit("/users/account")
      expect(page).to have_content("Your account")
    end

    it "personal details page is present and accessible" do
      visit("/users/account/personal_details")
      expect(page).to have_content("Change your personal details")
    end

    it "edit password page present and accessible" do
      visit("users/edit")
      expect(page).to have_content("Change your password")
    end

    it "can navigate to change your password page from main account page" do
      visit("/users/account")
      click_link("change-password")
      expect(page).to have_content("Change your password")
      fill_in("user_current_password", with: "pAssword1")
      fill_in("user_password", with: "Password123!")
      click_button("Update")
      expect(page).to have_current_path("/users/account")
    end

    it "allow user to change name" do
      visit("/users/account")
      click_link("change-name")
      expect(page).to have_content("Change your personal details")
      fill_in("user_name", with: "Test New")
      click_button("Save changes")
      expect(page).to have_current_path("/users/account")
      expect(page).to have_content("Test New")
    end
  end
end
