require "rails_helper"

RSpec.describe "User Features" do
  let!(:user) { create(:user, last_sign_in_at: Time.zone.now) }
  let(:reset_password_template_id) { User::RESET_PASSWORD_TEMPLATE_ID }
  let(:notify_client) { instance_double(Notifications::Client) }
  let(:reset_password_token) { "MCDH5y6Km-U7CFPgAMVS" }
  let(:devise_notify_mailer) { DeviseNotifyMailer.new }
  let(:storage_service) { instance_double(Storage::S3Service, get_file_metadata: nil) }

  before do
    allow(DeviseNotifyMailer).to receive(:new).and_return(devise_notify_mailer)
    allow(devise_notify_mailer).to receive(:notify_client).and_return(notify_client)
    allow(notify_client).to receive(:send_email).and_return(true)
    allow(Devise.token_generator).to receive(:generate).and_return(reset_password_token)
    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(storage_service).to receive(:configuration).and_return(OpenStruct.new(bucket_name: "core-test-collection-resources"))
  end

  context "when the user navigates to lettings logs" do
    it "is required to log in" do
      visit("/lettings-logs")
      expect(page).to have_current_path("/account/sign-in")
      expect(page).to have_content("Sign in to your account to submit CORE data")
    end

    it "does not see the default devise error message" do
      visit("/lettings-logs")
      expect(page).to have_no_content("You need to sign in or sign up before continuing.")
    end

    it "is redirected to lettings logs after signing in" do
      visit("/lettings-logs")
      fill_in("user[email]", with: user.email)
      fill_in("user[password]", with: "pAssword1")
      click_button("Sign in")
      expect(page).to have_current_path("/lettings-logs")
    end

    it "can log out again", js: true do
      visit("/lettings-logs")
      fill_in("user[email]", with: user.email)
      fill_in("user[password]", with: "pAssword1")
      click_button("Sign in")
      click_link("Sign out")
      expect(page).to have_current_path("/")
      expect(page).to have_content("Start now")
    end

    it "can log out again with js disabled" do
      visit("/lettings-logs")
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
      visit("/lettings-logs")
      click_link("reset your password")
      expect(page).to have_current_path("/account/password/new")
    end

    it "is shown an error message if they submit without entering an email address" do
      visit("/account/password/new")
      click_button("Send email")
      expect(page).to have_selector(".govuk-error-summary__title")
      expect(page).to have_selector("#user-email-field-error")
      expect(page).to have_title("Error")
    end

    it "is shown an error message if they submit an invalid email address" do
      visit("/account/password/new")
      fill_in("user[email]", with: "thisisn'tanemail")
      click_button("Send email")
      expect(page).to have_selector(".govuk-error-summary__title")
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
      visit("/lettings-logs")
      expect(page).to have_no_link("Your account")
    end

    it "Can navigate and sign in page with sign in button" do
      visit(root_path)
      expect(page).to have_link("Sign in")
      click_link("Sign in")
      fill_in("user[email]", with: user.email)
      fill_in("user[password]", with: "pAssword1")
      click_button("Sign in")
      expect(page).to have_current_path("/")
      expect(page).to have_content("Welcome back")
    end

    it "tries to access account page, redirects to log in page" do
      visit("/users/#{user.id}")
      expect(page).to have_content("Sign in to your account to submit CORE data")
    end

    it "does not show 'Sign in' link when the service has moved" do
      allow(FeatureToggle).to receive(:service_moved?).and_return(true)
      visit("/lettings-logs")
      expect(page).not_to have_link("Sign in")
    end

    it "does not show 'Sign in' link when the service is unavailable" do
      allow(FeatureToggle).to receive(:service_unavailable?).and_return(true)
      visit("/lettings-logs")
      expect(page).not_to have_link("Sign in")
    end

    it "does not show 'Sign in' link when both the service_moved? and service_unavailable? feature toggles are on" do
      allow(FeatureToggle).to receive(:service_moved?).and_return(true)
      allow(FeatureToggle).to receive(:service_unavailable?).and_return(true)
      visit("/lettings-logs")
      expect(page).not_to have_link("Sign in")
    end
  end

  context "when the user is trying to log in with incorrect credentials" do
    it "shows a gov uk error summary and no flash message" do
      visit("/lettings-logs")
      fill_in("user[email]", with: user.email)
      fill_in("user[password]", with: "nonsense")
      click_button("Sign in")
      expect(page).to have_selector(".govuk-error-summary__title")
      expect(page).to have_no_css(".govuk-notification-banner.govuk-notification-banner--success")
      expect(page).to have_title("Error")
    end

    it "show specific field error messages if a field was omitted" do
      visit("/lettings-logs")
      click_button("Sign in")
      expect(page).to have_selector(".govuk-error-summary__title")
      expect(page).to have_selector("#user-email-field-error")
      expect(page).to have_selector("#user-password-field-error")
      expect(page).to have_title("Error")
    end

    it "show specific field error messages if an invalid email address is entered" do
      visit("/lettings-logs")
      fill_in("user[email]", with: "thisisn'tanemail")
      click_button("Sign in")
      expect(page).to have_selector(".govuk-error-summary__title")
      expect(page).to have_selector("#user-email-field-error")
      expect(page).to have_content(/Enter an email address in the correct format, like name@example.com/)
      expect(page).to have_title("Error")
    end
  end

  context "when the user is trying to log in with deactivated user" do
    before do
      user.update!(active: false)
    end

    it "shows a gov uk error summary and no flash message" do
      visit("/lettings-logs")
      fill_in("user[email]", with: user.email)
      fill_in("user[password]", with: "pAssword1")
      click_button("Sign in")
      expect(page).to have_selector(".govuk-error-summary__title")
      expect(page).to have_no_css(".govuk-notification-banner.govuk-notification-banner--success")
      expect(page).to have_title("Error")
    end
  end

  context "when signed in as a data provider" do
    context "when viewing your account" do
      before do
        visit("/lettings-logs")
        fill_in("user[email]", with: user.email)
        fill_in("user[password]", with: "pAssword1")
        click_button("Sign in")
      end

      it "does not have change links for dpo and key contact" do
        visit("/account")
        expect(page).not_to have_selector('[data-qa="change-if-data-protection-officer"]')
        expect(page).not_to have_selector('[data-qa="change-if-key-contact"]')
      end

      it "does not have dpo and key contact as editable fields" do
        visit("/account/edit")
        expect(page).not_to have_field("user[is_dpo]")
        expect(page).not_to have_field("user[is_key_contact]")
      end
    end
  end

  context "when signed in as a data coordinator" do
    let!(:user) { create(:user, :data_coordinator, last_sign_in_at: Time.zone.now) }

    context "when viewing users" do
      before do
        visit("/lettings-logs")
        fill_in("user[email]", with: user.email)
        fill_in("user[password]", with: "pAssword1")
        click_button("Sign in")
        click_link("Users")
      end

      it "highlights the users navigation tab" do
        expect(page).to have_css('[aria-current="page"]', text: "Users")
        expect(page).not_to have_css('[aria-current="page"]', text: "Your organisation")
        expect(page).not_to have_css('[aria-current="page"]', text: "Logs")
      end

      context "when filtering users" do
        context "when no filters are selected" do
          it "displays the filters component with no clear button" do
            expect(page).to have_content("No filters applied")
            expect(page).not_to have_link("Clear", href: /clear-filters\?filter_type=users/)
          end
        end

        context "when I have selected filters" do
          before do
            check("Active")
            check("Deactivated")
            click_button("Apply filters")
          end

          it "displays the filters component with a correct count and clear button" do
            expect(page).to have_content("2 filters applied")
            expect(page).to have_link("Clear", href: /clear-filters\?filter_type=users/)
          end

          context "when clearing the filters" do
            before do
              click_link("Clear")
            end

            it "clears the filters and displays the filter component as before" do
              expect(page).to have_content("No filters applied")
              expect(page).not_to have_link("Clear", href: "/clear-filters?filter_type=users")
            end
          end
        end
      end
    end

    context "when viewing your organisation details" do
      before do
        visit("/lettings-logs")
        fill_in("user[email]", with: user.email)
        fill_in("user[password]", with: "pAssword1")
        click_button("Sign in")
        click_link("Your organisation")
      end

      it "highlights the users navigation tab" do
        expect(page).to have_css('[aria-current="page"]', text: "Your organisation")
        expect(page).not_to have_css('[aria-current="page"]', text: "Users")
        expect(page).not_to have_css('[aria-current="page"]', text: "Logs")
      end
    end

    context "when viewing your account" do
      before do
        visit("/lettings-logs")
        fill_in("user[email]", with: user.email)
        fill_in("user[password]", with: "pAssword1")
        click_button("Sign in")
      end

      it "shows 'Your account' link in navigation if logged in and redirect to correct page" do
        visit("/lettings-logs")
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
        expect(page).to have_selector('[data-qa="change-data-protection-officer"]')
        expect(page).to have_selector('[data-qa="change-key-contact"]')
      end

      it "does not show 'Your account' or 'Sign out' links when the service has moved" do
        allow(FeatureToggle).to receive(:service_moved?).and_return(true)
        visit("/lettings-logs")
        expect(page).not_to have_link("Your account")
        expect(page).not_to have_link("Sign out")
      end

      it "does not show 'Your account' or 'Sign out' links when the service is unavailable" do
        allow(FeatureToggle).to receive(:service_unavailable?).and_return(true)
        visit("/lettings-logs")
        expect(page).not_to have_link("Your account")
        expect(page).not_to have_link("Sign out")
      end

      it "does not show 'Your account' or 'Sign out' links when both the service_moved? and service_unavailable? feature toggles are on" do
        allow(FeatureToggle).to receive(:service_moved?).and_return(true)
        allow(FeatureToggle).to receive(:service_unavailable?).and_return(true)
        visit("/lettings-logs")
        expect(page).not_to have_link("Your account")
        expect(page).not_to have_link("Sign out")
      end
    end

    context "when adding a new user" do
      before do
        visit("/lettings-logs")
        fill_in("user[email]", with: user.email)
        fill_in("user[password]", with: "pAssword1")
        click_button("Sign in")
      end

      it "validates an email has been provided" do
        visit("users/new")
        fill_in("user[name]", with: "New User")
        click_button("Continue")
        expect(page).to have_selector(".govuk-error-summary__title")
        expect(page).to have_selector("#user-email-field-error")
        expect(page).to have_content(/Enter an email address/)
        expect(page).to have_title("Error")
      end

      it "validates email" do
        visit("users/new")
        fill_in("user[name]", with: "New User")
        fill_in("user[email]", with: "thisis'tanemail")
        click_button("Continue")
        expect(page).to have_selector(".govuk-error-summary__title")
        expect(page).to have_selector("#user-email-field-error")
        expect(page).to have_content(/Enter an email address in the correct format, like name@example.com/)
        expect(page).to have_title("Error")
      end

      it "sets name, email, role, is_dpo and is_key_contact fields" do
        visit("users/new")
        fill_in("user[name]", with: "New User")
        fill_in("user[email]", with: "newuser@example.com")
        fill_in("user[phone]", with: "12345678910")
        choose("user-role-data-provider-field")
        click_button("Continue")
        expect(User.find_by(
                 name: "New User",
                 email: "newuser@example.com",
                 role: "data_provider",
                 phone: "12345678910",
                 is_dpo: false,
                 is_key_contact: false,
               )).to be_a(User)
      end
    end

    context "when editing someone elses account details" do
      let!(:user) { create(:user, :data_coordinator, last_sign_in_at: Time.zone.now) }
      let!(:other_user) { create(:user, name: "Other name", is_dpo: false, organisation: user.organisation, last_sign_in_at: Time.zone.now) }

      before do
        visit("/lettings-logs")
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
        fill_in("user[name]", with: "Updated new name")
        click_button("Save changes")
        expect(page).to have_title("Updated new name’s account")
        expect(User.find_by(
                 name: "Updated new name",
                 role: "data_provider",
               )).to be_a(User)
      end

      context "when updating other user DPO and key contact information" do
        it "allows updating users dpo details" do
          visit("/organisations/#{user.organisation.id}")
          click_link("Users")
          click_link(other_user.name)
          find("a[href='#{user_edit_dpo_path(other_user)}']").click
          choose("Yes")
          click_button("Save changes")
          expect(User.find_by(name: "Other name", role: "data_provider", is_dpo: true)).to be_a(User)
        end

        it "allows updating users key contact details" do
          visit("/organisations/#{user.organisation.id}")
          click_link("Users")
          click_link(other_user.name)
          find("a[href='#{user_edit_key_contact_path(other_user)}']").click
          choose("Yes")
          click_button("Save changes")
          expect(User.find_by(name: "Other name", role: "data_provider", is_key_contact: true)).to be_a(User)
        end
      end
    end

    context "when deactivating a user" do
      let!(:user) { create(:user, :data_coordinator, last_sign_in_at: Time.zone.now) }
      let!(:other_user) { create(:user, name: "Other name", organisation: user.organisation) }

      before do
        visit("/lettings-logs")
        fill_in("user[email]", with: user.email)
        fill_in("user[password]", with: "pAssword1")
        click_button("Sign in")
        visit("/users/#{other_user.id}")
        click_link("Deactivate user")
      end

      it "allows to cancel user deactivation" do
        click_link("No – I’ve changed my mind")
        expect(page).to have_current_path("/users/#{other_user.id}")
        assert_selector ".govuk-tag", text: /Deactivated/, count: 0
        expect(page).to have_no_css(".govuk-notification-banner.govuk-notification-banner--success")
      end

      it "allows to deactivate the user" do
        click_button("I’m sure – deactivate this user")
        expect(page).to have_current_path("/users/#{other_user.id}")
        assert_selector ".govuk-tag", text: /Deactivated/, count: 1
        expect(page).to have_css(".govuk-notification-banner.govuk-notification-banner--success")
      end
    end

    context "when reactivating a user" do
      let!(:user) { create(:user, :data_coordinator, last_sign_in_at: Time.zone.now) }
      let!(:other_user) { create(:user, name: "Other name", active: false, organisation: user.organisation, last_sign_in_at: Time.zone.now) }
      let(:personalisation) do
        {
          name: other_user.name,
          email: other_user.email,
          organisation: other_user.organisation.name,
          link: include("/account/confirmation?confirmation_token=#{other_user.confirmation_token}"),
        }
      end

      before do
        other_user.update!(confirmation_token: "abc")
        visit("/lettings-logs")
        fill_in("user[email]", with: user.email)
        fill_in("user[password]", with: "pAssword1")
        click_button("Sign in")
        visit("/users/#{other_user.id}")
        click_link("Reactivate user")
      end

      it "allows to cancel user reactivation" do
        click_link("No – I’ve changed my mind")
        expect(page).to have_current_path("/users/#{other_user.id}")
        assert_selector ".govuk-tag", text: /Deactivated/, count: 1
        expect(page).to have_no_css(".govuk-notification-banner.govuk-notification-banner--success")
      end

      it "allows to reactivate the user" do
        expect(notify_client).to receive(:send_email).with(email_address: other_user.email, template_id: User::USER_REACTIVATED_TEMPLATE_ID, personalisation:).once
        click_button("I’m sure – reactivate this user")
        expect(page).to have_current_path("/users/#{other_user.id}")
        assert_selector ".govuk-tag", text: /Deactivated/, count: 0
        expect(page).to have_css(".govuk-notification-banner.govuk-notification-banner--success")
      end
    end
  end

  context "when signed in as support" do
    let!(:user) { create(:user, :support) }
    let!(:other_user) { create(:user, name: "new user", organisation: user.organisation, email: "new_user@example.com", confirmation_token: "abc") }

    context "when reinviting a user before initial confirmation email has been sent" do
      let(:personalisation) do
        {
          name: "new user",
          email: "new_user@example.com",
          organisation: other_user.organisation.name,
          link: include("/account/confirmation?confirmation_token=#{other_user.confirmation_token}"),
        }
      end

      before do
        other_user.update!(initial_confirmation_sent: false, last_sign_in_at: nil)
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in(user)
        other_user.legacy_users.destroy_all
        visit(user_path(other_user))
      end

      it "sends initial confirmable template email when the resend invite link is clicked" do
        expect(notify_client).to receive(:send_email).with(email_address: "new_user@example.com", template_id: User::CONFIRMABLE_TEMPLATE_ID, personalisation:).once
        click_button("Resend invite link")
      end
    end

    context "when reinviting a user after initial confirmation email has been sent" do
      let(:personalisation) do
        {
          name: "new user",
          email: "new_user@example.com",
          organisation: other_user.organisation.name,
          link: include("/account/confirmation?confirmation_token=#{other_user.confirmation_token}"),
        }
      end

      before do
        other_user.update!(initial_confirmation_sent: true, confirmed_at: nil)
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in(user)
        other_user.legacy_users.destroy_all
        visit(user_path(other_user))
      end

      it "sends and email when the resend invite link is clicked" do
        expect(notify_client).to receive(:send_email).with(email_address: "new_user@example.com", template_id: User::RECONFIRMABLE_TEMPLATE_ID, personalisation:).once
        click_button("Resend invite link")
      end
    end

    context "when reinviting a legacy user" do
      let(:personalisation) do
        {
          name: "new user",
          email: "new_user@example.com",
          organisation: other_user.organisation.name,
          link: include("/account/confirmation?confirmation_token=#{other_user.confirmation_token}"),
        }
      end

      before do
        other_user.update!(initial_confirmation_sent: true, last_sign_in_at: nil, old_user_id: "old-user-id")
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in(user)
        visit(user_path(other_user))
      end

      it "sends initial confirmable template email when user is legacy" do
        expect(notify_client).to receive(:send_email).with(email_address: "new_user@example.com", template_id: User::CONFIRMABLE_TEMPLATE_ID, personalisation:).once
        click_button("Resend invite link")
      end
    end
  end

  context "when the user is a customer support person" do
    let(:support_user) { create(:user, :support, last_sign_in_at: Time.zone.now) }
    let(:devise_notify_mailer) { DeviseNotifyMailer.new }
    let(:notify_client) { instance_double(Notifications::Client) }
    let(:mfa_template_id) { User::MFA_TEMPLATE_ID }
    let(:otp) { "999111" }

    before do
      allow(DeviseNotifyMailer).to receive(:new).and_return(devise_notify_mailer)
      allow(devise_notify_mailer).to receive(:notify_client).and_return(notify_client)
      allow(notify_client).to receive(:send_email).and_return(true)
      visit("/lettings-logs")
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

      it "the admin user is redirected to the organisations list page on successful sign in" do
        visit("/account/sign-in")
        fill_in("user[email]", with: support_user.email)
        fill_in("user[password]", with: support_user.password)
        click_button("Sign in")
        fill_in("code", with: otp)
        click_button("Submit")
        expect(page).to have_current_path("/organisations")
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
        expect(page).to have_content("Lettings logs")
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
          expect(page).to have_selector(".govuk-error-summary__title")
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
        expect(page).to have_selector(".govuk-error-summary__title")
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
        visit("/lettings-logs")
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
        expect(page).to have_selector(".govuk-error-summary__title")
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
      context "when filtering by owning organisation and then switching back to all organisations", js: true do
        let!(:organisation) { create(:organisation) }
        let(:parent_organisation) { create(:organisation, name: "Filtered Org") }

        before do
          create(:organisation_relationship, child_organisation: organisation, parent_organisation:)
          allow(SecureRandom).to receive(:random_number).and_return(otp)
          click_button("Sign in")
          fill_in("code", with: otp)
          click_button("Submit")
        end

        it "clears the previously selected organisation value" do
          visit("/lettings-logs")
          choose("owning-organisation-select-specific-org-field", allow_label_click: true)
          expect(page).to have_field("owning-organisation-field", with: "")
          find("#owning-organisation-field").click.native.send_keys("F", "i", "l", "t")
          select(parent_organisation.name, from: "owning-organisation-field-select", visible: false)
          click_button("Apply filters")
          expect(page).to have_current_path("/lettings-logs?%5Byears%5D%5B%5D=&%5Bstatus%5D%5B%5D=&%5Bneedstypes%5D%5B%5D=&assigned_to=all&user_text_search=&owning_organisation_select=specific_org&owning_organisation_text_search=&owning_organisation=#{parent_organisation.id}&managing_organisation_select=all&managing_organisation_text_search=")
          choose("owning-organisation-select-all-field", allow_label_click: true)
          click_button("Apply filters")
          expect(page).to have_current_path("/lettings-logs?%5Byears%5D%5B%5D=&%5Bstatus%5D%5B%5D=&%5Bneedstypes%5D%5B%5D=&assigned_to=all&user_text_search=&owning_organisation_select=all&owning_organisation_text_search=&managing_organisation_select=all&managing_organisation_text_search=")
        end
      end
    end
  end
end
