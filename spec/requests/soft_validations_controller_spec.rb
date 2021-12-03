require "rails_helper"

RSpec.describe SoftValidationsController, type: :request do
  let(:params) { { case_log_id: case_log.id } }
  let(:url) { "/case-logs/#{case_log.id}/net-income/soft-validations" }
  let(:user) { FactoryBot.create(:user) }

  context "a not signed in user" do
    let(:case_log) { FactoryBot.create(:case_log, :in_progress) }

    describe "GET #show" do
      it "redirects to the sign in page" do
        get url, headers: headers, params: {}
        expect(response).to redirect_to("/users/sign-in")
      end
    end
  end

  context "a signed in user" do
    before do
      sign_in user
      get url, params: {}
    end

    describe "GET #show" do
      context "Soft validation overide required" do
        let(:case_log) { FactoryBot.create(:case_log, :soft_validations_triggered) }

        it "returns a success response" do
          expect(response).to be_successful
        end

        it "returns a json with the soft validation fields" do
          json_response = JSON.parse(response.body)
          expect(json_response["show"]).to eq(true)
          expect(json_response["label"]).to match(/Are you sure this is correct?/)
        end
      end

      context "Soft validation overide not required" do
        let(:case_log) { FactoryBot.create(:case_log, :in_progress) }

        it "returns a success response" do
          expect(response).to be_successful
        end

        it "returns a json with the soft validation fields" do
          json_response = JSON.parse(response.body)
          expect(json_response["show"]).to eq(false)
        end
      end
    end
  end
end
