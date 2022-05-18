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
      context "when we access the details tab" do
        context "with an organisation that the user belongs to" do
          before do
            sign_in user
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
            sign_in user
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
            sign_in user
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
            sign_in user
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
            sign_in user
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
            sign_in user
            get "/organisations/#{unauthorised_organisation.id}/edit", headers:, params: {}
          end

          it "returns a 404 not found" do
            expect(response).to have_http_status(:not_found)
          end
        end
      end

      describe "#update" do
        context "with an organisation that the user belongs to" do
          before do
            sign_in user
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
            sign_in user
            patch "/organisations/#{unauthorised_organisation.id}", headers:, params: {}
          end

          it "returns a 404 not found" do
            expect(response).to have_http_status(:not_found)
          end
        end
      end
    end

    context "with a data provider user" do
      let(:user) { FactoryBot.create(:user) }

      context "when accessing the details tab" do
        context "with an organisation that the user belongs to" do
          before do
            sign_in user
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
          sign_in user
          get "/organisations/#{organisation.id}/users", headers:, params: {}
        end

        it "returns 200" do
          expect(response).to have_http_status(:ok)
        end
      end

      describe "#edit" do
        before do
          sign_in user
          get "/organisations/#{organisation.id}/edit", headers:, params: {}
        end

        it "redirects to home" do
          expect(response).to have_http_status(:unauthorized)
        end
      end

      describe "#update" do
        before do
          sign_in user
          patch "/organisations/#{organisation.id}", headers:, params:
        end

        it "redirects to home" do
          expect(response).to have_http_status(:unauthorized)
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
        expect(page).to have_content("2 total organisations")
        expect(page).to have_link organisation.name, href: "organisations/#{organisation.id}/logs"
        expect(page).to have_link unauthorised_organisation.name, href: "organisations/#{unauthorised_organisation.id}/logs"
      end
    end
  end
end
