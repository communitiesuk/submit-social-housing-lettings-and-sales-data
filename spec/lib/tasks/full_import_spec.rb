require "rails_helper"
require "rake"

describe "full import", type: :task do
  let(:instance_name) { "paas_import_instance" }
  let(:paas_config_service) { instance_double(Configuration::PaasConfigurationService) }
  let(:env_config_service) { instance_double(Configuration::EnvConfigurationService) }
  let(:storage_service) { instance_double(Storage::S3Service) }
  let(:orgs_list) { "Institution name,Id,Old Completed lettings logs,Old In progress lettings logs,Old Completed sales logs,Old In progress sales logs\norg1,1.zip,0,0,0,0\norg2,2.zip,0,0,0,0" }

  before do
    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(storage_service).to receive(:write_file).and_return(nil)
    allow(storage_service).to receive(:get_file_io).and_return(orgs_list)
    allow(Configuration::PaasConfigurationService).to receive(:new).and_return(paas_config_service)
    allow(Configuration::EnvConfigurationService).to receive(:new).and_return(env_config_service)
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with("IMPORT_PAAS_INSTANCE").and_return(instance_name)
  end

  describe "import:generate_reports" do
    subject(:task) { Rake::Task["import:generate_reports"] }

    before do
      Rake.application.rake_require("tasks/full_import")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when generating report" do
      let(:import_report_service) { instance_double(Imports::ImportReportService) }

      before do
        allow(Imports::ImportReportService).to receive(:new).and_return(import_report_service)
      end

      it "creates a report using given organisation csv when the VCAP_SERVICES environment variable exists" do
        allow(ENV).to receive(:[]).with("VCAP_SERVICES").and_return("dummy")
        expect(Storage::S3Service).to receive(:new).with(paas_config_service, instance_name)
        expect(Imports::ImportReportService).to receive(:new).with(storage_service, CSV.parse(orgs_list, headers: true))
        expect(import_report_service).to receive(:create_reports).with("some_name")

        task.invoke("some_name")
      end

      it "creates a report using given organisation csv when the VCAP_SERVICES environment variable does not exist" do
        allow(ENV).to receive(:[]).with("VCAP_SERVICES")
        expect(Storage::S3Service).to receive(:new).with(env_config_service, instance_name)
        expect(Imports::ImportReportService).to receive(:new).with(storage_service, CSV.parse(orgs_list, headers: true))
        expect(import_report_service).to receive(:create_reports).with("some_name")

        task.invoke("some_name")
      end
    end
  end

  describe "import:generate_missing_answers_report" do
    subject(:task) { Rake::Task["import:generate_missing_answers_report"] }

    before do
      Rake.application.rake_require("tasks/full_import")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when generating a missing answers report" do
      let(:import_report_service) { instance_double(Imports::ImportReportService) }

      before do
        allow(Imports::ImportReportService).to receive(:new).and_return(import_report_service)
        allow(ENV).to receive(:[]).with("VCAP_SERVICES").and_return("dummy")
      end

      it "creates a missing answers report" do
        expect(Storage::S3Service).to receive(:new).with(paas_config_service, instance_name)
        expect(Imports::ImportReportService).to receive(:new).with(storage_service, nil)
        expect(import_report_service).to receive(:generate_missing_answers_report).with("some_name")
        task.invoke("some_name")
      end
    end
  end

  describe "import:initial" do
    subject(:task) { Rake::Task["import:initial"] }

    let(:archive_service) { instance_double(Storage::ArchiveService) }

    before do
      Rake.application.rake_require("tasks/full_import")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when calling the initial import" do
      before do
        allow(Storage::ArchiveService).to receive(:new).and_return(archive_service)
        allow(archive_service).to receive(:folder_present?).and_return(false)
        allow(Imports::OrganisationImportService).to receive(:new).and_return(instance_double(Imports::OrganisationImportService))
        allow(Imports::SchemeImportService).to receive(:new).and_return(instance_double(Imports::SchemeImportService))
        allow(Imports::SchemeLocationImportService).to receive(:new).and_return(instance_double(Imports::SchemeLocationImportService))
        allow(Imports::UserImportService).to receive(:new).and_return(instance_double(Imports::UserImportService))
        allow(Imports::DataProtectionConfirmationImportService).to receive(:new).and_return(instance_double(Imports::DataProtectionConfirmationImportService))
        allow(Imports::OrganisationRentPeriodImportService).to receive(:new).and_return(instance_double(Imports::OrganisationRentPeriodImportService))
      end

      it "does not write a report if there were no errors" do
        expect(Storage::S3Service).to receive(:new).with(env_config_service, instance_name)
        expect(storage_service).not_to receive(:write_file).with("some_name_1_initial.log", "")
        expect(storage_service).not_to receive(:write_file).with("some_name_2_initial.log", "")

        task.invoke("some_name.csv")
      end
    end
  end

  describe "import:logs" do
    subject(:task) { Rake::Task["import:logs"] }

    let(:archive_service) { instance_double(Storage::ArchiveService) }

    before do
      Rake.application.rake_require("tasks/full_import")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when calling the logs import" do
      before do
        allow(Storage::ArchiveService).to receive(:new).and_return(archive_service)
        allow(archive_service).to receive(:folder_present?).and_return(false)
        allow(Imports::LettingsLogsImportService).to receive(:new).and_return(instance_double(Imports::LettingsLogsImportService))
        allow(Imports::SalesLogsImportService).to receive(:new).and_return(instance_double(Imports::SalesLogsImportService))
      end

      it "does not write a report if there were no errors" do
        expect(Storage::S3Service).to receive(:new).with(env_config_service, instance_name)
        expect(storage_service).not_to receive(:write_file).with("some_name_1_logs.log", "")
        expect(storage_service).not_to receive(:write_file).with("some_name_2_logs.log", "")

        task.invoke("some_name.csv")
      end
    end
  end
end
