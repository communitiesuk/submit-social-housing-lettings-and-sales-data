require "rails_helper"

RSpec.describe BulkUploadLettingsLogsController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:organisation) { user.organisation }

  before do
    sign_in user
  end

  describe "GET /lettings-logs/bulk-upload-logs/start" do
    context "when not in crossover period" do
      let(:expected_year) { 2021 }

      it "redirects to /prepare-your-file" do
        Timecop.freeze(2022, 1, 1) do
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
end
