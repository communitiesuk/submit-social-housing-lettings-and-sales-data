require "rails_helper"
require "rake"

describe "rake core:data_export", type: task do
  let(:paas_instance) { "paas_export_instance" }
  let(:storage_service) { instance_double(Storage::S3Service) }
  let(:paas_config_service) { instance_double(Configuration::PaasConfigurationService) }
  let(:export_service) { instance_double(Exports::LettingsLogExportService) }

  before do
    Rake.application.rake_require("tasks/data_export")
    Rake::Task.define_task(:environment)
    task.reenable

    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(Configuration::PaasConfigurationService).to receive(:new).and_return(paas_config_service)
    allow(Exports::LettingsLogExportService).to receive(:new).and_return(export_service)
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with("EXPORT_PAAS_INSTANCE").and_return(paas_instance)
  end

  context "when exporting lettings logs with no parameters" do
    let(:task) { Rake::Task["core:data_export_xml"] }

    it "starts the XML export process" do
      expect { task.invoke }.to enqueue_job(DataExportXmlJob)
    end
  end

  context "when exporting lettings logs with CSV format" do
    let(:task) { Rake::Task["core:data_export_csv"] }

    it "starts the CSV export process" do
      expect { task.invoke }.to enqueue_job(DataExportCsvJob)
    end
  end
end
