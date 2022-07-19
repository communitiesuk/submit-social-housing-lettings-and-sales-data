require "rails_helper"
require_relative "form/helpers"

RSpec.describe "User Features" do
  include Helpers
  let(:organisation) { user.organisation }
  let(:org_id) { organisation.id }
  let(:org_name) { organisation.name }
  let(:set_password_template_id) { User::CONFIRMABLE_TEMPLATE_ID }
  let(:notify_client) { instance_double(Notifications::Client) }
  let(:confirmation_token) { "MCDH5y6Km-U7CFPgAMVS" }
  let(:devise_notify_mailer) { DeviseNotifyMailer.new }

  before do
    allow(DeviseNotifyMailer).to receive(:new).and_return(devise_notify_mailer)
    allow(devise_notify_mailer).to receive(:notify_client).and_return(notify_client)
    allow(Devise).to receive(:friendly_token).and_return(confirmation_token)
    allow(notify_client).to receive(:send_email).and_return(true)
    visit("/organisations")
    fill_in("user[email]", with: user.email)
    fill_in("user[password]", with: user.password)
    click_button("Sign in")
  end

  context "when user is a data coordinator" do
    let!(:user) { FactoryBot.create(:user, :data_coordinator) }

    context "when viewing organisation page" do
      it "defaults to organisation details" do
        visit("/logs")
        click_link("About your organisation")
        expect(page).to have_content(user.organisation.name)
      end

      it "can switch tabs" do
        visit("/organisations/#{org_id}")
        click_link("Users")
        expect(page).to have_current_path("/organisations/#{org_id}/users")
        click_link("About your organisation")
        expect(page).to have_current_path("/organisations/#{org_id}/details")
      end
    end

    context "when users are part of organisation" do
      it "users can be added" do
        visit("/organisations/#{org_id}")
        click_link("Users")
        click_link("Invite user")
        expect(page).to have_current_path("/users/new")
        expect(page).to have_content("Invite somebody to submit CORE data")
        fill_in("user[name]", with: "New User")
        fill_in("user[email]", with: "new_user@example.com")
        choose("user-role-data-provider-field")
        expect(notify_client).to receive(:send_email).with(
          {
            email_address: "new_user@example.com",
            template_id: set_password_template_id,
            personalisation: {
              name: "New User",
              email: "new_user@example.com",
              organisation: organisation.name,
              link: "http://localhost:3000/account/confirmation?confirmation_token=#{confirmation_token}",
            },
          },
        )
        click_button("Continue")
        expect(page).to have_current_path("/organisations/#{org_id}/users")
        expect(User.last.role).to eq("data_provider")
      end
    end
  end

  context "when the user is a data provider" do
    let(:user) { FactoryBot.create(:user) }

    context "when viewing organisation page" do
      it "can see the details tab and users tab" do
        visit("/logs")
        click_link("About your organisation")
        expect(page).to have_current_path("/organisations/#{org_id}/details")
        expect(page).to have_link("Logs")
        expect(page).to have_link("Users")
        expect(page).to have_link("About your organisation")
      end
    end
  end

  context "when user is support user" do
    let(:otp) { "999111" }
    let(:user) { FactoryBot.create(:user, :support) }

    before do
      allow(SecureRandom).to receive(:random_number).and_return(otp)
      click_link("Sign out")
      visit("/organisations")
      fill_in("user[email]", with: user.email)
      fill_in("user[password]", with: user.password)
      click_button("Sign in")
      fill_in("code", with: otp)
      click_button("Submit")
    end

    context "when viewing logs for specific organisation" do
      let(:first_log) { organisation.case_logs.first }
      let!(:log_to_search) { FactoryBot.create(:case_log, owning_organisation: user.organisation, managing_organisation_id: organisation.id) }
      let!(:other_logs) { FactoryBot.create_list(:case_log, 4, owning_organisation_id: organisation.id, managing_organisation_id: organisation.id) }
      let(:number_of_case_logs) { CaseLog.count }

      before do
        visit("/organisations/#{org_id}/logs")
      end

      it "shows a create button for that organisation" do
        expect(page).to have_button("Create a new lettings log for this organisation")
      end

      context "when creating a log for that organisation" do
        it "pre-fills the value for owning organisation for that log" do
          click_button("Create a new lettings log for this organisation")
          click_link("Set up this lettings log")
          expect(page).to have_content(org_name)
        end
      end

      context "when searching for specific logs" do
        it "displays the logs belonging to the same organisation" do
          expect(page).to have_content(log_to_search.id)
          other_logs.each do |log|
            expect(page).to have_content(log.id)
          end
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
              other_logs.each do |log|
                expect(page).not_to have_link(log.id.to_s)
              end
            end

            context "when I want to clear results" do
              it "there is link to clear the search results" do
                expect(page).to have_link("Clear search")
              end

              it "displays the logs belonging to the same organisation after I clear the search result after I clear the search resultss" do
                click_link("Clear search")
                expect(page).to have_link(log_to_search.id.to_s)
              end
            end
          end
        end
      end

      it "can filter case logs" do
        expect(page).to have_content("#{number_of_case_logs} total logs")
        organisation.case_logs.map(&:id).each do |case_log_id|
          expect(page).to have_link case_log_id.to_s, href: "/logs/#{case_log_id}"
        end
        check("years-2021-field")
        click_button("Apply filters")
        expect(page).to have_current_path("/organisations/#{org_id}/logs?years[]=&years[]=2021&status[]=&user=all")
        expect(page).not_to have_link first_log.id.to_s, href: "/logs/#{first_log.id}"
      end
    end

    context "when I search for users belonging to a specific organisation" do
      context "when I am signed in and there are users in the database" do
        let!(:user_list) { FactoryBot.create_list(:user, 4, organisation: user.organisation) }

        context "when I visit the organisation page" do
          before do
            visit("/organisations/#{org_id}")
          end

          it "has link to the organisations users tab" do
            expect(page).to have_link("Users", href: "/organisations/#{org_id}/users")
          end

          context "when I click users link in submenu" do
            before do
              click_link("Users", href: "/organisations/#{org_id}/users")
            end

            it "shows list of users belonging to the same organisation" do
              user_list.each do |user|
                expect(page).to have_content(user.email)
              end
            end

            it "shows submenu for selected organisation" do
              expect(page).to have_css('[aria-current="page"]', text: "Users")
              expect(page).to have_current_path("/organisations/#{org_id}/users")
              expect(page).to have_link("Logs")
              expect(page).to have_link("About this organisation")
            end

            context "when I click on Invite user and there are multiple organisations in the database" do
              before do
                FactoryBot.create_list(:organisation, 5)
                click_link(text: "Invite user")
              end

              it "has only specific organisation name in the dropdown" do
                expect(page).to have_select("user-organisation-id-field", options: [org_name])
              end
            end
          end
        end
      end
    end
  end

  describe "delete cascade" do
    context "when the organisation is deleted" do
      let!(:organisation) { FactoryBot.create(:organisation) }
      let!(:user) { FactoryBot.create(:user, :support, last_sign_in_at: Time.zone.now, organisation:) }
      let!(:scheme_to_delete) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:log_to_delete) { FactoryBot.create(:case_log, owning_organisation: user.organisation) }

      context "when organisation is deleted" do
        it "child relationships ie logs, schemes and users are deleted too - application" do
          organisation.destroy!
          expect { organisation.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect { CaseLog.find(log_to_delete.id) }.to raise_error(ActiveRecord::RecordNotFound)
          expect { Scheme.find(scheme_to_delete.id) }.to raise_error(ActiveRecord::RecordNotFound)
          expect { User.find(user.id) }.to raise_error(ActiveRecord::RecordNotFound)
        end

        context "when the organisation is deleted" do
          let!(:organisation) { FactoryBot.create(:organisation) }
          let!(:user) { FactoryBot.create(:user, :support, last_sign_in_at: Time.zone.now, organisation:) }
          let!(:scheme_to_delete) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
          let!(:log_to_delete) { FactoryBot.create(:case_log, owning_organisation: user.organisation) }

          it "child relationships ie logs, schemes and users are deleted too - database" do
            ActiveRecord::Base.connection.exec_query("DELETE FROM organisations WHERE id = #{organisation.id};")
            expect { CaseLog.find(log_to_delete.id) }.to raise_error(ActiveRecord::RecordNotFound)
            expect { Scheme.find(scheme_to_delete.id) }.to raise_error(ActiveRecord::RecordNotFound)
            expect { User.find(user.id) }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end
end
