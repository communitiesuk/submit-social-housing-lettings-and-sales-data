require "rails_helper"

RSpec.describe "User Features" do
  let!(:user) { FactoryBot.create(:user, last_sign_in_at: Time.zone.now) }
  let(:reset_password_template_id) { User::RESET_PASSWORD_TEMPLATE_ID }
  let(:notify_client) { instance_double(Notifications::Client) }
  let(:reset_password_token) { "MCDH5y6Km-U7CFPgAMVS" }
  let(:devise_notify_mailer) { DeviseNotifyMailer.new }

  before do
    allow(DeviseNotifyMailer).to receive(:new).and_return(devise_notify_mailer)
    allow(devise_notify_mailer).to receive(:notify_client).and_return(notify_client)
    allow(notify_client).to receive(:send_email).and_return(true)
    allow(Devise.token_generator).to receive(:generate).and_return(reset_password_token)
  end

  context "when the user navigates to case logs" do
    it "is required to log in" do
      visit("/logs")
      expect(page).to have_current_path("/account/sign-in")
      expect(page).to have_content("Sign in to your account to submit CORE data")
    end

    it "does not see the default devise error message" do
      visit("/logs")
      expect(page).to have_no_content("You need to sign in or sign up before continuing.")
    end

    it "is redirected to case logs after signing in" do
      visit("/logs")
      fill_in("user[email]", with: user.email)
      fill_in("user[password]", with: "pAssword1")
      click_button("Sign in")
      expect(page).to have_current_path("/logs")
    end

    it "can log out again", js: true do
      visit("/logs")
      fill_in("user[email]", with: user.email)
      fill_in("user[password]", with: "pAssword1")
      click_button("Sign in")
      click_link("Sign out")
      expect(page).to have_current_path("/")
      expect(page).to have_content("Start now")
    end

    it "can log out again with js disabled" do
      visit("/logs")
      fill_in("user[email]", with: user.email)
      fill_in("user[password]", with: "pAssword1")
      click_button("Sign in")
      click_link("Sign out")
      expect(page).to have_current_path("/")
      expect(page).to have_content("Start now")
    end
  end

  context "when the user has forgotten their password" do
    it "is redirected to the reset password page when they click the reset password link" do
      visit("/logs")
      click_link("reset your password")
      expect(page).to have_current_path("/account/password/new")
    end

    it "is shown an error message if they submit without entering an email address" do
      visit("/account/password/new")
      click_button("Send email")
      expect(page).to have_selector("#error-summary-title")
      expect(page).to have_selector("#user-email-field-error")
      expect(page).to have_title("Error")
    end

    it "is shown an error message if they submit an invalid email address" do
      visit("/account/password/new")
      fill_in("user[email]", with: "thisisn'tanemail")
      click_button("Send email")
      expect(page).to have_selector("#error-summary-title")
      expect(page).to have_selector("#user-email-field-error")
      expect(page).to have_title("Error")
    end

    it "is redirected to check your email page after submitting an email on the reset password page" do
      visit("/account/password/new")
      fill_in("user[email]", with: user.email)
      click_button("Send email")
      expect(page).to have_content("Check your email")
    end

    it "is shown their email on the password reset confirmation page" do
      visit("/account/password/new")
      fill_in("user[email]", with: user.email)
      click_button("Send email")
      expect(page).to have_content(user.email)
    end

    it "is shown the reset password confirmation page even if their email doesn't exist in the system" do
      visit("/account/password/new")
      fill_in("user[email]", with: "idontexist@example.com")
      click_button("Send email")
      expect(page).to have_current_path("/account/password/reset-confirmation?email=idontexist%40example.com")
    end

    it "is sent a reset password email via Notify" do
      expect(notify_client).to receive(:send_email).with(
        {
          email_address: user.email,
          template_id: reset_password_template_id,
          personalisation: {
            name: user.name,
            email: user.email,
            organisation: user.organisation.name,
            link: "http://localhost:3000/account/password/edit?reset_password_token=#{reset_password_token}",
          },
        },
      )
      visit("/account/password/new")
      fill_in("user[email]", with: user.email)
      click_button("Send email")
    end
  end

  context "when the user is not logged in" do
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
      expect(page).to have_current_path("/logs")
    end

    it "tries to access account page, redirects to log in page" do
      visit("/users/#{user.id}")
      expect(page).to have_content("Sign in to your account to submit CORE data")
    end
  end

  context "when the user is trying to log in with incorrect credentials" do
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

  context "when signed in as a data provider" do
    context "when viewing your account" do
      before do
        visit("/logs")
        fill_in("user[email]", with: user.email)
        fill_in("user[password]", with: "pAssword1")
        click_button("Sign in")
      end

      it "does not have change links for dpo and key contact" do
        visit("/account")
        expect(page).not_to have_selector('[data-qa="change-are-you-a-data-protection-officer"]')
        expect(page).not_to have_selector('[data-qa="change-are-you-a-key-contact"]')
      end

      it "does not have dpo and key contact as editable fields" do
        visit("/account/edit")
        expect(page).not_to have_field("user[is_dpo]")
        expect(page).not_to have_field("user[is_key_contact]")
      end
    end
  end

  context "when signed in as a data coordinator" do
    let!(:user) { FactoryBot.create(:user, :data_coordinator, last_sign_in_at: Time.zone.now) }

    context "when viewing users" do
      before do
        visit("/logs")
        fill_in("user[email]", with: user.email)
        fill_in("user[password]", with: "pAssword1")
        click_button("Sign in")
        click_link("Users")
      end

      it "highlights the users navigation tab" do
        expect(page).to have_css('[aria-current="page"]', text: "Users")
        expect(page).not_to have_css('[aria-current="page"]', text: "About your organisation")
        expect(page).not_to have_css('[aria-current="page"]', text: "Logs")
      end
    end

    context "when viewing your organisation details" do
      before do
        visit("/logs")
        fill_in("user[email]", with: user.email)
        fill_in("user[password]", with: "pAssword1")
        click_button("Sign in")
        click_link("About your organisation")
      end

      it "highlights the users navigation tab" do
        expect(page).to have_css('[aria-current="page"]', text: "About your organisation")
        expect(page).not_to have_css('[aria-current="page"]', text: "Users")
        expect(page).not_to have_css('[aria-current="page"]', text: "Logs")
      end
    end

    context "when viewing your account" do
      before do
        visit("/logs")
        fill_in("user[email]", with: user.email)
        fill_in("user[password]", with: "pAssword1")
        click_button("Sign in")
      end

      it "shows 'Your account' link in navigation if logged in and redirect to correct page" do
        visit("/logs")
        expect(page).to have_link("Your account")
        click_link("Your account")
        expect(page).to have_current_path("/account")
      end

      it "does not highlight the users navigation tab" do
        visit("/account")
        expect(page).not_to have_css('[aria-current="page"]', text: "Users")
      end

      it "can navigate to change your password page from main account page" do
        visit("/account")
        find('[data-qa="change-password"]').click
        expect(page).to have_content("Change your password")
        fill_in("user[password]", with: "Password123!")
        fill_in("user[password_confirmation]", with: "Password123!")
        click_button("Update")
        expect(page).to have_current_path("/account")
      end

      it "allow user to change name" do
        visit("/account")
        find('[data-qa="change-name"]').click
        expect(page).to have_content("Change your personal details")
        fill_in("user[name]", with: "Test New")
        click_button("Save changes")
        expect(page).to have_current_path("/account")
        expect(page).to have_content("Test New")
      end

      it "has dpo and key contact as editable fields" do
        visit("/account")
        expect(page).to have_selector('[data-qa="change-are-you-a-data-protection-officer"]')
        expect(page).to have_selector('[data-qa="change-are-you-a-key-contact"]')
      end
    end

    context "when adding a new user" do
      before do
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

      it "sets name, email, role, is_dpo and is_key_contact fields" do
        visit("users/new")
        fill_in("user[name]", with: "New User")
        fill_in("user[email]", with: "newuser@example.com")
        choose("user-role-data-provider-field")
        choose("user-is-dpo-true-field")
        choose("user-is-key-contact-true-field")
        click_button("Continue")
        expect(User.find_by(
                 name: "New User",
                 email: "newuser@example.com",
                 role: "data_provider",
                 is_dpo: true,
                 is_key_contact: true,
               )).to be_a(User)
      end

      it "defaults to is_dpo false" do
        visit("users/new")
        expect(page).to have_field("user[is_dpo]", with: false)
      end
    end

    context "when editing someone elses account details" do
      let!(:user) { FactoryBot.create(:user, :data_coordinator, last_sign_in_at: Time.zone.now) }
      let!(:other_user) { FactoryBot.create(:user, name: "Other name", is_dpo: true, organisation: user.organisation) }

      before do
        visit("/logs")
        fill_in("user[email]", with: user.email)
        fill_in("user[password]", with: "pAssword1")
        click_button("Sign in")
      end

      it "allows updating other users details" do
        visit("/organisations/#{user.organisation.id}")
        click_link("Users")
        click_link(other_user.name)
        expect(page).to have_title("Other name’s account")
        first(:link, "Change").click
        expect(page).to have_field("user[is_dpo]", with: true)
        choose("user-is-dpo-field")
        choose("user-is-key-contact-true-field")
        fill_in("user[name]", with: "Updated new name")
        click_button("Save changes")
        expect(page).to have_title("Updated new name’s account")
        expect(User.find_by(
                 name: "Updated new name",
                 role: "data_provider",
                 is_dpo: false,
                 is_key_contact: true,
               )).to be_a(User)
      end
    end
  end

  context "when the user is a customer support person" do
    let(:support_user) { FactoryBot.create(:user, :support, last_sign_in_at: Time.zone.now) }
    let(:devise_notify_mailer) { DeviseNotifyMailer.new }
    let(:notify_client) { instance_double(Notifications::Client) }
    let(:mfa_template_id) { User::MFA_TEMPLATE_ID }
    let(:otp) { "999111" }

    before do
      allow(DeviseNotifyMailer).to receive(:new).and_return(devise_notify_mailer)
      allow(devise_notify_mailer).to receive(:notify_client).and_return(notify_client)
      allow(notify_client).to receive(:send_email).and_return(true)
      visit("/logs")
      fill_in("user[email]", with: support_user.email)
      fill_in("user[password]", with: "pAssword1")
    end

    context "when they are logging in" do
      before do
        allow(SecureRandom).to receive(:random_number).and_return(otp)
      end

      it "shows the 2FA code screen" do
        click_button("Sign in")
        expect(page).to have_content("We’ve sent you an email with a security code.")
        expect(page).to have_field("user[code]")
      end

      it "sends a 2FA code by email" do
        expect(notify_client).to receive(:send_email).with(
          {
            email_address: support_user.email,
            template_id: mfa_template_id,
            personalisation: { otp: },
          },
        )
        click_button("Sign in")
      end
    end

    context "with a valid 2FA code" do
      before do
        allow(SecureRandom).to receive(:random_number).and_return(otp)
      end

      it "authenticates successfully" do
        click_button("Sign in")
        fill_in("code", with: otp)
        click_button("Submit")
        expect(page).to have_content("Logs")
        expect(page).to have_content(I18n.t("devise.two_factor_authentication.success"))
      end

      context "but it is more than 15 minutes old" do
        it "does not authenticate successfully" do
          click_button("Sign in")
          support_user.update!(direct_otp_sent_at: 16.minutes.ago)
          fill_in("code", with: otp)
          click_button("Submit")
          expect(page).to have_content("Check your email")
          expect(page).to have_http_status(:unprocessable_entity)
          expect(page).to have_title("Error")
          expect(page).to have_selector("#error-summary-title")
        end
      end
    end

    context "with an invalid 2FA code" do
      it "does not authenticate successfully" do
        click_button("Sign in")
        fill_in("code", with: otp)
        click_button("Submit")
        expect(page).to have_content("Check your email")
        expect(page).to have_http_status(:unprocessable_entity)
        expect(page).to have_title("Error")
        expect(page).to have_selector("#error-summary-title")
      end
    end

    context "when the 2FA code needs to be resent" do
      before do
        click_button("Sign in")
      end

      it "displays the resend view" do
        click_link("Not received an email?")
        expect(page).to have_button("Resend security code")
      end

      it "send a new OTP code and redirects back to the 2FA view" do
        click_link("Not received an email?")
        expect { click_button("Resend security code") }.to(change { support_user.reload.direct_otp })
        expect(page).to have_current_path("/account/two-factor-authentication")
      end
    end

    context "when signing in and out again" do
      before do
        allow(SecureRandom).to receive(:random_number).and_return(otp)
      end

      it "requires the 2FA code on each login" do
        click_button("Sign in")
        fill_in("code", with: otp)
        click_button("Submit")
        click_link("Sign out")
        visit("/logs")
        fill_in("user[email]", with: support_user.email)
        fill_in("user[password]", with: "pAssword1")
        click_button("Sign in")
        expect(page).to have_content("Check your email")
      end
    end

    context "when they have forgotten their password" do
      let(:reset_password_token) { "MCDH5y6Km-U7CFPgAMVS" }

      before do
        allow(Devise.token_generator).to receive(:generate).and_return(reset_password_token)
        allow(DeviseNotifyMailer).to receive(:new).and_return(devise_notify_mailer)
        allow(devise_notify_mailer).to receive(:notify_client).and_return(notify_client)
        allow(notify_client).to receive(:send_email).and_return(true)
      end

      it "is redirected to the reset password page when they click the reset password link" do
        visit("/account/sign-in")
        click_link("reset your password")
        expect(page).to have_current_path("/account/password/new")
      end

      it "is shown an error message if they submit without entering an email address" do
        visit("/account/password/new")
        click_button("Send email")
        expect(page).to have_selector("#error-summary-title")
        expect(page).to have_selector("#user-email-field-error")
        expect(page).to have_title("Error")
      end

      it "is redirected to login page after reset email is sent" do
        visit("/account/password/new")
        fill_in("user[email]", with: support_user.email)
        click_button("Send email")
        expect(page).to have_content("Check your email")
      end

      it "is sent a reset password email via Notify" do
        expect(notify_client).to receive(:send_email).with(
          {
            email_address: support_user.email,
            template_id: support_user.reset_password_notify_template,
            personalisation: {
              name: support_user.name,
              email: support_user.email,
              organisation: support_user.organisation.name,
              link: "http://localhost:3000/account/password/edit?reset_password_token=#{reset_password_token}",
            },
          },
        )
        visit("/account/password/new")
        fill_in("user[email]", with: support_user.email)
        click_button("Send email")
      end
    end

    context "when viewing logs" do
      context "when filtering by organisation and then switching back to all organisations", js: true do
        let!(:organisation) { FactoryBot.create(:organisation, name: "Filtered Org") }

        before do
          allow(SecureRandom).to receive(:random_number).and_return(otp)
          click_button("Sign in")
          fill_in("code", with: otp)
          click_button("Submit")
        end

        it "clears the previously selected organisation value" do
          visit("/logs")
          choose("organisation-select-specific-org-field", allow_label_click: true)
          expect(page).to have_field("organisation-field", with: "")
          find("#organisation-field").click.native.send_keys("F", "i", "l", "t", :down, :enter)
          click_button("Apply filters")
          expect(page).to have_current_path("/logs?%5Byears%5D%5B%5D=&%5Bstatus%5D%5B%5D=&user=all&organisation_select=specific_org&organisation=#{organisation.id}")
          choose("organisation-select-all-field", allow_label_click: true)
          click_button("Apply filters")
          expect(page).to have_current_path("/logs?%5Byears%5D%5B%5D=&%5Bstatus%5D%5B%5D=&user=all&organisation_select=all")
        end
      end
    end
    context "when the user is logged in as a support user" do
      let!(:support_user) { FactoryBot.create(:user, :support) }
      let!(:test_org_1) { FactoryBot.create(:organisation, name: "Test1") }
      let!(:test_org_2) { FactoryBot.create(:organisation, name: "Test2") }
      let!(:test_org_3) { FactoryBot.create(:organisation, name: "Test3") }
      let!(:test_org_4) { FactoryBot.create(:organisation, name: "Test4") }
      let!(:test_org_5) { FactoryBot.create(:organisation, name: "Test5") }
      let!(:case_log) { FactoryBot.create(:case_log, owning_organisation_id: test_org_3.id, managing_organisation_id: test_org_3.id) }

      before do
        FactoryBot.create_list(:organisation, 50)
        allow(SecureRandom).to receive(:random_number).and_return(otp)
        visit("/logs")
        fill_in("user[email]", with: support_user.email)
        fill_in("user[password]", with: "pAssword1")
        click_button("Sign in")
        fill_in("code", with: otp)
        click_button("Submit")
      end

      it "they should see organisations instead of your organisations in the navigation bar" do
        visit("/organisations")
        expect(page).to have_selector("h1", text: "Organisations")
      end

      it "they should see all organisations listed in the organisations page, with pagination" do
        visit("/organisations")
        expect(page).to have_css("#all-organisations-table")
        expect(page).to have_css(".app-pagination__link")
      end

      context "when the support user is on the organisations list page" do
        it "they can click on an organisation to see their logs page", js: true do
          visit("/organisations")
          click_link("Test3")
          expect(page).to have_selector("a", text: "#{case_log.id}")
          visit("/organisations")
          click_link("Test5")
          expect(page).not_to have_selector("a", text: "#{case_log.id}")
        end
      end
    end
  end
end
