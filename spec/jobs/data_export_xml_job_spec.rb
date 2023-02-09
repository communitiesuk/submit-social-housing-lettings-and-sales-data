require "rails_helper"

describe DataExportXmlJob do
  let(:storage_service) { instance_double(Storage::S3Service) }
  let(:paas_config_service) { instance_double(Configuration::PaasConfigurationService) }
  let(:export_service) { instance_double(Exports::LettingsLogExportService) }

  before do
    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(Configuration::PaasConfigurationService).to receive(:new).and_return(paas_config_service)
    allow(Exports::LettingsLogExportService).to receive(:new).and_return(export_service)
  end

  it "calls the export service" do
    expect(export_service).to receive(:export_xml_lettings_logs)

    described_class.perform_now
  end

  context "with full update enabled" do
    it "calls the export service" do
      expect(export_service).to receive(:export_xml_lettings_logs).with(full_update: true)

      described_class.perform_now(full_update: true)
    end
  end
end
