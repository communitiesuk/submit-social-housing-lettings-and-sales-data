require "rails_helper"

RSpec.describe BulkUploadLettingsResultsController do
  before do
    sign_in user
  end

  describe "GET #resume /lettings-logs/bulk-upload-results/:ID/resume" do
    let(:user) { create(:user) }
    let(:bulk_upload) { create(:bulk_upload, :lettings, user:) }

    context "when there are no logs left to resolve" do
      render_views

      it "displays copy to user" do

        get :resume, params: { id: bulk_upload.id }

        expect(response.body).to include("There are no more logs that need updating")
      end

      it "resets logs filters" do
        get :resume, params: { id: bulk_upload.id }

        expect(JSON.parse(session["logs_filters"])).to eql({})
      end
    end

    context "when there are logs left to resolve" do
      before do
        create(:lettings_log, :in_progress, bulk_upload:)
      end

      it "clears the year filter" do
        hash = {
          years: ["", "2022"],
        }

        session["logs_filters"] = hash.to_json

        get :resume, params: { id: bulk_upload.id }

        expect(JSON.parse(session["logs_filters"])["years"]).to eql([""])
      end

      it "sets the status filter to in progress" do
        session["logs_filters"] ||= {}.to_json

        get :resume, params: { id: bulk_upload.id }

        expect(JSON.parse(session["logs_filters"])["status"]).to eql(["", "in_progress"])
      end

      it "sets the user filter to all" do
        session["logs_filters"] ||= {}.to_json

        get :resume, params: { id: bulk_upload.id }

        expect(JSON.parse(session["logs_filters"])["user"]).to eql("all")
      end

      it "redirects to logs with bulk upload filter applied" do
        get :resume, params: { id: bulk_upload.id }

        expect(response).to redirect_to("/lettings-logs?bulk_upload_id%5B%5D=#{bulk_upload.id}")
      end
    end
  end
end
