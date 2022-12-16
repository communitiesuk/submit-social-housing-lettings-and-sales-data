require "rails_helper"

RSpec.describe BulkUpload::Sales::Validator do
  subject(:validator) { described_class.new(bulk_upload:, path:) }

  let(:bulk_upload) { create(:bulk_upload) }
  let(:path) { file.path }
  let(:file) { Tempfile.new }

  describe "validations" do
    context "when file is empty" do
      it "is not valid" do
        expect(validator).not_to be_valid
      end
    end

    context "when file has too many columns" do
      before do
        file.write((%w[a] * 127).join(","))
        file.rewind
      end

      it "is not valid" do
        expect(validator).not_to be_valid
      end
    end

    context "when incorrect headers"
  end

  context "when a valid csv that contains errors" do
    let(:path) { file_fixture("2022_23_sales_bulk_upload.csv") }

    it "persists bulk upload errors" do
      expect {
        validator.call
      }.to change(BulkUploadError, :count).by(1)
    end
  end
end
