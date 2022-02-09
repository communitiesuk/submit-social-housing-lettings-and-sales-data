require "rails_helper"
require "rake"

describe "rake core:data_import", type: :task do
  subject(:task) { Rake::Task["core:data_import"] }

  let(:fixture_path) { "spec/fixtures/softwire_imports/organisations" }
  let(:instance_name) { "paas_import_instance" }
  let(:organisation_type) { "organisation" }

  let(:storage_service) { instance_double(StorageService) }
  let(:paas_config_service) { instance_double(PaasConfigurationService) }
  let(:import_service) { instance_double(Imports::OrganisationImportService) }

  before do
    Rake.application.rake_require("tasks/data_import")
    Rake::Task.define_task(:environment)
    task.reenable

    allow(StorageService).to receive(:new).and_return(storage_service)
    allow(PaasConfigurationService).to receive(:new).and_return(paas_config_service)
    allow(Imports::OrganisationImportService).to receive(:new).and_return(import_service)
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with("IMPORT_PAAS_INSTANCE").and_return(instance_name)
  end

  context "when importing organisation data" do
    it "creates an organisation from the given XML file" do
      expect(StorageService).to receive(:new).with(paas_config_service, instance_name)
      expect(Imports::OrganisationImportService).to receive(:new).with(storage_service)
      expect(import_service).to receive(:create_organisations).with(fixture_path)

      task.invoke(organisation_type, fixture_path)
    end
  end

  it "raises an exception if no parameters are provided" do
    expect { task.invoke }.to raise_error(/Usage/)
  end

  it "raises an exception if a single parameter is provided" do
    expect { task.invoke("one_parameter") }.to raise_error(/Usage/)
  end

  it "raises an exception if the type is not supported" do
    expect { task.invoke("unknown_type", "my_path") }.to raise_error(/Type unknown_type is not supported/)
  end
end
