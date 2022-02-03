require "rails_helper"
require "rake"

describe "rake data_import:organisations", type: :task do
  subject(:task) { Rake::Task["data_import:organisations"] }

  let(:fixture_path) { "spec/fixtures/softwire_imports/organisations" }
  let(:instance_name) { "my_instance" }
  let(:storage_service) { instance_double(StorageService) }
  let(:paas_config_service) { instance_double(PaasConfigurationService) }
  let(:import_service) { instance_double(ImportService) }

  before do
    allow(StorageService).to receive(:new).and_return(storage_service)
    allow(PaasConfigurationService).to receive(:new).and_return(paas_config_service)
    allow(ImportService).to receive(:new).and_return(import_service)
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with("IMPORT_PAAS_INSTANCE").and_return(instance_name)

    Rake.application.rake_require("tasks/data_import/organisations")
    Rake::Task.define_task(:environment)
    task.reenable
  end

  it "creates an organisation from the given XML file" do
    expect(StorageService).to receive(:new).with(paas_config_service, instance_name)
    expect(ImportService).to receive(:new).with(storage_service)
    expect(import_service).to receive(:update_organisations).with(fixture_path)

    task.invoke(fixture_path)
  end
end
