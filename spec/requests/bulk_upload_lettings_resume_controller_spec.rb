require "rails_helper"

RSpec.describe BulkUploadLettingsResumeController, type: :request do
  let(:user) { create(:user) }
  let(:bulk_upload) { create(:bulk_upload, :lettings, user:, bulk_upload_errors:) }
  let(:bulk_upload_errors) { create_list(:bulk_upload_error, 2) }

  before do
    sign_in user
  end

  describe "GET /lettings-logs/bulk-upload-resume/:ID/start" do
    it "redirects to choice page" do
      get "/lettings-logs/bulk-upload-resume/#{bulk_upload.id}/start"

      expect(response).to redirect_to("/lettings-logs/bulk-upload-resume/#{bulk_upload.id}/fix-choice")
    end
  end

  describe "GET /lettings-logs/bulk-upload-resume/:ID/fix-choice" do
    it "renders the page correctly" do
      get "/lettings-logs/bulk-upload-resume/#{bulk_upload.id}/fix-choice"

      expect(response).to be_successful

      expect(response.body).to include("Bulk upload for lettings")
      expect(response.body).to include("2022/23")
      expect(response.body).to include("How would you like to fix 2 errors?")
      expect(response.body).to include(bulk_upload.filename)
    end
  end

  describe "PATCH /lettings-logs/bulk-upload-resume/:ID/fix-choice" do
    context "when no option selected" do
      it "renders error message" do
        patch "/lettings-logs/bulk-upload-resume/#{bulk_upload.id}/fix-choice"

        expect(response).to be_successful

        expect(response.body).to include("You must select")
      end
    end
  end
end
