require "rails_helper"

RSpec.describe BulkUploadSalesResumeController, type: :request do
  let(:user) { create(:user) }
  let(:bulk_upload) { create(:bulk_upload, :sales, user:, bulk_upload_errors:) }
  let(:bulk_upload_errors) { create_list(:bulk_upload_error, 2) }

  before do
    sign_in user
  end

  describe "GET /sales-logs/bulk-upload-resume/:ID/start" do
    context "when a choice has not been made" do
      it "redirects to choice page" do
        get "/sales-logs/bulk-upload-resume/#{bulk_upload.id}/start"

        expect(response).to redirect_to("/sales-logs/bulk-upload-resume/#{bulk_upload.id}/fix-choice")
      end
    end

    context "when a choice has been made and then the logs have been completed" do
      let(:sales_log) { create_list(:sales_log, 2, :completed, bulk_upload:) }

      it "redirects to the complete page if the bulk uploads are completed" do
        bulk_upload.update!(choice: "create-fix-inline")

        get "/sales-logs/bulk-upload-resume/#{bulk_upload.id}/start"
        follow_redirect!
        expect(response).to redirect_to("/sales-logs/bulk-upload-resume/#{bulk_upload.id}/chosen")

        follow_redirect!
        expect(response.body).to include("You have created logs from your bulk upload, and the logs are complete. Return to sales logs to view them.")
      end
    end

    context "when a choice to reupload has been made" do
      it "redirects to the error report" do
        bulk_upload.update!(choice: "upload-again")

        get "/sales-logs/bulk-upload-resume/#{bulk_upload.id}/start"
        follow_redirect!
        expect(response).to redirect_to("/sales-logs/bulk-upload-results/#{bulk_upload.id}")
      end
    end

    context "when bulk upload was cancelled by moved user" do
      it "redirects to the error report" do
        bulk_upload.update!(choice: "cancelled-by-moved-user")

        get "/sales-logs/bulk-upload-resume/#{bulk_upload.id}/start"
        follow_redirect!
        expect(response).to redirect_to("/sales-logs/bulk-upload-results/#{bulk_upload.id}")
      end
    end
  end

  describe "GET /sales-logs/bulk-upload-resume/:ID/fix-choice" do
    it "renders the page correctly" do
      get "/sales-logs/bulk-upload-resume/#{bulk_upload.id}/fix-choice"

      expect(response).to be_successful

      expect(response.body).to include("Upload sales logs in bulk")
      expect(response.body).to include(bulk_upload.year_combo)
      expect(response.body).to include("View the error report")
      expect(response.body).to include("How would you like to fix the errors?")
      expect(response.body).to include(bulk_upload.filename)
      expect(response.body).not_to include("Cancel")
    end

    it "sets no cache headers" do
      get "/sales-logs/bulk-upload-resume/#{bulk_upload.id}/fix-choice"

      expect(response.headers["Cache-Control"]).to eql("no-store")
    end

    context "and previously told us to fix inline" do
      let(:bulk_upload) { create(:bulk_upload, :sales, user:, bulk_upload_errors:, choice: "create-fix-inline") }

      it "redirects to chosen" do
        get "/sales-logs/bulk-upload-resume/#{bulk_upload.id}/fix-choice"

        expect(response).to redirect_to("/sales-logs/bulk-upload-resume/#{bulk_upload.id}/chosen")
      end
    end

    context "and previously told us to bulk confirm soft validations" do
      let(:bulk_upload) { create(:bulk_upload, :sales, user:, bulk_upload_errors:, choice: "bulk-confirm-soft-validations") }

      it "redirects to soft validations check chosen" do
        get "/sales-logs/bulk-upload-resume/#{bulk_upload.id}/fix-choice"

        expect(response).to redirect_to("/sales-logs/bulk-upload-soft-validations-check/#{bulk_upload.id}/chosen")
      end
    end

    context "when a choice to reupload has been made" do
      let(:bulk_upload) { create(:bulk_upload, :sales, user:, bulk_upload_errors:, choice: "upload-again") }

      it "redirects to the error report" do
        get "/sales-logs/bulk-upload-resume/#{bulk_upload.id}/fix-choice"
        expect(response).to redirect_to("/sales-logs/bulk-upload-results/#{bulk_upload.id}")
      end
    end

    context "when bulk upload was cancelled by moved user" do
      let(:bulk_upload) { create(:bulk_upload, :sales, user:, bulk_upload_errors:, choice: "cancelled-by-moved-user") }

      it "redirects to the error report" do
        get "/sales-logs/bulk-upload-resume/#{bulk_upload.id}/start"
        follow_redirect!
        expect(response).to redirect_to("/sales-logs/bulk-upload-results/#{bulk_upload.id}")
      end
    end
  end

  describe "GET /sales-logs/bulk-upload-resume/:ID/fix-choice?soft_errors_only=true" do
    it "displays a cancel button" do
      get "/sales-logs/bulk-upload-resume/#{bulk_upload.id}/fix-choice?soft_errors_only=true"

      expect(response).to be_successful

      expect(response.body).to include("Upload sales logs in bulk")
      expect(response.body).to include("Cancel")
    end
  end

  describe "PATCH /sales-logs/bulk-upload-resume/:ID/fix-choice" do
    context "when no option selected" do
      it "renders error message" do
        patch "/sales-logs/bulk-upload-resume/#{bulk_upload.id}/fix-choice"

        expect(response).to be_successful

        expect(response.body).to include("Select how you would like to fix these errors")
      end
    end

    context "when upload again selected" do
      it "sends them to relevant report" do
        patch "/sales-logs/bulk-upload-resume/#{bulk_upload.id}/fix-choice", params: { form: { choice: "upload-again" } }

        expect(response).to redirect_to("/sales-logs/bulk-upload-results/#{bulk_upload.id}")

        expect(bulk_upload.reload.choice).to eql("upload-again")
      end
    end

    context "when fix inline selected" do
      it "sends them to confirm choice" do
        patch "/sales-logs/bulk-upload-resume/#{bulk_upload.id}/fix-choice", params: { form: { choice: "create-fix-inline" } }

        expect(response).to redirect_to("/sales-logs/bulk-upload-resume/#{bulk_upload.id}/confirm")

        expect(bulk_upload.reload.choice).to be_blank
      end
    end
  end

  describe "GET /sales-logs/bulk-upload-resume/:ID/confirm" do
    it "renders page" do
      get "/sales-logs/bulk-upload-resume/#{bulk_upload.id}/confirm"

      expect(response).to be_successful

      expect(response.body).to include("Are you sure you want to upload all logs from this bulk upload?")
      expect(response.body).to include("View the error report")
      expect(response.body).to include("2 answers will be deleted because they are invalid.")
      expect(response.body).to include("See which answers will be deleted")
    end

    it "sets no cache headers" do
      get "/sales-logs/bulk-upload-resume/#{bulk_upload.id}/confirm"

      expect(response.headers["Cache-Control"]).to eql("no-store")
    end

    context "and previously told us to fix inline" do
      let(:bulk_upload) { create(:bulk_upload, :sales, user:, bulk_upload_errors:, choice: "create-fix-inline") }

      it "redirects to chosen" do
        get "/sales-logs/bulk-upload-resume/#{bulk_upload.id}/confirm"

        expect(response).to redirect_to("/sales-logs/bulk-upload-resume/#{bulk_upload.id}/chosen")
      end
    end

    context "and previously told us to bulk confirm soft validations" do
      let(:bulk_upload) { create(:bulk_upload, :sales, user:, bulk_upload_errors:, choice: "bulk-confirm-soft-validations") }

      it "redirects to soft validations check chosen" do
        get "/sales-logs/bulk-upload-resume/#{bulk_upload.id}/confirm"

        expect(response).to redirect_to("/sales-logs/bulk-upload-soft-validations-check/#{bulk_upload.id}/chosen")
      end
    end
  end

  describe "PATCH /sales-logs/bulk-upload-resume/:ID/confirm" do
    let(:mock_processor) { instance_double(BulkUpload::Processor, approve: nil) }

    it "approves logs for creation" do
      allow(BulkUpload::Processor).to receive(:new).with(bulk_upload:).and_return(mock_processor)

      patch "/sales-logs/bulk-upload-resume/#{bulk_upload.id}/confirm"

      expect(mock_processor).to have_received(:approve)

      expect(bulk_upload.reload.choice).to eql("create-fix-inline")

      expect(response).to redirect_to("/sales-logs/bulk-upload-results/#{bulk_upload.id}/resume")
    end
  end

  describe "GET /sales-logs/bulk-upload-resume/:ID/deletion-report" do
    it "renders the page correctly" do
      get "/sales-logs/bulk-upload-resume/#{bulk_upload.id}/deletion-report"

      expect(response).to be_successful

      expect(response.body).to include("Upload sales logs in bulk")
      expect(response.body).to include(bulk_upload.year_combo)
      expect(response.body).to include("These 2 answers will be deleted if you upload the log")
      expect(response.body).to include(bulk_upload.filename)
      expect(response.body).to include("Clear this data and upload the logs")
    end

    it "sets no cache headers" do
      get "/sales-logs/bulk-upload-resume/#{bulk_upload.id}/deletion-report"

      expect(response.headers["Cache-Control"]).to eql("no-store")
    end

    context "and previously told us to fix inline" do
      let(:bulk_upload) { create(:bulk_upload, :sales, user:, bulk_upload_errors:, choice: "create-fix-inline") }

      it "redirects to chosen" do
        get "/sales-logs/bulk-upload-resume/#{bulk_upload.id}/deletion-report"

        expect(response).to redirect_to("/sales-logs/bulk-upload-resume/#{bulk_upload.id}/chosen")
      end
    end

    context "and previously told us to bulk confirm soft validations" do
      let(:bulk_upload) { create(:bulk_upload, :sales, user:, bulk_upload_errors:, choice: "bulk-confirm-soft-validations") }

      it "redirects to soft validations check chosen" do
        get "/sales-logs/bulk-upload-resume/#{bulk_upload.id}/deletion-report"

        expect(response).to redirect_to("/sales-logs/bulk-upload-soft-validations-check/#{bulk_upload.id}/chosen")
      end
    end

    context "and has a row with all non-cleared errors" do
      let(:bulk_upload_errors) { [create(:bulk_upload_error, row: 1), create(:bulk_upload_error, row: 2, category: :not_answered), create(:bulk_upload_error, row: 3, category: :soft_validation), create(:bulk_upload_error, row: 4)] }
      let(:bulk_upload) { create(:bulk_upload, :sales, user:, bulk_upload_errors:) }

      it "renders the page correctly" do
        get "/sales-logs/bulk-upload-resume/#{bulk_upload.id}/deletion-report"

        expect(response).to be_successful

        expect(response.body).to include("Upload sales logs in bulk")
        expect(response.body).to include(bulk_upload.year_combo)
        expect(response.body).to include("These 2 answers will be deleted if you upload the log")
        expect(response.body).to include(bulk_upload.filename)
        expect(response.body).to include("Clear this data and upload the logs")
      end
    end
  end
end
