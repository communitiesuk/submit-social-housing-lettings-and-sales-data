require "rails_helper"

RSpec.describe Exports::CaseLogExportService do
  let(:storage_service) { instance_double(StorageService) }
  let(:export_filepath) { "spec/fixtures/exports/case_logs.xml" }
  let(:export_file) { File.open(export_filepath, "r:UTF-8") }
  let(:expected_filename) { "core_2022_02_08/dat_core_2022_02_08_0001.xml" }

  def replace_entity_ids(export_template)
    export_template.sub!(/\{id\}/, case_log["id"].to_s)
    export_template.sub!(/\{owning_org_id\}/, case_log["owning_organisation_id"].to_s)
    export_template.sub!(/\{managing_org_id\}/, case_log["managing_organisation_id"].to_s)
  end

  context "when exporting case logs" do
    subject(:export_service) { described_class.new(storage_service) }

    let(:case_log) { FactoryBot.create(:case_log, :completed) }

    before do
      Timecop.freeze(case_log.updated_at)
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
