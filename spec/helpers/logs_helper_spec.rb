require "rails_helper"

RSpec.describe LogsHelper, type: :helper do
  describe "#unique_answers_to_be_cleared" do
    let(:result) { unique_answers_to_be_cleared(bulk_upload) }

    context "with a lettings bulk upload with various errors" do
      let(:bulk_upload) { create(:bulk_upload, :lettings) }

      context "with one row" do
        before do
          errors = [OpenStruct.new(attribute: "field_50", message: "you must answer field 50", category: :not_answered),
                    OpenStruct.new(attribute: "field_60", message: "some compound error", category: :other_category),
                    OpenStruct.new(attribute: "field_61", message: "some compound error", category: :other_category),
                    OpenStruct.new(attribute: "field_61", message: "some other compound error that overlaps with a previous error field", category: :another_category),
                    OpenStruct.new(attribute: "field_62", message: "some other compound error that overlaps with a previous error field", category: :another_category),
                    OpenStruct.new(attribute: "field_63", message: "some soft validation error", category: :soft_validation)]
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

      context "with multiple rows" do
        before do
          errors = [OpenStruct.new(attribute: "field_50", message: "you must answer field 50", category: :not_answered, row: 1),
                    OpenStruct.new(attribute: "field_60", message: "some compound error", category: :other_category, row: 1),
                    OpenStruct.new(attribute: "field_61", message: "some compound error", category: :other_category, row: 1),
                    OpenStruct.new(attribute: "field_61", message: "some other compound error that overlaps with a previous error field", category: :another_category, row: 1),
                    OpenStruct.new(attribute: "field_62", message: "some other compound error that overlaps with a previous error field", category: :another_category, row: 1),
                    OpenStruct.new(attribute: "field_63", message: "some soft validation error", category: :soft_validation, row: 1),
                    OpenStruct.new(attribute: "field_50", message: "you must answer field 50", category: :not_answered, row: 2),
                    OpenStruct.new(attribute: "field_60", message: "some compound error", category: :other_category, row: 2),
                    OpenStruct.new(attribute: "field_61", message: "some compound error", category: :other_category, row: 2),
                    OpenStruct.new(attribute: "field_61", message: "some other compound error that overlaps with a previous error field", category: :another_category, row: 2),
                    OpenStruct.new(attribute: "field_62", message: "some other compound error that overlaps with a previous error field", category: :another_category, row: 2),
                    OpenStruct.new(attribute: "field_63", message: "some soft validation error", category: :soft_validation, row: 2)]
          errors.each do |error|
            bulk_upload.bulk_upload_errors.create!(
              field: error.attribute,
              error: error.message,
              tenant_code: "test",
              property_ref: "test",
              row: error.row,
              cell: "test",
              col: "test",
              category: error.category,
            )
          end
        end

        it "returns the correct unique answers to be cleared" do
          expect(result.count).to eq(6)
          expect(result.map(&:field)).to match_array(%w[field_60 field_61 field_62 field_60 field_61 field_62])
        end
      end
    end

    context "with a sales bulk upload with various errors" do
      let(:bulk_upload) { create(:bulk_upload, :sales) }

      context "with one row" do
        before do
          errors = [OpenStruct.new(attribute: "field_50", message: "you must answer field 50", category: :not_answered),
                    OpenStruct.new(attribute: "field_60", message: "some compound error", category: :other_category),
                    OpenStruct.new(attribute: "field_61", message: "some compound error", category: :other_category),
                    OpenStruct.new(attribute: "field_61", message: "some other compound error that overlaps with a previous error field", category: :another_category),
                    OpenStruct.new(attribute: "field_62", message: "some other compound error that overlaps with a previous error field", category: :another_category),
                    OpenStruct.new(attribute: "field_63", message: "some soft validation error", category: :soft_validation)]
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

      context "with multiple rows" do
        before do
          errors = [OpenStruct.new(attribute: "field_50", message: "you must answer field 50", category: :not_answered, row: 1),
                    OpenStruct.new(attribute: "field_60", message: "some compound error", category: :other_category, row: 1),
                    OpenStruct.new(attribute: "field_61", message: "some compound error", category: :other_category, row: 1),
                    OpenStruct.new(attribute: "field_61", message: "some other compound error that overlaps with a previous error field", category: :another_category, row: 1),
                    OpenStruct.new(attribute: "field_62", message: "some other compound error that overlaps with a previous error field", category: :another_category, row: 1),
                    OpenStruct.new(attribute: "field_63", message: "some soft validation error", category: :soft_validation, row: 1),
                    OpenStruct.new(attribute: "field_50", message: "you must answer field 50", category: :not_answered, row: 2),
                    OpenStruct.new(attribute: "field_60", message: "some compound error", category: :other_category, row: 2),
                    OpenStruct.new(attribute: "field_61", message: "some compound error", category: :other_category, row: 2),
                    OpenStruct.new(attribute: "field_61", message: "some other compound error that overlaps with a previous error field", category: :another_category, row: 2),
                    OpenStruct.new(attribute: "field_62", message: "some other compound error that overlaps with a previous error field", category: :another_category, row: 2),
                    OpenStruct.new(attribute: "field_63", message: "some soft validation error", category: :soft_validation, row: 2)]
          errors.each do |error|
            bulk_upload.bulk_upload_errors.create!(
              field: error.attribute,
              error: error.message,
              tenant_code: "test",
              property_ref: "test",
              row: error.row,
              cell: "test",
              col: "test",
              category: error.category,
              )
          end
        end

        it "returns the correct unique answers to be cleared" do
          expect(result.count).to eq(6)
          expect(result.map(&:field)).to match_array(%w[field_60 field_61 field_62 field_60 field_61 field_62])
        end
      end
    end
  end
end
