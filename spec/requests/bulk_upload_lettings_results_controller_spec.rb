require "rails_helper"

RSpec.describe BulkUploadLettingsResultsController, type: :request do
  let(:user) { create(:user) }
  let(:bulk_upload) { create(:bulk_upload, :lettings, user:, bulk_upload_errors:) }
  let(:bulk_upload_errors) { create_list(:bulk_upload_error, 2) }

  before do
    sign_in user
  end

  describe "GET /lettings-logs/bulk-upload-results/:ID/summary" do
    it "renders year combo" do
      get "/lettings-logs/bulk-upload-results/#{bulk_upload.id}/summary"

      expect(response).to be_successful
      expect(response.body).to include("Bulk upload for lettings (2022/23)")
    end

    it "renders the bulk upload filename" do
      get "/lettings-logs/bulk-upload-results/#{bulk_upload.id}/summary"

      expect(response.body).to include(bulk_upload.filename)
    end
  end

  describe "GET /lettings-logs/bulk-upload-results/:ID" do
    it "renders correct year" do
      get "/lettings-logs/bulk-upload-results/#{bulk_upload.id}"

      expect(response).to be_successful
      expect(response.body).to include("Bulk upload for lettings (2022/23)")
    end

    it "renders correct number of errors" do
      get "/lettings-logs/bulk-upload-results/#{bulk_upload.id}"

      expect(response).to be_successful
      expect(response.body).to include("We found 2 errors in your file")
    end

    it "renders filename of the upload" do
      get "/lettings-logs/bulk-upload-results/#{bulk_upload.id}"

      expect(response).to be_successful
      expect(response.body).to include(bulk_upload.filename)
    end

    context "when there are errors for more than 1 row" do
      let(:bulk_upload_errors) { [bulk_upload_error_1, bulk_upload_error_2] }
      let(:bulk_upload_error_1) { create(:bulk_upload_error, row: 1) }
      let(:bulk_upload_error_2) { create(:bulk_upload_error, row: 2) }

      it "renders no. of tables equal to no. of rows with errors" do
        get "/lettings-logs/bulk-upload-results/#{bulk_upload.id}"

        expect(response.body).to include("<table").twice
      end
    end

    context "when viewing sales log" do
      let(:bulk_upload) { create(:bulk_upload, :sales, user:, bulk_upload_errors:) }

      it "renders a 404" do
        get "/lettings-logs/bulk-upload-results/#{bulk_upload.id}"

        expect(response).not_to be_successful
        expect(response).to be_not_found
      end
    end
  end
end
