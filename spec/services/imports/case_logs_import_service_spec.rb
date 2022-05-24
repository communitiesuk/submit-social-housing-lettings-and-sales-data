require "rails_helper"

RSpec.describe Imports::CaseLogsImportService do
  subject(:case_log_service) { described_class.new(storage_service, logger) }

  let(:storage_service) { instance_double(StorageService) }
  let(:logger) { instance_double(ActiveSupport::Logger) }

  let(:real_2021_2022_form) { Form.new("config/forms/2021_2022.json", "2021_2022") }
  let(:real_2022_2023_form) { Form.new("config/forms/2022_2023.json", "2022_2023") }
  let(:fixture_directory) { "spec/fixtures/softwire_imports/case_logs" }

  def open_file(directory, filename)
    File.open("#{directory}/#{filename}.xml")
  end

  before do
    # Owning and Managing organisations
    FactoryBot.create(:organisation, old_visible_id: "1", provider_type: "PRP")

    # Created by users
    FactoryBot.create(:user, old_user_id: "c3061a2e6ea0b702e6f6210d5c52d2a92612d2aa")
    FactoryBot.create(:user, old_user_id: "e29c492473446dca4d50224f2bb7cf965a261d6f")

    # Stub the form handler to use the real form
    allow(FormHandler.instance).to receive(:get_form).with("2021_2022").and_return(real_2021_2022_form)
    allow(FormHandler.instance).to receive(:get_form).with("2022_2023").and_return(real_2022_2023_form)

    WebMock.stub_request(:get, /api.postcodes.io\/postcodes\/LS166FT/)
           .to_return(status: 200, body: '{"status":200,"result":{"codes":{"admin_district":"E08000035"}}}', headers: {})
  end

  context "when importing users" do
    let(:remote_folder) { "case_logs" }
    let(:case_log_id) { "0ead17cb-1668-442d-898c-0d52879ff592" }
    let(:case_log_id2) { "166fc004-392e-47a8-acb8-1c018734882b" }
    let(:case_log_id3) { "00d2343e-d5fa-4c89-8400-ec3854b0f2b4" }

    before do
      # Stub the S3 file listing and download
      allow(storage_service).to receive(:list_files)
                                  .and_return(%W[#{remote_folder}/#{case_log_id}.xml #{remote_folder}/#{case_log_id2}.xml #{remote_folder}/#{case_log_id3}.xml])
      allow(storage_service).to receive(:get_file_io)
                                  .with("#{remote_folder}/#{case_log_id}.xml")
                                  .and_return(open_file(fixture_directory, case_log_id), open_file(fixture_directory, case_log_id))
      allow(storage_service).to receive(:get_file_io)
                                  .with("#{remote_folder}/#{case_log_id2}.xml")
                                  .and_return(open_file(fixture_directory, case_log_id2), open_file(fixture_directory, case_log_id2))
      allow(storage_service).to receive(:get_file_io)
                                  .with("#{remote_folder}/#{case_log_id3}.xml")
                                  .and_return(open_file(fixture_directory, case_log_id3), open_file(fixture_directory, case_log_id3))
    end

    it "successfully create all case logs" do
      expect(logger).not_to receive(:error)
      expect(logger).not_to receive(:warn)
      expect(logger).not_to receive(:info)
      expect { case_log_service.create_logs(remote_folder) }
        .to change(CaseLog, :count).by(3)
    end

    it "only updates existing case logs" do
      expect(logger).not_to receive(:error)
      expect(logger).not_to receive(:warn)
      expect(logger).to receive(:info).with(/Updating case log/).exactly(3).times
      expect { 2.times { case_log_service.create_logs(remote_folder) } }
        .to change(CaseLog, :count).by(3)
    end
  end

  context "when import a specific log" do
    let(:case_log_id) { "0ead17cb-1668-442d-898c-0d52879ff592" }
    let(:case_log_file) { open_file(fixture_directory, case_log_id) }

    context "and the void date is after the start date" do
      let(:case_log_xml) do
        xml_doc = Nokogiri::XML(case_log_file)
        xml_doc.at_xpath("//xmlns:VYEAR").content = 2023
        xml_doc
      end

      it "does not import the voiddate" do
        allow(logger).to receive(:warn).with(/is not completed/)
        case_log_service.send(:create_log, case_log_xml)

        case_log = CaseLog.where(old_id: case_log_id).first
        expect(case_log).not_to be_nil
        expect(case_log.voiddate).to be_nil
      end
    end

    context "and the organisation legacy ID does not exist" do
      let(:case_log_xml) do
        xml_doc = Nokogiri::XML(case_log_file)
        xml_doc.at_xpath("//xmlns:OWNINGORGID").content = 99999
        xml_doc
      end

      it "raises an exception" do
        expect { case_log_service.send(:create_log, case_log_xml) }
          .to raise_error(RuntimeError, "Organisation not found with legacy ID 99999")
      end
    end
  end
end
