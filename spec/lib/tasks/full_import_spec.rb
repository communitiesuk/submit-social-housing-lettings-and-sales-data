require "rails_helper"
require "rake"

describe "rake core:full_import", type: :task do
  subject(:task) { Rake::Task["core:full_import"] }

  let(:instance_name) { "paas_import_instance" }
  let(:storage_service) { instance_double(S3StorageService) }
  let(:paas_config_service) { instance_double(PaasConfigurationService) }

  before do
    Rake.application.rake_require("tasks/full_import")
    Rake::Task.define_task(:environment)
    task.reenable

    allow(S3StorageService).to receive(:new).and_return(storage_service)
    allow(PaasConfigurationService).to receive(:new).and_return(paas_config_service)
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with("IMPORT_PAAS_INSTANCE").and_return(instance_name)
  end

  context "when starting a full import with mocked services" do
    let(:fixture_path) { "spec/fixtures/imports" }
    let(:case_logs_service) { instance_double(Imports::CaseLogsImportService) }
    let(:rent_period_service) { instance_double(Imports::OrganisationRentPeriodImportService) }
    let(:data_protection_service) { instance_double(Imports::DataProtectionConfirmationImportService) }
    let(:user_service) { instance_double(Imports::UserImportService) }
    let(:location_service) { instance_double(Imports::SchemeLocationImportService) }
    let(:scheme_service) { instance_double(Imports::SchemeImportService) }
    let(:organisation_service) { instance_double(Imports::OrganisationImportService) }

    before do
      allow(Imports::OrganisationImportService).to receive(:new).and_return(organisation_service)
      allow(Imports::SchemeImportService).to receive(:new).and_return(scheme_service)
      allow(Imports::SchemeLocationImportService).to receive(:new).and_return(location_service)
      allow(Imports::UserImportService).to receive(:new).and_return(user_service)
      allow(Imports::DataProtectionConfirmationImportService).to receive(:new).and_return(data_protection_service)
      allow(Imports::OrganisationRentPeriodImportService).to receive(:new).and_return(rent_period_service)
      allow(Imports::CaseLogsImportService).to receive(:new).and_return(case_logs_service)
    end

    it "raises an exception if no parameters are provided" do
      expect { task.invoke }.to raise_error(/Usage/)
    end

    context "with all folders being present" do
      before { allow(storage_service).to receive(:folder_present?).and_return(true) }

      it "calls every import method with the correct folder" do
        expect(organisation_service).to receive(:create_organisations).with("#{fixture_path}/institution/")
        expect(scheme_service).to receive(:create_schemes).with("#{fixture_path}/mgmtgroups/")
        expect(location_service).to receive(:create_scheme_locations).with("#{fixture_path}/schemes/")
        expect(user_service).to receive(:create_users).with("#{fixture_path}/user/")
        expect(data_protection_service).to receive(:create_data_protection_confirmations).with("#{fixture_path}/dataprotect/")
        expect(rent_period_service).to receive(:create_organisation_rent_periods).with("#{fixture_path}/rent-period/")
        expect(case_logs_service).to receive(:create_logs).with("#{fixture_path}/logs/")

        task.invoke(fixture_path)
      end
    end

    context "when a specific folders are missing" do
      before do
        allow(storage_service).to receive(:folder_present?).and_return(true)
        allow(storage_service).to receive(:folder_present?).with("#{fixture_path}/mgmtgroups/").and_return(false)
        allow(storage_service).to receive(:folder_present?).with("#{fixture_path}/schemes/").and_return(false)
      end

      it "only calls import methods for existing folders" do
        expect(organisation_service).to receive(:create_organisations)
        expect(user_service).to receive(:create_users)
        expect(data_protection_service).to receive(:create_data_protection_confirmations)
        expect(rent_period_service).to receive(:create_organisation_rent_periods)
        expect(case_logs_service).to receive(:create_logs)

        expect(scheme_service).not_to receive(:create_schemes)
        expect(location_service).not_to receive(:create_scheme_locations)
        expect(Rails.logger).to receive(:info).with("spec/fixtures/imports/mgmtgroups/ does not exist, skipping Imports::SchemeImportService")
        expect(Rails.logger).to receive(:info).with("spec/fixtures/imports/schemes/ does not exist, skipping Imports::SchemeLocationImportService")

        task.invoke(fixture_path)
      end
    end
  end
end
