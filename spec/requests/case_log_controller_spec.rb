require "rails_helper"

RSpec.describe CaseLogsController, type: :request do
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

  before do
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with("API_USER").and_return(api_username)
    allow(ENV).to receive(:[]).with("API_KEY").and_return(api_password)
  end

  describe "POST #create" do
    let(:tenant_code) { "T365" }
    let(:tenant_age) { 35 }
    let(:property_postcode) { "SE11 6TY" }
    let(:in_progress) { "in progress" }
    let(:submitted) { "submitted" }

    let(:params) do
      {
        "tenant_code": tenant_code,
        "tenant_age": tenant_age,
        "property_postcode": property_postcode,
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

    context "invalid json params" do
      let(:tenant_age) { 2000 }

      it "validates case log parameters" do
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["errors"]).to eq(["Tenant age must be between 0 and 120"])
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

  describe "PATCH" do
    let(:case_log) do
      FactoryBot.create(:case_log, :in_progress, tenant_code: "Old Value", property_postcode: "Old Value")
    end
    let(:params) do
      { tenant_code: "New Value" }
    end
    let(:id) { case_log.id }

    before do
      patch "/case_logs/#{id}", headers: headers, params: params.to_json
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "updates the case log with the given fields and keeps original values where none are passed" do
      case_log.reload
      expect(case_log.tenant_code).to eq("New Value")
      expect(case_log.property_postcode).to eq("Old Value")
    end

    context "invalid case log id" do
      let(:id) { (CaseLog.order(:id).last&.id || 0) + 1 }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
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

  # We don't really have any meaningful distinction between PUT and PATCH here since you can update some or all
  # fields in both cases, and both route to #Update. Rails generally recommends PATCH as it more closely matches
  # what actually happens to an ActiveRecord object and what we're doing here, but either is allowed.
  describe "PUT" do
    let(:case_log) do
      FactoryBot.create(:case_log, :in_progress, tenant_code: "Old Value", property_postcode: "Old Value")
    end
    let(:params) do
      { tenant_code: "New Value" }
    end
    let(:id) { case_log.id }

    before do
      put "/case_logs/#{id}", headers: headers, params: params.to_json
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "updates the case log with the given fields and keeps original values where none are passed" do
      case_log.reload
      expect(case_log.tenant_code).to eq("New Value")
      expect(case_log.property_postcode).to eq("Old Value")
    end

    context "invalid case log id" do
      let(:id) { (CaseLog.order(:id).last&.id || 0) + 1 }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
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
