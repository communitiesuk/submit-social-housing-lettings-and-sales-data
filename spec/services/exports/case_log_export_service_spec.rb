require "rails_helper"

RSpec.describe Exports::CaseLogExportService do
  let(:storage_service) { instance_double(StorageService) }

  let(:export_filepath) { "spec/fixtures/exports/case_logs.xml" }
  let(:export_file) { File.open(export_filepath, "r:UTF-8") }

  let(:expected_data_filename) { "core_2022_02_08/dat_core_2022_02_08_0001.xml" }
  let(:expected_master_manifest_filename) { "Manifest_2022_02_08_0001.csv" }
  let(:expected_master_manifest_filename2) { "Manifest_2022_02_08_0002.csv" }

  let(:case_log) { FactoryBot.create(:case_log, :completed) }

  def replace_entity_ids(export_template)
    export_template.sub!(/\{id\}/, (case_log["id"] + Exports::CaseLogExportService::LOG_ID_OFFSET).to_s)
    export_template.sub!(/\{owning_org_id\}/, case_log["owning_organisation_id"].to_s)
    export_template.sub!(/\{managing_org_id\}/, case_log["managing_organisation_id"].to_s)
    export_template.sub!(/\{created_by_id\}/, case_log["created_by_id"].to_s)
  end

  context "when exporting daily case logs" do
    subject(:export_service) { described_class.new(storage_service) }

    let(:case_log) { FactoryBot.create(:case_log, :completed) }

    before do
      Timecop.freeze(case_log.updated_at)
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

    context "and case logs are available for export" do
      let!(:time_now) { Time.now }
      before do
        Timecop.freeze(time_now)
        case_log
      end

      after do
        LogsExport.destroy_all
      end

      it "generates an XML export file with the expected filename" do
        expect(storage_service).to receive(:write_file).with(expected_data_filename, any_args)
        export_service.export_case_logs
      end

      it "generates an XML export file with the expected content" do
        actual_content = nil
        expected_content = replace_entity_ids(export_file.read)
        allow(storage_service).to receive(:write_file).with(expected_data_filename, any_args) { |_, arg2| actual_content = arg2&.string }

        export_service.export_case_logs
        expect(actual_content).to eq(expected_content)
      end

      it "creates a logs export record in a database with correct time" do
        export_service.export_case_logs
        records_from_db = ActiveRecord::Base.connection.execute("select started_at, id from logs_exports ").to_a
        expect(records_from_db[0]["started_at"]).to eq(time_now)
        expect(records_from_db.count).to eq(1)
      end

      it "gets the logs for correct timeframe" do
        start_time = Time.zone.local(2022, 4, 13, 2, 2, 2)
        export = LogsExport.new(started_at: start_time, daily_run_number: 1)
        export.save!
        params = { from: start_time, to: time_now, status: CaseLog.statuses[:completed] }
        expect(CaseLog).to receive(:where).with("updated_at >= :from and updated_at <= :to and status = :status", params).and_return([])
        export_service.export_case_logs
      end

      context "when this is the first export" do
        it "gets the logs for the timeframe up until the current time" do
          params = { to: time_now, status: CaseLog.statuses[:completed] }
          expect(CaseLog).to receive(:where).with("updated_at <= :to and status = :status", params).and_return([])
          export_service.export_case_logs
        end
      end
    end

    context "and a previous export has run the same day" do
      before do
        export_service.export_case_logs
      end

      it "increments the master manifest number by 1" do
        expect(storage_service).to receive(:write_file).with(expected_master_manifest_filename2, any_args)
        export_service.export_case_logs
      end
    end
  end
end
