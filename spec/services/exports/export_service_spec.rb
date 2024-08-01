require "rails_helper"

RSpec.describe Exports::ExportService do
  subject(:export_service) { described_class.new(storage_service) }

  let(:storage_service) { instance_double(Storage::S3Service) }
  let(:expected_master_manifest_filename) { "Manifest_2022_05_01_0001.csv" }
  let(:start_time) { Time.zone.local(2022, 5, 1) }
  let(:user) { FactoryBot.create(:user, email: "test1@example.com") }

  before do
    Timecop.freeze(start_time)
    Singleton.__init__(FormHandler)
    allow(storage_service).to receive(:write_file)
    allow(Exports::LettingsLogExportService).to receive(:new).and_return(lettings_logs_export_service)
  end

  after do
    Timecop.return
  end

  context "when exporting daily XMLs" do
    context "and no lettings archives get created in lettings logs export" do
      let(:lettings_logs_export_service) { instance_double("Exports::LettingsLogExportService", export_xml_lettings_logs: {}) }

      it "generates a master manifest with the correct name" do
        expect(storage_service).to receive(:write_file).with(expected_master_manifest_filename, any_args)
        export_service.export_xml
      end

      it "generates a master manifest with CSV headers but no data" do
        actual_content = nil
        expected_content = "zip-name,date-time zipped folder generated,zip-file-uri\n"
        allow(storage_service).to receive(:write_file).with(expected_master_manifest_filename, any_args) { |_, arg2| actual_content = arg2&.string }

        export_service.export_xml
        expect(actual_content).to eq(expected_content)
      end
    end

    context "and one lettings archive gets created in lettings logs export" do
      let(:lettings_logs_export_service) { instance_double("Exports::LettingsLogExportService", export_xml_lettings_logs: { "some_file_base_name" => start_time }) }

      it "generates a master manifest with the correct name" do
        expect(storage_service).to receive(:write_file).with(expected_master_manifest_filename, any_args)
        export_service.export_xml
      end

      it "generates a master manifest with CSV headers and correct data" do
        actual_content = nil
        expected_content = "zip-name,date-time zipped folder generated,zip-file-uri\nsome_file_base_name,2022-05-01 00:00:00 +0100,some_file_base_name.zip\n"
        allow(storage_service).to receive(:write_file).with(expected_master_manifest_filename, any_args) { |_, arg2| actual_content = arg2&.string }

        export_service.export_xml
        expect(actual_content).to eq(expected_content)
      end
    end

    context "and multiple lettings archives get created in lettings logs export" do
      let(:lettings_logs_export_service) { instance_double("Exports::LettingsLogExportService", export_xml_lettings_logs: { "some_file_base_name" => start_time, "second_file_base_name" => start_time }) }

      it "generates a master manifest with the correct name" do
        expect(storage_service).to receive(:write_file).with(expected_master_manifest_filename, any_args)
        export_service.export_xml
      end

      it "generates a master manifest with CSV headers and correct data" do
        actual_content = nil
        expected_content = "zip-name,date-time zipped folder generated,zip-file-uri\nsome_file_base_name,2022-05-01 00:00:00 +0100,some_file_base_name.zip\nsecond_file_base_name,2022-05-01 00:00:00 +0100,second_file_base_name.zip\n"
        allow(storage_service).to receive(:write_file).with(expected_master_manifest_filename, any_args) { |_, arg2| actual_content = arg2&.string }

        export_service.export_xml
        expect(actual_content).to eq(expected_content)
      end
    end
  end
end
