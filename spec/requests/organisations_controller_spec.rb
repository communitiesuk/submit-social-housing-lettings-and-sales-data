require "rails_helper"

RSpec.describe OrganisationsController, type: :request do
  let(:organisation) { user.organisation }
  let!(:unauthorised_organisation) { FactoryBot.create(:organisation) }
  let(:headers) { { "Accept" => "text/html" } }
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:user) { FactoryBot.create(:user, :data_coordinator) }
  let(:new_value) { "Test Name 35" }
  let(:params) { { id: organisation.id, organisation: { name: new_value } } }

  context "when user is not signed in" do
    describe "#show" do
      it "does not let you see organisation details from org route" do
        get "/organisations/#{organisation.id}", headers: headers, params: {}
        expect(response).to redirect_to("/account/sign-in")
      end

      it "does not let you see organisation details from details route" do
        get "/organisations/#{organisation.id}/details", headers: headers, params: {}
        expect(response).to redirect_to("/account/sign-in")
      end

      it "does not let you see organisation users" do
        get "/organisations/#{organisation.id}/users", headers: headers, params: {}
        expect(response).to redirect_to("/account/sign-in")
      end
    end
  end

  context "when user is signed in" do
    describe "#show" do
      context "with an organisation that the user belongs to" do
        before do
          sign_in user
          get "/organisations/#{organisation.id}", headers:, params: {}
        end

        it "redirects to details" do
          expect(response).to have_http_status(:redirect)
        end
      end

      context "with an organisation that are not in scope for the user, i.e. that they do not belong to" do
        before do
          sign_in user
          get "/organisations/#{unauthorised_organisation.id}", headers:, params: {}
        end

        it "returns not found 404 from org route" do
          expect(response).to have_http_status(:not_found)
        end

        it "shows the 404 view" do
          expect(page).to have_content("Page not found")
        end
      end
    end

    context "with a data coordinator user" do
      before do
        sign_in user
      end

      context "when we access the details tab" do
        context "with an organisation that the user belongs to" do
          before do
            get "/organisations/#{organisation.id}/details", headers:, params: {}
          end

          it "shows the tab navigation" do
            expected_html = "<nav class=\"app-primary-navigation\""
            expect(response.body).to include(expected_html)
          end

          it "shows a summary list of org details" do
            expected_html = "<dl class=\"govuk-summary-list\""
            expect(response.body).to include(expected_html)
            expect(response.body).to include(organisation.name)
          end

          it "has a hidden header title" do
            expected_html = "<h2 class=\"govuk-visually-hidden\">  Details"
            expect(response.body).to include(expected_html)
          end

          it "has a change details link" do
            expected_html = "data-qa=\"change-name\" href=\"/organisations/#{organisation.id}/edit\""
            expect(response.body).to include(expected_html)
          end
        end

        context "with organisation that are not in scope for the user, i.e. that they do not belong to" do
          before do
            get "/organisations/#{unauthorised_organisation.id}/details", headers:, params: {}
          end

          it "returns not found 404 from org details route" do
            expect(response).to have_http_status(:not_found)
          end
        end
      end

      context "when accessing the users tab" do
        context "with an organisation that the user belongs to" do
          let!(:other_user) { FactoryBot.create(:user, organisation: user.organisation, name: "User 2") }
          let!(:inactive_user) { FactoryBot.create(:user, organisation: user.organisation, active: false, name: "User 3") }
          let!(:other_org_user) { FactoryBot.create(:user, name: "User 4") }

          before do
            get "/organisations/#{organisation.id}/users", headers:, params: {}
          end

          it "shows the tab navigation" do
            expected_html = "<nav class=\"app-primary-navigation\""
            expect(response.body).to include(expected_html)
          end

          it "shows a new user button" do
            expect(page).to have_link("Invite user")
          end

          it "shows a table of users" do
            expected_html = "<table class=\"govuk-table\""
            expect(response.body).to include(expected_html)
            expect(response.body).to include(user.email)
          end

          it "has a hidden header title" do
            expected_html = "<h2 class=\"govuk-visually-hidden\">  Users"
            expect(response.body).to include(expected_html)
          end

          it "shows only active users in the current user's organisation" do
            expect(page).to have_content(user.name)
            expect(page).to have_content(other_user.name)
            expect(page).not_to have_content(inactive_user.name)
            expect(page).not_to have_content(other_org_user.name)
          end

          it "shows the pagination count" do
            expect(page).to have_content("2 total users")
          end
        end

        context "with an organisation that are not in scope for the user, i.e. that they do not belong to" do
          before do
            get "/organisations/#{unauthorised_organisation.id}/users", headers:, params: {}
          end

          it "returns not found 404 from users page" do
            expect(response).to have_http_status(:not_found)
          end
        end
      end

      describe "#edit" do
        context "with an organisation that the user belongs to" do
          before do
            get "/organisations/#{organisation.id}/edit", headers:, params: {}
          end

          it "shows an edit form" do
            expect(response.body).to include("Change #{organisation.name}’s details")
            expect(page).to have_field("organisation-name-field")
            expect(page).to have_field("organisation-phone-field")
          end
        end

        context "with an organisation that the user does not belong to" do
          before do
            get "/organisations/#{unauthorised_organisation.id}/edit", headers:, params: {}
          end

          it "returns a 404 not found" do
            expect(response).to have_http_status(:not_found)
          end

          it "shows the 404 view" do
            expect(page).to have_content("Page not found")
          end
        end
      end

      describe "#update" do
        context "with an organisation that the user belongs to" do
          before do
            patch "/organisations/#{organisation.id}", headers:, params:
          end

          it "updates the org" do
            organisation.reload
            expect(organisation.name).to eq(new_value)
          end

          it "redirects to the organisation details page" do
            expect(response).to redirect_to("/organisations/#{organisation.id}/details")
          end

          it "shows a success banner" do
            follow_redirect!
            expect(page).to have_css(".govuk-notification-banner.govuk-notification-banner--success")
          end

          it "tracks who updated the record" do
            organisation.reload
            whodunnit_actor = organisation.versions.last.actor
            expect(whodunnit_actor).to be_a(User)
            expect(whodunnit_actor.id).to eq(user.id)
          end
        end

        context "with an organisation that the user does not belong to" do
          before do
            patch "/organisations/#{unauthorised_organisation.id}", headers:, params: {}
          end

          it "returns a 404 not found" do
            expect(response).to have_http_status(:not_found)
          end
        end
      end

      context "when viewing logs for other organisation" do
        before do
          get "/organisations/#{unauthorised_organisation.id}/logs", headers:, params: {}
        end

        it "returns not found 404 from org details route" do
          expect(response).to have_http_status(:not_found)
        end

        it "shows the 404 view" do
          expect(page).to have_content("Page not found")
        end
      end

      context "when viewing logs for your organisation" do
        before do
          get "/organisations/#{organisation.id}/logs", headers:, params: {}
        end

        it "redirects to /logs page" do
          expect(response).to redirect_to("/logs")
        end
      end
    end

    context "with a data provider user" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
      end

      context "when accessing the details tab" do
        context "with an organisation that the user belongs to" do
          before do
            get "/organisations/#{organisation.id}/details", headers:, params: {}
          end

          it "shows the tab navigation" do
            expected_html = "<nav class=\"app-primary-navigation\""
            expect(response.body).to include(expected_html)
          end

          it "shows a summary list of org details" do
            expected_html = "<dl class=\"govuk-summary-list\""
            expect(response.body).to include(expected_html)
            expect(response.body).to include(organisation.name)
          end

          it "has a hidden header title" do
            expected_html = "<h2 class=\"govuk-visually-hidden\">  Details"
            expect(response.body).to include(expected_html)
          end

          it "does not have a change details link" do
            expected_html = "data-qa=\"change-name\" href=\"/organisations/#{organisation.id}/edit\""
            expect(response.body).not_to include(expected_html)
          end
        end

        context "with an organisation that is not in scope for the user, i.e. that they do not belong to" do
          before do
            sign_in user
            get "/organisations/#{unauthorised_organisation.id}/details", headers:, params: {}
          end

          it "returns not found 404" do
            expect(response).to have_http_status(:not_found)
          end
        end
      end

      context "when accessing the users tab" do
        before do
          get "/organisations/#{organisation.id}/users", headers:, params: {}
        end

        it "returns 200" do
          expect(response).to have_http_status(:ok)
        end
      end

      describe "#edit" do
        before do
          get "/organisations/#{organisation.id}/edit", headers:, params: {}
        end

        it "redirects to home" do
          expect(response).to have_http_status(:unauthorized)
        end
      end

      describe "#update" do
        before do
          patch "/organisations/#{organisation.id}", headers:, params:
        end

        it "redirects to home" do
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "when viewing logs for other organisation" do
        before do
          get "/organisations/#{unauthorised_organisation.id}/logs", headers:, params: {}
        end

        it "returns not found 404 from org details route" do
          expect(response).to have_http_status(:not_found)
        end

        it "shows the 404 view" do
          expect(page).to have_content("Page not found")
        end
      end

      context "when viewing logs for your organisation" do
        before do
          get "/organisations/#{organisation.id}/logs", headers:, params: {}
        end

        it "redirects to /logs page" do
          expect(response).to redirect_to("/logs")
        end
      end
    end

    context "with a support user" do
      let(:user) { FactoryBot.create(:user, :support) }

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        get "/organisations"
      end

      it "shows all organisations" do
        total_number_of_orgs = Organisation.all.count
        expect(page).to have_link organisation.name, href: "organisations/#{organisation.id}/logs"
        expect(page).to have_link unauthorised_organisation.name, href: "organisations/#{unauthorised_organisation.id}/logs"
        expect(page).to have_content("#{total_number_of_orgs} total organisations")
      end

      context "when viewing a specific organisation" do
        let(:number_of_org1_case_logs) { 2 }
        let(:number_of_org2_case_logs) { 4 }

        before do
          FactoryBot.create_list(:case_log, number_of_org1_case_logs, owning_organisation_id: organisation.id, managing_organisation_id: organisation.id)
          FactoryBot.create_list(:case_log, number_of_org2_case_logs, owning_organisation_id: unauthorised_organisation.id, managing_organisation_id: unauthorised_organisation.id)

          get "/organisations/#{organisation.id}/logs", headers:, params: {}
        end

        it "displays the name of the organisation in the header" do
          expect(CGI.unescape_html(response.body)).to match("<span class=\"govuk-caption-l\">#{organisation.name}</span>")
        end

        it "only shows logs for that organisation" do
          expect(page).to have_content("#{number_of_org1_case_logs} total logs")
          organisation.case_logs.map(&:id).each do |case_log_id|
            expect(page).to have_link case_log_id.to_s, href: "/logs/#{case_log_id}"
          end

          unauthorised_organisation.case_logs.map(&:id).each do |case_log_id|
            expect(page).not_to have_link case_log_id.to_s, href: "/logs/#{case_log_id}"
          end
        end

        it "has filters" do
          expect(page).to have_content("Filters")
          expect(page).to have_content("Collection year")
        end

        it "does not have specific organisation filter" do
          expect(page).not_to have_content("Specific organisation")
        end

        it "has a sub-navigation with correct tabs" do
          expect(page).to have_css(".app-sub-navigation")
          expect(page).to have_content("About this organisation")
        end
      end

      context "when viewing a specific organisation details" do
        before do
          get "/organisations/#{organisation.id}/details", headers:, params: {}
        end

        it "displays the name of the organisation" do
          expect(page).to have_content(organisation.name)
        end

        it "has a sub-navigation with correct tabs" do
          expect(page).to have_css(".app-sub-navigation")
          expect(page).to have_content("About this organisation")
        end

        it "allows to edit the organisation details" do
          expect(page).to have_link("Change", count: 3)
        end
      end
    end

    context "when there are more than 20 organisations" do
      let(:support_user) { FactoryBot.create(:user, :support) }

      let(:total_organisations_count) { Organisation.all.count }

      before do
        FactoryBot.create_list(:organisation, 25)
        allow(support_user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in support_user
        get "/organisations"
      end

      context "when on the first page" do
        it "has pagination links" do
          expect(page).to have_content("Previous")
          expect(page).not_to have_link("Previous")
          expect(page).to have_content("Next")
          expect(page).to have_link("Next")
        end

        it "shows which organisations are being shown on the current page" do
          expect(CGI.unescape_html(response.body)).to match("Showing <b>1</b> to <b>20</b> of <b>#{total_organisations_count}</b> organisations")
        end

        it "has pagination in the title" do
          expect(page).to have_title("Organisations (page 1 of 2)")
        end
      end

      context "when on the second page" do
        before do
          get "/organisations?page=2", headers:, params: {}
        end

        it "shows the total organisations count" do
          expect(CGI.unescape_html(response.body)).to match("<strong>#{total_organisations_count}</strong><span style=\"font-weight: normal\"> total organisations</span>")
        end

        it "has pagination links" do
          expect(page).to have_content("Previous")
          expect(page).to have_link("Previous")
          expect(page).to have_content("Next")
          expect(page).not_to have_link("Next")
        end

        it "shows which logs are being shown on the current page" do
          expect(CGI.unescape_html(response.body)).to match("Showing <b>21</b> to <b>#{total_organisations_count}</b> of <b>#{total_organisations_count}</b> organisations")
        end

        it "has pagination in the title" do
          expect(page).to have_title("Organisations (page 2 of 2)")
        end
      end
    end
  end
end
