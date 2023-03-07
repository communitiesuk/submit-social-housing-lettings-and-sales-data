require "rails_helper"

RSpec.describe BulkUpload::Lettings::Year2022::CsvParser do
  subject(:service) { described_class.new(path:) }

  let(:path) { file_fixture("2022_23_lettings_bulk_upload.csv") }

  context "when parsing csv with headers" do
    it "returns correct offsets" do
      expect(service.row_offset).to eq(5)
      expect(service.col_offset).to eq(1)
    end

    it "parses csv correctly" do
      expect(service.row_parsers[0].field_12.to_i).to eq(55)
    end
  end

  context "when parsing csv without headers" do
    let(:file) { Tempfile.new }
    let(:path) { file.path }
    let(:log) { build(:lettings_log, :completed) }

    before do
      file.write(BulkUpload::LogToCsv.new(log:, col_offset: 0).to_2022_csv_row)
      file.rewind
    end

    it "returns correct offsets" do
      expect(service.row_offset).to eq(0)
      expect(service.col_offset).to eq(0)
    end

    it "parses csv correctly" do
      expect(service.row_parsers[0].field_12.to_i).to eql(log.age1)
    end
  end

  context "when parsing with BOM aka byte order mark" do
    let(:file) { Tempfile.new }
    let(:path) { file.path }
    let(:log) { build(:lettings_log, :completed) }
    let(:bom) { "\uFEFF" }

    before do
      file.write(bom)
      file.write(BulkUpload::LogToCsv.new(log:, col_offset: 0).to_2022_csv_row)
      file.close
    end

    it "parses csv correctly" do
      expect(service.row_parsers[0].field_12.to_i).to eql(log.age1)
    end
  end

  context "when an invalid byte sequence" do
    let(:file) { Tempfile.new }
    let(:path) { file.path }
    let(:log) { build(:lettings_log, :completed) }
    let(:invalid_sequence) { "\x81" }

    before do
      file.write(invalid_sequence)
      file.write(BulkUpload::LogToCsv.new(log:, col_offset: 0).to_2022_csv_row)
      file.close
    end

    it "parses csv correctly" do
      expect(service.row_parsers[0].field_12.to_i).to eql(log.age1)
    end
  end
end
