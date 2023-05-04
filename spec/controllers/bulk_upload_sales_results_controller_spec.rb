require "rails_helper"

RSpec.describe BulkUploadSalesResultsController do
  before do
    sign_in user
  end

  describe "#show" do
    let(:user) { create(:user) }
    let(:bulk_upload) { create(:bulk_upload, :sales, user:) }

    it "passes thru pundit" do
      allow(controller).to receive(:authorize)

      get :show, params: { id: bulk_upload.id }

      expect(controller).to have_received(:authorize)
    end
  end

  describe "#summary" do
    let(:user) { create(:user) }
    let(:bulk_upload) { create(:bulk_upload, :sales, user:) }

    it "passes thru pundit" do
      allow(controller).to receive(:authorize)

      get :summary, params: { id: bulk_upload.id }

      expect(controller).to have_received(:authorize)
    end
  end
end
