require "rails_helper"

RSpec.describe OrganisationsController, type: :request do
  let(:organisation) { user.organisation }
  let(:unauthorised_organisation) { FactoryBot.create(:organisation) }
  let(:headers) { { "Accept" => "text/html" } }
  let(:page) { Capybara::Node::Simple.new(response.body) }

  describe "#show" do
    let(:user) { FactoryBot.create(:user, :data_coordinator) }

    context "organisation that the user belongs to" do
      before do
        sign_in user
        get "/organisations/#{organisation.id}", headers: headers, params: {}
      end

      it "redirects to details" do
        expect(response).to have_http_status(:redirect)
      end
    end

    context "organisation that are not in scope for the user, i.e. that they do not belong to" do
      before do
        sign_in user
        get "/organisations/#{unauthorised_organisation.id}", headers: headers, params: {}
      end

      it "returns unauthorised from org route" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  context "As a data coordinator user" do
    let(:user) { FactoryBot.create(:user, :data_coordinator) }

    context "details tab" do
      context "organisation that the user belongs to" do
        before do
          sign_in user
          get "/organisations/#{organisation.id}/details", headers: headers, params: {}
        end

        it "shows the tab navigation" do
          expected_html = "<nav class=\"app-tab-navigation\""
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
      end

      context "organisation that are not in scope for the user, i.e. that they do not belong to" do
        before do
          sign_in user
          get "/organisations/#{unauthorised_organisation.id}/details", headers: headers, params: {}
        end

        it "returns unauthorised from org details route" do
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context "users tab" do
      context "organisation that the user belongs to" do
        before do
          sign_in user
          get "/organisations/#{organisation.id}/users", headers: headers, params: {}
        end

        it "shows the tab navigation" do
          expected_html = "<nav class=\"app-tab-navigation\""
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
      end

      context "organisation that are not in scope for the user, i.e. that they do not belong to" do
        before do
          sign_in user
          get "/organisations/#{unauthorised_organisation.id}/users", headers: headers, params: {}
        end

        it "returns unauthorised from users page" do
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end

  context "As a data provider user" do
    let(:user) { FactoryBot.create(:user) }

    context "details tab" do
      context "organisation that the user belongs to" do
        before do
          sign_in user
          get "/organisations/#{organisation.id}/details", headers: headers, params: {}
        end

        it "shows the tab navigation" do
          expected_html = "<nav class=\"app-tab-navigation\""
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
      end

      context "organisation that are not in scope for the user, i.e. that they do not belong to" do
        before do
          sign_in user
          get "/organisations/#{unauthorised_organisation.id}/details", headers: headers, params: {}
        end

        it "returns unauthorised" do
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context "users tab" do
      before do
        sign_in user
        get "/organisations/#{organisation.id}/users", headers: headers, params: {}
      end

      it "should return unauthorised 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
