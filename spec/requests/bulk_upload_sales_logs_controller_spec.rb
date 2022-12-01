require "rails_helper"

RSpec.describe BulkUploadSalesLogsController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:organisation) { user.organisation }

  before do
    sign_in user
  end

  describe "GET /sales-logs/bulk-upload-logs/start" do
    context "when not in crossover period" do
      it "redirects to /prepare-your-file" do
        Timecop.freeze(2022, 1, 1) do
          get "/sales-logs/bulk-upload-logs/start", params: {}

          expect(response).to redirect_to("/sales-logs/bulk-upload-logs/prepare-your-file?form%5Byear%5D=2022")
        end
      end
    end

    context "when in crossover period" do
      it "redirects to /year" do
        Timecop.freeze(2023, 6, 1) do
          get "/sales-logs/bulk-upload-logs/start", params: {}

          expect(response).to redirect_to("/sales-logs/bulk-upload-logs/year")
        end
      end
    end
  end
end
