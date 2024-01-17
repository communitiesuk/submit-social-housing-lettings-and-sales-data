require "rails_helper"

RSpec.describe LogsHelper, type: :helper do
  describe "#unique_answers_to_be_cleared" do
    let(:result) { unique_answers_to_be_cleared(bulk_upload) }

    context "with a lettings bulk upload with various errors" do
      let(:bulk_upload) { create(:bulk_upload, :lettings) }

      before do
        errors = [OpenStruct.new(attribute: "field_50", message: "you must answer field 50", category: :not_answered),
                  OpenStruct.new(attribute: "field_60", message: "some compound error", category: :other_category),
                  OpenStruct.new(attribute: "field_61", message: "some compound error", category: :other_category),
                  OpenStruct.new(attribute: "field_61", message: "some other compound error that overlaps with a previous error field", category: :another_category),
                  OpenStruct.new(attribute: "field_62", message: "some other compound error that overlaps with a previous error field", category: :another_category)]
        errors.each do |error|
          bulk_upload.bulk_upload_errors.create!(
            field: error.attribute,
            error: error.message,
            tenant_code: "test",
            property_ref: "test",
            row: "test",
            cell: "test",
            col: "test",
            category: error.category,
          )
        end
      end

      it "returns the correct unique answers to be cleared" do
        expect(result.count).to eq(3)
        expect(result.map(&:field)).to match_array(%w[field_60 field_61 field_62])
      end
    end

    context "with a sales bulk upload with various errors" do
      let(:bulk_upload) { create(:bulk_upload, :sales) }

      before do
        errors = [OpenStruct.new(attribute: "field_50", message: "you must answer field 50", category: :not_answered),
                  OpenStruct.new(attribute: "field_60", message: "some compound error", category: :other_category),
                  OpenStruct.new(attribute: "field_61", message: "some compound error", category: :other_category),
                  OpenStruct.new(attribute: "field_61", message: "some other compound error that overlaps with a previous error field", category: :another_category),
                  OpenStruct.new(attribute: "field_62", message: "some other compound error that overlaps with a previous error field", category: :another_category)]
        errors.each do |error|
          bulk_upload.bulk_upload_errors.create!(
            field: error.attribute,
            error: error.message,
            purchaser_code: "test",
            row: "test",
            cell: "test",
            col: "test",
            category: error.category,
          )
        end
      end

      it "returns the correct unique answers to be cleared" do
        expect(result.count).to eq(3)
        expect(result.map(&:field)).to match_array(%w[field_60 field_61 field_62])
      end
    end
  end
end
