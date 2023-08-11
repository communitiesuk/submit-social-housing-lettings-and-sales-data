require "rails_helper"

RSpec.describe BulkUpload, type: :model do
  let(:bulk_upload) { create(:bulk_upload, log_type: "lettings") }

  describe "def bulk_upload.completed?" do
    context "when there are incomplete logs" do
      it "returns false" do
        create_list(:lettings_log, 2, :in_progress, bulk_upload:)
        expect(bulk_upload.completed?).to equal(false)
      end
    end

    context "when there are no incomplete logs" do
      it "returns true" do
        create_list(:lettings_log, 2, :completed, bulk_upload:)
        expect(bulk_upload.completed?).to equal(true)
      end
    end
  end
end
