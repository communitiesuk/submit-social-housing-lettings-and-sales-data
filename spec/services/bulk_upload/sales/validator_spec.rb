require "rails_helper"

RSpec.describe BulkUpload::Sales::Validator do
  subject(:validator) { described_class.new(bulk_upload:, path:) }

  let(:user) { create(:user, organisation:) }
  let(:organisation) { create(:organisation, old_visible_id: "123") }
  let(:bulk_upload) { create(:bulk_upload, user:) }
  let(:path) { file.path }
  let(:file) { Tempfile.new }

  describe "validations" do
    context "when file is empty" do
      it "is not valid" do
        expect(validator).not_to be_valid
        expect(validator.errors["base"]).to eql(["Template is blank - The template must be filled in for us to create the logs and check if data is correct."])
      end
    end

    context "and has a new line in it (empty)" do
      before do
        file.write("\n")
        file.rewind
      end

      it "is not valid" do
        expect(validator).not_to be_valid
        expect(validator.errors["base"]).to eql(["Template is blank - The template must be filled in for us to create the logs and check if data is correct."])
      end
    end

    context "when file has too many columns" do
      before do
        file.write((%w[a] * (BulkUpload::Sales::Year2023::CsvParser::MAX_COLUMNS + 1)).join(","))
        file.rewind
      end

      it "is not valid" do
        expect(validator).not_to be_valid
      end
    end

    context "when trying to upload different year data for 2024 bulk upload" do
      let(:bulk_upload) { create(:bulk_upload, user:, year: 2024) }

      context "with a valid csv" do
        let(:path) { file_fixture("2022_23_sales_bulk_upload.csv") }

        it "is not valid" do
          expect(validator).not_to be_valid
        end
      end

      context "with unix line endings" do
        let(:fixture_path) { file_fixture("2022_23_sales_bulk_upload.csv") }
        let(:file) { Tempfile.new }
        let(:path) { file.path }

        before do
          string = File.read(fixture_path)
          string.gsub!("\r\n", "\n")
          file.write(string)
          file.rewind
        end

        it "is not valid" do
          expect(validator).not_to be_valid
        end
      end

      context "without headers" do
        let(:log) { build(:sales_log, :completed) }
        let(:file) { Tempfile.new }
        let(:path) { file.path }

        before do
          Timecop.freeze(Time.utc(2023, 10, 3))
          file.write(BulkUpload::SalesLogToCsv.new(log:, line_ending: "\r\n", col_offset: 0).to_2024_csv_row)
          file.close
        end

        after do
          Timecop.unfreeze
        end

        it "is not valid" do
          expect(validator).not_to be_valid
        end
      end

      context "with headers" do
        let(:file) { Tempfile.new }
        let(:seed) { rand }
        let(:log) { build(:sales_log, :completed, saledate: Time.zone.local(2023, 10, 10)) }
        let(:log_to_csv) { BulkUpload::SalesLogToCsv.new(log:) }
        let(:field_numbers) { log_to_csv.default_2024_field_numbers }
        let(:field_values) { log_to_csv.to_2024_row }

        before do
          file.write(log_to_csv.custom_field_numbers_row(seed:, field_numbers:))
          file.write(log_to_csv.to_custom_csv_row(seed:, field_values:))
          file.rewind
        end

        it "is not valid" do
          expect(validator).not_to be_valid
        end
      end
    end

    context "when trying to upload 2024 year data for 2024 bulk upload" do
      let(:bulk_upload) { create(:bulk_upload, user:, year: 2024) }

      context "with headers" do
        let(:file) { Tempfile.new }
        let(:seed) { rand }
        let(:log) { build(:sales_log, :completed, saledate: Time.zone.local(2024, 10, 10)) }
        let(:log_to_csv) { BulkUpload::SalesLogToCsv.new(log:) }
        let(:field_numbers) { log_to_csv.default_2024_field_numbers }
        let(:field_values) { log_to_csv.to_2024_row }

        before do
          file.write(log_to_csv.custom_field_numbers_row(seed:, field_numbers:))
          file.write(log_to_csv.to_custom_csv_row(seed:, field_values:))
          file.rewind
        end

        it "is valid" do
          expect(validator).to be_valid
        end
      end
    end

    context "when trying to upload different years data for 2023 bulk upload" do
      let(:bulk_upload) { create(:bulk_upload, user:, year: 2023) }

      context "with a valid csv" do
        let(:path) { file_fixture("2022_23_sales_bulk_upload.csv") }

        it "is not valid" do
          expect(validator).not_to be_valid
        end
      end

      context "with unix line endings" do
        let(:fixture_path) { file_fixture("2022_23_sales_bulk_upload.csv") }
        let(:file) { Tempfile.new }
        let(:path) { file.path }

        before do
          string = File.read(fixture_path)
          string.gsub!("\r\n", "\n")
          file.write(string)
          file.rewind
        end

        it "is not valid" do
          expect(validator).not_to be_valid
        end
      end

      context "without headers" do
        let(:log) { build(:sales_log, :completed) }
        let(:file) { Tempfile.new }
        let(:path) { file.path }

        before do
          Timecop.freeze(Time.utc(2022, 10, 3))
          file.write(BulkUpload::SalesLogToCsv.new(log:, line_ending: "\r\n", col_offset: 0).to_2023_csv_row)
          file.close
        end

        after do
          Timecop.unfreeze
        end

        it "is not valid" do
          expect(validator).not_to be_valid
        end
      end

      context "with headers" do
        let(:file) { Tempfile.new }
        let(:seed) { rand }
        let(:log) { build(:sales_log, :completed, saledate: Time.zone.local(2022, 10, 10)) }
        let(:log_to_csv) { BulkUpload::SalesLogToCsv.new(log:) }
        let(:field_numbers) { log_to_csv.default_2023_field_numbers }
        let(:field_values) { log_to_csv.to_2023_row }

        before do
          file.write(log_to_csv.custom_field_numbers_row(seed:, field_numbers:))
          file.write(log_to_csv.to_custom_csv_row(seed:, field_values:))
          file.rewind
        end

        it "is not valid" do
          expect(validator).not_to be_valid
        end
      end
    end

    context "when file is missing required headers" do
      let(:bulk_upload) { create(:bulk_upload, user:, year: 2024) }
      let(:log) { build(:sales_log, :completed, saledate: Time.zone.local(2024, 5, 5)) }
      let(:file) { Tempfile.new }
      let(:path) { file.path }

      before do
        file.write(BulkUpload::SalesLogToCsv.new(log:, line_ending: "\r\n", col_offset: 0).to_2024_csv_row)
        file.close
      end

      it "is not valid" do
        expect(validator).not_to be_valid
      end
    end
  end

  describe "#call" do
    context "when a valid csv" do
      let(:path) { file_fixture("2023_24_sales_bulk_upload_invalid.csv") }

      it "creates validation errors" do
        expect { validator.call }.to change(BulkUploadError, :count)
      end

      it "create validation error with correct values" do
        validator.call

        error = BulkUploadError.find_by(row: "9", field: "field_1", category: "setup")

        expect(error.field).to eql("field_1")
        expect(error.error).to eql("You must answer owning organisation")
        expect(error.purchaser_code).to eql("23 test BU")
        expect(error.row).to eql("9")
        expect(error.cell).to eql("B9")
        expect(error.col).to eql("B")
      end
    end

    context "with unix line endings" do
      let(:fixture_path) { file_fixture("2023_24_sales_bulk_upload.csv") }
      let(:file) { Tempfile.new }
      let(:path) { file.path }

      before do
        string = File.read(fixture_path)
        string.gsub!("\r\n", "\n")
        file.write(string)
        file.rewind
      end

      it "creates validation errors" do
        expect { validator.call }.to change(BulkUploadError, :count)
      end
    end

    context "without headers" do
      let(:log) { build(:sales_log, :completed) }
      let(:file) { Tempfile.new }
      let(:path) { file.path }

      before do
        file.write(BulkUpload::SalesLogToCsv.new(log:, line_ending: "\r\n", col_offset: 0).to_2023_csv_row)
        file.close
      end

      it "creates validation errors" do
        expect { validator.call }.to change(BulkUploadError, :count)
      end
    end

    context "when duplicate rows present" do
      let(:file) { Tempfile.new }
      let(:path) { file.path }
      let(:log) { build(:sales_log, :completed) }

      before do
        file.write(BulkUpload::SalesLogToCsv.new(log:, col_offset: 0).to_2023_csv_row)
        file.write(BulkUpload::SalesLogToCsv.new(log:, col_offset: 0).to_2023_csv_row)
        file.close
      end

      it "creates errors" do
        expect { validator.call }.to change(BulkUploadError.where(category: :setup, error: "This is a duplicate of a log in your file"), :count).by(20)
      end
    end
  end

  describe "#create_logs?" do
    around do |example|
      Timecop.freeze(Time.zone.local(2023, 10, 22)) do
        Singleton.__init__(FormHandler)
        example.run
      end
      Timecop.return
      Singleton.__init__(FormHandler)
    end

    context "when all logs are valid" do
      let(:target_path) { file_fixture("2023_24_sales_bulk_upload.csv") }

      it "returns truthy" do
        validator.call
        expect(validator).to be_create_logs
      end
    end

    context "when there is an invalid log" do
      let(:path) { file_fixture("2023_24_sales_bulk_upload_invalid.csv") }

      it "returns falsey" do
        validator.call
        expect(validator).not_to be_create_logs
      end
    end

    context "when a log is not valid?" do
      let(:log_1) { build(:sales_log, :completed, assigned_to: user) }
      let(:log_2) { build(:sales_log, :completed, assigned_to: user) }

      before do
        file.write(BulkUpload::SalesLogToCsv.new(log: log_1, line_ending: "\r\n", col_offset: 0).to_2023_csv_row)
        file.write(BulkUpload::SalesLogToCsv.new(log: log_2, line_ending: "\r\n", col_offset: 0, overrides: { organisation_id: "random" }).to_2023_csv_row)
        file.close
      end

      it "returns false" do
        validator.call
        expect(validator).not_to be_create_logs
      end
    end

    context "when all logs valid?" do
      let(:path) { file_fixture("2023_24_sales_bulk_upload.csv") }

      it "returns true" do
        validator.call
        expect(validator).to be_create_logs
      end
    end

    context "when a single log wants to block log creation" do
      let(:unaffiliated_org) { create(:organisation) }

      let(:log_1) { build(:sales_log, :completed, assigned_to: user, owning_organisation: unaffiliated_org) }

      before do
        file.write(BulkUpload::SalesLogToCsv.new(log: log_1, line_ending: "\r\n", col_offset: 0).to_2023_csv_row)
        file.close
      end

      it "will not create logs" do
        validator.call
        expect(validator).not_to be_create_logs
      end
    end

    context "when a log has incomplete setup secion" do
      let(:log) { build(:sales_log, assigned_to: user, saledate: Time.zone.local(2022, 5, 1)) }

      before do
        file.write(BulkUpload::SalesLogToCsv.new(log:, line_ending: "\r\n", col_offset: 0).to_2023_csv_row)
        file.close
      end

      it "returns false" do
        validator.call
        expect(validator).not_to be_create_logs
      end
    end
  end

  describe "#total_logs_count?" do
    around do |example|
      Timecop.freeze(Time.zone.local(2023, 10, 22)) do
        Singleton.__init__(FormHandler)
        example.run
      end
      Timecop.return
      Singleton.__init__(FormHandler)
    end

    context "when all logs are valid" do
      let(:target_path) { file_fixture("2023_24_sales_bulk_upload.csv") }

      before do
        target_array = File.open(target_path).readlines
        target_array[0..118].each do |line|
          file.write line
        end
        file.rewind
      end

      it "returns correct total logs count" do
        expect(validator.total_logs_count).to be(1)
      end
    end
  end
end
