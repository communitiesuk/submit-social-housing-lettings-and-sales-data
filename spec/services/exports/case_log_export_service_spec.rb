require "rails_helper"

RSpec.describe Exports::CaseLogExportService do
  let(:storage_service) { instance_double(StorageService) }
  let(:export_filepath) { "spec/fixtures/exports/case_logs.xml" }
  let(:export_file) { File.open(export_filepath, "r:UTF-8") }
  let(:expected_filename) { "core_2022_02_08/dat_core_2022_02_08_0001.xml" }
  let(:case_logs) { FactoryBot.create_list(:case_log, 2, :completed) }

  def replace_entity_ids(export_template)
    export_template.sub!(/\{id_1\}/, case_logs[0]["id"].to_s)
    export_template.sub!(/\{id_2\}/, case_logs[1]["id"].to_s)
    export_template.sub!(/\{owning_org_id_1\}/, case_logs[0]["owning_organisation_id"].to_s)
    export_template.sub!(/\{owning_org_id_2\}/, case_logs[1]["owning_organisation_id"].to_s)
    export_template.sub!(/\{managing_org_id_1\}/, case_logs[0]["managing_organisation_id"].to_s)
    export_template.sub!(/\{managing_org_id_2\}/, case_logs[1]["managing_organisation_id"].to_s)
  end

  context "when exporting case logs" do
    subject(:export_service) { described_class.new(storage_service) }

    before do
      Timecop.freeze(Time.new(2022, 2, 8, 16, 52, 15, "+00:00"))
      case_logs
    end

    it "generate an XML export file with the expected filename" do
      actual_filename = nil
      allow(storage_service).to receive(:write_file) { |filename, _| actual_filename = filename }
      export_service.export_case_logs
      expect(actual_filename).to eq(expected_filename)
    end

    it "generate an XML export file with the expected content" do
      actual_stringio = nil
      allow(storage_service).to receive(:write_file) { |_, stringio| actual_stringio = stringio }
      actual_content = replace_entity_ids(export_file.read)
      export_service.export_case_logs
      expect(actual_stringio&.string).to eq(actual_content)
    end
  end
end
