require "rails_helper"

RSpec.describe "User Features" do
  let!(:user) { FactoryBot.create(:user, last_sign_in_at: Time.zone.now) }
  let(:reset_password_template_id) { DeviseNotifyMailer::RESET_PASSWORD_TEMPLATE_ID }
  let(:notify_client) { double(Notifications::Client) }
  let(:reset_password_token) { "MCDH5y6Km-U7CFPgAMVS" }
  before do
    allow_any_instance_of(DeviseNotifyMailer).to receive(:notify_client).and_return(notify_client)
    allow_any_instance_of(DeviseNotifyMailer).to receive(:host).and_return("test.com")
    allow(notify_client).to receive(:send_email).and_return(true)
    allow_any_instance_of(User).to receive(:set_reset_password_token).and_return(reset_password_token)
  end

  context "A user navigating to case logs" do
    it " is required to log in" do
      visit("/logs")
      expect(page).to have_current_path("/users/sign-in")
    end

    it "does not see the default devise error message" do
      visit("/logs")
      expect(page).to have_no_content("You need to sign in or sign up before continuing.")
    end

    it " is redirected to case logs after signing in" do
      visit("/logs")
      fill_in("user[email]", with: user.email)
      fill_in("user[password]", with: "pAssword1")
      click_button("Sign in")
      expect(page).to have_current_path("/logs")
    end
  end

  context "A user who has forgotten their password" do
    it " is redirected to the reset password page when they click the reset password link" do
      visit("/logs")
      click_link("reset your password")
      expect(page).to have_current_path("/users/password/new")
    end

    it " is shown an error message if they submit without entering an email address" do
      visit("/users/password/new")
      click_button("Send email")
      expect(page).to have_selector("#error-summary-title")
      expect(page).to have_selector("#user-email-field-error")
      expect(page).to have_title("Error")
    end

    it " is shown an error message if they submit an invalid email address" do
      visit("/users/password/new")
      fill_in("user[email]", with: "thisisn'tanemail")
      click_button("Send email")
      expect(page).to have_selector("#error-summary-title")
      expect(page).to have_selector("#user-email-field-error")
      expect(page).to have_title("Error")
    end

    it " is redirected to check your email page after submitting an email on the reset password page" do
      visit("/users/password/new")
      fill_in("user[email]", with: user.email)
      click_button("Send email")
      expect(page).to have_content("Check your email")
    end

    it " is shown their email on the password reset confirmation page" do
      visit("/users/password/new")
      fill_in("user[email]", with: user.email)
      click_button("Send email")
      expect(page).to have_content(user.email)
    end

    it " is shown the reset password confirmation page even if their email doesn't exist in the system" do
      visit("/users/password/new")
      fill_in("user[email]", with: "idontexist@example.com")
      click_button("Send email")
      expect(page).to have_current_path("/confirmations/reset?email=idontexist%40example.com")
    end

    it " is sent a reset password email via Notify" do
      expect(notify_client).to receive(:send_email).with(
        {
          email_address: user.email,
          template_id: reset_password_template_id,
          personalisation: {
            name: user.name,
            email: user.email,
            organisation: user.organisation.name,
            link: "https://test.com/users/password/edit?reset_password_token=#{reset_password_token}",
          },
        },
      )
      visit("/users/password/new")
      fill_in("user[email]", with: user.email)
      click_button("Send email")
    end
  end

  context "If user not logged in" do
    it "'Your account' link does not display" do
      visit("/logs")
      expect(page).to have_no_link("Your account")
    end

    it "Can navigate and sign in page with sign in button" do
      visit("/")
      expect(page).to have_link("Sign in")
      click_link("Sign in")
      fill_in("user[email]", with: user.email)
      fill_in("user[password]", with: "pAssword1")
      click_button("Sign in")
      expect(page).to have_current_path("/")
    end

    it "tries to access account page, redirects to log in page" do
      visit("/users/#{user.id}")
      expect(page).to have_content("Sign in to your account to submit CORE data")
    end
  end

  context "Trying to log in with incorrect credentials" do
    it "shows a gov uk error summary and no flash message" do
      visit("/logs")
      fill_in("user[email]", with: user.email)
      fill_in("user[password]", with: "nonsense")
      click_button("Sign in")
      expect(page).to have_selector("#error-summary-title")
      expect(page).to have_no_css(".govuk-notification-banner.govuk-notification-banner--success")
      expect(page).to have_title("Error")
    end

    it "show specific field error messages if a field was omitted" do
      visit("/logs")
      click_button("Sign in")
      expect(page).to have_selector("#error-summary-title")
      expect(page).to have_selector("#user-email-field-error")
      expect(page).to have_selector("#user-password-field-error")
      expect(page).to have_title("Error")
    end

    it "show specific field error messages if an invalid email address is entered" do
      visit("/logs")
      fill_in("user[email]", with: "thisisn'tanemail")
      click_button("Sign in")
      expect(page).to have_selector("#error-summary-title")
      expect(page).to have_selector("#user-email-field-error")
      expect(page).to have_content(/Enter an email address in the correct format, like name@example.com/)
      expect(page).to have_title("Error")
    end
  end

  context "Your Account " do
    before(:each) do
      visit("/logs")
      fill_in("user[email]", with: user.email)
      fill_in("user[password]", with: "pAssword1")
      click_button("Sign in")
    end

    it "shows 'Your account' link in navigation if logged in and redirect to correct page" do
      visit("/logs")
      expect(page).to have_link("Your account")
      click_link("Your account")
      expect(page).to have_current_path("/users/#{user.id}")
    end

    it "can navigate to change your password page from main account page" do
      visit("/users/#{user.id}")
      find('[data-qa="change-password"]').click
      expect(page).to have_content("Change your password")
      fill_in("user[password]", with: "Password123!")
      fill_in("user[password_confirmation]", with: "Password123!")
      click_button("Update")
      expect(page).to have_current_path("/users/#{user.id}")
    end

    it "allow user to change name" do
      visit("/users/#{user.id}")
      find('[data-qa="change-name"]').click
      expect(page).to have_content("Change your personal details")
      fill_in("user[name]", with: "Test New")
      click_button("Save changes")
      expect(page).to have_current_path("/users/#{user.id}")
      expect(page).to have_content("Test New")
    end
  end

  context "Adding a new user" do
    before(:each) do
      visit("/logs")
      fill_in("user[email]", with: user.email)
      fill_in("user[password]", with: "pAssword1")
      click_button("Sign in")
    end

    it "validates an email has been provided" do
      visit("users/new")
      fill_in("user[name]", with: "New User")
      click_button("Continue")
      expect(page).to have_selector("#error-summary-title")
      expect(page).to have_selector("#user-email-field-error")
      expect(page).to have_content(/Enter an email address/)
      expect(page).to have_title("Error")
    end

    it "validates email" do
      visit("users/new")
      fill_in("user[name]", with: "New User")
      fill_in("user[email]", with: "thisis'tanemail")
      click_button("Continue")
      expect(page).to have_selector("#error-summary-title")
      expect(page).to have_selector("#user-email-field-error")
      expect(page).to have_content(/Enter an email address in the correct format, like name@example.com/)
      expect(page).to have_title("Error")
    end
  end
end
