require "rails_helper"

RSpec.describe BulkUploadLettingsSoftValidationsCheckController, type: :request do
  let(:user) { create(:user) }
  let(:bulk_upload) { create(:bulk_upload, :lettings, user:, bulk_upload_errors:, total_logs_count: 2) }
  let(:bulk_upload_errors) { create_list(:bulk_upload_error, 2) }

  before do
    create_list(:lettings_log, 2, bulk_upload:)
    sign_in user
  end

  describe "GET /lettings-logs/bulk-upload-soft-validations-check/:ID/confirm-soft-errors" do
    it "shows the soft validation errors with confirmation question" do
      get "/lettings-logs/bulk-upload-soft-validations-check/#{bulk_upload.id}/confirm-soft-errors"

      expect(response.body).to include("Upload lettings logs in bulk")
      expect(response.body).to include(bulk_upload.year_combo)
      expect(response.body).to include("Check these 2 answers")
      expect(response.body).to include(bulk_upload.filename)
      expect(response.body).to include("Are these fields correct?")
    end

    it "shows the soft validation and lists the errors" do
      get "/lettings-logs/bulk-upload-soft-validations-check/#{bulk_upload.id}/confirm-soft-errors"

      expect(response.body).to include("Row #{bulk_upload_errors.first.row}")
      expect(response.body).to include("Tenant code")
      expect(response.body).to include("some error")
    end

    it "sets no cache headers" do
      get "/lettings-logs/bulk-upload-soft-validations-check/#{bulk_upload.id}/confirm-soft-errors"

      expect(response.headers["Cache-Control"]).to eql("no-store")
    end

    context "and previously told us to fix inline" do
      let(:bulk_upload) { create(:bulk_upload, :lettings, user:, bulk_upload_errors:, choice: "create-fix-inline") }

      it "redirects to resume chosen" do
        get "/lettings-logs/bulk-upload-soft-validations-check/#{bulk_upload.id}/confirm-soft-errors"

        expect(response).to redirect_to("/lettings-logs/bulk-upload-resume/#{bulk_upload.id}/chosen")
      end
    end

    context "and previously told us to bulk confirm soft validations" do
      let(:bulk_upload) { create(:bulk_upload, :lettings, user:, bulk_upload_errors:, choice: "bulk-confirm-soft-validations") }

      it "redirects to soft validations check chosen" do
        get "/lettings-logs/bulk-upload-soft-validations-check/#{bulk_upload.id}/confirm-soft-errors"

        expect(response).to redirect_to("/lettings-logs/bulk-upload-soft-validations-check/#{bulk_upload.id}/chosen")
      end
    end
  end

  describe "PATCH /lettings-logs/bulk-upload-soft-validations-check/:ID/confirm-soft-errors" do
    context "when no option selected" do
      it "renders error message" do
        patch "/lettings-logs/bulk-upload-soft-validations-check/#{bulk_upload.id}/confirm-soft-errors"

        expect(response).to be_successful

        expect(response.body).to include("You must select if there are errors in these fields")

        expect(bulk_upload.reload.choice).to be_blank
      end
    end

    context "when no is selected" do
      it "sends them to the fix choice page" do
        patch "/lettings-logs/bulk-upload-soft-validations-check/#{bulk_upload.id}/confirm-soft-errors", params: { form: { confirm_soft_errors: "no" } }

        expect(response).to redirect_to("/lettings-logs/bulk-upload-resume/#{bulk_upload.id}/fix-choice?soft_errors_only=true")

        expect(bulk_upload.reload.choice).to be_blank
      end
    end

    context "when yes is selected" do
      it "sends them to confirm choice" do
        patch "/lettings-logs/bulk-upload-soft-validations-check/#{bulk_upload.id}/confirm-soft-errors", params: { form: { confirm_soft_errors: "yes" } }

        expect(response).to redirect_to("/lettings-logs/bulk-upload-soft-validations-check/#{bulk_upload.id}/confirm")
        follow_redirect!
        expect(response.body).not_to include("You’ve successfully uploaded")

        expect(bulk_upload.reload.choice).to be_blank
      end
    end
  end

  describe "GET /lettings-logs/bulk-upload-soft-validations-check/:ID/confirm" do
    it "renders page" do
      get "/lettings-logs/bulk-upload-soft-validations-check/#{bulk_upload.id}/confirm"

      expect(response).to be_successful

      expect(response.body).to include("You have chosen to upload all logs from this bulk upload.")
      expect(response.body).to include("You will upload 2 logs. There are unexpected answers in 2 logs, and 2 unexpected answers in total. These unexpected answers will be marked as correct.")
      expect(response.body).not_to include("You’ve successfully uploaded")
    end
  end

  describe "PATCH /lettings-logs/bulk-upload-soft-validations-check/:ID/confirm" do
    let(:mock_processor) { instance_double(BulkUpload::Processor, approve_and_confirm_soft_validations: nil) }

    it "approves logs for creation" do
      allow(BulkUpload::Processor).to receive(:new).with(bulk_upload:).and_return(mock_processor)

      patch "/lettings-logs/bulk-upload-soft-validations-check/#{bulk_upload.id}/confirm"

      expect(mock_processor).to have_received(:approve_and_confirm_soft_validations)

      expect(response).to redirect_to("/lettings-logs")
      follow_redirect!
      expect(response.body).to include("You’ve successfully uploaded 2 logs")

      expect(bulk_upload.reload.choice).to eql("bulk-confirm-soft-validations")
    end
  end
end
