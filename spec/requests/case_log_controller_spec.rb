require "rails_helper"

RSpec.describe CaseLogsController, type: :request do
  describe "POST #create" do
    let(:tenant_code) { "T365" }
    let(:tenant_age) { 35 }
    let(:property_postcode) { "SE11 6TY" }
    let(:api_username) { "test_user" }
    let(:api_password) { "test_password" }
    let(:basic_credentials) do
      ActionController::HttpAuthentication::Basic
                          .encode_credentials(api_username, api_password)
    end

    let(:headers) do
      {
        "Content-Type" => "application/json",
        "Accept" => "application/json",
        "Authorization" => basic_credentials,
      }
    end

    let(:params) do
      {
        "tenant_code": tenant_code,
        "tenant_age": 35,
        "property_postcode": property_postcode,
      }
    end

    before do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with("API_USER").and_return(api_username)
      allow(ENV).to receive(:[]).with("API_KEY").and_return(api_password)
      post "/case_logs", headers: headers, params: params.to_json
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "returns a serialized Case Log" do
      json_response = JSON.parse(response.body)
      expect(json_response.keys).to match_array(CaseLog.new.attributes.keys)
    end

    it "creates a case log with the values passed" do
      json_response = JSON.parse(response.body)
      expect(json_response["tenant_code"]).to eq(tenant_code)
      expect(json_response["tenant_age"]).to eq(tenant_age)
      expect(json_response["property_postcode"]).to eq(property_postcode)
    end

    context "request with invalid credentials" do
      let(:basic_credentials) do
        ActionController::HttpAuthentication::Basic.encode_credentials(api_username, "Oops")
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
