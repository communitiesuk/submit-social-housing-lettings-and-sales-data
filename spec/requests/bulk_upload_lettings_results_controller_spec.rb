require "rails_helper"

RSpec.describe BulkUploadLettingsResultsController, type: :request do
  let(:user) { create(:user) }
  let(:support_user) { create(:user, :support) }
  let(:bulk_upload) { create(:bulk_upload, :lettings, user:, bulk_upload_errors:) }
  let(:bulk_upload_errors) { create_list(:bulk_upload_error, 2) }
  let(:viewing_user) { user }

  before do
    sign_in viewing_user
  end

  describe "GET /lettings-logs/bulk-upload-results/:ID/summary" do
    it "renders year combo" do
      get "/lettings-logs/bulk-upload-results/#{bulk_upload.id}/summary"

      expect(response).to be_successful
      expect(response.body).to include("Upload lettings logs in bulk (#{bulk_upload.year_combo})")
    end

    it "renders the bulk upload filename" do
      get "/lettings-logs/bulk-upload-results/#{bulk_upload.id}/summary"

      expect(response.body).to include(bulk_upload.filename)
    end

    context "when viewed by support user" do
      before do
        allow(support_user).to receive(:need_two_factor_authentication?).and_return(false)
      end

      let(:viewing_user) { support_user }

      it "is accessible" do
        get "/lettings-logs/bulk-upload-results/#{bulk_upload.id}/summary"

        expect(response).to be_successful
        expect(response.body).to include(bulk_upload.filename)
      end
    end

    context "when viewed by some other random user" do
      let(:other_user) { create(:user) }
      let(:viewing_user) { other_user }

      it "is not accessible" do
        get "/lettings-logs/bulk-upload-results/#{bulk_upload.id}/summary"
        expect(response).to be_unauthorized
      end
    end

    context "when viewed by another user in the same org" do
      let(:other_user) { create(:user, organisation: user.organisation) }
      let(:viewing_user) { other_user }

      it "is accessible" do
        get "/lettings-logs/bulk-upload-results/#{bulk_upload.id}/summary"

        expect(response).to be_successful
        expect(response.body).to include(bulk_upload.filename)
      end

      context "and bulk upload has been cancelled by not the current moved user" do
        let(:bulk_upload) { create(:bulk_upload, :lettings, user:, bulk_upload_errors:, choice: "cancelled-by-moved-user", moved_user_id: user.id) }

        it "is displays a correct banner" do
          get "/lettings-logs/bulk-upload-results/#{bulk_upload.id}/summary"

          expect(response.body).to include("This error report is out of date.")
          expect(CGI.unescapeHTML(response.body)).to include("Some logs in this upload are assigned to #{user.name}, who has moved to a different organisation since this file was uploaded. Upload the file again to get an accurate error report.")
        end
      end

      context "and bulk upload has been cancelled by the current moved user" do
        let(:bulk_upload) { create(:bulk_upload, :lettings, user:, bulk_upload_errors:, choice: "cancelled-by-moved-user", moved_user_id: other_user.id) }

        it "is displays a correct banner" do
          get "/lettings-logs/bulk-upload-results/#{bulk_upload.id}/summary"

          expect(response.body).to include("This error report is out of date.")
          expect(response.body).to include("You moved to a different organisation since this file was uploaded. Upload the file again to get an accurate error report.")
        end
      end
    end
  end

  describe "GET /lettings-logs/bulk-upload-results/:ID" do
    it "renders correct year" do
      get "/lettings-logs/bulk-upload-results/#{bulk_upload.id}"

      expect(response).to be_successful
      expect(response.body).to include("Upload lettings logs in bulk (#{bulk_upload.year_combo})")
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

    context "and bulk upload has been cancelled by not the current moved user" do
      let(:other_user) { create(:user, organisation: user.organisation) }
      let(:bulk_upload) { create(:bulk_upload, :lettings, user:, bulk_upload_errors:, choice: "cancelled-by-moved-user", moved_user_id: other_user.id) }

      it "is displays a correct banner" do
        get "/lettings-logs/bulk-upload-results/#{bulk_upload.id}/summary"

        expect(response.body).to include("This error report is out of date.")
        expect(CGI.unescapeHTML(response.body)).to include("Some logs in this upload are assigned to #{other_user.name}, who has moved to a different organisation since this file was uploaded. Upload the file again to get an accurate error report.")
      end
    end

    context "and bulk upload has been cancelled by the current moved user" do
      let(:bulk_upload) { create(:bulk_upload, :lettings, user:, bulk_upload_errors:, choice: "cancelled-by-moved-user", moved_user_id: user.id) }

      it "is displays a correct banner" do
        get "/lettings-logs/bulk-upload-results/#{bulk_upload.id}/summary"

        expect(response.body).to include("This error report is out of date.")
        expect(response.body).to include("You moved to a different organisation since this file was uploaded. Upload the file again to get an accurate error report.")
      end
    end
  end
end
