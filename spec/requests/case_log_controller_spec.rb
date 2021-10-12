require 'rails_helper'

RSpec.describe CaseLogsController, type: :request do
  describe "POST #create" do
    let(:headers) do
      {
       "Content-Type" => "application/json",
       "ACCEPT" => "application/json"
      }
    end

    let(:tenant_code) { "T365" }
    let(:tenant_age) { 35 }
    let(:property_postcode) { "SE11 6TY" }

    let(:params) do
      {
        "tenant_code": tenant_code,
        "tenant_age": 35,
        "property_postcode": property_postcode
      }
    end

    before do
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
  end
end
