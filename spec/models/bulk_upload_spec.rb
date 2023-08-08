require "rails_helper"

RSpec.describe BulkUpload, type: :model do
let(:bulk_upload) { create(:bulk_upload, log_type: "lettings") }

describe "completed?" do
  context "when the fixed-choice has not been selected" do
    it "returns false" do
    end
  end

  context "when there are incomplete logs" do
    let!(:lettings_log) { create_list(:lettings_log, 2,:in_progress, bulk_upload:) }

    it "returns false" do
      expect(bulk_upload.completed?).to equal(false)
    end
  end

  context "when there are no incomplete logs" do
    let!(:lettings_log) { create_list(:lettings_log, 2, :completed, bulk_upload:) }

    it "returns true" do
      expect(bulk_upload.completed?).to equal(true)
    end
  end

end
end
