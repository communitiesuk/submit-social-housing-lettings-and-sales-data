require "rails_helper"

RSpec.describe SoftValidationsController, type: :request do
  let(:params) { { case_log_id: case_log.id } }
  let(:url) { "/logs/#{case_log.id}/net-income/soft-validations" }
  let(:user) { FactoryBot.create(:user) }

  context "when a user is not signed in" do
    let(:case_log) { FactoryBot.create(:case_log, :in_progress) }

    describe "GET #show" do
      it "redirects to the sign in page" do
        get url, headers: headers, params: {}
        expect(response).to redirect_to("/users/sign-in")
      end
    end
  end

  context "when a user is signed in" do
    before do
      sign_in user
      get url, params: {}
    end

    describe "GET #show" do
      context "when a soft validation is triggered" do
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

      context "when no soft validation is triggered" do
        let(:case_log) { FactoryBot.create(:case_log, :in_progress) }

        it "returns a success response" do
          expect(response).to be_successful
        end

        it "returns a json without the soft validation fields" do
          json_response = JSON.parse(response.body)
          expect(json_response["show"]).to eq(false)
        end
      end
    end
  end
end
