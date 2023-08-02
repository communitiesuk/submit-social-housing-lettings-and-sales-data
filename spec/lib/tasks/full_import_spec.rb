require "rails_helper"
require "rake"

describe "full import", type: :task do
  let(:instance_name) { "paas_import_instance" }
  let(:paas_config_service) { instance_double(Configuration::PaasConfigurationService) }
  let(:storage_service) { instance_double(Storage::S3Service) }
  let(:orgs_list) { "Institution name,Id,Old Completed lettings logs,Old In progress lettings logs,Old Completed sales logs,Old In progress sales logs\norg1,1.zip,0,0,0,0\norg2,2.zip,0,0,0,0" }

  before do
    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(storage_service).to receive(:write_file).and_return(nil)
    allow(storage_service).to receive(:get_file_io).and_return(orgs_list)
    allow(Configuration::PaasConfigurationService).to receive(:new).and_return(paas_config_service)
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with("IMPORT_PAAS_INSTANCE").and_return(instance_name)
  end

  describe "import:generate_report" do
    subject(:task) { Rake::Task["import:generate_report"] }

    before do
      Rake.application.rake_require("tasks/full_import")
      Rake::Task.define_task(:environment)
      task.reenable

      create(:organisation, old_visible_id: 1, name: "org1")
      create(:organisation, old_visible_id: 2, name: "org2")
    end

    context "when generating report" do
      let(:import_report_service) { instance_double(Imports::ImportReportService) }

      before do
        allow(Imports::ImportReportService).to receive(:new).and_return(import_report_service)
      end

      it "creates an organisation from the given XML file" do
        expect(Storage::S3Service).to receive(:new).with(paas_config_service, instance_name)
        expect(Imports::ImportReportService).to receive(:new).with(storage_service, %w[1 2])
        expect(import_report_service).to receive(:generate_missing_data_coordinators_report).with("some_name")

        task.invoke("some_name")
      end
    end
  end
end
