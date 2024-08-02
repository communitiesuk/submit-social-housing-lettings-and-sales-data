require "rails_helper"

describe DataExportXmlJob do
  let(:storage_service) { instance_double(Storage::S3Service, write_file: nil) }
  let(:env_config_service) { instance_double(Configuration::EnvConfigurationService) }
  let(:lettings_export_service) { instance_double(Exports::LettingsLogExportService, export_xml_lettings_logs: {}) }
  let(:user_export_service) { instance_double(Exports::UserExportService, export_xml_users: {}) }

  before do
    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(Configuration::EnvConfigurationService).to receive(:new).and_return(env_config_service)
    allow(Exports::LettingsLogExportService).to receive(:new).and_return(lettings_export_service)
    allow(Exports::UserExportService).to receive(:new).and_return(user_export_service)
  end

  it "calls the export services" do
    expect(lettings_export_service).to receive(:export_xml_lettings_logs)
    expect(user_export_service).to receive(:export_xml_users)

    described_class.perform_now
  end

  context "with full update enabled" do
    it "calls the export service" do
      expect(lettings_export_service).to receive(:export_xml_lettings_logs).with(full_update: true, collection_year: nil)
      expect(user_export_service).to receive(:export_xml_users).with(full_update: true)

      described_class.perform_now(full_update: true)
    end
  end
end
