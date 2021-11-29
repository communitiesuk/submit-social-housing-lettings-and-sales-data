require "rails_helper"

RSpec.describe CaseLogsController, type: :request do
  let(:owning_organisation) { FactoryBot.create(:organisation) }
  let(:managing_organisation) { owning_organisation }
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
    let(:age1) { 35 }
    let(:offered) { 12 }
    let(:property_postcode) { "SE11 6TY" }
    let(:in_progress) { "in_progress" }
    let(:completed) { "completed" }

    let(:params) do
      {
        "owning_organisation_id": owning_organisation.id,
        "managing_organisation_id": managing_organisation.id,
        "tenant_code": tenant_code,
        "age1": age1,
        "property_postcode": property_postcode,
        "offered": offered,
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
      expect(json_response["age1"]).to eq(age1)
      expect(json_response["property_postcode"]).to eq(property_postcode)
    end

    context "invalid json params" do
      let(:age1) { 2000 }
      let(:offered) { 21 }

      it "validates case log parameters" do
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["errors"]).to match_array([["offered", ["Property number of times relet must be between 0 and 20"]], ["age1", ["Tenant age must be an integer between 16 and 120"]]])
      end
    end

    context "partial case log submission" do
      it "marks the record as in_progress" do
        json_response = JSON.parse(response.body)
        expect(json_response["status"]).to eq(in_progress)
      end
    end

    context "complete case log submission" do
      let(:org_params) do
        {
          "case_log" => {
            "owning_organisation_id" => owning_organisation.id,
            "managing_organisation_id" => managing_organisation.id,
          },
        }
      end
      let(:case_log_params) { JSON.parse(File.open("spec/fixtures/complete_case_log.json").read) }
      let(:params) do
        case_log_params.merge(org_params) { |_k, a_val, b_val| a_val.merge(b_val) }
      end

      it "marks the record as completed" do
        json_response = JSON.parse(response.body)
        expect(json_response["status"]).to eq(completed)
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

  describe "GET" do
    context "collection" do
      let(:user) { FactoryBot.create(:user) }
      let(:organisation) { user.organisation }
      let(:other_organisation) { FactoryBot.create(:organisation) }
      let!(:case_log) do
        FactoryBot.create(
          :case_log,
          owning_organisation: organisation,
          managing_organisation: organisation,
        )
      end
      let!(:unauthorized_case_log) do
        FactoryBot.create(
          :case_log,
          owning_organisation: other_organisation,
          managing_organisation: other_organisation,
        )
      end
      let(:headers) { { "Accept" => "text/html" } }

      before do
        sign_in user
        get "/case_logs", headers: headers, params: {}
      end

      it "only shows case logs for your organisation" do
        expected_case_row_log = "<a class=\"govuk-link\" href=\"/case_logs/#{case_log.id}\">#{case_log.id}</a>"
        unauthorized_case_row_log = "<a class=\"govuk-link\" href=\"/case_logs/#{unauthorized_case_log.id}\">#{unauthorized_case_log.id}</a>"
        expect(CGI.unescape_html(response.body)).to include(expected_case_row_log)
        expect(CGI.unescape_html(response.body)).not_to include(unauthorized_case_row_log)
      end
    end

    context "member" do
      let(:case_log) { FactoryBot.create(:case_log, :completed) }
      let(:id) { case_log.id }

      before do
        get "/case_logs/#{id}", headers: headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns a serialized Case Log" do
        json_response = JSON.parse(response.body)
        expect(json_response["status"]).to eq(case_log.status)
      end

      context "invalid case log id" do
        let(:id) { (CaseLog.order(:id).last&.id || 0) + 1 }

        it "returns 404" do
          expect(response).to have_http_status(:not_found)
        end
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

    context "invalid case log params" do
      let(:params) { { age1: 200 } }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns an error message" do
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to eq({ "age1" => ["Tenant age must be an integer between 16 and 120"] })
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

  describe "DELETE" do
    let!(:case_log) do
      FactoryBot.create(:case_log, :in_progress)
    end
    let(:id) { case_log.id }

    context "expected deletion" do
      before do
        delete "/case_logs/#{id}", headers: headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "soft deletes the case log" do
        expect { CaseLog.find(id) }.to raise_error(ActiveRecord::RecordNotFound)
        expect(CaseLog.with_discarded.find(id)).to be_a(CaseLog)
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

    context "deletion fails" do
      before do
        allow_any_instance_of(CaseLog).to receive(:discard).and_return(false)
        delete "/case_logs/#{id}", headers: headers
      end

      it "returns an unprocessable entity 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "Submit Form" do
    let(:user) { FactoryBot.create(:user) }
    let(:form) { Form.new("spec/fixtures/forms/test_form.json") }
    let(:case_log) { FactoryBot.create(:case_log, :in_progress) }
    let(:page_id) { "person_1_age" }
    let(:params) do
      {
        id: case_log.id,
        case_log: {
          page: page_id,
          age1: answer,
        },
      }
    end

    before do
      allow(FormHandler.instance).to receive(:get_form).and_return(form)
      sign_in user
      post "/case_logs/#{case_log.id}/form", params: params
    end

    context "invalid answers" do
      let(:answer) { 2000 }

      it "re-renders the same page with errors if validation fails" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "valid answers" do
      let(:answer) { 20 }

      it "re-renders the same page with errors if validation fails" do
        expect(response).to have_http_status(:redirect)
      end

      let(:params) do
        {
          id: case_log.id,
          case_log: {
            page: page_id,
            age1: answer,
            age2: 2000
          },
        }
      end

      it "only updates answers that apply to the page being submitted" do
        case_log.reload
        expect(case_log.age1).to eq(answer)
        expect(case_log.age2).to be nil
      end
    end
  end
end
