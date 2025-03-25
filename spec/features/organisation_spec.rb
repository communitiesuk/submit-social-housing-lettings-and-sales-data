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
  let(:storage_service) { instance_double(Storage::S3Service, get_file_metadata: nil) }

  before do
    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(storage_service).to receive(:configuration).and_return(OpenStruct.new(bucket_name: "core-test-collection-resources"))
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
        visit("/lettings-logs")
        click_link("Your organisation")
        expect(page).to have_content(user.organisation.name)
      end

      it "can switch tabs" do
        visit("/organisations/#{org_id}")
        click_link("Users")
        expect(page).to have_current_path("/organisations/#{org_id}/users")
        click_link("Your organisation")
        expect(page).to have_current_path("/organisations/#{org_id}/details")
      end

      it "does not allow coordinator users to edit their organisation's group and profit status" do
        expect(page).to have_no_link("Change part of group")
        expect(page).to have_no_link("Select profit status")
      end

      context "and the organisation does not hold housing stock" do
        before do
          organisation.update(holds_own_stock: false)
        end

        it "does not show schemes in the navigation bar" do
          visit("/lettings-logs")
          expect(page).not_to have_link("Schemes", href: "/schemes")
        end
      end

      context "and the organisation holds housing stock" do
        before do
          organisation.update(holds_own_stock: true)
        end

        it "shows schemes in the navigation bar" do
          visit("/lettings-logs")
          expect(page).to have_link("Schemes", href: "/schemes")
        end
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
        fill_in("user[phone]", with: "+88877677777")
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
        visit("/lettings-logs")
        click_link("Your organisation")
        expect(page).to have_current_path("/organisations/#{org_id}/details")
        expect(page).to have_link("Lettings logs")
        expect(page).to have_link("Users")
        expect(page).to have_link("Your organisation")
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

    context "when viewing lettings logs for specific organisation" do
      let(:first_log) { organisation.lettings_logs.first }
      let!(:log_to_search) { FactoryBot.create(:lettings_log, assigned_to: user) }
      let!(:other_general_needs_logs) { FactoryBot.create_list(:lettings_log, 4, assigned_to: user, needstype: 1) }
      let!(:other_supported_housing_logs) { FactoryBot.create_list(:lettings_log, 4, assigned_to: user, needstype: 2) }
      let(:number_of_lettings_logs) { LettingsLog.count }
      let(:previous_year) { FormHandler.instance.previous_lettings_form.start_date.year }

      before do
        allow(FormHandler.instance).to receive(:in_crossover_period?).and_return(true)
        visit("/organisations/#{org_id}/lettings-logs")
      end

      it "shows a create button for that organisation" do
        expect(page).to have_button("Create a new lettings log")
      end

      it "shows a upload lettings logs in bulk link" do
        expect(page).to have_link("Upload lettings logs in bulk")
      end

      context "when creating a log for that organisation" do
        it "pre-fills the value for owning organisation for that log" do
          click_button("Create a new lettings log")
          click_link("Set up this lettings log")
          expect(page).to have_content(org_name)
        end
      end

      context "when searching for specific logs" do
        it "displays the logs belonging to the same organisation" do
          expect(page).to have_content(log_to_search.id)
          (other_general_needs_logs + other_supported_housing_logs).each do |log|
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
              (other_general_needs_logs + other_supported_housing_logs).each do |log|
                expect(page).not_to have_link(log.id.to_s)
              end
            end

            context "when I want to clear results" do
              it "there is link to clear the search results" do
                expect(page).to have_link("Clear search")
              end

              it "displays the logs belonging to the same organisation after I clear the search result after I clear the search results" do
                click_link("Clear search")
                expect(page).to have_link(log_to_search.id.to_s)
              end
            end
          end
        end
      end

      it "has correct page details" do
        expect(page).to have_content("#{number_of_lettings_logs} total logs")
        organisation.lettings_logs.map(&:id).each do |lettings_log_id|
          expect(page).to have_link lettings_log_id.to_s, href: "/lettings-logs/#{lettings_log_id}"
        end
      end

      it "can filter lettings logs by year" do
        check("years-#{previous_year}-field")
        click_button("Apply filters")
        expect(page).to have_current_path("/organisations/#{org_id}/lettings-logs?%5Byears%5D[]=&years[]=#{previous_year}&%5Bstatus%5D[]=&%5Bneedstypes%5D[]=&assigned_to=all&user_text_search=&user=&owning_organisation_select=all&owning_organisation_text_search=&owning_organisation=&managing_organisation_select=all&managing_organisation_text_search=&managing_organisation=")
        expect(page).not_to have_link first_log.id.to_s, href: "/lettings-logs/#{first_log.id}"
      end

      it "can filter lettings logs by needstype" do
        check("needstypes-1-field")
        click_button("Apply filters")
        expect(page).to have_current_path("/organisations/#{org_id}/lettings-logs?%5Byears%5D[]=&%5Bstatus%5D[]=&%5Bneedstypes%5D[]=&needstypes[]=1&assigned_to=all&user_text_search=&user=&owning_organisation_select=all&owning_organisation_text_search=&owning_organisation=&managing_organisation_select=all&managing_organisation_text_search=&managing_organisation=")
        other_general_needs_logs.each do |general_needs_log|
          expect(page).to have_link general_needs_log.id.to_s, href: "/lettings-logs/#{general_needs_log.id}"
        end
        other_supported_housing_logs.each do |supported_housing_log|
          expect(page).not_to have_link supported_housing_log.id.to_s, href: "/lettings-logs/#{supported_housing_log.id}"
        end
      end
    end

    context "when viewing sales logs for specific organisation" do
      let(:first_log) { organisation.sales_logs.first }
      let(:number_of_sales_logs) { SalesLog.count }
      let(:previous_year) { FormHandler.instance.previous_sales_form.start_date.year }

      before do
        allow(FormHandler.instance).to receive(:in_crossover_period?).and_return(true)
        FactoryBot.create_list(:sales_log, 4, owning_organisation_id: organisation.id)
        visit("/organisations/#{org_id}/sales-logs")
      end

      it "shows a create button for that organisation" do
        expect(page).to have_button("Create a new sales log")
      end

      it "shows a upload sales logs in bulk link" do
        expect(page).to have_link("Upload sales logs in bulk")
      end

      context "when creating a log for that organisation" do
        it "pre-fills the value for owning organisation for that log" do
          click_button("Create a new sales log")
          click_link("Set up this sales log")
          expect(page).to have_content(org_name)
        end
      end

      it "can filter sales logs" do
        expect(page).to have_content("#{number_of_sales_logs} total logs")
        organisation.sales_logs.map(&:id).each do |sales_log_id|
          expect(page).to have_link sales_log_id.to_s, href: "/sales-logs/#{sales_log_id}"
        end
        check("years-#{previous_year}-field")
        click_button("Apply filters")
        expect(page).to have_current_path("/organisations/#{org_id}/sales-logs?%5Byears%5D[]=&years[]=#{previous_year}&%5Bstatus%5D[]=&assigned_to=all&user_text_search=&user=&owning_organisation_select=all&owning_organisation_text_search=&owning_organisation=&managing_organisation_select=all&managing_organisation_text_search=&managing_organisation=")
        expect(page).not_to have_link first_log.id.to_s, href: "/sales-logs/#{first_log.id}"
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
              expect(page).to have_link("Lettings logs")
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

      describe "delete cascade" do
        context "when the organisation is deleted" do
          let!(:organisation) { FactoryBot.create(:organisation) }
          let!(:user) { FactoryBot.create(:user, :support, last_sign_in_at: Time.zone.now, organisation:) }
          let!(:scheme_to_delete) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
          let!(:log_to_delete) { FactoryBot.create(:lettings_log, owning_organisation: user.organisation) }

          context "when organisation is deleted" do
            it "child relationships ie logs, schemes and users are deleted too - application" do
              organisation.destroy!
              expect { organisation.reload }.to raise_error(ActiveRecord::RecordNotFound)
              expect { LettingsLog.find(log_to_delete.id) }.to raise_error(ActiveRecord::RecordNotFound)
              expect { Scheme.find(scheme_to_delete.id) }.to raise_error(ActiveRecord::RecordNotFound)
              expect { User.find(user.id) }.to raise_error(ActiveRecord::RecordNotFound)
            end

            context "when the organisation is deleted" do
              let!(:organisation) { FactoryBot.create(:organisation) }
              let!(:user) { FactoryBot.create(:user, :support, last_sign_in_at: Time.zone.now, organisation:) }
              let!(:scheme_to_delete) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
              let!(:log_to_delete) { FactoryBot.create(:lettings_log, :in_progress, needstype: 1, owning_organisation: user.organisation) }

              it "child relationships ie logs, schemes and users are deleted too - database" do
                ActiveRecord::Base.connection.exec_query("DELETE FROM organisations WHERE id = #{organisation.id};")
                expect { LettingsLog.find(log_to_delete.id) }.to raise_error(ActiveRecord::RecordNotFound)
                expect { Scheme.find(scheme_to_delete.id) }.to raise_error(ActiveRecord::RecordNotFound)
                expect { User.find(user.id) }.to raise_error(ActiveRecord::RecordNotFound)
              end
            end
          end
        end
      end
    end

    context "when viewing schemes for specific organisation" do
      before do
        create(:scheme, owning_organisation: organisation)
        visit("/organisations/#{org_id}/schemes")
      end

      it "allows downloading schemes csv for the specific org" do
        click_link("Download schemes (CSV)")
        click_button("Send email")
        expect(page).to have_current_path("/organisations/#{org_id}/schemes/csv-confirmation")
      end
    end

    context "and the organisation does not hold housing stock" do
      before do
        organisation.update!(holds_own_stock: false)
      end

      it "does not show schemes in the primary or secondary navigation bar on the organisations page" do
        visit("/organisations")
        expect(page).not_to have_link("Schemes", href: "/schemes", count: 2)
      end
    end

    context "and is creating a new organisation" do
      before do
        visit("/organisations")
        click_link("Create a new organisation")
      end

      it "displays the new organisation form" do
        expect(page).to have_content("Create a new organisation")
        expect(page).to have_field("organisation[name]", type: "text")
        expect(page).to have_field("organisation[address_line1]", type: "text")
        expect(page).to have_field("organisation[address_line2]", type: "text")
        expect(page).to have_field("organisation[postcode]", type: "text")
        expect(page).to have_field("organisation[phone]")
        expect(page).to have_field("organisation[housing_registration_no]", type: "text")
        expect(page).to have_select("organisation[provider_type]")
        expect(page).to have_field("organisation[holds_own_stock]", type: "radio")
        expect(page).to have_field("organisation[group_member]", type: "radio")
        expect(page).to have_select("organisation[profit_status]")
        expect(page).to have_button("Create organisation")
      end
    end

    context "when viewing a specific organisation's details page" do
      before do
        visit("/organisations/#{org_id}/details")
      end

      it "allows the support user to edit the organisation's group and profit status" do
        expect(page).to have_link("Change part of group")
        expect(page).to have_link("Select profit status")
      end
    end
  end
end
