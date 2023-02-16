require "rails_helper"

RSpec.describe BulkUpload::Lettings::Validator do
  subject(:validator) { described_class.new(bulk_upload:, path:) }

  let(:organisation) { create(:organisation, old_visible_id: "3") }
  let(:user) { create(:user, organisation:) }
  let(:bulk_upload) { create(:bulk_upload, user:) }
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
        file.write("a," * 136)
        file.write("\n")
        file.rewind
      end

      it "is not valid" do
        expect(validator).not_to be_valid
      end
    end

    context "when incorrect headers"
  end

  describe "#call" do
    context "when a valid csv" do
      let(:path) { file_fixture("2022_23_lettings_bulk_upload.csv") }

      it "creates validation errors" do
        expect { validator.call }.to change(BulkUploadError, :count)
      end

      it "create validation error with correct values" do
        validator.call

        error = BulkUploadError.order(:row, :field).first

        expect(error.field).to eql("field_11")
        expect(error.error).to eql("You must only answer the length of the tenancy if it's fixed-term")
        expect(error.tenant_code).to eql("123")
        expect(error.property_ref).to be_nil
        expect(error.row).to eql("7")
        expect(error.cell).to eql("L7")
        expect(error.col).to eql("L")
      end
    end

    context "with unix line endings" do
      let(:fixture_path) { file_fixture("2022_23_lettings_bulk_upload.csv") }
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
      let(:log) { build(:lettings_log, :completed) }
      let(:file) { Tempfile.new }
      let(:path) { file.path }

      before do
        file.write(BulkUpload::LogToCsv.new(log:, line_ending: "\r\n", col_offset: 0).to_csv_row)
        file.close
      end

      it "creates validation errors" do
        expect { validator.call }.to change(BulkUploadError, :count)
      end
    end
  end

  describe "#create_logs?" do
    context "when all logs are valid" do
      let(:target_path) { file_fixture("2022_23_lettings_bulk_upload.csv") }

      before do
        target_array = File.open(target_path).readlines
        target_array[0..71].each do |line|
          file.write line
        end
        file.rewind
      end

      it "returns truthy" do
        expect(validator).to be_create_logs
      end
    end

    context "when there is an invalid log" do
      let(:path) { file_fixture("2022_23_lettings_bulk_upload.csv") }

      it "returns falsey" do
        expect(validator).not_to be_create_logs
      end
    end

    context "when a log is not valid?" do
      let(:log_1) { build(:lettings_log, :completed, created_by: user) }
      let(:log_2) { build(:lettings_log, :completed, created_by: user) }

      before do
        file.write(BulkUpload::LogToCsv.new(log: log_1, line_ending: "\r\n", col_offset: 0).to_csv_row)
        file.write(BulkUpload::LogToCsv.new(log: log_2, line_ending: "\r\n", col_offset: 0, overrides: { illness: 100 }).to_csv_row)
        file.close
      end

      it "returns false" do
        validator.call
        expect(validator).not_to be_create_logs
      end
    end

    context "when all logs valid?" do
      let(:log_1) { build(:lettings_log, :completed, renttype: 1, created_by: user) }
      let(:log_2) { build(:lettings_log, :completed, renttype: 1, created_by: user) }

      before do
        file.write(BulkUpload::LogToCsv.new(log: log_1, line_ending: "\r\n", col_offset: 0).to_csv_row)
        file.write(BulkUpload::LogToCsv.new(log: log_2, line_ending: "\r\n", col_offset: 0).to_csv_row)
        file.close
      end

      it "returns true" do
        validator.call
        expect(validator).to be_create_logs
      end
    end

    context "when a single log wants to block log creation" do
      let(:unaffiliated_org) { create(:organisation) }

      let(:log_1) { build(:lettings_log, :completed, renttype: 1, created_by: user, owning_organisation: unaffiliated_org) }

      before do
        file.write(BulkUpload::LogToCsv.new(log: log_1, line_ending: "\r\n", col_offset: 0).to_csv_row)
        file.close
      end

      it "will not create logs" do
        validator.call
        expect(validator).not_to be_create_logs
      end
    end

    context "when a log has incomplete setup secion" do
      let(:log) { build(:lettings_log, :in_progress, created_by: user, startdate: Time.zone.local(2022, 5, 1)) }

      before do
        file.write(BulkUpload::LogToCsv.new(log:, line_ending: "\r\n", col_offset: 0).to_csv_row)
        file.close
      end

      it "returns false" do
        validator.call
        expect(validator).not_to be_create_logs
      end
    end

    context "when a column has error rate below absolute threshold" do
      context "when a column is over 60% error threshold" do
        let(:log_1) { build(:lettings_log, :completed, renttype: 1, created_by: user) }
        let(:log_2) { build(:lettings_log, renttype: 2, created_by: user, builtype: nil, startdate: Time.zone.local(2022, 5, 1)) }
        let(:log_3) { build(:lettings_log, renttype: 2, created_by: user, builtype: nil, startdate: Time.zone.local(2022, 5, 1)) }
        let(:log_4) { build(:lettings_log, renttype: 2, created_by: user, builtype: nil, startdate: Time.zone.local(2022, 5, 1)) }
        let(:log_5) { build(:lettings_log, renttype: 2, created_by: user, builtype: nil, startdate: Time.zone.local(2022, 5, 1)) }

        before do
          file.write(BulkUpload::LogToCsv.new(log: log_1, line_ending: "\r\n", col_offset: 0).to_csv_row)
          file.write(BulkUpload::LogToCsv.new(log: log_2, line_ending: "\r\n", col_offset: 0).to_csv_row)
          file.write(BulkUpload::LogToCsv.new(log: log_3, line_ending: "\r\n", col_offset: 0).to_csv_row)
          file.write(BulkUpload::LogToCsv.new(log: log_4, line_ending: "\r\n", col_offset: 0).to_csv_row)
          file.write(BulkUpload::LogToCsv.new(log: log_5, line_ending: "\r\n", col_offset: 0).to_csv_row)
          file.close
        end

        it "returns true" do
          validator.call
          expect(validator).to be_create_logs
        end
      end

      context "when a column is under 60% error threshold" do
        let(:log_1) { build(:lettings_log, :completed, renttype: 1, created_by: user) }
        let(:log_2) { build(:lettings_log, :completed, renttype: 1, created_by: user) }
        let(:log_3) { build(:lettings_log, renttype: 2, created_by: user, builtype: nil, startdate: Time.zone.local(2022, 5, 1)) }
        let(:log_4) { build(:lettings_log, renttype: 2, created_by: user, builtype: nil, startdate: Time.zone.local(2022, 5, 1)) }
        let(:log_5) { build(:lettings_log, renttype: 2, created_by: user, builtype: nil, startdate: Time.zone.local(2022, 5, 1)) }

        before do
          file.write(BulkUpload::LogToCsv.new(log: log_1, line_ending: "\r\n", col_offset: 0).to_csv_row)
          file.write(BulkUpload::LogToCsv.new(log: log_2, line_ending: "\r\n", col_offset: 0).to_csv_row)
          file.write(BulkUpload::LogToCsv.new(log: log_3, line_ending: "\r\n", col_offset: 0).to_csv_row)
          file.write(BulkUpload::LogToCsv.new(log: log_4, line_ending: "\r\n", col_offset: 0).to_csv_row)
          file.write(BulkUpload::LogToCsv.new(log: log_5, line_ending: "\r\n", col_offset: 0).to_csv_row)
          file.close
        end

        it "returns true" do
          validator.call
          expect(validator).to be_create_logs
        end
      end
    end

    context "when a column has error rate above absolute threshold" do
      before do
        stub_const("BulkUpload::Lettings::Validator::COLUMN_ABSOLUTE_ERROR_THRESHOLD", 1)
      end

      context "when a column is over 60% error threshold" do
        let(:log_1) { build(:lettings_log, :completed, renttype: 1, created_by: user) }
        let(:log_2) { build(:lettings_log, renttype: 2, created_by: user, builtype: nil, startdate: Time.zone.local(2022, 5, 1)) }
        let(:log_3) { build(:lettings_log, renttype: 2, created_by: user, builtype: nil, startdate: Time.zone.local(2022, 5, 1)) }
        let(:log_4) { build(:lettings_log, renttype: 2, created_by: user, builtype: nil, startdate: Time.zone.local(2022, 5, 1)) }
        let(:log_5) { build(:lettings_log, renttype: 2, created_by: user, builtype: nil, startdate: Time.zone.local(2022, 5, 1)) }

        before do
          file.write(BulkUpload::LogToCsv.new(log: log_1, line_ending: "\r\n", col_offset: 0).to_csv_row)
          file.write(BulkUpload::LogToCsv.new(log: log_2, line_ending: "\r\n", col_offset: 0).to_csv_row)
          file.write(BulkUpload::LogToCsv.new(log: log_3, line_ending: "\r\n", col_offset: 0).to_csv_row)
          file.write(BulkUpload::LogToCsv.new(log: log_4, line_ending: "\r\n", col_offset: 0).to_csv_row)
          file.write(BulkUpload::LogToCsv.new(log: log_5, line_ending: "\r\n", col_offset: 0).to_csv_row)
          file.close
        end

        it "returns false" do
          validator.call
          expect(validator).not_to be_create_logs
        end
      end

      context "when a column is under 60% error threshold" do
        let(:log_1) { build(:lettings_log, :completed, renttype: 1, created_by: user) }
        let(:log_2) { build(:lettings_log, :completed, renttype: 1, created_by: user) }
        let(:log_3) { build(:lettings_log, renttype: 2, created_by: user, builtype: nil, startdate: Time.zone.local(2022, 5, 1)) }
        let(:log_4) { build(:lettings_log, renttype: 2, created_by: user, builtype: nil, startdate: Time.zone.local(2022, 5, 1)) }
        let(:log_5) { build(:lettings_log, renttype: 2, created_by: user, builtype: nil, startdate: Time.zone.local(2022, 5, 1)) }

        before do
          file.write(BulkUpload::LogToCsv.new(log: log_1, line_ending: "\r\n", col_offset: 0).to_csv_row)
          file.write(BulkUpload::LogToCsv.new(log: log_2, line_ending: "\r\n", col_offset: 0).to_csv_row)
          file.write(BulkUpload::LogToCsv.new(log: log_3, line_ending: "\r\n", col_offset: 0).to_csv_row)
          file.write(BulkUpload::LogToCsv.new(log: log_4, line_ending: "\r\n", col_offset: 0).to_csv_row)
          file.write(BulkUpload::LogToCsv.new(log: log_5, line_ending: "\r\n", col_offset: 0).to_csv_row)
          file.close
        end

        it "returns true" do
          validator.call
          expect(validator).to be_create_logs
        end
      end
    end
  end
end
