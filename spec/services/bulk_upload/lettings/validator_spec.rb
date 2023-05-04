require "rails_helper"

RSpec.describe BulkUpload::Lettings::Validator do
  subject(:validator) { described_class.new(bulk_upload:, path:) }

  let(:organisation) { create(:organisation, old_visible_id: "3") }
  let(:user) { create(:user, organisation:) }
  let(:log) { build(:lettings_log, :completed) }
  let(:bulk_upload) { create(:bulk_upload, user:) }
  let(:path) { file.path }
  let(:file) { Tempfile.new }

  describe "validations" do
    context "when file is empty" do
      it "is not valid" do
        expect(validator).not_to be_valid
      end
    end

    context "when 2022" do
      let(:bulk_upload) { create(:bulk_upload, user:, year: 2022) }

      context "when file has no headers" do
        context "and too many columns" do
          before do
            file.write(("a" * 136).chars.join(","))
            file.write("\n")
            file.rewind
          end

          it "is not valid" do
            expect(validator).not_to be_valid
            expect(validator.errors["base"]).to eql(["too many columns, please ensure you have used the correct template"])
          end
        end

        context "and doesn't have too many columns" do
          before do
            file.write(("a" * 135).chars.join(","))
            file.write("\n")
            file.rewind
          end

          it "is valid" do
            expect(validator).to be_valid
          end
        end
      end

      context "when file has headers" do
        context "and file has extra invalid headers" do
          let(:seed) { rand }
          let(:log_to_csv) { BulkUpload::LettingsLogToCsv.new(log:) }
          let(:field_numbers) { log_to_csv.default_2022_field_numbers + %w[invalid_field_number] }
          let(:field_values) { log_to_csv.to_2022_row + %w[value_for_invalid_field_number] }

          before do
            file.write(log_to_csv.custom_field_numbers_row(seed:, field_numbers:))
            file.write(log_to_csv.to_custom_csv_row(seed:, field_values:))
            file.rewind
          end

          it "is valid" do
            expect(validator).to be_valid
          end
        end

        context "and file has too few valid headers" do
          let(:seed) { rand }
          let(:log_to_csv) { BulkUpload::LettingsLogToCsv.new(log:) }
          let(:field_numbers) { log_to_csv.default_2022_field_numbers }
          let(:field_values) { log_to_csv.to_2022_row }

          before do
            field_numbers.delete_at(20)
            field_values.delete_at(20)
            file.write(log_to_csv.custom_field_numbers_row(seed:, field_numbers:))
            file.write(log_to_csv.to_custom_csv_row(seed:, field_values:))
            file.rewind
          end

          it "is not valid" do
            expect(validator).not_to be_valid
            expect(validator.errors["base"]).to eql(["incorrect number of fields, please ensure you have used the correct template"])
          end
        end

        context "and file has too many valid headers" do
          let(:seed) { rand }
          let(:log_to_csv) { BulkUpload::LettingsLogToCsv.new(log:) }
          let(:field_numbers) { log_to_csv.default_2022_field_numbers + %w[23] }
          let(:field_values) { log_to_csv.to_2022_row + %w[value] }

          before do
            file.write(log_to_csv.custom_field_numbers_row(seed:, field_numbers:))
            file.write(log_to_csv.to_custom_csv_row(seed:, field_values:))
            file.rewind
          end

          it "is not valid" do
            expect(validator).not_to be_valid
            expect(validator.errors["base"]).to eql(["incorrect number of fields, please ensure you have used the correct template"])
          end
        end
      end
    end

    context "when 2023" do
      let(:bulk_upload) { create(:bulk_upload, user:, year: 2023) }

      context "when file has no headers" do
        context "and too many columns" do
          before do
            file.write(("a" * 143).chars.join(","))
            file.write("\n")
            file.rewind
          end

          it "is not valid" do
            expect(validator).not_to be_valid
            expect(validator.errors["base"]).to eql(["too many columns, please ensure you have used the correct template"])
          end
        end

        context "and doesn't have too many columns" do
          before do
            file.write(("a" * 142).chars.join(","))
            file.write("\n")
            file.rewind
          end

          it "is valid" do
            expect(validator).to be_valid
          end
        end
      end

      context "when file has headers" do
        context "and file has extra invalid headers" do
          let(:seed) { rand }
          let(:log_to_csv) { BulkUpload::LettingsLogToCsv.new(log:) }
          let(:field_numbers) { log_to_csv.default_2023_field_numbers + %w[invalid_field_number] }
          let(:field_values) { log_to_csv.to_2023_row + %w[value_for_invalid_field_number] }

          before do
            file.write(log_to_csv.custom_field_numbers_row(seed:, field_numbers:))
            file.write(log_to_csv.to_custom_csv_row(seed:, field_values:))
            file.rewind
          end

          it "is valid" do
            expect(validator).to be_valid
          end
        end

        context "and file has too few valid headers" do
          let(:seed) { rand }
          let(:log_to_csv) { BulkUpload::LettingsLogToCsv.new(log:) }
          let(:field_numbers) { log_to_csv.default_2023_field_numbers }
          let(:field_values) { log_to_csv.to_2023_row }

          before do
            field_numbers.delete_at(20)
            field_values.delete_at(20)
            file.write(log_to_csv.custom_field_numbers_row(seed:, field_numbers:))
            file.write(log_to_csv.to_custom_csv_row(seed:, field_values:))
            file.rewind
          end

          it "is not valid" do
            expect(validator).not_to be_valid
            expect(validator.errors["base"]).to eql(["incorrect number of fields, please ensure you have used the correct template"])
          end
        end

        context "and file has too many valid headers" do
          let(:seed) { rand }
          let(:log_to_csv) { BulkUpload::LettingsLogToCsv.new(log:) }
          let(:field_numbers) { log_to_csv.default_2023_field_numbers + %w[23] }
          let(:field_values) { log_to_csv.to_2023_row + %w[value] }

          before do
            file.write(log_to_csv.custom_field_numbers_row(seed:, field_numbers:))
            file.write(log_to_csv.to_custom_csv_row(seed:, field_values:))
            file.rewind
          end

          it "is not valid" do
            expect(validator).not_to be_valid
            expect(validator.errors["base"]).to eql(["incorrect number of fields, please ensure you have used the correct template"])
          end
        end
      end
    end
  end

  describe "#call" do
    context "when a valid csv" do
      let(:path) { file_fixture("2022_23_lettings_bulk_upload.csv") }

      it "creates validation errors" do
        expect { validator.call }.to change(BulkUploadError, :count)
      end

      it "create validation error with correct values" do
        validator.call

        error = BulkUploadError.find_by(row: "7", field: "field_96", category: "setup")

        expect(error.field).to eql("field_96")
        expect(error.error).to eql("You must answer tenancy start date")
        expect(error.tenant_code).to eql("123")
        expect(error.property_ref).to be_nil
        expect(error.row).to eql("7")
        expect(error.cell).to eql("CS7")
        expect(error.col).to eql("CS")
      end
    end

    context "with arbitrary ordered 23/24 csv" do
      let(:bulk_upload) { create(:bulk_upload, user:, year: 2023) }
      let(:log) { build(:lettings_log, :completed) }
      let(:file) { Tempfile.new }
      let(:path) { file.path }
      let(:seed) { 321 }

      around do |example|
        FormHandler.instance.use_real_forms!

        example.run

        FormHandler.instance.use_fake_forms!
      end

      before do
        file.write(BulkUpload::LettingsLogToCsv.new(log:, line_ending: "\r\n").default_2023_field_numbers_row(seed:))
        file.write(BulkUpload::LettingsLogToCsv.new(log:, line_ending: "\r\n").to_2023_csv_row(seed:))
        file.close
      end

      it "creates validation errors" do
        expect { validator.call }.to change(BulkUploadError, :count)
      end

      it "create validation error with correct values" do
        validator.call

        error = BulkUploadError.find_by(field: "field_5")

        expect(error.field).to eql("field_5")
        expect(error.error).to eql("You must answer letting type")
        expect(error.tenant_code).to eql(log.tenancycode)
        expect(error.property_ref).to eql(log.propcode)
        expect(error.row).to eql("2")
        expect(error.cell).to eql("DD2")
        expect(error.col).to eql("DD")
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
        file.write(BulkUpload::LettingsLogToCsv.new(log:, line_ending: "\r\n", col_offset: 0).to_2022_csv_row)
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
        validator.call
        expect(validator).to be_create_logs
      end
    end

    context "when there is an invalid log" do
      let(:path) { file_fixture("2022_23_lettings_bulk_upload.csv") }

      it "returns falsey" do
        validator.call
        expect(validator).not_to be_create_logs
      end
    end

    context "when a log is not valid?" do
      let(:log_1) { build(:lettings_log, :completed, created_by: user) }
      let(:log_2) { build(:lettings_log, :completed, created_by: user) }

      before do
        file.write(BulkUpload::LettingsLogToCsv.new(log: log_1, line_ending: "\r\n", col_offset: 0).to_2022_csv_row)
        file.write(BulkUpload::LettingsLogToCsv.new(log: log_2, line_ending: "\r\n", col_offset: 0, overrides: { illness: 100 }).to_2022_csv_row)
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
        file.write(BulkUpload::LettingsLogToCsv.new(log: log_1, line_ending: "\r\n", col_offset: 0).to_2022_csv_row)
        file.write(BulkUpload::LettingsLogToCsv.new(log: log_2, line_ending: "\r\n", col_offset: 0).to_2022_csv_row)
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
        file.write(BulkUpload::LettingsLogToCsv.new(log: log_1, line_ending: "\r\n", col_offset: 0).to_2022_csv_row)
        file.close
      end

      it "will not create logs" do
        validator.call
        expect(validator).not_to be_create_logs
      end
    end

    context "when a log has incomplete setup section" do
      let(:log) { build(:lettings_log, :in_progress, created_by: user, startdate: Time.zone.local(2022, 5, 1)) }

      before do
        file.write(BulkUpload::LettingsLogToCsv.new(log:, line_ending: "\r\n", col_offset: 0).to_2022_csv_row)
        file.close
      end

      it "returns false" do
        validator.call
        expect(validator).not_to be_create_logs
      end
    end
  end
end
