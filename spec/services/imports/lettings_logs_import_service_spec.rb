require "rails_helper"

RSpec.describe Imports::LettingsLogsImportService do
  subject(:lettings_log_service) { described_class.new(storage_service, Rails.logger) }

  let(:storage_service) { instance_double(Storage::S3Service) }
  let(:logger) { instance_double(ActiveSupport::Logger) }

  let(:real_2021_2022_form) { Form.new("config/forms/2021_2022.json") }
  let(:real_2022_2023_form) { Form.new("config/forms/2022_2023.json") }
  let(:fixture_directory) { "spec/fixtures/imports/logs" }

  let(:organisation) { FactoryBot.create(:organisation, old_visible_id: "1", provider_type: "PRP") }
  let(:scheme1) { FactoryBot.create(:scheme, old_visible_id: 123, owning_organisation: organisation) }
  let(:scheme2) { FactoryBot.create(:scheme, old_visible_id: 456, owning_organisation: organisation) }

  let(:remote_folder)     { "lettings_logs" }
  let(:lettings_log_id)   { "0ead17cb-1668-442d-898c-0d52879ff592" }
  let(:lettings_log_id2)  { "166fc004-392e-47a8-acb8-1c018734882b" }
  let(:lettings_log_id3)  { "00d2343e-d5fa-4c89-8400-ec3854b0f2b4" }
  let(:lettings_log_id4)  { "0b4a68df-30cc-474a-93c0-a56ce8fdad3b" }
  let(:lettings_log_id5)  { "893ufj2s-lq77-42m4-rty6-ej09gh585uy1" }
  let(:lettings_log_id6)  { "5ybz29dj-l33t-k1l0-hj86-n4k4ma77xkcd" }
  let(:lettings_log_file) { open_file(fixture_directory, lettings_log_id5) }
  let(:lettings_log_xml)  { Nokogiri::XML(lettings_log_file) }

  before do
    WebMock.stub_request(:get, /api.postcodes.io\/postcodes\/LS166FT/)
           .to_return(status: 200, body: '{"status":200,"result":{"admin_district":"Westminster","codes":{"admin_district":"E08000035"}}}', headers: {})

    allow(Organisation).to receive(:find_by).and_return(nil)
    allow(Organisation).to receive(:find_by).with(old_visible_id: organisation.old_visible_id.to_i).and_return(organisation)

    # Created by users
    FactoryBot.create(:user, old_user_id: "c3061a2e6ea0b702e6f6210d5c52d2a92612d2aa", organisation:)
    FactoryBot.create(:user, old_user_id: "e29c492473446dca4d50224f2bb7cf965a261d6f", organisation:)

    # Location setup
    FactoryBot.create(:location, old_visible_id: 10, postcode: "LS166FT", scheme_id: scheme1.id, mobility_type: "W")
    FactoryBot.create(:location, scheme_id: scheme1.id)
    FactoryBot.create(:location, old_visible_id: 10, postcode: "LS166FT", scheme_id: scheme2.id, mobility_type: "W")

    # Stub the form handler to use the real form
    allow(FormHandler.instance).to receive(:get_form).with("previous_lettings").and_return(real_2021_2022_form)
    allow(FormHandler.instance).to receive(:get_form).with("current_lettings").and_return(real_2022_2023_form)

    # Stub the S3 file listing and download
    allow(storage_service).to receive(:list_files)
                                .and_return(%W[#{remote_folder}/#{lettings_log_id}.xml #{remote_folder}/#{lettings_log_id2}.xml #{remote_folder}/#{lettings_log_id3}.xml #{remote_folder}/#{lettings_log_id4}.xml])
    allow(storage_service).to receive(:get_file_io)
                                .with("#{remote_folder}/#{lettings_log_id}.xml")
                                .and_return(open_file(fixture_directory, lettings_log_id), open_file(fixture_directory, lettings_log_id))
    allow(storage_service).to receive(:get_file_io)
                                .with("#{remote_folder}/#{lettings_log_id2}.xml")
                                .and_return(open_file(fixture_directory, lettings_log_id2), open_file(fixture_directory, lettings_log_id2))
    allow(storage_service).to receive(:get_file_io)
                                .with("#{remote_folder}/#{lettings_log_id3}.xml")
                                .and_return(open_file(fixture_directory, lettings_log_id3), open_file(fixture_directory, lettings_log_id3))
    allow(storage_service).to receive(:get_file_io)
                                .with("#{remote_folder}/#{lettings_log_id4}.xml")
                                .and_return(open_file(fixture_directory, lettings_log_id4), open_file(fixture_directory, lettings_log_id4))
  end

  describe "importing lettings logs from S3 asynchronously" do
    it "successfully generates background jobs for processing lettings logs" do
      expect(logger).not_to receive(:error)
      expect(logger).not_to receive(:warn)

      assert_enqueued_jobs 4 do
        lettings_log_service.create_logs(remote_folder)
      end
    end

    it "does not immediately change the database" do
      expect { lettings_log_service.create_logs(remote_folder) }
        .to change(LettingsLog, :count).by(0)
    end

    it "only updates existing lettings logs when import run multiple times" do
      expect(logger).not_to receive(:error)
      expect(logger).not_to receive(:warn)

      expect {
        perform_enqueued_jobs do
          lettings_log_service.create_logs(remote_folder)
          lettings_log_service.create_logs(remote_folder)
        end
      }.to change(LettingsLog, :count).by(4) # Rather than 8
    end
  end

  describe "processing background jobs" do
    context "when there are status discrepancies" do
      let(:lettings_log_id5) { "893ufj2s-lq77-42m4-rty6-ej09gh585uy1" }
      let(:lettings_log_id6) { "5ybz29dj-l33t-k1l0-hj86-n4k4ma77xkcd" }
      let(:lettings_log_file) { open_file(fixture_directory, lettings_log_id5) }
      let(:lettings_log_xml) { Nokogiri::XML(lettings_log_file) }
      let(:logger) { instance_double(ActiveSupport::Logger) }

      before do
        allow(storage_service).to receive(:get_file_io)
          .with("#{remote_folder}/#{lettings_log_id5}.xml")
          .and_return(open_file(fixture_directory, lettings_log_id5), open_file(fixture_directory, lettings_log_id5))
        allow(storage_service).to receive(:get_file_io)
          .with("#{remote_folder}/#{lettings_log_id6}.xml")
          .and_return(open_file(fixture_directory, lettings_log_id6), open_file(fixture_directory, lettings_log_id6))
      end

      it "the logger logs a warning with the lettings log's old id/filename" do
        expect(Rails.logger).to receive(:warn).with(/is not completed/).once
        expect(Rails.logger).to receive(:warn).with(/lettings log with old id:#{lettings_log_id5} is incomplete but status should be complete/).once

        perform_enqueued_jobs do
          lettings_log_service.send(:enqueue_job, lettings_log_xml)
        end
      end

      it "on completion the ids of all logs with status discrepancies are logged in a warning" do
        allow(storage_service).to receive(:list_files)
                                  .and_return(%W[#{remote_folder}/#{lettings_log_id5}.xml #{remote_folder}/#{lettings_log_id6}.xml])

        expect(Rails.logger).to receive(:warn).with(/is not completed/).twice
        expect(Rails.logger).to receive(:warn).with(/lettings log with old id:893ufj2s-lq77-42m4-rty6-ej09gh585uy1 is incomplete but status should be complete/).once
        expect(Rails.logger).to receive(:warn).with(/lettings log with old id:5ybz29dj-l33t-k1l0-hj86-n4k4ma77xkcd is incomplete but status should be complete/).once

        perform_enqueued_jobs do
          lettings_log_service.create_logs(remote_folder)
        end
      end
    end
  end

  def open_file(directory, filename)
    File.open("#{directory}/#{filename}.xml")
  end
end
