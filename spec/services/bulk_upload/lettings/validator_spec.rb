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

        error = BulkUploadError.first
        expect(error.row).to eq("7")
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
        file.rewind
      end

      it "creates validation errors" do
        expect { validator.call }.to change(BulkUploadError, :count)
      end
    end
  end

  describe "#should_create_logs?" do
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
  end
end
