require "rails_helper"

RSpec.describe LettingsLogsController do
  before do
    sign_in bulk_upload.user
  end

  describe "#index" do
    context "when a sales bulk upload filter is applied" do
      let(:bulk_upload) { create(:bulk_upload, :sales) }

      it "does not redirect to resume path" do
        session[:logs_filters] = { bulk_upload_id: [bulk_upload.id.to_s] }.to_json

        get :index

        expect(response).to be_successful
      end
    end
  end
end
