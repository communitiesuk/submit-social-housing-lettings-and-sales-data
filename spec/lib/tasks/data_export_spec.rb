require "rails_helper"
require "rake"

describe "rake core:data_export", type: task do
  subject(:task) { Rake::Task["core:data_export"] }

  let(:paas_instance) { "paas_export_instance" }
  let(:storage_service) { instance_double(StorageService) }
  let(:paas_config_service) { instance_double(PaasConfigurationService) }
  let(:export_service) { instance_double(Exports::CaseLogExportService) }

  before do
    Rake.application.rake_require("tasks/data_export")
    Rake::Task.define_task(:environment)
    task.reenable

    allow(StorageService).to receive(:new).and_return(storage_service)
    allow(PaasConfigurationService).to receive(:new).and_return(paas_config_service)
    allow(Exports::CaseLogExportService).to receive(:new).and_return(export_service)
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with("EXPORT_PAAS_INSTANCE").and_return(paas_instance)
  end

  context "when exporting case logs" do
    it "starts the export process" do
      expect(StorageService).to receive(:new).with(paas_config_service, paas_instance)
      expect(Exports::CaseLogExportService).to receive(:new).with(storage_service)
      expect(export_service).to receive(:export_case_logs)

      task.invoke
    end
  end
end
