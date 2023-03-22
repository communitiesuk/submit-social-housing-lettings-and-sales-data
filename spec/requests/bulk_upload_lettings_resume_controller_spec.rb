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

    context "when upload again selected" do
      it "sends them to relevant report" do
        patch "/lettings-logs/bulk-upload-resume/#{bulk_upload.id}/fix-choice", params: { form: { choice: "upload-again" } }

        expect(response).to redirect_to("/lettings-logs/bulk-upload-results/#{bulk_upload.id}")
      end
    end

    context "when fix inline selected" do
      it "sends them to confirm choice" do
        patch "/lettings-logs/bulk-upload-resume/#{bulk_upload.id}/fix-choice", params: { form: { choice: "create-fix-inline" } }

        expect(response).to redirect_to("/lettings-logs/bulk-upload-resume/#{bulk_upload.id}/confirm")
      end
    end
  end

  describe "GET /lettings-logs/bulk-upload-resume/:ID/confirm" do
    it "renders page" do
      get "/lettings-logs/bulk-upload-resume/#{bulk_upload.id}/confirm"

      expect(response).to be_successful

      expect(response.body).to include("Are you sure")
    end
  end

  describe "PATCH /lettings-logs/bulk-upload-resume/:ID/confirm" do
    let(:mock_processor) { instance_double(BulkUpload::Processor, approve: nil) }

    it "approves logs for creation" do
      allow(BulkUpload::Processor).to receive(:new).with(bulk_upload:).and_return(mock_processor)

      patch "/lettings-logs/bulk-upload-resume/#{bulk_upload.id}/confirm"

      expect(mock_processor).to have_received(:approve)

      expect(response).to redirect_to("/lettings-logs/bulk-upload-results/#{bulk_upload.id}/resume")
    end
  end
end
