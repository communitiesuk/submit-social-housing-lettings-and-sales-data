require "rails_helper"

RSpec.describe BulkUpload::Lettings::Year2023::CsvParser do
  subject(:service) { described_class.new(path:) }

  let(:file) { Tempfile.new }
  let(:path) { file.path }
  let(:log) { build(:lettings_log, :completed) }

  context "when parsing csv with headers" do
    before do
      file.write("Question\n")
      file.write("Additional info\n")
      file.write("Values\n")
      file.write("Can be empty?\n")
      file.write("Type of letting the question applies to\n")
      file.write("Duplicate check field?\n")
      file.write(BulkUpload::LogToCsv.new(log:).default_2023_field_numbers_row)
      file.write(BulkUpload::LogToCsv.new(log:).to_2023_csv_row)
      file.rewind
    end

    it "returns correct offsets" do
      expect(service.row_offset).to eq(7)
      expect(service.col_offset).to eq(1)
    end

    it "parses csv correctly" do
      expect(service.row_parsers[0].field_13).to eql(log.tenancycode)
    end
  end

  context "when parsing csv with headers in arbitrary order" do
    let(:seed) { rand }

    before do
      file.write("Question\n")
      file.write("Additional info\n")
      file.write("Values\n")
      file.write("Can be empty?\n")
      file.write("Type of letting the question applies to\n")
      file.write("Duplicate check field?\n")
      file.write(BulkUpload::LogToCsv.new(log:).default_2023_field_numbers_row(seed:))
      file.write(BulkUpload::LogToCsv.new(log:).to_2023_csv_row(seed:))
      file.rewind
    end

    it "returns correct offsets" do
      expect(service.row_offset).to eq(7)
      expect(service.col_offset).to eq(1)
    end

    it "parses csv correctly" do
      expect(service.row_parsers[0].field_13).to eql(log.tenancycode)
    end
  end

  # context "when parsing csv without headers" do
  #   let(:file) { Tempfile.new }
  #   let(:path) { file.path }
  #   let(:log) { build(:lettings_log, :completed) }

  #   before do
  #     file.write(BulkUpload::LogToCsv.new(log:, col_offset: 0).to_2022_csv_row)
  #     file.rewind
  #   end

  #   it "returns correct offsets" do
  #     expect(service.row_offset).to eq(0)
  #     expect(service.col_offset).to eq(0)
  #   end

  #   it "parses csv correctly" do
  #     expect(service.row_parsers[0].field_12.to_i).to eql(log.age1)
  #   end
  # end

  # context "when parsing with BOM aka byte order mark" do
  #   let(:file) { Tempfile.new }
  #   let(:path) { file.path }
  #   let(:log) { build(:lettings_log, :completed) }
  #   let(:bom) { "\uFEFF" }

  #   before do
  #     file.write(bom)
  #     file.write(BulkUpload::LogToCsv.new(log:, col_offset: 0).to_2022_csv_row)
  #     file.close
  #   end

  #   it "parses csv correctly" do
  #     expect(service.row_parsers[0].field_12.to_i).to eql(log.age1)
  #   end
  # end

  # context "when an invalid byte sequence" do
  #   let(:file) { Tempfile.new }
  #   let(:path) { file.path }
  #   let(:log) { build(:lettings_log, :completed) }
  #   let(:invalid_sequence) { "\x81" }

  #   before do
  #     file.write(invalid_sequence)
  #     file.write(BulkUpload::LogToCsv.new(log:, col_offset: 0).to_2022_csv_row)
  #     file.close
  #   end

  #   it "parses csv correctly" do
  #     expect(service.row_parsers[0].field_12.to_i).to eql(log.age1)
  #   end
  # end
end
