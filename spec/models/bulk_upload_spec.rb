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

  describe "value check clearing" do
    context "with a lettings log bulk upload" do
      let(:value_check_fields) { LettingsLog.columns_hash.keys.select { |column| column.end_with?("_value_check") } }

      it "has the correct number of value checks to be set as confirmed" do
        expect(value_check_fields.count).to eq(BulkUpload::SHARED_VALUE_CHECKS.count + BulkUpload::LETTINGS_VALUE_CHECKS.count)
      end
    end

    context "with a sales log bulk upload" do
      let(:value_check_fields) { SalesLog.columns_hash.keys.select { |column| column.end_with?("_value_check") } }

      it "has the correct number of value checks to be set as confirmed" do
        expect(value_check_fields.count).to eq(BulkUpload::SHARED_VALUE_CHECKS.count + BulkUpload::SALES_VALUE_CHECKS.count)
      end
    end
  end
end
