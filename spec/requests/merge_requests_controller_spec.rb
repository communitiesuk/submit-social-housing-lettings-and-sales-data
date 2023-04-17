require "rails_helper"

RSpec.describe MergeRequestsController, type: :request do
  let(:organisation) { user.organisation }
  let!(:other_organisation) { FactoryBot.create(:organisation, name: "Other Test Org") }
  let(:headers) { { "Accept" => "text/html" } }
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:user) { FactoryBot.create(:user, :data_coordinator) }
  let(:support_user) { FactoryBot.create(:user, :support, organisation:) }
  let(:merge_request) { MergeRequest.create!(requesting_organisation: organisation) }

  context "when user is signed in with a data coordinator user" do
    before do
      sign_in user
    end

    describe "#organisations" do
      let(:params) { { merge_request: { requesting_organisation_id: "9" } } }

      before do
        organisation.update!(name: "Test Org")
        post "/merge-request", headers:, params:
      end

      it "creates merge request with requesting organisation" do
        follow_redirect!
        expect(page).to have_content("Which organisations are merging?")
        expect(page).to have_content("Test Org")
        expect(page).not_to have_link("Remove")
      end

      context "when passing a different requesting organisation id" do
        let(:params) { { merge_request: { requesting_organisation_id: other_organisation.id } } }

        it "creates merge request with current user organisation" do
          follow_redirect!
          expect(MergeRequest.count).to eq(1)
          expect(MergeRequest.first.requesting_organisation_id).to eq(organisation.id)
        end
      end
    end

    describe "#update_organisations" do
      let(:params) { { merge_request: { merging_organisation: other_organisation.id } } }

      context "when updating a merge request with a new organisation" do
        before do
          patch "/merge-request/#{merge_request.id}/organisations", headers:, params:
        end

        it "updates the merge request" do
          merge_request.reload
          expect(merge_request.merging_organisations.count).to eq(1)
          expect(page).to have_content("Test Org")
          expect(page).to have_content("Other Test Org")
          expect(page).to have_link("Remove")
        end
      end

      context "when the user selects an organisation that requested another merge" do
        let(:params) { { merge_request: { merging_organisation: other_organisation.id } } }

        before do
          MergeRequest.create!(requesting_organisation_id: other_organisation.id)
          patch "/merge-request/#{merge_request.id}/organisations", headers:, params:
        end

        it "does not update the merge request" do
          merge_request.reload
          expect(merge_request.merging_organisations.count).to eq(0)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.merge_request.organisation_part_of_another_merge"))
        end
      end

      context "when the user selects an organisation that is a part of another merge" do
        let(:another_organisation) { FactoryBot.create(:organisation, name: "Other Test Org") }
        let(:params) { { merge_request: { merging_organisation: another_organisation.id } } }

        before do
          existing_merge_request = MergeRequest.create!(requesting_organisation_id: other_organisation.id)
          MergeRequestOrganisation.create!(merge_request_id: existing_merge_request.id, merging_organisation_id: another_organisation.id)
          patch "/merge-request/#{merge_request.id}/organisations", headers:, params:
        end

        it "does not update the merge request" do
          merge_request.reload
          expect(merge_request.merging_organisations.count).to eq(0)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.merge_request.organisation_part_of_another_merge"))
        end
      end

      context "when the user selects an organisation that is a part of current merge" do
        let(:another_organisation) { FactoryBot.create(:organisation, name: "Other Test Org") }
        let(:params) { { merge_request: { merging_organisation: another_organisation.id } } }

        before do
          merge_request.merging_organisations << another_organisation
          patch "/merge-request/#{merge_request.id}/organisations", headers:, params:
        end

        it "does not update the merge request" do
          merge_request.reload
          expect(merge_request.merging_organisations.count).to eq(1)
        end
      end

      context "when the user does not select an organisation" do
        let(:params) { { merge_request: { merging_organisation: nil } } }

        before do
          patch "/merge-request/#{merge_request.id}/organisations", headers:, params:
        end

        it "does not update the merge request" do
          merge_request.reload
          expect(merge_request.merging_organisations.count).to eq(0)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.merge_request.organisation_not_selected"))
        end
      end

      context "when the user selects non existent id" do
        let(:params) { { merge_request: { merging_organisation: "clearly_not_an_id" } } }

        before do
          patch "/merge-request/#{merge_request.id}/organisations", headers:, params:
        end

        it "does not update the merge request" do
          merge_request.reload
          expect(merge_request.merging_organisations.count).to eq(0)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.merge_request.organisation_not_selected"))
        end
      end
    end

    describe "#remove_organisation" do
      let(:params) { { merge_request: { merging_organisation: other_organisation.id } } }

      context "when removing an organisation from merge request " do
        before do
          MergeRequestOrganisation.create!(merge_request_id: merge_request.id, merging_organisation_id: other_organisation.id)
          get "/merge-request/#{merge_request.id}/organisations/remove", headers:, params:
        end

        it "updates the merge request" do
          expect(merge_request.merging_organisations.count).to eq(0)
          expect(page).not_to have_link("Remove")
        end
      end
    end

    describe "#other_merging_organisations" do
      let(:params) { { merge_request: { other_merging_organisations: "A list of other merging organisations" } } }

      context "when adding other merging organisations" do
        before do
          MergeRequestOrganisation.create!(merge_request_id: merge_request.id, merging_organisation_id: other_organisation.id)
          patch "/merge-request/#{merge_request.id}", headers:, params:
        end

        it "updates the merge request" do
          merge_request.reload
          expect(merge_request.other_merging_organisations).to eq("A list of other merging organisations")
        end
      end
    end
  end

  context "when user is signed in as a support user" do
    before do
      allow(support_user).to receive(:need_two_factor_authentication?).and_return(false)
      sign_in support_user
    end

    describe "#organisations" do
      let(:params) { { merge_request: { requesting_organisation_id: other_organisation.id } } }

      before do
        organisation.update!(name: "Test Org")
        post "/merge-request", headers:, params:
      end

      it "creates merge request with requesting organisation" do
        follow_redirect!
        expect(MergeRequest.count).to eq(1)
        expect(MergeRequest.first.requesting_organisation_id).to eq(other_organisation.id)
      end
    end
  end
end
