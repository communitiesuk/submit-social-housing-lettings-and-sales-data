require "rails_helper"

RSpec.describe BulkUploadController, type: :request do
  let(:url) { "/logs/bulk-upload" }
  let(:user) { FactoryBot.create(:user) }
  let(:organisation) { user.organisation }

  before do
    allow(Organisation).to receive(:find).with(107_242).and_return(organisation)
  end

  context "a not signed in user" do
    describe "GET #show" do
      it "does not let you see the bulk upload page" do
        get url, headers: headers, params: {}
        expect(response).to redirect_to("/users/sign-in")
      end
    end

    describe "POST #bulk upload" do
      before do
        @file = fixture_file_upload("2021_22_lettings_bulk_upload.xlsx", "application/vnd.ms-excel")
      end

      it "does not let you submit bulk uploads" do
        post url, params: { bulk_upload: { case_log_bulk_upload: @file } }
        expect(response).to redirect_to("/users/sign-in")
      end
    end
  end

  context "a signed in user" do
    before do
      sign_in user
    end

    describe "GET #show" do
      before do
        get url, params: {}
      end

      it "returns a success response" do
        expect(response).to be_successful
      end

      it "returns a page with a file upload form" do
        expect(response.body).to match(/<input id="bulk-upload-case-log-bulk-upload-field" class="govuk-file-upload"/)
        expect(response.body).to match(/<button type="submit" formnovalidate="formnovalidate" class="govuk-button"/)
      end
    end

    describe "POST #bulk upload" do
      subject { post url, params: { bulk_upload: { case_log_bulk_upload: @file } } }

      context "given a valid file based on the upload template" do
        before do
          @file = fixture_file_upload("2021_22_lettings_bulk_upload.xlsx", "application/vnd.ms-excel")
        end

        it "creates case logs for each row in the template" do
          expect { subject }.to change(CaseLog, :count).by(9)
        end

        it "redirects to the case log index page" do
          expect(subject).to redirect_to(case_logs_path)
        end
      end

      context "given an invalid file type" do
        before do
          @file = fixture_file_upload("random.txt", "text/plain")
          subject
        end

        it "displays an error message" do
          expect(response.body).to match(/Invalid file type/)
        end
      end

      context "given an empty file" do
        before do
          @file = fixture_file_upload("2021_22_lettings_bulk_upload_empty.xlsx", "application/vnd.ms-excel")
          subject
        end

        it "displays an error message" do
          expect(response.body).to match(/No data found/)
        end
      end
    end
  end
end
