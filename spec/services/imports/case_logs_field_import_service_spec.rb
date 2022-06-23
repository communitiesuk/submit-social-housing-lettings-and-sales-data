require "rails_helper"

RSpec.describe Imports::CaseLogsFieldImportService do
  subject(:import_service) { described_class.new(storage_service, logger) }

  let(:storage_service) { instance_double(StorageService) }
  let(:logger) { instance_double(ActiveSupport::Logger) }

  let(:real_2021_2022_form) { Form.new("config/forms/2021_2022.json", "2021_2022") }
  let(:fixture_directory) { "spec/fixtures/softwire_imports/case_logs" }

  let(:case_log_id) { "0ead17cb-1668-442d-898c-0d52879ff592" }
  let(:case_log_file) { open_file(fixture_directory, case_log_id) }
  let(:case_log_xml) { Nokogiri::XML(case_log_file) }
  let(:remote_folder) { "case_logs" }
  let(:old_user_id) { "c3061a2e6ea0b702e6f6210d5c52d2a92612d2aa" }
  let(:organisation) { FactoryBot.create(:organisation, old_visible_id: "1", provider_type: "PRP") }

  def open_file(directory, filename)
    File.open("#{directory}/#{filename}.xml")
  end

  before do
    allow(Organisation).to receive(:find_by).and_return(organisation)

    # Created by users
    FactoryBot.create(:user, old_user_id:, organisation:)

    # Stub the form handler to use the real form
    allow(FormHandler.instance).to receive(:get_form).with("2021_2022").and_return(real_2021_2022_form)

    WebMock.stub_request(:get, /api.postcodes.io\/postcodes\/LS166FT/)
           .to_return(status: 200, body: '{"status":200,"result":{"codes":{"admin_district":"E08000035"}}}', headers: {})

    # Stub the S3 file listing and download
    allow(storage_service).to receive(:list_files)
                                .and_return(["#{remote_folder}/#{case_log_id}.xml"])
    allow(storage_service).to receive(:get_file_io)
                                .with("#{remote_folder}/#{case_log_id}.xml")
                                .and_return(case_log_file)
  end

  context "when updating tenant code" do
    let(:field) { "tenancycode" }

    context "and the case log was previously imported" do
      let(:case_log) { CaseLog.find_by(old_id: case_log_id) }

      before do
        Imports::CaseLogsImportService.new(storage_service, logger).create_logs(fixture_directory)
        case_log_file.rewind
      end

      it "logs that the tenancycode already has a value and does not update the case_log" do
        expect(logger).to receive(:info).with(/Case Log \d+ has a value for tenancycode, skipping update/)
        expect { import_service.send(:update_field, field, remote_folder) }
          .not_to(change { case_log.reload.tenancycode })
      end
    end

    context "and the case log was previously imported with empty fields" do
      let(:case_log) { CaseLog.find_by(old_id: case_log_id) }

      before do
        Imports::CaseLogsImportService.new(storage_service, logger).create_logs(fixture_directory)
        case_log_file.rewind
        case_log.update!(tenancycode: nil)
      end

      it "updates the case_log" do
        expect { import_service.send(:update_field, field, remote_folder) }
          .to(change { case_log.reload.tenancycode })
      end
    end
  end

  context "when updating letings allocation values" do
    let(:field) { "lettings_allocation" }
    let(:case_log) { CaseLog.find_by(old_id: case_log_id) }

    before do
      allow(logger).to receive(:warn)
      Imports::CaseLogsImportService.new(storage_service, logger).create_logs(fixture_directory)
      case_log_file.rewind
    end

    context "when cbl" do
      let(:case_log_id) { "166fc004-392e-47a8-acb8-1c018734882b" }

      context "when it was incorrectly set" do
        before do
          case_log.update!(cbl: 1)
        end

        it "updates the value" do
          expect(logger).to receive(:info).with(/Case Log \d+'s cbl value has been updated/)
          expect { import_service.send(:update_field, field, remote_folder) }
            .to(change { case_log.reload.cbl }.from(1).to(0))
        end
      end

      context "when it was correctly set" do
        before do
          case_log.update!(cbl: 0)
        end

        it "does not update the value" do
          expect { import_service.send(:update_field, field, remote_folder) }
            .not_to(change { case_log.reload.cbl })
        end
      end
    end

    context "when chr" do
      let(:case_log_id) { "166fc004-392e-47a8-acb8-1c018734882b" }

      context "when it was incorrectly set" do
        before do
          case_log.update!(chr: 1)
        end

        it "updates the value" do
          expect(logger).to receive(:info).with(/Case Log \d+'s chr value has been updated/)
          expect { import_service.send(:update_field, field, remote_folder) }
            .to(change { case_log.reload.chr }.from(1).to(0))
        end
      end

      context "when it was correctly set" do
        before do
          case_log.update!(chr: 0)
        end

        it "does not update the value" do
          expect { import_service.send(:update_field, field, remote_folder) }
            .not_to(change { case_log.reload.chr })
        end
      end
    end

    context "when cap" do
      let(:case_log_id) { "0ead17cb-1668-442d-898c-0d52879ff592" }

      context "when it was incorrectly set" do
        before do
          case_log.update!(cap: 1)
        end

        it "updates the value" do
          expect(logger).to receive(:info).with(/Case Log \d+'s cap value has been updated/)
          expect { import_service.send(:update_field, field, remote_folder) }
            .to(change { case_log.reload.cap }.from(1).to(0))
        end
      end

      context "when it was correctly set" do
        before do
          case_log.update!(cap: 0)
        end

        it "does not update the value" do
          expect { import_service.send(:update_field, field, remote_folder) }
            .not_to(change { case_log.reload.cap })
        end
      end
    end

    context "when allocation type is none of cap, chr, cbl" do
      let(:case_log_id) { "893ufj2s-lq77-42m4-rty6-ej09gh585uy1" }

      context "when it did not have a value set for letting_allocation_unknown" do
        before do
          case_log.update!(letting_allocation_unknown: nil)
        end

        it "updates the value" do
          expect(logger).to receive(:info).with(/Case Log \d+'s letting_allocation_unknown value has been updated/)
          expect { import_service.send(:update_field, field, remote_folder) }
            .to(change { case_log.reload.letting_allocation_unknown }.from(nil).to(1))
        end
      end

      context "when it had a value set for letting_allocation_unknown" do
        before do
          case_log.update!(letting_allocation_unknown: 1)
        end

        it "updates the value" do
          expect { import_service.send(:update_field, field, remote_folder) }
            .not_to(change { case_log.reload.letting_allocation_unknown })
        end
      end
    end
  end

  context "when updating major repairs" do
    let(:field) { "major_repairs" }

    context "and the case log already has a value" do
      let(:case_log) { CaseLog.find_by(old_id: case_log_id) }

      before do
        Imports::CaseLogsImportService.new(storage_service, logger).create_logs(fixture_directory)
        case_log_file.rewind
        case_log.update!(majorrepairs: 0, mrcdate: Time.zone.local(2021, 10, 30, 10, 10, 10))
      end

      it "logs that major repairs already has a value and does not update major repairs" do
        expect(logger).to receive(:info).with(/Case Log \d+ has a value for major repairs, skipping update/)
        expect { import_service.send(:update_field, field, remote_folder) }
          .not_to(change { case_log.reload.majorrepairs })
      end

      it "logs that major repairs already has a value and does not update the major repairs date" do
        expect(logger).to receive(:info).with(/Case Log \d+ has a value for major repairs, skipping update/)
        expect { import_service.send(:update_field, field, remote_folder) }
          .not_to(change { case_log.reload.mrcdate })
      end
    end

    context "and the case log was previously imported with empty fields" do
      let(:case_log) { CaseLog.find_by(old_id: case_log_id) }

      before do
        Imports::CaseLogsImportService.new(storage_service, logger).create_logs(fixture_directory)
        case_log_file.rewind
        case_log.update!(mrcdate: nil, majorrepairs: nil)
      end

      it "updates the case_log major repairs date" do
        expect(logger).to receive(:info).with(/Case Log \d+'s major repair value has been updated/)
        expect { import_service.send(:update_field, field, remote_folder) }
          .to(change { case_log.reload.mrcdate })
      end

      it "updates the case_log major repairs" do
        expect(logger).to receive(:info).with(/Case Log \d+'s major repair value has been updated/)
        expect { import_service.send(:update_field, field, remote_folder) }
          .to(change { case_log.reload.majorrepairs })
      end
    end
  end
end
