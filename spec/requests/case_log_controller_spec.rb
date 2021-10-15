require "rails_helper"

RSpec.describe CaseLogsController, type: :request do
  describe "POST #create" do
    let(:tenant_code) { "T365" }
    let(:tenant_age) { 35 }
    let(:property_number_of_times_relet) { 12 }
    let(:property_postcode) { "SE11 6TY" }
    let(:api_username) { "test_user" }
    let(:api_password) { "test_password" }
    let(:basic_credentials) do
      ActionController::HttpAuthentication::Basic
                          .encode_credentials(api_username, api_password)
    end
    let(:in_progress) { "in progress" }
    let(:submitted) { "submitted" }

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
        "tenant_age": tenant_age,
        "property_postcode": property_postcode,
        "property_number_of_times_relet": property_number_of_times_relet
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

    context "invalid json params" do
      let(:tenant_age) { 2000 }
      let(:property_number_of_times_relet) { 21 }

      it "validates case log parameters" do
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["errors"]).to match_array(["Tenant age must be between 0 and 120", "Property number of times relet must be between 0 and 20"])
      end
    end

    context "partial case log submission" do
      it "marks the record as in_progress" do
        json_response = JSON.parse(response.body)
        expect(json_response["status"]).to eq(in_progress)
      end
    end

    context "complete case log submission" do
      let(:params) do
        JSON.parse(File.open("spec/fixtures/complete_case_log.json").read)
      end

      it "marks the record as submitted" do
        json_response = JSON.parse(response.body)
        expect(json_response["status"]).to eq(submitted)
      end
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
