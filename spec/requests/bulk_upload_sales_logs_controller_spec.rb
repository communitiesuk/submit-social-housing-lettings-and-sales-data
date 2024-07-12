require "rails_helper"

RSpec.describe BulkUploadSalesLogsController, type: :request do
  include CollectionTimeHelper

  let(:user) { create(:user) }
  let(:organisation) { user.organisation }

  before do
    sign_in user
  end

  describe "GET /sales-logs/bulk-upload-logs/start" do
    context "when data protection confirmation not signed" do
      let(:organisation) { create(:organisation, :without_dpc) }
      let(:user) { create(:user, organisation:, with_dsa: false) }

      it "redirects to sales index page" do
        get "/sales-logs/bulk-upload-logs/start", params: {}

        expect(response).to redirect_to("/sales-logs")
      end
    end

    context "when not in crossover period" do
      let(:expected_year) { current_collection_start_year }

      before do
        allow(FormHandler.instance).to receive(:sales_in_crossover_period?).and_return(false)
      end

      it "redirects to /prepare-your-file" do
        get "/sales-logs/bulk-upload-logs/start", params: {}

        expect(response).to redirect_to("/sales-logs/bulk-upload-logs/prepare-your-file?form%5Byear%5D=#{expected_year}")
      end
    end

    context "when in crossover period" do
      before do
        allow(FormHandler.instance).to receive(:sales_in_crossover_period?).and_return(true)
      end

      it "redirects to /year" do
        get "/sales-logs/bulk-upload-logs/start", params: {}

        expect(response).to redirect_to("/sales-logs/bulk-upload-logs/year")
      end
    end
  end

  describe "GET /sales-logs/bulk-upload-logs/guidance" do
    context "when not in crossover period" do
      before do
        allow(FormHandler.instance).to receive(:sales_in_crossover_period?).and_return(false)
      end

      it "shows guidance page with correct title" do
        get "/sales-logs/bulk-upload-logs/guidance?form%5Byear%5D=#{current_collection_start_year}", params: {}

        expect(response.body).to include("How to upload logs in bulk")
      end
    end

    context "when in crossover period" do
      before do
        allow(FormHandler.instance).to receive(:sales_in_crossover_period?).and_return(true)
      end

      it "shows guidance page with correct title" do
        get "/sales-logs/bulk-upload-logs/guidance?form%5Byear%5D=2023", params: {}

        expect(response.body).to include("How to upload logs in bulk")
      end
    end
  end
end
