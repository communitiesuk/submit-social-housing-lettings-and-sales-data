require "rails_helper"

RSpec.describe BulkUploadSalesDataCheckController, type: :request do
  let(:user) { create(:user) }
  let(:bulk_upload) { create(:bulk_upload, :sales, user:, bulk_upload_errors:) }
  let(:bulk_upload_errors) { create_list(:bulk_upload_error, 2) }

  before do
    create_list(:sales_log, 2, bulk_upload:)
    sign_in user
  end

  describe "GET /sales-logs/bulk-upload-data-check/:ID/soft-errors-valid" do
    it "shows the soft validation errors with confirmation question" do
      get "/sales-logs/bulk-upload-data-check/#{bulk_upload.id}/soft-errors-valid"

      expect(response.body).to include("Bulk upload for sales")
      expect(response.body).to include("2022/23")
      expect(response.body).to include("Check these 2 answers")
      expect(response.body).to include(bulk_upload.filename)
      expect(response.body).to include("Are there any errors in these fields?")
    end
  end

  describe "PATCH /sales-logs/bulk-upload-data-check/:ID/soft-errors-valid" do
    context "when no option selected" do
      it "renders error message" do
        patch "/sales-logs/bulk-upload-data-check/#{bulk_upload.id}/soft-errors-valid"

        expect(response).to be_successful

        expect(response.body).to include("You must select if there are errors in these fields")
      end
    end

    context "when yes is selected" do
      it "sends them to the fix choice page" do
        patch "/sales-logs/bulk-upload-data-check/#{bulk_upload.id}/soft-errors-valid", params: { form: { soft_errors_valid: "yes" } }

        expect(response).to redirect_to("/sales-logs/bulk-upload-resume/#{bulk_upload.id}/fix-choice")
      end
    end

    context "when no is selected" do
      it "sends them to confirm choice" do
        patch "/sales-logs/bulk-upload-data-check/#{bulk_upload.id}/soft-errors-valid", params: { form: { soft_errors_valid: "no" } }

        expect(response).to redirect_to("/sales-logs/bulk-upload-data-check/#{bulk_upload.id}/confirm")
        follow_redirect!
        expect(response.body).not_to include("You’ve successfully uploaded")
      end
    end
  end

  describe "GET /sales-logs/bulk-upload-data-check/:ID/confirm" do
    it "renders page" do
      get "/sales-logs/bulk-upload-data-check/#{bulk_upload.id}/confirm"

      expect(response).to be_successful

      expect(response.body).to include("Are you sure you want to upload all logs from this bulk upload?")
      expect(response.body).to include("There are 2 logs in this bulk upload, and 2 unexpected answers will be marked as correct.")
      expect(response.body).not_to include("You’ve successfully uploaded")
    end
  end

  describe "PATCH /sales-logs/bulk-upload-data-check/:ID/confirm" do
    let(:mock_processor) { instance_double(BulkUpload::Processor, approve_and_confirm_soft_validations: nil) }

    it "approves logs for creation" do
      allow(BulkUpload::Processor).to receive(:new).with(bulk_upload:).and_return(mock_processor)

      patch "/sales-logs/bulk-upload-data-check/#{bulk_upload.id}/confirm"

      expect(mock_processor).to have_received(:approve_and_confirm_soft_validations)

      expect(response).to redirect_to("/sales-logs")
      follow_redirect!
      expect(response.body).to include("You’ve successfully uploaded 2 logs")
    end
  end
end
