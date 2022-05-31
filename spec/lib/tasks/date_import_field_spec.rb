require "rails_helper"
require "rake"

describe "rake core:data_import_field", type: :task do
  subject(:task) { Rake::Task["core:data_import_field"] }

  let(:instance_name) { "paas_import_instance" }
  let(:storage_service) { instance_double(StorageService) }
  let(:paas_config_service) { instance_double(PaasConfigurationService) }

  before do
    Rake.application.rake_require("tasks/data_import_field")
    Rake::Task.define_task(:environment)
    task.reenable

    allow(StorageService).to receive(:new).and_return(storage_service)
    allow(PaasConfigurationService).to receive(:new).and_return(paas_config_service)
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with("IMPORT_PAAS_INSTANCE").and_return(instance_name)
  end

  context "when importing a case log field" do
    let(:import_service) { instance_double(Imports::CaseLogsFieldImportService) }
    let(:fixture_path) { "spec/fixtures/softwire_imports/case_logs" }

    before do
      allow(Imports::CaseLogsFieldImportService).to receive(:new).and_return(import_service)
      allow(import_service).to receive(:update_field)
    end

    context "and we update the tenant_code field" do
      let(:field) { "tenant_code" }

      it "properly configures the storage service" do
        expect(StorageService).to receive(:new).with(paas_config_service, instance_name)
        task.invoke(field, fixture_path)
      end

      it "calls the expected update method with parameters" do
        expect(import_service).to receive(:update_field).with(field, fixture_path)
        task.invoke(field, fixture_path)
      end
    end

    context "and we update the major repairs fields" do
      let(:field) { "major_repairs" }

      it "properly configures the storage service" do
        expect(StorageService).to receive(:new).with(paas_config_service, instance_name)
        task.invoke(field, fixture_path)
      end

      it "calls the expected update method with parameters" do
        expect(import_service).to receive(:update_field).with(field, fixture_path)
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
