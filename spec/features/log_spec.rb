require "rails_helper"

RSpec.describe "Log Features" do
  context "when searching for specific logs" do
    context "when I am signed in and there are logs in the database" do
      let(:user) { FactoryBot.create(:user, last_sign_in_at: Time.zone.now) }
      let!(:log_to_search) { FactoryBot.create(:case_log, owning_organisation: user.organisation) }
      let!(:same_organisation_log) { FactoryBot.create(:case_log, owning_organisation: user.organisation) }
      let!(:another_organisation_log) { FactoryBot.create(:case_log) }

      before do
        visit("/logs")
        fill_in("user[email]", with: user.email)
        fill_in("user[password]", with: user.password)
        click_button("Sign in")
      end

      it "displays the logs belonging to the same organisation" do
        expect(page).to have_link(log_to_search.id.to_s)
        expect(page).to have_link(same_organisation_log.id.to_s)
        expect(page).not_to have_link(another_organisation_log.id.to_s)
      end

      context "when I search for a specific log" do
        it "there is a search bar with a message and search button for logs" do
          expect(page).to have_field("search")
          expect(page).to have_content("Search by log ID, tenant code, property reference or postcode")
          expect(page).to have_button("Search")
        end

        context "when I fill in search information and press the search button" do
          before do
            fill_in("search", with: log_to_search.id)
            click_button("Search")
          end

          it "displays log matching the log ID" do
            expect(page).to have_link(log_to_search.id.to_s)
            expect(page).not_to have_link(same_organisation_log.id.to_s)
            expect(page).not_to have_link(another_organisation_log.id.to_s)
          end

          context "when I want to clear results" do
            it "there is link to clear the search results" do
              expect(page).to have_link("Clear search")
            end

            it "displays the logs belonging to the same organisation after I clear the search results" do
              click_link("Clear search")
              expect(page).to have_link(log_to_search.id.to_s)
              expect(page).to have_link(same_organisation_log.id.to_s)
              expect(page).not_to have_link(another_organisation_log.id.to_s)
            end
          end
        end
      end
    end
  end

  context "when the signed is user is a Support user" do
    let(:support_user) { FactoryBot.create(:user, :support, last_sign_in_at: Time.zone.now) }
    let(:devise_notify_mailer) { DeviseNotifyMailer.new }
    let(:notify_client) { instance_double(Notifications::Client) }
    let(:mfa_template_id) { User::MFA_TEMPLATE_ID }
    let(:otp) { "999111" }

    before do
      allow(DeviseNotifyMailer).to receive(:new).and_return(devise_notify_mailer)
      allow(devise_notify_mailer).to receive(:notify_client).and_return(notify_client)
      allow(notify_client).to receive(:send_email).and_return(true)
      allow(SecureRandom).to receive(:random_number).and_return(otp)
      visit("/account/sign-in")
      fill_in("user[email]", with: support_user.email)
      fill_in("user[password]", with: support_user.password)
      click_button("Sign in")
      fill_in("code", with: otp)
      click_button("Submit")
    end

    context "when completing the setup log section" do
      it "includes the organisation and created by questions" do
        visit("/logs")
        click_button("Create a new lettings log")
        click_link("Set up this lettings log")
        select(support_user.organisation.name, from: "case-log-owning-organisation-id-field")
        click_button("Save and continue")
        select(support_user.name, from: "case-log-created-by-id-field")
        click_button("Save and continue")
        log_id = page.current_path.scan(/\d/).join
        visit("logs/#{log_id}/setup/check-answers")
        expect(page).to have_content("Owning organisation #{support_user.organisation.name}")
        expect(page).to have_content("User #{support_user.name}")
        expect(page).to have_content("You have answered 2 of 8 questions")
      end
    end
  end

  context "when the signed is user is not a Support user" do
    let(:support_user) { FactoryBot.create(:user) }
    let(:devise_notify_mailer) { DeviseNotifyMailer.new }
    let(:notify_client) { instance_double(Notifications::Client) }

    before do
      allow(DeviseNotifyMailer).to receive(:new).and_return(devise_notify_mailer)
      allow(devise_notify_mailer).to receive(:notify_client).and_return(notify_client)
      allow(notify_client).to receive(:send_email).and_return(true)
      visit("/account/sign-in")
      fill_in("user[email]", with: support_user.email)
      fill_in("user[password]", with: support_user.password)
      click_button("Sign in")
    end

    context "when completing the setup log section" do
      it "does not include the organisation and created by questions" do
        visit("/logs")
        click_button("Create a new lettings log")
        click_link("Set up this lettings log")
        log_id = page.current_path.scan(/\d/).join
        expect(page).to have_current_path("/logs/#{log_id}/needs-type")
        visit("logs/#{log_id}/setup/check-answers")
        expect(page).not_to have_content("Owning organisation #{support_user.organisation.name}")
        expect(page).not_to have_content("User #{support_user.name}")
        expect(page).to have_content("You have answered 0 of 6 questions")
      end
    end
  end
end
