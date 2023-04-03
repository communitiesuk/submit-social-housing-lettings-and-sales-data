require "rails_helper"

RSpec.describe BulkUploadLettingsLogsController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:organisation) { user.organisation }

  before do
    sign_in user
  end

  describe "GET /lettings-logs/bulk-upload-logs/start" do
    context "when not in crossover period" do
      let(:expected_year) { 2022 }

      it "redirects to /prepare-your-file" do
        Timecop.freeze(2023, 1, 1) do
          get "/lettings-logs/bulk-upload-logs/start", params: {}

          expect(response).to redirect_to("/lettings-logs/bulk-upload-logs/prepare-your-file?form%5Byear%5D=#{expected_year}")
        end
      end
    end

    context "when in crossover period" do
      it "redirects to /year" do
        Timecop.freeze(2022, 6, 1) do
          get "/lettings-logs/bulk-upload-logs/start", params: {}

          expect(response).to redirect_to("/lettings-logs/bulk-upload-logs/year")
        end
      end
    end
  end

  describe "GET /lettings-logs/bulk-upload-logs/guidance" do
    context "when not in crossover period" do
      let(:expected_year) { FormHandler.instance.forms["current_lettings"].start_date.year }

      it "shows guidance page with correct title" do
        Timecop.freeze(2022, 1, 1) do
          get "/lettings-logs/bulk-upload-logs/guidance", params: {}

          expect(response.body).to include("How to upload logs in bulk")
        end
      end
    end

    context "when in crossover period" do
      it "shows guidance page with correct title" do
        Timecop.freeze(2023, 6, 1) do
          get "/lettings-logs/bulk-upload-logs/guidance", params: {}

          expect(response.body).to include("How to upload logs in bulk")
        end
      end
    end
  end
end
