require "rails_helper"

RSpec.describe SalesLogsController do
  let(:bulk_upload) { create(:bulk_upload, :sales) }

  before do
    sign_in bulk_upload.user
  end

  describe "#index" do
    context "when a sales bulk upload has been resolved" do
      it "redirects to resume_bulk_upload_sales_result_path" do
        session[:sales_logs_filters] = { bulk_upload_id: [bulk_upload.id.to_s] }.to_json

        get :index

        expect(response).to redirect_to("/sales-logs/bulk-upload-results/#{bulk_upload.id}/resume")
      end
    end

    context "when a resolved lettings bulk upload filter applied" do
      let(:bulk_upload) { create(:bulk_upload, :lettings) }

      it "does not redirect to resume" do
        session[:sales_logs_filters] = { bulk_upload_id: [bulk_upload.id.to_s] }.to_json

        get :index

        expect(response).not_to redirect_to("/sales-logs/bulk-upload-results/#{bulk_upload.id}/resume")
      end
    end
  end
end
