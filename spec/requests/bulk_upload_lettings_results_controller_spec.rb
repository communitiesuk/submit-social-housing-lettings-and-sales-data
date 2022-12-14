require "rails_helper"

RSpec.describe BulkUploadLettingsResultsController, type: :request do
  let(:user) { create(:user) }
  let(:bulk_upload) { create(:bulk_upload, user:, bulk_upload_errors:) }
  let(:bulk_upload_errors) { create_list(:bulk_upload_error, 2) }

  before do
    sign_in user
  end

  describe "GET /lettings-logs/bulk-upload-results/:ID" do
    it "renders correct year" do
      get "/lettings-logs/bulk-upload-results/#{bulk_upload.id}"

      expect(response).to be_successful
      expect(response.body).to include("Bulk Upload for lettings (2022/23)")
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
  end
end
