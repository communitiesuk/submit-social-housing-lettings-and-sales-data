require "rails_helper"

RSpec.describe Imports::CaseLogsImportService do
  let(:remote_folder) { "case_logs" }
  let(:fixture_directory) { "spec/fixtures/softwire_imports/case_logs" }
  let(:case_log_id) { "0ead17cb-1668-442d-898c-0d52879ff592" }
  let(:case_log_file) { File.open("#{fixture_directory}/#{case_log_id}.xml") }
  let(:storage_service) { instance_double(StorageService) }
  let(:real_2021_2022_form) { Form.new("config/forms/2021_2022.json", "2021_2022") }

  context "when importing users" do
    subject(:case_log_service) { described_class.new(storage_service) }

    before do
      # Stub the S3 file listing and download
      allow(storage_service).to receive(:list_files)
                                  .and_return(["#{remote_folder}/#{case_log_id}.xml"])
      allow(storage_service).to receive(:get_file_io)
                                  .with("#{remote_folder}/#{case_log_id}.xml")
                                  .and_return(case_log_file)
      # Stub the form handler to use the real form
      allow(FormHandler.instance).to receive(:get_form).with(anything).and_return(real_2021_2022_form)
    end

    it "successfully create a case log with the expected data" do
      case_log_service.create_logs(remote_folder)

    end
  end
end
