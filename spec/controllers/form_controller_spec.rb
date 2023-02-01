require "rails_helper"

RSpec.describe FormController do
  before do
    sign_in user
  end

  describe "GET #check_answers /lettings-logs/:ID/:SECTION_ID/check-answers" do
    let(:user) { create(:user) }
    let(:bulk_upload) { create(:bulk_upload, :lettings, user:) }
    let(:log) { create(:lettings_log, bulk_upload:) }

    context "when checking answers without bulk upload " do
      it "assigns @bulk_upload to nil" do
        get :check_answers, params: { lettings_log_id: log.id }

        expect(assigns(:bulk_upload)).to be_nil
      end
    end

    context "when checking answers with bulk upload " do
      it "assigns @bulk_upload" do
        session[:logs_filters] = { bulk_upload_id: [bulk_upload.id.to_s] }.to_json

        get :check_answers, params: { lettings_log_id: log.id }

        expect(assigns(:bulk_upload)).to eql(bulk_upload)
      end
    end
  end
end
