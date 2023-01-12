require "rails_helper"

RSpec.describe "Lettings Log Features" do
  context "when searching for specific logs" do
    context "when I am signed in and there are logs in the database" do
      let(:user) { create(:user, last_sign_in_at: Time.zone.now) }
      let!(:log_to_search) { create(:lettings_log, owning_organisation: user.organisation) }
      let!(:same_organisation_log) { create(:lettings_log, owning_organisation: user.organisation) }
      let!(:another_organisation_log) { create(:lettings_log) }

      before do
        visit("/lettings-logs")
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
    let(:support_user) { create(:user, :support, last_sign_in_at: Time.zone.now) }
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

    context "when completing the setup lettings log section", :aggregate_failure do
      it "includes the organisation and created by questions" do
        visit("/lettings-logs")
        click_button("Create a new lettings log")
        click_link("Set up this lettings log")
        select(support_user.organisation.name, from: "lettings-log-owning-organisation-id-field")
        click_button("Save and continue")
        select(support_user.name, from: "lettings-log-created-by-id-field")
        click_button("Save and continue")
        log_id = page.current_path.scan(/\d/).join
        visit("lettings-logs/#{log_id}/setup/check-answers")
        expect(page).to have_content("Stock owner #{support_user.organisation.name}")
        expect(page).to have_content("You have answered 2 of 8 questions")
      end
    end
  end

  context "when the signed is user is not a Support user" do
    let!(:user) { create(:user, :data_coordinator, name: "User name", organisation: create(:organisation, name: "User org")) }
    let(:devise_notify_mailer) { DeviseNotifyMailer.new }
    let(:notify_client) { instance_double(Notifications::Client) }

    before do
      allow(DeviseNotifyMailer).to receive(:new).and_return(devise_notify_mailer)
      allow(devise_notify_mailer).to receive(:notify_client).and_return(notify_client)
      allow(notify_client).to receive(:send_email).and_return(true)
      visit("/account/sign-in")
      fill_in("user[email]", with: user.email)
      fill_in("user[password]", with: user.password)
      click_button("Sign in")
    end

    context "when completing the setup log section" do
      context "and there is at most 1 potential stock owner" do
        it "does not include the organisation and created by questions" do
          visit("/lettings-logs")
          click_button("Create a new lettings log")
          click_link("Set up this lettings log")
          log_id = page.current_path.scan(/\d/).join
          expect(page).to have_current_path("/lettings-logs/#{log_id}/needs-type")
          visit("lettings-logs/#{log_id}/setup/check-answers")
          expect(page).not_to have_content("Stock owner User org")
          expect(page).not_to have_content("Log owner User name")
        end
      end

      context "and there are 2 or more potential stock owners" do
        let!(:owning_org1) { create(:organisation, name: "Owning org 1") }
        let!(:org_rel1) { create(:organisation_relationship, child_organisation: user.organisation, parent_organisation: owning_org1) }

        it "does include the stock owner question" do
          visit("/lettings-logs")
          click_button("Create a new lettings log")
          click_link("Set up this lettings log")
          log_id = page.current_path.scan(/\d/).join
          expect(page).to have_current_path("/lettings-logs/#{log_id}/stock-owner")
          visit("lettings-logs/#{log_id}/setup/check-answers")
          expect(page).to have_content("Stock owner User org")
        end

        context "and there are 3 or more potential stock owners" do
          let!(:owning_org2) { create(:organisation, name: "Owning org 2") }
          let!(:org_rel2) { create(:organisation_relationship, child_organisation: user.organisation, parent_organisation: owning_org2) }

          context "and the organisation relationship for the selected stock owner is deleted" do
            it "doesn't change the CYA page text to be 'You didn't answer this question'" do
              visit("/lettings-logs")
              click_button("Create a new lettings log")
              click_link("Set up this lettings log")
              log_id = page.current_path.scan(/\d/).join
              expect(page).to have_current_path("/lettings-logs/#{log_id}/stock-owner")
              select(owning_org1.name, from: "lettings-log-owning-organisation-id-field")
              click_button("Save and continue")
              visit("lettings-logs/#{log_id}/setup/check-answers")
              expect(page).to have_content("Stock owner Owning org 1")
              org_rel1.destroy!
              visit("lettings-logs/#{log_id}/setup/check-answers")
              expect(page).to have_content("Stock owner Owning org 1")
              expect(user.organisation.stock_owners).to eq([org_rel2.parent_organisation])
            end
          end
        end
      end
    end

    context "when returning to the list of logs via breadcrumbs link" do
      before do
        visit("/lettings-logs")
        click_button("Create a new lettings log")
        click_link("Logs")
      end

      it "navigates you to the lettings logs page" do
        expect(page).to have_current_path("/lettings-logs")
      end
    end
  end
end
