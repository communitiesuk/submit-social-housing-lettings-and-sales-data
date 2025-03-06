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
      file.write(BulkUpload::LettingsLogToCsv.new(log:).default_field_numbers_row_for_year(2023))
      file.write(BulkUpload::LettingsLogToCsv.new(log:).to_year_csv_row(2023))
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

  context "when parsing csv with headers with extra rows" do
    before do
      file.write("Section\n")
      file.write("Question\n")
      file.write("Additional info\n")
      file.write("Values\n")
      file.write("Can be empty?\n")
      file.write("Type of letting the question applies to\n")
      file.write("Duplicate check field?\n")
      file.write(BulkUpload::LettingsLogToCsv.new(log:).default_field_numbers_row_for_year(2023))
      file.write(BulkUpload::LettingsLogToCsv.new(log:).to_year_csv_row(2023))
      file.rewind
    end

    it "returns correct offsets" do
      expect(service.row_offset).to eq(8)
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
      file.write(BulkUpload::LettingsLogToCsv.new(log:).default_field_numbers_row_for_year(2023, seed:))
      file.write(BulkUpload::LettingsLogToCsv.new(log:).to_year_csv_row(2023, seed:))
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

  context "when parsing csv with extra invalid headers" do
    let(:seed) { rand }
    let(:log_to_csv) { BulkUpload::LettingsLogToCsv.new(log:) }
    let(:field_numbers) { log_to_csv.default_2023_field_numbers + %w[invalid_field_number] }
    let(:field_values) { log_to_csv.to_2023_row + %w[value_for_invalid_field_number] }

    before do
      file.write("Question\n")
      file.write("Additional info\n")
      file.write("Values\n")
      file.write("Can be empty?\n")
      file.write("Type of letting the question applies to\n")
      file.write("Duplicate check field?\n")
      file.write(log_to_csv.custom_field_numbers_row(seed:, field_numbers:))
      file.write(log_to_csv.to_custom_csv_row(seed:, field_values:))
      file.rewind
    end

    it "parses csv correctly" do
      expect(service.row_parsers[0].field_13).to eql(log.tenancycode)
    end

    it "counts the number of valid field numbers correctly" do
      expect(service).to be_correct_field_count
    end
  end

  context "when parsing csv without headers" do
    before do
      file.write(BulkUpload::LettingsLogToCsv.new(log:, col_offset: 0).to_year_csv_row(2023))
      file.rewind
    end

    it "returns correct offsets" do
      expect(service.row_offset).to eq(0)
      expect(service.col_offset).to eq(0)
    end

    it "parses csv correctly" do
      expect(service.row_parsers[0].field_13).to eql(log.tenancycode)
    end
  end

  context "when parsing with BOM aka byte order mark" do
    let(:bom) { "\uFEFF" }

    before do
      file.write(bom)
      file.write(BulkUpload::LettingsLogToCsv.new(log:, col_offset: 0).to_year_csv_row(2023))
      file.rewind
    end

    it "parses csv correctly" do
      expect(service.row_parsers[0].field_13).to eql(log.tenancycode)
    end
  end

  context "when an invalid byte sequence" do
    let(:invalid_sequence) { "\x81" }

    before do
      file.write(invalid_sequence)
      file.write(BulkUpload::LettingsLogToCsv.new(log:, col_offset: 0).to_year_csv_row(2023))
      file.rewind
    end

    it "parses csv correctly" do
      expect(service.row_parsers[0].field_13).to eql(log.tenancycode)
    end
  end

  context "when parsing csv with carriage returns" do
    before do
      file.write("Question\r\n")
      file.write("Additional info\r")
      file.write("Values\r\n")
      file.write("Can be empty?\r")
      file.write("Type of letting the question applies to\r\n")
      file.write("Duplicate check field?\r")
      file.write(BulkUpload::LettingsLogToCsv.new(log:).default_field_numbers_row_for_year(2023))
      file.write(BulkUpload::LettingsLogToCsv.new(log:).to_year_csv_row(2023))
      file.rewind
    end

    it "parses csv correctly" do
      expect(service.row_parsers[0].field_13).to eql(log.tenancycode)
    end
  end

  describe "#column_for_field", aggregate_failures: true do
    context "when with headers using default ordering" do
      before do
        file.write("Question\n")
        file.write("Additional info\n")
        file.write("Values\n")
        file.write("Can be empty?\n")
        file.write("Type of letting the question applies to\n")
        file.write("Duplicate check field?\n")
        file.write(BulkUpload::LettingsLogToCsv.new(log:).default_field_numbers_row_for_year(2023))
        file.write(BulkUpload::LettingsLogToCsv.new(log:).to_year_csv_row(2023))
        file.rewind
      end

      it "returns correct column" do
        expect(service.column_for_field("field_5")).to eql("B")
        expect(service.column_for_field("field_22")).to eql("EL")
      end
    end

    context "when without headers using default ordering" do
      before do
        file.write(BulkUpload::LettingsLogToCsv.new(log:, col_offset: 0).to_year_csv_row(2023))
        file.rewind
      end

      it "returns correct column" do
        expect(service.column_for_field("field_5")).to eql("A")
        expect(service.column_for_field("field_22")).to eql("EK")
      end
    end

    context "when with headers using custom ordering" do
      let(:seed) { 123 }

      before do
        file.write("Question\n")
        file.write("Additional info\n")
        file.write("Values\n")
        file.write("Can be empty?\n")
        file.write("Type of letting the question applies to\n")
        file.write("Duplicate check field?\n")
        file.write(BulkUpload::LettingsLogToCsv.new(log:).default_field_numbers_row_for_year(2023, seed:))
        file.write(BulkUpload::LettingsLogToCsv.new(log:).to_year_csv_row(2023, seed:))
        file.rewind
      end

      it "returns correct column" do
        expect(service.column_for_field("field_5")).to eql("N")
        expect(service.column_for_field("field_22")).to eql("O")
        expect(service.column_for_field("field_26")).to eql("B")
        expect(service.column_for_field("field_25")).to eql("EF")
      end
    end
  end
end
