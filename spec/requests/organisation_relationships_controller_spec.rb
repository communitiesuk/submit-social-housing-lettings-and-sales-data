require "rails_helper"

RSpec.describe OrganisationRelationshipsController, type: :request do
  let(:organisation) { user.organisation }
  let!(:unauthorised_organisation) { FactoryBot.create(:organisation) }
  let(:headers) { { "Accept" => "text/html" } }
  let(:page) { Capybara::Node::Simple.new(response.body) }

  context "when user is signed in" do
    let(:user) { FactoryBot.create(:user, :data_coordinator) }

    context "with a data coordinator user" do
      before do
        sign_in user
      end

      context "when accessing the stock owners tab" do
        context "with an organisation that the user belongs to" do
          let!(:stock_owner) { FactoryBot.create(:organisation) }
          let!(:other_org_stock_owner) { FactoryBot.create(:organisation, name: "Foobar LTD") }
          let!(:other_organisation) { FactoryBot.create(:organisation, name: "Foobar LTD 2") }

          before do
            FactoryBot.create(:organisation_relationship, child_organisation: organisation, parent_organisation: stock_owner)
            FactoryBot.create(:organisation_relationship, child_organisation: other_organisation, parent_organisation: other_org_stock_owner)
            get "/organisations/#{organisation.id}/stock-owners", headers:, params: {}
          end

          it "shows the tab navigation" do
            expected_html = "<nav class=\"app-primary-navigation\""
            expect(response.body).to include(expected_html)
          end

          it "shows an add stock owner button" do
            expect(page).to have_link("Add a stock owner")
          end

          it "shows a table of stock owners" do
            expected_html = "<table class=\"govuk-table\""
            expect(response.body).to include(expected_html)
            expect(response.body).to include(stock_owner.name)
          end

          it "shows only stock owners for the current user's organisation" do
            expect(page).to have_content(stock_owner.name)
            expect(page).not_to have_content(other_org_stock_owner.name)
          end

          it "shows the pagination count" do
            expect(page).to have_content("1 total stock owners")
          end

          context "when adding a stock owner" do
            before do
              get "/organisations/#{organisation.id}/stock-owners/add", headers:, params: {}
            end

            it "has the correct header" do
              expect(response.body).to include("What is the name of your stock owner?")
            end

            it "shows an add button" do
              expect(page).to have_button("Add")
            end
          end
        end

        context "with an organisation that are not in scope for the user, i.e. that they do not belong to" do
          before do
            get "/organisations/#{unauthorised_organisation.id}/stock-owners", headers:, params: {}
          end

          it "returns not found 404 from users page" do
            expect(response).to have_http_status(:not_found)
          end
        end
      end

      context "when accessing the managing agents tab" do
        context "with an organisation that the user belongs to" do
          let!(:managing_agent) { FactoryBot.create(:organisation) }
          let!(:other_org_managing_agent) { FactoryBot.create(:organisation, name: "Foobar LTD") }
          let!(:other_organisation) { FactoryBot.create(:organisation, name: "Foobar LTD") }

          before do
            FactoryBot.create(:organisation_relationship, parent_organisation: organisation, child_organisation: managing_agent)
            FactoryBot.create(:organisation_relationship, parent_organisation: other_organisation, child_organisation: other_org_managing_agent)
            get "/organisations/#{organisation.id}/managing-agents", headers:, params: {}
          end

          it "shows the tab navigation" do
            expected_html = "<nav class=\"app-primary-navigation\""
            expect(response.body).to include(expected_html)
          end

          it "shows an add managing-agent button" do
            expect(page).to have_link("Add a managing agent")
          end

          it "shows a table of managing-agents" do
            expected_html = "<table class=\"govuk-table\""
            expect(response.body).to include(expected_html)
            expect(response.body).to include(managing_agent.name)
          end

          it "shows only managing-agents for the current user's organisation" do
            expect(page).to have_content(managing_agent.name)
            expect(page).not_to have_content(other_org_managing_agent.name)
          end

          it "shows the pagination count" do
            expect(page).to have_content("1 total agents")
          end
        end

        context "when adding a managing agent" do
          before do
            get "/organisations/#{organisation.id}/managing-agents/add", headers:, params: {}
          end

          it "has the correct header" do
            expect(response.body).to include("What is the name of your managing agent?")
          end
        end

        context "with an organisation that are not in scope for the user, i.e. that they do not belong to" do
          before do
            get "/organisations/#{unauthorised_organisation.id}/managing-agents", headers:, params: {}
          end

          it "returns not found 404 from users page" do
            expect(response).to have_http_status(:not_found)
          end
        end
      end

      describe "organisation_relationships#create_stock_owner" do
        let!(:stock_owner) { FactoryBot.create(:organisation) }

        let(:params) do
          {
            "organisation_relationship": {
              "parent_organisation_id": stock_owner.id,
            },
          }
        end

        let(:request) { post "/organisations/#{organisation.id}/stock-owners", headers:, params: }

        it "creates a new organisation relationship" do
          expect { request }.to change(OrganisationRelationship, :count).by(1)
        end

        it "sets the organisation relationship attributes correctly" do
          request
          expect(OrganisationRelationship).to exist(child_organisation_id: organisation.id, parent_organisation_id: stock_owner.id)
        end

        it "redirects to the organisation list" do
          request
          expect(response).to redirect_to("/organisations/#{organisation.id}/stock-owners")
        end
      end

      describe "organisation_relationships#create_managing_agent" do
        let!(:managing_agent) { FactoryBot.create(:organisation) }

        let(:params) do
          {
            "organisation_relationship": {
              "child_organisation_id": managing_agent.id,
            },
          }
        end

        let(:request) { post "/organisations/#{organisation.id}/managing-agents", headers:, params: }

        it "creates a new organisation relationship" do
          expect { request }.to change(OrganisationRelationship, :count).by(1)
        end

        it "sets the organisation relationship attributes correctly" do
          request
          expect(OrganisationRelationship).to exist(parent_organisation_id: organisation.id, child_organisation_id: managing_agent.id)
        end

        it "redirects to the organisation list" do
          request
          expect(response).to redirect_to("/organisations/#{organisation.id}/managing-agents")
        end
      end

      describe "organisation_relationships#delete_stock_owner" do
        let!(:stock_owner) { FactoryBot.create(:organisation) }
        let(:params) do
          {
            "target_organisation_id": stock_owner.id,
          }
        end
        let(:request) { delete "/organisations/#{organisation.id}/stock-owners", headers:, params: }

        before do
          FactoryBot.create(:organisation_relationship, child_organisation: organisation, parent_organisation: stock_owner)
        end

        it "deletes the new organisation relationship" do
          expect { request }.to change(OrganisationRelationship, :count).by(-1)
        end

        it "redirects to the organisation list" do
          request
          expect(response).to redirect_to("/organisations/#{organisation.id}/stock-owners")
        end
      end

      describe "organisation_relationships#delete_managing_agent" do
        let!(:managing_agent) { FactoryBot.create(:organisation) }
        let(:params) do
          {
            "target_organisation_id": managing_agent.id,
          }
        end
        let(:request) { delete "/organisations/#{organisation.id}/managing-agents", headers:, params: }

        before do
          FactoryBot.create(
            :organisation_relationship,
            parent_organisation: organisation,
            child_organisation: managing_agent,
          )
        end

        it "deletes the new organisation relationship" do
          expect { request }.to change(OrganisationRelationship, :count).by(-1)
        end

        it "redirects to the organisation list" do
          request
          expect(response).to redirect_to("/organisations/#{organisation.id}/managing-agents")
        end
      end
    end

    context "with a data provider user" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
      end

      context "when accessing the stock owners tab" do
        context "with an organisation that the user belongs to" do
          let!(:stock_owner) { FactoryBot.create(:organisation) }
          let!(:other_org_stock_owner) { FactoryBot.create(:organisation, name: "Foobar LTD") }
          let!(:other_organisation) { FactoryBot.create(:organisation, name: "Foobar LTD") }

          before do
            FactoryBot.create(:organisation_relationship, child_organisation: organisation, parent_organisation: stock_owner)
            FactoryBot.create(:organisation_relationship, child_organisation: other_organisation, parent_organisation: other_org_stock_owner)
            get "/organisations/#{organisation.id}/stock-owners", headers:, params: {}
          end

          it "shows the tab navigation" do
            expected_html = "<nav class=\"app-primary-navigation\""
            expect(response.body).to include(expected_html)
          end

          it "doesn't show an add stock owner button" do
            expect(page).not_to have_link("Add a stock owner")
          end

          it "shows a table of stock owners" do
            expected_html = "<table class=\"govuk-table\""
            expect(response.body).to include(expected_html)
            expect(response.body).to include(stock_owner.name)
          end

          it "shows only stock owners for the current user's organisation" do
            expect(page).to have_content(stock_owner.name)
            expect(page).not_to have_content(other_org_stock_owner.name)
          end

          it "shows the pagination count" do
            expect(page).to have_content("1 total stock owners")
          end
        end

        context "with an organisation that are not in scope for the user, i.e. that they do not belong to" do
          before do
            get "/organisations/#{unauthorised_organisation.id}/stock-owners", headers:, params: {}
          end

          it "returns not found 404 from users page" do
            expect(response).to have_http_status(:not_found)
          end
        end
      end

      context "when accessing the managing agents tab" do
        context "with an organisation that the user belongs to" do
          let!(:managing_agent) { FactoryBot.create(:organisation) }
          let!(:other_org_managing_agent) { FactoryBot.create(:organisation, name: "Foobar LTD") }
          let!(:other_organisation) { FactoryBot.create(:organisation, name: "Foobar LTD") }

          before do
            FactoryBot.create(:organisation_relationship, parent_organisation: organisation, child_organisation: managing_agent)
            FactoryBot.create(:organisation_relationship, parent_organisation: other_organisation, child_organisation: other_org_managing_agent)
            get "/organisations/#{organisation.id}/managing-agents", headers:, params: {}
          end

          it "shows the tab navigation" do
            expected_html = "<nav class=\"app-primary-navigation\""
            expect(response.body).to include(expected_html)
          end

          it "doesn't show an add managing agent button" do
            expect(page).not_to have_link("Add a managing agent")
          end

          it "shows a table of managing agents" do
            expected_html = "<table class=\"govuk-table\""
            expect(response.body).to include(expected_html)
            expect(response.body).to include(managing_agent.name)
          end

          it "shows only managing agents for the current user's organisation" do
            expect(page).to have_content(managing_agent.name)
            expect(page).not_to have_content(other_org_managing_agent.name)
          end

          it "shows the pagination count" do
            expect(page).to have_content("1 total agents")
          end
        end

        context "when adding a managing agent" do
          before do
            get "/organisations/#{organisation.id}/managing-agents/add", headers:, params: {}
          end

          it "has the correct header" do
            expect(response.body).to include("What is the name of your managing agent?")
          end
        end

        context "with an organisation that are not in scope for the user, i.e. that they do not belong to" do
          before do
            get "/organisations/#{unauthorised_organisation.id}/managing-agents", headers:, params: {}
          end

          it "returns not found 404 from users page" do
            expect(response).to have_http_status(:not_found)
          end
        end
      end
    end

    context "with a support user" do
      let(:user) { FactoryBot.create(:user, :support) }

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
      end

      describe "organisation_relationships#create_stock_owner" do
        let!(:stock_owner) { FactoryBot.create(:organisation) }

        let(:params) do
          {
            "organisation_relationship": {
              "parent_organisation_id": stock_owner.id,
            },
          }
        end

        let(:request) { post "/organisations/#{organisation.id}/stock-owners", headers:, params: }

        it "creates a new organisation relationship" do
          expect { request }.to change(OrganisationRelationship, :count).by(1)
        end

        it "sets the organisation relationship attributes correctly" do
          request
          expect(OrganisationRelationship).to exist(child_organisation_id: organisation.id, parent_organisation_id: stock_owner.id)
        end

        it "redirects to the organisation list" do
          request
          expect(response).to redirect_to("/organisations/#{organisation.id}/stock-owners")
        end
      end

      describe "organisation_relationships#create_managing_agent" do
        let!(:managing_agent) { FactoryBot.create(:organisation) }

        let(:params) do
          {
            "organisation_relationship": {
              "child_organisation_id": managing_agent.id,
            },
          }
        end

        let(:request) { post "/organisations/#{organisation.id}/managing-agents", headers:, params: }

        it "creates a new organisation relationship" do
          expect { request }.to change(OrganisationRelationship, :count).by(1)
        end

        it "sets the organisation relationship attributes correctly" do
          request
          expect(OrganisationRelationship).to exist(parent_organisation_id: organisation.id, child_organisation_id: managing_agent.id)
        end

        it "redirects to the organisation list" do
          request
          expect(response).to redirect_to("/organisations/#{organisation.id}/managing-agents")
        end
      end

      describe "organisation_relationships#delete_stock_owner" do
        let!(:stock_owner) { FactoryBot.create(:organisation) }
        let(:params) do
          {
            "target_organisation_id": stock_owner.id,
          }
        end
        let(:request) { delete "/organisations/#{organisation.id}/stock-owners", headers:, params: }

        before do
          FactoryBot.create(:organisation_relationship, child_organisation: organisation, parent_organisation: stock_owner)
        end

        it "deletes the new organisation relationship" do
          expect { request }.to change(OrganisationRelationship, :count).by(-1)
        end

        it "redirects to the organisation list" do
          request
          expect(response).to redirect_to("/organisations/#{organisation.id}/stock-owners")
        end
      end

      describe "organisation_relationships#delete_managing_agent" do
        let!(:managing_agent) { FactoryBot.create(:organisation) }
        let(:params) do
          {
            "target_organisation_id": managing_agent.id,
          }
        end
        let(:request) { delete "/organisations/#{organisation.id}/managing-agents", headers:, params: }

        before do
          FactoryBot.create(
            :organisation_relationship,
            parent_organisation: organisation,
            child_organisation: managing_agent,
          )
        end

        it "deletes the new organisation relationship" do
          expect { request }.to change(OrganisationRelationship, :count).by(-1)
        end

        it "redirects to the organisation list" do
          request
          expect(response).to redirect_to("/organisations/#{organisation.id}/managing-agents")
        end
      end

      context "when viewing a specific organisation's stock owners" do
        let!(:stock_owner) { FactoryBot.create(:organisation) }
        let!(:other_org_stock_owner) { FactoryBot.create(:organisation, name: "Foobar LTD") }
        let!(:other_organisation) { FactoryBot.create(:organisation, name: "Foobar LTD 2") }

        before do
          FactoryBot.create(:organisation_relationship, child_organisation: organisation, parent_organisation: stock_owner)
          FactoryBot.create(:organisation_relationship, child_organisation: other_organisation, parent_organisation: other_org_stock_owner)
          get "/organisations/#{organisation.id}/stock-owners", headers:, params: {}
        end

        it "displays the name of the organisation" do
          expect(page).to have_content(organisation.name)
        end

        it "has a sub-navigation with correct tabs" do
          expect(page).to have_css(".app-sub-navigation")
          expect(page).to have_content("Users")
        end

        it "shows a table of stock owners" do
          expected_html = "<table class=\"govuk-table\""
          expect(response.body).to include(expected_html)
          expect(response.body).to include(stock_owner.name)
        end

        it "shows only stock owners for this organisation" do
          expect(page).to have_content(stock_owner.name)
          expect(page).not_to have_content(other_org_stock_owner.name)
        end

        it "shows remove link(s)" do
          expect(response.body).to include("Remove")
        end

        it "shows the pagination count" do
          expect(page).to have_content("1 total stock owners")
        end

        context "when adding a stock owner" do
          before do
            get "/organisations/#{organisation.id}/stock-owners/add", headers:, params: {}
          end

          it "has the correct header" do
            expect(response.body).to include("What is the name of this organisation&#39;s stock owner?")
          end

          it "shows an add button" do
            expect(page).to have_button("Add")
          end
        end
      end

      context "when viewing a specific organisation's managing agents" do
        let!(:managing_agent) { FactoryBot.create(:organisation) }
        let!(:other_org_managing_agent) { FactoryBot.create(:organisation, name: "Foobar LTD") }
        let!(:other_organisation) { FactoryBot.create(:organisation, name: "Foobar LTD 2") }

        before do
          FactoryBot.create(:organisation_relationship, parent_organisation: organisation, child_organisation: managing_agent)
          FactoryBot.create(:organisation_relationship, parent_organisation: other_organisation, child_organisation: other_org_managing_agent)
          get "/organisations/#{organisation.id}/managing-agents", headers:, params: {}
        end

        it "displays the name of the organisation" do
          expect(page).to have_content(organisation.name)
        end

        it "has a sub-navigation with correct tabs" do
          expect(page).to have_css(".app-sub-navigation")
          expect(page).to have_content("Users")
        end

        it "shows a table of managing agents" do
          expected_html = "<table class=\"govuk-table\""
          expect(response.body).to include(expected_html)
          expect(response.body).to include(managing_agent.name)
        end

        it "shows only managing agents for this organisation" do
          expect(page).to have_content(managing_agent.name)
          expect(page).not_to have_content(other_org_managing_agent.name)
        end

        it "shows the pagination count" do
          expect(page).to have_content("1 total agents")
        end

        it "shows remove link(s)" do
          expect(response.body).to include("Remove")
        end

        context "when adding a stock owner" do
          before do
            get "/organisations/#{organisation.id}/managing-agents/add", headers:, params: {}
          end

          it "has the correct header" do
            expect(response.body).to include("What is the name of this organisation&#39;s managing agent?")
          end

          it "shows an add button" do
            expect(page).to have_button("Add")
          end
        end
      end
    end
  end
end
