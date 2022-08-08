require "rails_helper"
require "rake"

describe "rake core:full_import", type: :task do
  subject(:task) { Rake::Task["core:full_import"] }

  let(:instance_name) { "paas_import_instance" }
  let(:storage_service) { instance_double(StorageService) }
  let(:paas_config_service) { instance_double(PaasConfigurationService) }

  before do
    Rake.application.rake_require("tasks/full_import")
    Rake::Task.define_task(:environment)
    task.reenable

    allow(StorageService).to receive(:new).and_return(storage_service)
    allow(PaasConfigurationService).to receive(:new).and_return(paas_config_service)
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with("IMPORT_PAAS_INSTANCE").and_return(instance_name)
  end

  context "when starting a full import" do
    it "raises an exception if no parameters are provided" do
      expect { task.invoke }.to raise_error(/Usage/)
    end

    context "with all folders being present"
      let(:organisation_service) { instance_double(Imports::OrganisationImportService) }
      let(:scheme_service) { instance_double(Imports::SchemeImportService) }
      let(:location_service) { instance_double(Imports::SchemeLocationImportService) }
      let(:user_service) { instance_double(Imports::UserImportService) }
      let(:data_protection_service) { instance_double(Imports::DataProtectionConfirmationImportService) }
      let(:rent_period_service) { instance_double(Imports::OrganisationRentPeriodImportService) }
      let(:case_logs_service) { instance_double(Imports::CaseLogsImportService) }
      let(:fixture_path) { "spec/fixtures/imports" }

    before do
        allow(Imports::OrganisationImportService).to receive(:new).and_return(organisation_service)
        allow(Imports::SchemeImportService).to receive(:new).and_return(scheme_service)
        allow(Imports::SchemeLocationImportService).to receive(:new).and_return(location_service)
        allow(Imports::UserImportService).to receive(:new).and_return(user_service)
        allow(Imports::DataProtectionConfirmationImportService).to receive(:new).and_return(data_protection_service)
        allow(Imports::OrganisationRentPeriodImportService).to receive(:new).and_return(rent_period_service)
        allow(Imports::CaseLogsImportService).to receive(:new).and_return(case_logs_service)
    end

    it "calls every import method" do
      expect(organisation_service).to receive(:create_organisations).with(fixture_path)
      expect(scheme_service).to receive(:create_schemes).with(fixture_path)
      expect(location_service).to receive(:create_scheme_locations).with(fixture_path)
      expect(user_service).to receive(:create_users).with(fixture_path)
      expect(data_protection_service).to receive(:create_data_protection_confirmations).with(fixture_path)
      expect(rent_period_service).to receive(:create_organisation_rent_periods).with(fixture_path)
      expect(case_logs_service).to receive(:create_logs).with(fixture_path)

      task.invoke(fixture_path)
    end
  end
end
