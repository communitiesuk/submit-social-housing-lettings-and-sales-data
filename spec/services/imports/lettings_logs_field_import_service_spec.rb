require "rails_helper"

RSpec.describe Imports::LettingsLogsFieldImportService do
  subject(:import_service) { described_class.new(storage_service, logger) }

  let(:storage_service) { instance_double(Storage::S3Service) }
  let(:logger) { instance_double(ActiveSupport::Logger) }

  let(:real_2021_2022_form) { Form.new("config/forms/2021_2022.json") }
  let(:fixture_directory) { "spec/fixtures/imports/logs" }

  let(:lettings_log_id) { "0ead17cb-1668-442d-898c-0d52879ff592" }
  let(:lettings_log_file) { File.open("#{fixture_directory}/#{lettings_log_id}.xml") }
  let(:lettings_log_xml) { Nokogiri::XML(lettings_log_file) }
  let(:remote_folder) { "lettings_logs" }
  let(:old_user_id) { "c3061a2e6ea0b702e6f6210d5c52d2a92612d2aa" }
  let(:organisation) { FactoryBot.create(:organisation, old_visible_id: "1", provider_type: "PRP") }

  around do |example|
    Timecop.freeze(Time.zone.local(2022, 1, 1)) do
      Singleton.__init__(FormHandler)
      example.run
    end
  end

  before do
    allow(Organisation).to receive(:find_by).and_return(organisation)

    # Created by users
    FactoryBot.create(:user, old_user_id:, organisation:)

    # Stub the form handler to use the real form
    allow(FormHandler.instance).to receive(:get_form).with("current_lettings").and_return(real_2021_2022_form)

    WebMock.stub_request(:get, /api.postcodes.io\/postcodes\/LS166FT/)
           .to_return(status: 200, body: '{"status":200,"result":{"codes":{"admin_district":"E08000035"}}}', headers: {})

    # Stub the S3 file listing and download
    allow(storage_service).to receive(:list_files)
                                .and_return(["#{remote_folder}/#{lettings_log_id}.xml"])
    allow(storage_service).to receive(:get_file_io)
                                .with("#{remote_folder}/#{lettings_log_id}.xml")
                                .and_return(lettings_log_file)
  end

  context "when updating tenant code" do
    let(:field) { "tenancycode" }

    context "and the lettings log was previously imported" do
      let(:lettings_log) { LettingsLog.find_by(old_id: lettings_log_id) }

      before do
        Imports::LettingsLogsImportService.new(storage_service, logger).create_logs(fixture_directory)
        lettings_log_file.rewind
      end

      it "logs that the tenancycode already has a value and does not update the lettings_log" do
        expect(logger).not_to receive(:info)
        expect { import_service.send(:update_field, field, remote_folder) }
          .not_to(change { lettings_log.reload.tenancycode })
      end
    end

    context "and the lettings log was previously imported with empty fields" do
      let(:lettings_log) { LettingsLog.find_by(old_id: lettings_log_id) }

      before do
        Imports::LettingsLogsImportService.new(storage_service, logger).create_logs(fixture_directory)
        lettings_log_file.rewind
        lettings_log.update!(tenancycode: nil)
      end

      it "updates the lettings_log" do
        expect { import_service.send(:update_field, field, remote_folder) }
          .to(change { lettings_log.reload.tenancycode })
      end
    end
  end

  context "when updating creation method" do
    let(:field) { "creation_method" }
    let(:lettings_log) { LettingsLog.find_by(old_id: lettings_log_id) }

    before do
      Imports::LettingsLogsImportService.new(storage_service, logger).create_logs(fixture_directory)
      lettings_log_file.rewind
    end

    context "and the log was manually entered" do
      it "logs that bulk upload id does not need setting" do
        expect(logger).to receive(:info).with("lettings log with old id #{lettings_log_id} entered manually, no need for update")
        expect { import_service.update_field(field, remote_folder) }.not_to(change { lettings_log.reload.creation_method })
      end
    end

    context "and the log was bulk uploaded and the creation method is already correct" do
      let(:lettings_log_id) { "166fc004-392e-47a8-acb8-1c018734882b" }

      it "logs that bulk upload id does not need setting" do
        expect(logger).to receive(:info).with(/lettings log \d+ creation method already set to bulk upload, no need for update/)
        expect { import_service.update_field(field, remote_folder) }.not_to(change { lettings_log.reload.creation_method })
      end
    end

    context "and the log was bulk uploaded and the creation method requires updating" do
      let(:lettings_log_id) { "166fc004-392e-47a8-acb8-1c018734882b" }

      it "logs that bulk upload id does not need setting" do
        lettings_log.creation_method_single_log!
        expect(logger).to receive(:info).with(/lettings log \d+ creation method set to bulk upload/)
        expect { import_service.update_field(field, remote_folder) }.to change { lettings_log.reload.creation_method }.to "bulk upload"
      end
    end

    context "and the log was not previously imported" do
      it "logs a warning that the log has not been found in the db" do
        lettings_log.destroy!
        expect(logger).to receive(:warn).with("lettings log with old id #{lettings_log_id} not found")
        import_service.update_field(field, remote_folder)
      end
    end
  end

  context "when updating lettings allocation values" do
    let(:field) { "lettings_allocation" }
    let(:lettings_log) { LettingsLog.find_by(old_id: lettings_log_id) }

    before do
      allow(logger).to receive(:warn)
      Imports::LettingsLogsImportService.new(storage_service, logger).create_logs(fixture_directory)
      lettings_log_file.rewind
    end

    context "when cbl" do
      let(:lettings_log_id) { "166fc004-392e-47a8-acb8-1c018734882b" }

      context "when it was incorrectly set" do
        before do
          lettings_log.update!(cbl: 1)
        end

        it "updates the value" do
          expect(logger).to receive(:info).with(/lettings log \d+'s cbl value has been updated/)
          expect { import_service.send(:update_field, field, remote_folder) }
            .to(change { lettings_log.reload.cbl }.from(1).to(0))
        end
      end

      context "when it was correctly set" do
        before do
          lettings_log.update!(cbl: 0)
        end

        it "does not update the value" do
          expect { import_service.send(:update_field, field, remote_folder) }
            .not_to(change { lettings_log.reload.cbl })
        end
      end
    end

    context "when chr" do
      let(:lettings_log_id) { "166fc004-392e-47a8-acb8-1c018734882b" }

      context "when it was incorrectly set" do
        before do
          lettings_log.update!(chr: 1)
        end

        it "updates the value" do
          expect(logger).to receive(:info).with(/lettings log \d+'s chr value has been updated/)
          expect { import_service.send(:update_field, field, remote_folder) }
            .to(change { lettings_log.reload.chr }.from(1).to(0))
        end
      end

      context "when it was correctly set" do
        before do
          lettings_log.update!(chr: 0)
        end

        it "does not update the value" do
          expect { import_service.send(:update_field, field, remote_folder) }
            .not_to(change { lettings_log.reload.chr })
        end
      end
    end

    context "when cap" do
      let(:lettings_log_id) { "0ead17cb-1668-442d-898c-0d52879ff592" }

      context "when it was incorrectly set" do
        before do
          lettings_log.update!(cap: 1)
        end

        it "updates the value" do
          expect(logger).to receive(:info).with(/lettings log \d+'s cap value has been updated/)
          expect { import_service.send(:update_field, field, remote_folder) }
            .to(change { lettings_log.reload.cap }.from(1).to(0))
        end
      end

      context "when it was correctly set" do
        before do
          lettings_log.update!(cap: 0)
        end

        it "does not update the value" do
          expect { import_service.send(:update_field, field, remote_folder) }
            .not_to(change { lettings_log.reload.cap })
        end
      end
    end

    context "when allocation type is none of cap, chr, cbl" do
      let(:lettings_log_id) { "893ufj2s-lq77-42m4-rty6-ej09gh585uy1" }

      context "when it did not have a value set for letting_allocation_unknown" do
        before do
          lettings_log.update!(letting_allocation_unknown: nil)
        end

        it "updates the value" do
          expect(logger).to receive(:info).with(/lettings log \d+'s letting_allocation_unknown value has been updated/)
          expect { import_service.send(:update_field, field, remote_folder) }
            .to(change { lettings_log.reload.letting_allocation_unknown }.from(nil).to(1))
        end
      end

      context "when it had a value set for letting_allocation_unknown" do
        before do
          lettings_log.update!(letting_allocation_unknown: 1)
        end

        it "updates the value" do
          expect { import_service.send(:update_field, field, remote_folder) }
            .not_to(change { lettings_log.reload.letting_allocation_unknown })
        end
      end
    end
  end

  context "when updating major repairs" do
    let(:field) { "major_repairs" }

    context "and the lettings log already has a value" do
      let(:lettings_log) { LettingsLog.find_by(old_id: lettings_log_id) }

      before do
        Imports::LettingsLogsImportService.new(storage_service, logger).create_logs(fixture_directory)
        lettings_log_file.rewind
        lettings_log.update!(majorrepairs: 0, mrcdate: Time.zone.local(2021, 10, 30, 10, 10, 10))
      end

      it "logs that major repairs already has a value and does not update major repairs" do
        expect(logger).not_to receive(:info)
        expect { import_service.send(:update_field, field, remote_folder) }
          .not_to(change { lettings_log.reload.majorrepairs })
      end

      it "logs that major repairs already has a value and does not update the major repairs date" do
        expect(logger).not_to receive(:info)
        expect { import_service.send(:update_field, field, remote_folder) }
          .not_to(change { lettings_log.reload.mrcdate })
      end
    end

    context "and the lettings log was previously imported with empty fields" do
      let(:lettings_log) { LettingsLog.find_by(old_id: lettings_log_id) }

      before do
        Imports::LettingsLogsImportService.new(storage_service, logger).create_logs(fixture_directory)
        lettings_log_file.rewind
        lettings_log.update!(mrcdate: nil, majorrepairs: nil)
      end

      it "updates the lettings_log major repairs date" do
        expect(logger).to receive(:info).with(/lettings log \d+'s major repair value has been updated/)
        expect { import_service.send(:update_field, field, remote_folder) }
          .to(change { lettings_log.reload.mrcdate })
      end

      it "updates the lettings_log major repairs" do
        expect(logger).to receive(:info).with(/lettings log \d+'s major repair value has been updated/)
        expect { import_service.send(:update_field, field, remote_folder) }
          .to(change { lettings_log.reload.majorrepairs })
      end
    end
  end

  context "when updating offered" do
    let(:field) { "offered" }

    context "when the lettings log has no offered value" do
      let(:lettings_log) { LettingsLog.find_by(old_id: lettings_log_id) }

      before do
        Imports::LettingsLogsImportService.new(storage_service, logger).create_logs(fixture_directory)
        lettings_log_file.rewind
        lettings_log.update!(offered: nil)
      end

      it "updates the lettings_log offered value" do
        expect(logger).to receive(:info).with(/lettings log \d+'s offered value has been set to 21/)
        expect { import_service.send(:update_field, field, remote_folder) }
          .to(change { lettings_log.reload.offered }.from(nil).to(21))
      end
    end

    context "when the lettings log has a different offered value" do
      let(:lettings_log) { LettingsLog.find_by(old_id: lettings_log_id) }

      before do
        Imports::LettingsLogsImportService.new(storage_service, logger).create_logs(fixture_directory)
        lettings_log_file.rewind
        lettings_log.update!(offered: 18)
      end

      it "does not update the lettings_log offered value" do
        expect(logger).not_to receive(:info)
        expect { import_service.send(:update_field, field, remote_folder) }
          .not_to(change { lettings_log.reload.offered })
      end
    end
  end
end
