require "rails_helper"

RSpec.describe BulkUpload::Lettings::CsvParser do
  subject(:service) { described_class.new(path:) }

  let(:path) { file_fixture("2022_23_lettings_bulk_upload.csv") }

  context "when parsing csv with headers" do
    it "returns correct offsets" do
      expect(service.row_offset).to eq(5)
      expect(service.col_offset).to eq(1)
    end

    it "parses csv correctly" do
      expect(service.row_parsers[0].field_12).to eq(55)
    end
  end

  context "when parsing csv without headers" do
    let(:file) { Tempfile.new }
    let(:path) { file.path }
    let(:log) { build(:lettings_log, :completed) }

    before do
      file.write(BulkUpload::LogToCsv.new(log:, col_offset: 0).to_csv_row)
      file.rewind
    end

    it "returns correct offsets" do
      expect(service.row_offset).to eq(0)
      expect(service.col_offset).to eq(0)
    end

    it "parses csv correctly" do
      expect(service.row_parsers[0].field_12).to eql(log.age1)
    end
  end
end
