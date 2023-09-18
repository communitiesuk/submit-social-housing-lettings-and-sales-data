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
        expect(logger).to receive(:info).with(/lettings log \d+ has a value for tenancycode, skipping update/)
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
        expect(logger).to receive(:info).with(/lettings log \d+ has a value for major repairs, skipping update/)
        expect { import_service.send(:update_field, field, remote_folder) }
          .not_to(change { lettings_log.reload.majorrepairs })
      end

      it "logs that major repairs already has a value and does not update the major repairs date" do
        expect(logger).to receive(:info).with(/lettings log \d+ has a value for major repairs, skipping update/)
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
        expect(logger).to receive(:info).with(/lettings log \d+ has a value for offered, skipping update/)
        expect { import_service.send(:update_field, field, remote_folder) }
          .not_to(change { lettings_log.reload.offered })
      end
    end
  end

  context "when updating address" do
    let(:field) { "address" }

    before do
      WebMock.stub_request(:get, /api.postcodes.io\/postcodes\/B11BB/)
      .to_return(status: 200, body: '{"status":200,"result":{"admin_district":"Westminster","codes":{"admin_district":"E08000035"}}}', headers: {})

      stub_request(:get, "https://api.os.uk/search/places/v1/uprn?key=OS_DATA_KEY&uprn=123")
        .to_return(status: 500, body: "{}", headers: {})

      Timecop.freeze(2023, 5, 5)
      Singleton.__init__(FormHandler)
      Imports::LettingsLogsImportService.new(storage_service, logger).create_logs(fixture_directory)
      lettings_log_file.rewind
    end

    after do
      Timecop.unfreeze
      Singleton.__init__(FormHandler)
    end

    context "when the lettings log has no address values" do
      let(:lettings_log_id) { "00d2343e-d5fa-4c89-8400-ec3854b0f2b4" }
      let(:lettings_log) { LettingsLog.find_by(old_id: lettings_log_id) }

      before do
        lettings_log.update!(uprn_known: nil,
                             startdate: Time.zone.local(2023, 5, 5),
                             uprn: nil,
                             uprn_confirmed: nil,
                             address_line1: nil,
                             address_line2: nil,
                             town_or_city: nil,
                             county: nil,
                             postcode_known: nil,
                             postcode_full: nil,
                             la: nil,
                             is_la_inferred: nil)
      end

      context "and new address values include address" do
        before do
          lettings_log_xml.at_xpath("//xmlns:UPRN").content = "123456781234"
          lettings_log_xml.at_xpath("//xmlns:AddressLine1").content = "address 1"
          lettings_log_xml.at_xpath("//xmlns:AddressLine2").content = "address 2"
          lettings_log_xml.at_xpath("//xmlns:TownCity").content = "towncity"
          lettings_log_xml.at_xpath("//xmlns:County").content = "county"
          lettings_log_xml.at_xpath("//xmlns:POSTCODE").content = "B1"
          lettings_log_xml.at_xpath("//xmlns:POSTCOD2").content = "1BB"
          lettings_log_xml.at_xpath("//xmlns:Q28ONS").content = nil
        end

        it "updates the lettings_log prioritising address values" do
          expect(logger).to receive(:info).with(/lettings log #{lettings_log.id} address_line1 value has been set to address 1/)
          expect(logger).to receive(:info).with(/lettings log #{lettings_log.id} address_line2 value has been set to address 2/)
          expect(logger).to receive(:info).with(/lettings log #{lettings_log.id} town_or_city value has been set to towncity/)
          expect(logger).to receive(:info).with(/lettings log #{lettings_log.id} county value has been set to county/)
          expect(logger).to receive(:info).with(/lettings log #{lettings_log.id} postcode_full value has been set to B1 1BB/)
          import_service.send(:update_address, lettings_log_xml)
          lettings_log.reload

          expect(lettings_log.uprn_known).to eq(0)
          expect(lettings_log.uprn).to eq(nil)
          expect(lettings_log.uprn_confirmed).to eq(nil)
          expect(lettings_log.address_line1).to eq("address 1")
          expect(lettings_log.address_line2).to eq("address 2")
          expect(lettings_log.town_or_city).to eq("towncity")
          expect(lettings_log.county).to eq("county")
          expect(lettings_log.postcode_known).to eq(1)
          expect(lettings_log.postcode_full).to eq("B1 1BB")
          expect(lettings_log.la).to eq("E08000035")
          expect(lettings_log.is_la_inferred).to eq(true)
        end
      end

      context "and new address values don't include address" do
        it "skips the update" do
          expect(logger).to receive(:info).with(/lettings log #{lettings_log.id} is missing either or both of address_line1 and town or city, skipping/)
          import_service.send(:update_address, lettings_log_xml)
        end
      end
    end

    context "when the lettings log has address values" do
      let(:lettings_log_id) { "00d2343e-d5fa-4c89-8400-ec3854b0f2b4" }
      let(:lettings_log) { LettingsLog.find_by(old_id: lettings_log_id) }

      before do
        lettings_log_xml.at_xpath("//xmlns:UPRN").content = "123456781234"
        lettings_log_xml.at_xpath("//xmlns:AddressLine1").content = "address 1"
        lettings_log_xml.at_xpath("//xmlns:AddressLine2").content = "address 2"
        lettings_log_xml.at_xpath("//xmlns:TownCity").content = "towncity"
        lettings_log_xml.at_xpath("//xmlns:County").content = "county"
        lettings_log_xml.at_xpath("//xmlns:POSTCODE").content = "B1"
        lettings_log_xml.at_xpath("//xmlns:POSTCOD2").content = "1BC"
        lettings_log_xml.at_xpath("//xmlns:Q28ONS").content = nil
        lettings_log.update!(uprn_known: 1,
                             startdate: Time.zone.local(2023, 5, 5),
                             uprn: "123",
                             uprn_confirmed: 0,
                             address_line1: "wrong address line1",
                             address_line2: "wrong address 2",
                             town_or_city: "wrong town",
                             county: "wrong city",
                             postcode_known: 1,
                             postcode_full: "A11AA",
                             la: "E06000064",
                             is_la_inferred: true)
      end

      it "replaces the lettings_log address values" do
        expect(logger).to receive(:info).with(/lettings log #{lettings_log.id} address_line1 value has been set to address 1/)
        expect(logger).to receive(:info).with(/lettings log #{lettings_log.id} address_line2 value has been set to address 2/)
        expect(logger).to receive(:info).with(/lettings log #{lettings_log.id} town_or_city value has been set to towncity/)
        expect(logger).to receive(:info).with(/lettings log #{lettings_log.id} county value has been set to county/)
        expect(logger).to receive(:info).with(/lettings log #{lettings_log.id} postcode_full value has been set to B11BC/)
        import_service.send(:update_address, lettings_log_xml)
        lettings_log.reload

        expect(lettings_log.uprn_known).to eq(0)
        expect(lettings_log.uprn).to eq(nil)
        expect(lettings_log.uprn_confirmed).to eq(nil)
        expect(lettings_log.address_line1).to eq("address 1")
        expect(lettings_log.address_line2).to eq("address 2")
        expect(lettings_log.town_or_city).to eq("towncity")
        expect(lettings_log.county).to eq("county")
        expect(lettings_log.postcode_known).to eq(1)
        expect(lettings_log.postcode_full).to eq("B11BC")
        expect(lettings_log.la).to eq(nil)
        expect(lettings_log.is_la_inferred).to eq(false)
      end
    end

    context "when the lettings log is from before collection 23/24" do
      let(:lettings_log_id) { "00d2343e-d5fa-4c89-8400-ec3854b0f2b4" }
      let(:lettings_log) { LettingsLog.find_by(old_id: lettings_log_id) }

      before do
        lettings_log.update!(startdate: Time.zone.local(2022, 5, 5))
      end

      it "skips the update" do
        expect(logger).to receive(:info).with(/lettings log #{lettings_log.id} is from previous collection year, skipping/)
        import_service.send(:update_address, lettings_log_xml)
      end
    end
  end

  context "when updating reason" do
    let(:field) { "reason" }

    context "when the lettings log has no reason value" do
      let(:lettings_log) { LettingsLog.find_by(old_id: lettings_log_id) }

      before do
        Imports::LettingsLogsImportService.new(storage_service, logger).create_logs(fixture_directory)
        lettings_log_file.rewind
        lettings_log.update!(reason: nil, values_updated_at: nil)
        lettings_log_xml.at_xpath("//xmlns:Q9a").content = "47"
      end

      it "updates the lettings_log reason value" do
        expect(logger).to receive(:info).with(/lettings log \d+'s reason value has been set to 47/)
        expect { import_service.send(:update_reason, lettings_log_xml) }
          .to(change { lettings_log.reload.reason }.from(nil).to(47))
        expect(lettings_log.values_updated_at).not_to be_nil
      end
    end

    context "when the lettings log has a different reason value" do
      let(:lettings_log) { LettingsLog.find_by(old_id: lettings_log_id) }

      before do
        Imports::LettingsLogsImportService.new(storage_service, logger).create_logs(fixture_directory)
        lettings_log_file.rewind
        lettings_log.update!(reason: 18, values_updated_at: nil)
        lettings_log_xml.at_xpath("//xmlns:Q9a").content = "47"
      end

      it "does not update the lettings_log reason value" do
        expect(logger).to receive(:info).with(/lettings log \d+ has a value for reason, skipping update/)
        expect { import_service.send(:update_reason, lettings_log_xml) }
          .not_to(change { lettings_log.reload.reason })
        expect(lettings_log.values_updated_at).to be_nil
      end
    end

    context "when the new value is 'other'" do
      let(:lettings_log) { LettingsLog.find_by(old_id: lettings_log_id) }

      before do
        Imports::LettingsLogsImportService.new(storage_service, logger).create_logs(fixture_directory)
        lettings_log_file.rewind
        lettings_log.update!(reason: nil, values_updated_at: nil)
        lettings_log_xml.at_xpath("//xmlns:Q9a").content = "20"
      end

      context "and other value is given" do
        before do
          lettings_log_xml.at_xpath("//xmlns:Q9aa").content = "other"
        end

        it "updates the lettings_log reason value" do
          expect(logger).to receive(:info).with(/lettings log \d+'s reason value has been set to 20/)
          expect(logger).to receive(:info).with(/lettings log \d+'s reasonother value has been set to other/)
          expect { import_service.send(:update_reason, lettings_log_xml) }
            .to(change { lettings_log.reload.reason }.from(nil).to(20))
          expect(lettings_log.values_updated_at).not_to be_nil
        end
      end

      context "and other value is not given" do
        it "does not update the lettings_log reason value" do
          expect(logger).to receive(:info).with(/lettings log \d+'s reason is other but other reason is not provided, skipping update/)
          expect { import_service.send(:update_reason, lettings_log_xml) }
            .not_to(change { lettings_log.reload.reason })
          expect(lettings_log.values_updated_at).to be_nil
        end
      end
    end
  end

  context "when updating homeless fields" do
    let(:field) { "homeless" }

    before do
      Imports::LettingsLogsImportService.new(storage_service, logger).create_logs(fixture_directory)
      lettings_log_file.rewind
      lettings_log_xml.at_xpath("//xmlns:Q14b1").content = "1"
      lettings_log_xml.at_xpath("//xmlns:Q13").content = "11"
      lettings_log.update!(values_updated_at: nil)
    end

    context "and the lettings log already has a value for homeless (yes) and rp_homeless" do
      let(:lettings_log) { LettingsLog.find_by(old_id: lettings_log_id) }

      before do
        lettings_log.update!(homeless: 11, reasonpref: 1, rp_homeless: 1)
      end

      it "logs that homeless and rp_homeless already has a value and does not update homeless fields" do
        expect(logger).to receive(:info).with(/lettings log \d+ has a value for homeless and rp_homeless, skipping update/)
        import_service.send(:update_homelessness, lettings_log_xml)

        lettings_log.reload
        expect(lettings_log.homeless).to eq(11)
        expect(lettings_log.reasonpref).to eq(1)
        expect(lettings_log.rp_homeless).to eq(1)
        expect(lettings_log.values_updated_at).to be_nil
      end
    end

    context "and the lettings log already has a value for homeless (no) and rp_homeless" do
      let(:lettings_log) { LettingsLog.find_by(old_id: lettings_log_id) }

      before do
        lettings_log.update!(homeless: 1, reasonpref: 1, rp_homeless: 1)
      end

      it "logs that homeless and rp_homeless already has a value and does not update homeless fields" do
        expect(logger).to receive(:info).with(/lettings log \d+ has a value for homeless and rp_homeless, skipping update/)
        import_service.send(:update_homelessness, lettings_log_xml)

        lettings_log.reload
        expect(lettings_log.homeless).to eq(1)
        expect(lettings_log.reasonpref).to eq(1)
        expect(lettings_log.rp_homeless).to eq(1)
        expect(lettings_log.values_updated_at).to be_nil
      end
    end

    context "and the lettings log already has a value for homeless and reasonpref(no or don't know)" do
      let(:lettings_log) { LettingsLog.find_by(old_id: lettings_log_id) }

      before do
        lettings_log.update!(homeless: 11, reasonpref: 2, rp_homeless: nil)
      end

      it "logs that homeless and reasonpref already has a value and does not update homeless" do
        expect(logger).to receive(:info).with(/lettings log \d+ has a value for homeless and reasonpref is not yes, skipping update/)
        import_service.send(:update_homelessness, lettings_log_xml)

        lettings_log.reload
        expect(lettings_log.homeless).to eq(11)
        expect(lettings_log.reasonpref).to eq(2)
        expect(lettings_log.rp_homeless).to eq(nil)
        expect(lettings_log.values_updated_at).to be_nil
      end
    end

    context "and the lettings log has a value for homeless and reasonpref(yes)" do
      let(:lettings_log) { LettingsLog.find_by(old_id: lettings_log_id) }

      before do
        lettings_log.update!(homeless: 11, reasonpref: 1, rp_insan_unsat: nil)
      end

      it "only updates rp_homeless" do
        expect(logger).to receive(:info).with(/updating lettings log \d+'s rp_homeless value to 1/)
        import_service.send(:update_homelessness, lettings_log_xml)

        lettings_log.reload
        expect(lettings_log.homeless).to eq(11)
        expect(lettings_log.reasonpref).to eq(1)
        expect(lettings_log.rp_homeless).to eq(1)
        expect(lettings_log.values_updated_at).not_to be_nil
      end
    end

    context "and the lettings log has no values for homeless and rp_homeless and reasonpref is Yes" do
      let(:lettings_log) { LettingsLog.find_by(old_id: lettings_log_id) }

      before do
        lettings_log.update!(homeless: nil, reasonpref: 1, rp_homeless: 0)
      end

      it "updates homeless and rp_homeless" do
        expect(logger).to receive(:info).with(/updating lettings log \d+'s homeless value to 11/)
        expect(logger).to receive(:info).with(/updating lettings log \d+'s rp_homeless value to 1/)
        import_service.send(:update_homelessness, lettings_log_xml)

        lettings_log.reload
        expect(lettings_log.homeless).to eq(11)
        expect(lettings_log.reasonpref).to eq(1)
        expect(lettings_log.rp_homeless).to eq(1)
        expect(lettings_log.values_updated_at).not_to be_nil
      end
    end

    context "and the lettings log has no values for homeless and reasonpref is Yes" do
      let(:lettings_log) { LettingsLog.find_by(old_id: lettings_log_id) }

      before do
        lettings_log.update!(homeless: nil, reasonpref: 1, rp_homeless: 1)
      end

      it "updates homeless" do
        expect(logger).to receive(:info).with(/updating lettings log \d+'s homeless value to 11/)
        import_service.send(:update_homelessness, lettings_log_xml)

        lettings_log.reload
        expect(lettings_log.homeless).to eq(11)
        expect(lettings_log.reasonpref).to eq(1)
        expect(lettings_log.rp_homeless).to eq(1)
        expect(lettings_log.values_updated_at).not_to be_nil
      end
    end

    context "and the lettings log has no values for homeless and reasonpref is No" do
      let(:lettings_log) { LettingsLog.find_by(old_id: lettings_log_id) }

      before do
        lettings_log.update!(homeless: nil, reasonpref: 2, rp_homeless: nil)
      end

      it "updates homeless" do
        expect(logger).to receive(:info).with(/updating lettings log \d+'s homeless value to 11/)
        import_service.send(:update_homelessness, lettings_log_xml)

        lettings_log.reload
        expect(lettings_log.homeless).to eq(11)
        expect(lettings_log.reasonpref).to eq(2)
        expect(lettings_log.rp_homeless).to eq(nil)
        expect(lettings_log.values_updated_at).not_to be_nil
      end
    end

    context "and the new values do not set rp_homeless" do
      let(:lettings_log) { LettingsLog.find_by(old_id: lettings_log_id) }

      before do
        lettings_log_xml.at_xpath("//xmlns:Q14b1").content = ""
        lettings_log_xml.at_xpath("//xmlns:Q13").content = "1"
      end

      it "skips update for any fields" do
        expect(logger).to receive(:info).with(/lettings log \d+ reimport values are not homeless - 11 and rp_homeless - yes, skipping update/)
        expect { import_service.send(:update_homelessness, lettings_log_xml) }
          .not_to(change { lettings_log.reload.homeless })
        expect(lettings_log.values_updated_at).to be_nil
      end
    end
  end
end
