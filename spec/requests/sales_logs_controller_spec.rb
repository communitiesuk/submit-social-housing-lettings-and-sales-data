require "rails_helper"

RSpec.describe SalesLogsController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:owning_organisation) { user.organisation }
  let(:managing_organisation) { owning_organisation }
  let(:api_username) { "test_user" }
  let(:api_password) { "test_password" }
  let(:basic_credentials) do
    ActionController::HttpAuthentication::Basic
      .encode_credentials(api_username, api_password)
  end

  let(:params) do
    {
      "owning_organisation_id": owning_organisation.id,
      "managing_organisation_id": managing_organisation.id,
      "created_by_id": user.id,
    }
  end

  let(:headers) do
    {
      "Content-Type" => "application/json",
      "Accept" => "application/json",
      "Authorization" => basic_credentials,
    }
  end

  before do
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with("API_USER").and_return(api_username)
    allow(ENV).to receive(:[]).with("API_KEY").and_return(api_password)
  end

  describe "POST #create" do
    context "when API" do
      before do
        post "/sales-logs", headers:, params: params.to_json
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns a serialized sales log" do
        json_response = JSON.parse(response.body)
        expect(json_response.keys).to match_array(SalesLog.new.attributes.keys)
      end

      it "creates a sales log with the values passed" do
        json_response = JSON.parse(response.body)
        expect(json_response["owning_organisation_id"]).to eq(owning_organisation.id)
        expect(json_response["managing_organisation_id"]).to eq(managing_organisation.id)
        expect(json_response["created_by_id"]).to eq(user.id)
      end

      context "with a request containing invalid credentials" do
        let(:basic_credentials) do
          ActionController::HttpAuthentication::Basic.encode_credentials(api_username, "Oops")
        end

        it "returns 401" do
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context "when UI" do
      let(:user) { FactoryBot.create(:user) }
      let(:headers) { { "Accept" => "text/html" } }

      before do
        RequestHelper.stub_http_requests
        sign_in user
        post "/sales-logs", headers:
      end

      it "tracks who created the record" do
        created_id = response.location.match(/[0-9]+/)[0]
        whodunnit_actor = SalesLog.find_by(id: created_id).versions.last.actor
        expect(whodunnit_actor).to be_a(User)
        expect(whodunnit_actor.id).to eq(user.id)
      end
    end
  end
end
