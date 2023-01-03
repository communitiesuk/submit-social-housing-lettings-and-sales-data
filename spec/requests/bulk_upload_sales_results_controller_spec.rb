require "rails_helper"

RSpec.describe BulkUploadSalesResultsController, type: :request do
  let(:user) { create(:user) }
  let(:bulk_upload) { create(:bulk_upload, :sales, user:, bulk_upload_errors:) }
  let(:bulk_upload_errors) { create_list(:bulk_upload_error, 2) }

  before do
    sign_in user
  end

  describe "GET /sales-logs/bulk-upload-results/:ID" do
    it "renders correct year" do
      get "/sales-logs/bulk-upload-results/#{bulk_upload.id}"

      expect(response).to be_successful
      expect(response.body).to include("Bulk Upload for sales (2022/23)")
    end

    it "renders correct number of errors" do
      get "/sales-logs/bulk-upload-results/#{bulk_upload.id}"

      expect(response).to be_successful
      expect(response.body).to include("We found 2 errors in your file")
    end

    it "renders filename of the upload" do
      get "/sales-logs/bulk-upload-results/#{bulk_upload.id}"

      expect(response).to be_successful
      expect(response.body).to include(bulk_upload.filename)
    end

    it "renders Purchaser code" do
      get "/sales-logs/bulk-upload-results/#{bulk_upload.id}"

      expect(response.body).to include("Purchaser code: #{bulk_upload.bulk_upload_errors.first.purchaser_code}")
    end

    it "does not render tenant code or property reference" do
      get "/sales-logs/bulk-upload-results/#{bulk_upload.id}"

      expect(response.body).not_to include("Tenant code:")
      expect(response.body).not_to include("Property reference:")
    end

    context "when there are errors for more than 1 row" do
      let(:bulk_upload_errors) { [bulk_upload_error_1, bulk_upload_error_2] }
      let(:bulk_upload_error_1) { create(:bulk_upload_error, row: 1) }
      let(:bulk_upload_error_2) { create(:bulk_upload_error, row: 2) }

      it "renders no. of tables equal to no. of rows with errors" do
        get "/sales-logs/bulk-upload-results/#{bulk_upload.id}"

        expect(response.body).to include("<table").twice
      end
    end

    context "when viewing lettings log" do
      let(:bulk_upload) { create(:bulk_upload, :lettings, user:, bulk_upload_errors:) }

      it "renders a 404" do
        get "/sales-logs/bulk-upload-results/#{bulk_upload.id}"

        expect(response).not_to be_successful
        expect(response).to be_not_found
      end
    end
  end
end
