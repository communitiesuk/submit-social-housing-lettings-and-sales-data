require "rails_helper"

RSpec.describe MergeRequestsController, type: :request do
  let(:organisation) { user.organisation }
  let!(:other_organisation) { FactoryBot.create(:organisation) }
  let(:headers) { { "Accept" => "text/html" } }
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:user) { FactoryBot.create(:user, :data_coordinator) }
  let(:merge_request) { MergeRequest.create!(requesting_organisation: organisation) }

  context "when user is signed in with a data coordinator user" do
    before do
      sign_in user
    end

    describe "#organisations" do
      before do
        organisation.update!(name: "Test Org")
        post "/merge-request", headers:, params: {}
      end

      it "creates merge request with requesting organisation" do
        follow_redirect!
        expect(page).to have_content("Which organisations are merging?")
        expect(page).to have_content("Test Org")
        expect(page).not_to have_link("Remove")
      end
    end

    describe "#update_organisations" do
      let(:params) { { merge_request: { merging_organisation: other_organisation.id } } }

      before do
        other_organisation.update!(name: "Other Test Org")
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
  end
end
