require "rails_helper"
require "rake"

describe "rake core:data_import_field", type: :task do
  subject(:task) { Rake::Task["core:data_import_field"] }

  let(:instance_name) { "paas_import_instance" }
  let(:storage_service) { instance_double(Storage::S3Service) }
  let(:paas_config_service) { instance_double(Configuration::PaasConfigurationService) }

  before do
    Rake.application.rake_require("tasks/data_import_field")
    Rake::Task.define_task(:environment)
    task.reenable

    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(Configuration::PaasConfigurationService).to receive(:new).and_return(paas_config_service)
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with("IMPORT_PAAS_INSTANCE").and_return(instance_name)
    allow(Imports::LettingsLogsFieldImportService).to receive(:new).and_return(import_service)
  end

  context "when importing a lettings log field" do
    let(:import_service) { instance_double(Imports::LettingsLogsFieldImportService) }
    let(:fixture_path) { "spec/fixtures/imports/logs" }
    let(:archive_service) { instance_double(Storage::ArchiveService) }

    before do
      allow(import_service).to receive(:update_field)
      allow(Storage::ArchiveService).to receive(:new).and_return(archive_service)
      allow(archive_service).to receive(:folder_present?).with("logs").and_return(true)
    end

    context "and we update the tenancycode field" do
      let(:field) { "tenancycode" }

      it "updates the logs from the given XML file" do
        expect(Storage::S3Service).to receive(:new).with(paas_config_service, instance_name)
        expect(storage_service).to receive(:get_file_io).with("spec/fixtures/imports/logs")
        expect(Imports::LettingsLogsFieldImportService).to receive(:new).with(archive_service)
        expect(import_service).to receive(:update_field).with(field, "logs")
        task.invoke(field, fixture_path)
      end
    end

    context "and we update the lettings_allocation fields" do
      let(:field) { "lettings_allocation" }

      it "updates the logs from the given XML file" do
        expect(Storage::S3Service).to receive(:new).with(paas_config_service, instance_name)
        expect(storage_service).to receive(:get_file_io).with("spec/fixtures/imports/logs")
        expect(Imports::LettingsLogsFieldImportService).to receive(:new).with(archive_service)
        expect(import_service).to receive(:update_field).with(field, "logs")
        task.invoke(field, fixture_path)
      end
    end

    context "and we update the major repairs fields" do
      let(:field) { "major_repairs" }

      it "updates the logs from the given XML file" do
        expect(Storage::S3Service).to receive(:new).with(paas_config_service, instance_name)
        expect(storage_service).to receive(:get_file_io).with("spec/fixtures/imports/logs")
        expect(Imports::LettingsLogsFieldImportService).to receive(:new).with(archive_service)
        expect(import_service).to receive(:update_field).with(field, "logs")
        task.invoke(field, fixture_path)
      end
    end

    context "and we update the offered fields" do
      let(:field) { "offered" }

      it "updates the logs from the given XML file" do
        expect(Storage::S3Service).to receive(:new).with(paas_config_service, instance_name)
        expect(storage_service).to receive(:get_file_io).with("spec/fixtures/imports/logs")
        expect(Imports::LettingsLogsFieldImportService).to receive(:new).with(archive_service)
        expect(import_service).to receive(:update_field).with(field, "logs")
        task.invoke(field, fixture_path)
      end
    end

    it "raises an exception if no parameters are provided" do
      expect { task.invoke }.to raise_error(/Usage/)
    end

    it "raises an exception if a single parameter is provided" do
      expect { task.invoke("one_parameter") }.to raise_error(/Usage/)
    end

    it "raises an exception if the field is not supported" do
      expect { task.invoke("random_field", "my_path") }.to raise_error("Field random_field cannot be updated by data_import_field")
    end
  end
end
