require "rails_helper"

RSpec.describe BulkUploadController, type: :request do
  let(:url) { "/case_logs/bulk_upload" }

  before do
    get url, params: {}
  end

  describe "GET #show" do
    it "returns a success response" do
      expect(response).to be_successful
    end

    it "returns a page with a file upload form" do
      expect(response.body).to match(/<input id="case-log-bulk-upload-field" class="govuk-file-upload"/)
      expect(response.body).to match(/<button type="submit" formnovalidate="formnovalidate" class="govuk-button"/)
    end
  end

  describe "POST #bulk upload" do
    before do
      @file = fixture_file_upload('2021_22_lettings_bulk_upload.xlsx', 'application/vnd.ms-excel')
    end

    subject { post url, params: { case_log_bulk_upload: @file } }

    context "given a valid file based on the upload template" do
      it "creates case logs for each row in the template" do
        expect { subject }.to change(CaseLog, :count).by(2)
      end

      it "redirects to the case log index page" do
        expect(subject).to redirect_to(case_logs_path)
      end
    end
  end
end
