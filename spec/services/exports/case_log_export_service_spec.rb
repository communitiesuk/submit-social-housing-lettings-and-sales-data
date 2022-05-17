require "rails_helper"

RSpec.describe Exports::CaseLogExportService do
  let(:storage_service) { instance_double(StorageService) }
  let(:export_filepath) { "spec/fixtures/exports/case_logs.xml" }
  let(:export_file) { File.open(export_filepath, "r:UTF-8") }
  let(:expected_master_manifest_filename) { "Manifest_2022_05_01_0001.csv" }
  let(:case_log) { FactoryBot.create(:case_log, :completed) }

  def replace_entity_ids(export_template)
    export_template.sub!(/\{id\}/, (case_log["id"] + Exports::CaseLogExportService::LOG_ID_OFFSET).to_s)
    export_template.sub!(/\{owning_org_id\}/, case_log["owning_organisation_id"].to_s)
    export_template.sub!(/\{managing_org_id\}/, case_log["managing_organisation_id"].to_s)
    export_template.sub!(/\{created_by_id\}/, case_log["created_by_id"].to_s)
  end

  context "when exporting daily case logs" do
    subject(:export_service) { described_class.new(storage_service) }

    let!(:case_log) { FactoryBot.create(:case_log, :completed) }

    before do
      Timecop.freeze(2022, 5, 1)
      allow(storage_service).to receive(:write_file)
    end

    context "and no case logs is available for export" do
      it "generates a master manifest with the correct name" do
        expect(storage_service).to receive(:write_file).with(expected_master_manifest_filename, any_args)
        export_service.export_case_logs
      end

      it "generates a master manifest with CSV headers but no data" do
        actual_content = nil
        expected_content = "zip-name,date-time zipped folder generated,zip-file-uri\n"
        allow(storage_service).to receive(:write_file).with(expected_master_manifest_filename, any_args) { |_, arg2| actual_content = arg2&.string }

        export_service.export_case_logs
        expect(actual_content).to eq(expected_content)
      end
    end

    context "and one case log is available for export" do
      let(:expected_zip_filename) { "core_2021_2022_jan_mar_f0001_inc001.zip" }
      let(:expected_data_filename) { "core_2022_02_08/dat_core_2022_02_08_0001.xml" }

      it "generates a ZIP export file with the expected filename" do
        expect(storage_service).to receive(:write_file).with(expected_zip_filename, any_args)

        export_service.export_case_logs
      end

      it "generates an XML export file with the expected filename within the ZIP file" do
        allow(storage_service).to receive(:write_file).with(expected_zip_filename, any_args) do |_, content|
          pp Zip::File.open_buffer(content).entries
          expect(content).to eq("Manifest_2022_05_01_0001.csv")
        end
        export_service.export_case_logs
      end

      it "generates an XML export file with the expected content" do
        actual_content = nil
        expected_content = replace_entity_ids(export_file.read)
        allow(storage_service).to receive(:write_file).with(expected_data_filename, any_args) { |_, arg2| actual_content = arg2&.string }

        export_service.export_case_logs
        expect(actual_content).to eq(expected_content)
      end
    end

    context "and multiple case logs are available for export" do
      let!(:case_log_2) { FactoryBot.create(:case_log, startdate: Time.zone.local(2022, 4, 1)) }

      context "when case logs are across multiple quarters" do
        it "generates multiple ZIP export files with the expected filenames" do
          expect(storage_service).to receive(:write_file).with("core_2021_2022_jan_mar_f0001_inc001.zip", any_args)
          expect(storage_service).to receive(:write_file).with("core_2022_2023_apr_jun_f0001_inc001.zip", any_args)

          export_service.export_case_logs
        end
      end
    end

    context "and a previous export has run the same day" do
      let(:expected_master_manifest_rerun) { "Manifest_2022_05_01_0002.csv" }
      before do
        export_service.export_case_logs
      end

      it "increments the master manifest number by 1" do
        expect(storage_service).to receive(:write_file).with(expected_master_manifest_rerun, any_args)
        export_service.export_case_logs
      end
    end
  end
end
