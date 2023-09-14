require "rails_helper"
require "rake"

describe "data_import_field imports" do
  context "with rake core:lettings_data_import_field", type: :task do
    subject(:task) { Rake::Task["core:lettings_data_import_field"] }

    let(:instance_name) { "paas_import_instance" }
    let(:storage_service) { instance_double(Storage::S3Service) }
    let(:env_config_service) { instance_double(Configuration::EnvConfigurationService) }
    let(:paas_config_service) { instance_double(Configuration::PaasConfigurationService) }

    before do
      Rake.application.rake_require("tasks/data_import_field")
      Rake::Task.define_task(:environment)
      task.reenable

      allow(Storage::S3Service).to receive(:new).and_return(storage_service)
      allow(Configuration::EnvConfigurationService).to receive(:new).and_return(env_config_service)
      allow(Configuration::PaasConfigurationService).to receive(:new).and_return(paas_config_service)
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with("IMPORT_PAAS_INSTANCE").and_return(instance_name)
      allow(ENV).to receive(:[]).with("VCAP_SERVICES").and_return("dummy")
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

        it "updates the logs from the given XML file when the VCAP_SERVICES environment variable exists" do
          expect(Storage::S3Service).to receive(:new).with(paas_config_service, instance_name)
          expect(storage_service).to receive(:get_file_io).with("spec/fixtures/imports/logs")
          expect(Imports::LettingsLogsFieldImportService).to receive(:new).with(archive_service)
          expect(import_service).to receive(:update_field).with(field, "logs")
          task.invoke(field, fixture_path)
        end

        it "updates the logs from the given XML file when the VCAP_SERVICES environment variable does not exist" do
          allow(ENV).to receive(:[]).with("VCAP_SERVICES")
          expect(Storage::S3Service).to receive(:new).with(env_config_service, instance_name)
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

      context "and we update the address fields" do
        let(:field) { "address" }

        it "updates the 2023 logs from the given XML file" do
          expect(Storage::S3Service).to receive(:new).with(paas_config_service, instance_name)
          expect(storage_service).to receive(:get_file_io).with("spec/fixtures/imports/logs")
          expect(Imports::LettingsLogsFieldImportService).to receive(:new).with(archive_service)
          expect(import_service).to receive(:update_field).with(field, "logs")
          task.invoke(field, fixture_path)
        end
      end

      context "and we update the reason field" do
        let(:field) { "reason" }

        it "updates the 2023 logs from the given XML file" do
          expect(Storage::S3Service).to receive(:new).with(paas_config_service, instance_name)
          expect(storage_service).to receive(:get_file_io).with("spec/fixtures/imports/logs")
          expect(Imports::LettingsLogsFieldImportService).to receive(:new).with(archive_service)
          expect(import_service).to receive(:update_field).with(field, "logs")
          task.invoke(field, fixture_path)
        end
      end

      context "and we update homeless fields" do
        let(:field) { "homeless" }

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
        expect { task.invoke("random_field", "my_path") }.to raise_error("Field random_field cannot be updated by lettings_data_import_field")
      end
    end
  end

  context "with rake core:sales_data_import_field", type: :task do
    subject(:task) { Rake::Task["core:sales_data_import_field"] }

    let(:instance_name) { "paas_import_instance" }
    let(:storage_service) { instance_double(Storage::S3Service) }
    let(:env_config_service) { instance_double(Configuration::EnvConfigurationService) }
    let(:paas_config_service) { instance_double(Configuration::PaasConfigurationService) }

    before do
      Rake.application.rake_require("tasks/data_import_field")
      Rake::Task.define_task(:environment)
      task.reenable

      allow(Storage::S3Service).to receive(:new).and_return(storage_service)
      allow(Configuration::EnvConfigurationService).to receive(:new).and_return(env_config_service)
      allow(Configuration::PaasConfigurationService).to receive(:new).and_return(paas_config_service)
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with("IMPORT_PAAS_INSTANCE").and_return(instance_name)
      allow(ENV).to receive(:[]).with("VCAP_SERVICES").and_return("dummy")
      allow(Imports::SalesLogsFieldImportService).to receive(:new).and_return(import_service)
    end

    context "when importing a sales log field" do
      let(:import_service) { instance_double(Imports::SalesLogsFieldImportService) }
      let(:fixture_path) { "spec/fixtures/imports/sales_logs" }
      let(:archive_service) { instance_double(Storage::ArchiveService) }

      before do
        allow(import_service).to receive(:update_field)
        allow(Storage::ArchiveService).to receive(:new).and_return(archive_service)
        allow(archive_service).to receive(:folder_present?).with("logs").and_return(true)
      end

      context "and we update the owning_organisation_id field" do
        let(:field) { "owning_organisation_id" }

        it "updates the logs from the given XML file when the VCAP_SERVICES environment variable exists" do
          expect(Storage::S3Service).to receive(:new).with(paas_config_service, instance_name)
          expect(storage_service).to receive(:get_file_io).with("spec/fixtures/imports/sales_logs")
          expect(Imports::SalesLogsFieldImportService).to receive(:new).with(archive_service)
          expect(import_service).to receive(:update_field).with(field, "logs")
          task.invoke(field, fixture_path)
        end

        it "updates the logs from the given XML file when the VCAP_SERVICES environment variable does not exist" do
          allow(ENV).to receive(:[]).with("VCAP_SERVICES")
          expect(Storage::S3Service).to receive(:new).with(env_config_service, instance_name)
          expect(storage_service).to receive(:get_file_io).with("spec/fixtures/imports/sales_logs")
          expect(Imports::SalesLogsFieldImportService).to receive(:new).with(archive_service)
          expect(import_service).to receive(:update_field).with(field, "logs")
          task.invoke(field, fixture_path)
        end
      end

      context "and we update the old_form_id field" do
        let(:field) { "old_form_id" }

        it "updates the logs from the given XML file when the VCAP_SERVICES environment variable exists" do
          expect(Storage::S3Service).to receive(:new).with(paas_config_service, instance_name)
          expect(storage_service).to receive(:get_file_io).with("spec/fixtures/imports/sales_logs")
          expect(Imports::SalesLogsFieldImportService).to receive(:new).with(archive_service)
          expect(import_service).to receive(:update_field).with(field, "logs")
          task.invoke(field, fixture_path)
        end

        it "updates the logs from the given XML file when the VCAP_SERVICES environment variable does not exist" do
          allow(ENV).to receive(:[]).with("VCAP_SERVICES")
          expect(Storage::S3Service).to receive(:new).with(env_config_service, instance_name)
          expect(storage_service).to receive(:get_file_io).with("spec/fixtures/imports/sales_logs")
          expect(Imports::SalesLogsFieldImportService).to receive(:new).with(archive_service)
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
        expect { task.invoke("random_field", "my_path") }.to raise_error("Field random_field cannot be updated by sales_data_import_field")
      end
    end
  end
end
