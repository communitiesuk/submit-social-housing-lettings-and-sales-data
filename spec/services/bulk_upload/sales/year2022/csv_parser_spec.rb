require "rails_helper"

RSpec.describe BulkUpload::Sales::Year2022::CsvParser do
  subject(:service) { described_class.new(path:) }

  let(:path) { file_fixture("completed_2022_23_sales_bulk_upload.csv") }

  context "when parsing csv with headers" do
    it "returns correct offsets" do
      expect(service.row_offset).to eq(5)
      expect(service.col_offset).to eq(1)
    end

    it "parses csv correctly" do
      expect(service.row_parsers[0].field_7.to_i).to eq(32)
    end
  end

  context "when parsing csv without headers" do
    let(:file) { Tempfile.new }
    let(:path) { file.path }
    let(:log) { build(:sales_log, :completed) }

    before do
      file.write(BulkUpload::SalesLogToCsv.new(log:, col_offset: 0).to_2022_csv_row)
      file.rewind
    end

    it "returns correct offsets" do
      expect(service.row_offset).to eq(0)
      expect(service.col_offset).to eq(0)
    end

    it "parses csv correctly" do
      expect(service.row_parsers[0].field_7.to_i).to eql(log.age1)
    end
  end

  context "when parsing with BOM aka byte order mark" do
    let(:file) { Tempfile.new }
    let(:path) { file.path }
    let(:log) { build(:sales_log, :completed) }
    let(:bom) { "\uFEFF" }

    before do
      file.write(bom)
      file.write(BulkUpload::SalesLogToCsv.new(log:, col_offset: 0).to_2022_csv_row)
      file.close
    end

    it "parses csv correctly" do
      expect(service.row_parsers[0].field_7.to_i).to eql(log.age1)
    end
  end

  context "when an invalid byte sequence" do
    let(:file) { Tempfile.new }
    let(:path) { file.path }
    let(:log) { build(:sales_log, :completed) }
    let(:invalid_sequence) { "\x81" }

    before do
      file.write(invalid_sequence)
      file.write(BulkUpload::SalesLogToCsv.new(log:, col_offset: 0).to_2022_csv_row)
      file.close
    end

    it "parses csv correctly" do
      expect(service.row_parsers[0].field_7.to_i).to eql(log.age1)
    end
  end

  describe "#column_for_field", aggregate_failures: true do
    context "when headers present" do
      it "returns correct column" do
        expect(service.column_for_field("field_1")).to eql("B")
        expect(service.column_for_field("field_125")).to eql("DV")
      end
    end

    context "when no headers" do
      let(:file) { Tempfile.new }
      let(:path) { file.path }
      let(:log) { build(:sales_log, :completed) }

      before do
        file.write(BulkUpload::SalesLogToCsv.new(log:, col_offset: 0).to_2022_csv_row)
        file.rewind
      end

      it "returns correct column" do
        expect(service.column_for_field("field_1")).to eql("A")
        expect(service.column_for_field("field_125")).to eql("DU")
      end
    end
  end

  context "when parsing csv with carriage returns" do
    let(:file) { Tempfile.new }
    let(:path) { file.path }
    let(:log) { build(:sales_log, :completed) }

    before do
      file.write("Question\r\n")
      file.write("Additional info\r")
      file.write("Values\r\n")
      file.write("Can be empty?\r")
      file.write("Type of letting the question applies to\r\n")
      file.write("Duplicate check field?\r")
      file.write(BulkUpload::SalesLogToCsv.new(log:).to_2022_csv_row)
      file.rewind
    end

    it "parses csv correctly" do
      expect(service.column_for_field("field_1")).to eql("A")
      expect(service.column_for_field("field_125")).to eql("DU")
    end
  end
end
