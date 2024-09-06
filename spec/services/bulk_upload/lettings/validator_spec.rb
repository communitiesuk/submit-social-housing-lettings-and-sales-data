require "rails_helper"

RSpec.describe BulkUpload::Lettings::Validator do
  subject(:validator) { described_class.new(bulk_upload:, path:) }

  let(:organisation) { create(:organisation, old_visible_id: "3", rent_periods: [2]) }
  let(:user) { create(:user, organisation:) }
  let(:log) { build(:lettings_log, :completed, period: 2, assigned_to: user) }
  let(:log_to_csv) { BulkUpload::LettingsLogToCsv.new(log:) }
  let(:bulk_upload) { create(:bulk_upload, user:, year: log.collection_start_year) }
  let(:path) { file.path }
  let(:file) { Tempfile.new }

  describe "validations" do
    context "when file has headers" do
      context "and is empty" do
        it "is not valid" do
          expect(validator).not_to be_valid
          expect(validator.errors["base"]).to eql(["Template is blank - The template must be filled in for us to create the logs and check if data is correct."])
        end
      end

      context "and file has extra invalid headers" do
        let(:seed) { rand }
        let(:field_numbers) { log_to_csv.default_field_numbers + %w[invalid_field_number] }
        let(:field_values) { log_to_csv.to_row + %w[value_for_invalid_field_number] }

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
        let(:field_numbers) { log_to_csv.default_field_numbers }
        let(:field_values) { log_to_csv.to_row }

        before do
          field_numbers.delete_at(20)
          field_values.delete_at(20)
          file.write(log_to_csv.custom_field_numbers_row(seed:, field_numbers:))
          file.write(log_to_csv.to_custom_csv_row(seed:, field_values:))
          file.rewind
        end

        it "is not valid" do
          expect(validator).not_to be_valid
          expect(validator.errors["base"]).to eql(["Incorrect number of fields, please ensure you have used the correct template."])
        end
      end

      context "and file has too many valid headers" do
        let(:seed) { rand }
        let(:field_numbers) { log_to_csv.default_field_numbers + %w[23] }
        let(:field_values) { log_to_csv.to_row + %w[value] }

        before do
          file.write(log_to_csv.custom_field_numbers_row(seed:, field_numbers:))
          file.write(log_to_csv.to_custom_csv_row(seed:, field_values:))
          file.rewind
        end

        it "is not valid" do
          expect(validator).not_to be_valid
          expect(validator.errors["base"]).to eql(["Incorrect number of fields, please ensure you have used the correct template."])
        end
      end
    end

    context "when uploading a 2023 logs for 2024 bulk upload" do
      let(:log) { build(:lettings_log, :completed, startdate: Time.zone.local(2023, 5, 6), tenancycode: "5234234234234") }
      let(:bulk_upload) { build(:bulk_upload, user:, year: 2024) }

      context "with headers" do
        let(:seed) { rand }
        let(:field_numbers) { log_to_csv.default_2024_field_numbers }
        let(:field_values) { log_to_csv.to_2024_row }

        before do
          file.write(log_to_csv.custom_field_numbers_row(seed:, field_numbers:))
          file.write(log_to_csv.to_custom_csv_row(seed:, field_values:))
          file.rewind
        end

        it "is not valid" do
          expect(validator).not_to be_valid
          expect(validator.errors["base"]).to eql(["Incorrect start dates, please ensure you have used the correct template."])
        end
      end
    end
  end

  describe "#call" do
    context "with an invalid 2024 csv" do
      let(:log) { build(:lettings_log, :completed, startdate: Time.zone.local(2024, 7, 1), period: 2, assigned_to: user) }

      before do
        values = log_to_csv.to_2024_row
        values[7] = nil
        file.write(log_to_csv.default_2024_field_numbers_row)
        file.write(log_to_csv.to_custom_csv_row(seed: nil, field_values: values))
        file.rewind
      end

      it "creates validation errors" do
        expect { validator.call }.to change(BulkUploadError, :count)
      end

      it "create validation error with correct values" do
        validator.call

        error = BulkUploadError.find_by(row: "2", field: "field_8", category: "setup")

        expect(error.field).to eql("field_8")
        expect(error.error).to eql("You must answer tenancy start date (day)")
        expect(error.tenant_code).to eql(log.tenancycode)
        expect(error.property_ref).to eql(log.propcode)
        expect(error.row).to eql("2")
        expect(error.cell).to eql("I2")
        expect(error.col).to eql("I")
      end
    end

    context "with a valid csv" do
      before do
        file.write(log_to_csv.default_field_numbers_row)
        file.write(log_to_csv.to_csv_row)
        file.rewind
      end

      it "does not create validation errors" do
        expect { validator.call }.not_to change(BulkUploadError, :count)
      end
    end

    context "with arbitrary ordered invalid csv" do
      let(:seed) { 321 }
      let(:log) { build(:lettings_log, :completed, startdate: Time.zone.local(2024, 7, 1), period: 2, assigned_to: user) }

      before do
        log.needstype = nil
        values = log_to_csv.to_2024_row
        file.write(log_to_csv.default_2024_field_numbers_row(seed:))
        file.write(log_to_csv.to_custom_csv_row(seed:, field_values: values))
        file.close
      end

      it "creates validation errors" do
        expect { validator.call }.to change(BulkUploadError, :count)
      end

      it "create validation error with correct values" do
        validator.call

        error = BulkUploadError.find_by(field: "field_4")

        expect(error.field).to eql("field_4")
        expect(error.error).to eql("You must answer needs type")
        expect(error.tenant_code).to eql(log.tenancycode)
        expect(error.property_ref).to eql(log.propcode)
        expect(error.row).to eql("2")
        expect(error.cell).to eql("CY2")
        expect(error.col).to eql("CY")
      end
    end

    context "when duplicate rows present" do
      before do
        file.write(log_to_csv.default_field_numbers_row)
        file.write(log_to_csv.to_csv_row)
        file.write(log_to_csv.to_csv_row)
        file.close
      end

      it "creates errors" do
        expect { validator.call }.to change(BulkUploadError.where(category: :setup, error: "This is a duplicate of a log in your file"), :count)
      end
    end

    [
      { line_ending: "\n", name: "unix" },
      { line_ending: "\r\n", name: "windows" },
    ].each do |test_case|
      context "with #{test_case[:name]} line endings" do
        let(:log_to_csv) { BulkUpload::LettingsLogToCsv.new(log:, line_ending: test_case[:line_ending]) }

        context "with a valid file" do
          before do
            file.write(log_to_csv.default_field_numbers_row)
            file.write(log_to_csv.to_csv_row)
            file.rewind
          end

          it "does not create validation errors" do
            expect { validator.call }.not_to change(BulkUploadError, :count)
          end
        end

        context "with an invalid file" do
          let(:log) { build(:lettings_log, :completed, assigned_to: user, owning_organisation: organisation, managing_organisation: organisation, declaration: nil) }

          before do
            file.write(log_to_csv.default_field_numbers_row)
            file.write(log_to_csv.to_csv_row)
            file.rewind
          end

          it "creates validation errors" do
            expect { validator.call }.to change(BulkUploadError, :count)
          end
        end
      end
    end

    context "with a 2024 csv without headers" do
      let(:log) { build(:lettings_log, :completed, startdate: Time.zone.local(2024, 7, 1), period: 2, assigned_to: user) }

      before do
        file.write(log_to_csv.to_csv_row)
        file.close
      end

      it "creates validation errors" do
        expect { validator.call }.to change(BulkUploadError, :count)
      end
    end
  end

  describe "#create_logs?" do
    context "when a log has a clearable, non-setup error" do
      let(:log_1) { build(:lettings_log, :completed, period: 2, assigned_to: user) }
      let(:log_2) { build(:lettings_log, :completed, period: 2, assigned_to: user, age1: 5) }

      before do
        file.write(BulkUpload::LettingsLogToCsv.new(log: log_1, col_offset: 0).to_csv_row)
        file.write(BulkUpload::LettingsLogToCsv.new(log: log_2, col_offset: 0).to_csv_row)
        file.close
      end

      it "returns false" do
        validator.call
        expect(validator).to be_create_logs
      end
    end

    context "when all logs valid?" do
      let(:log_1) { build(:lettings_log, :completed, period: 2, assigned_to: user) }
      let(:log_2) { build(:lettings_log, :completed, period: 2, assigned_to: user) }

      before do
        file.write(BulkUpload::LettingsLogToCsv.new(log: log_1, col_offset: 0).to_csv_row)
        file.write(BulkUpload::LettingsLogToCsv.new(log: log_2, col_offset: 0).to_csv_row)
        file.close
      end

      it "returns true" do
        validator.call
        expect(validator).to be_create_logs
      end
    end

    context "when a log wants to block log creation" do
      let(:unaffiliated_org) { create(:organisation) }

      let(:log) { build(:lettings_log, :completed, assigned_to: user, owning_organisation: unaffiliated_org) }

      before do
        file.write(log_to_csv.to_csv_row)
        file.close
      end

      it "will not create logs" do
        validator.call
        expect(validator).not_to be_create_logs
      end
    end

    context "when a log has incomplete setup section" do
      let(:log) { build(:lettings_log, :completed, declaration: nil, assigned_to: user) }

      before do
        file.write(log_to_csv.to_csv_row)
        file.close
      end

      it "returns false" do
        validator.call
        expect(validator).not_to be_create_logs
      end
    end
  end
end
