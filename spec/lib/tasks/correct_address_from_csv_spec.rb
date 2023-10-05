require "rails_helper"
require "rake"

RSpec.describe "data_import" do
  def replace_entity_ids(lettings_log, second_lettings_log, third_lettings_log, fourth_lettings_log, export_template)
    export_template.sub!(/\{id\}/, lettings_log.id.to_s)
    export_template.sub!(/\{id2\}/, second_lettings_log.id.to_s)
    export_template.sub!(/\{id3\}/, third_lettings_log.id.to_s)
    export_template.sub!(/\{id4\}/, fourth_lettings_log.id.to_s)
  end

  describe ":import_lettings_addresses_from_csv", type: :task do
    subject(:task) { Rake::Task["data_import:import_lettings_addresses_from_csv"] }

    let(:instance_name) { "paas_import_instance" }
    let(:storage_service) { instance_double(Storage::S3Service) }
    let(:env_config_service) { instance_double(Configuration::EnvConfigurationService) }
    let(:paas_config_service) { instance_double(Configuration::PaasConfigurationService) }

    before do
      allow(Storage::S3Service).to receive(:new).and_return(storage_service)
      allow(Configuration::EnvConfigurationService).to receive(:new).and_return(env_config_service)
      allow(Configuration::PaasConfigurationService).to receive(:new).and_return(paas_config_service)
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with("IMPORT_PAAS_INSTANCE").and_return(instance_name)
      allow(ENV).to receive(:[]).with("VCAP_SERVICES").and_return("dummy")

      Rake.application.rake_require("tasks/import_address_from_csv")
      Rake::Task.define_task(:environment)
      task.reenable

      WebMock.stub_request(:get, /api.postcodes.io/)
        .to_return(status: 200, body: "{\"status\":404,\"error\":\"Postcode not found\"}", headers: {})
      WebMock.stub_request(:get, /api.postcodes.io\/postcodes\/B11BB/)
        .to_return(status: 200, body: '{"status":200,"result":{"admin_district":"Westminster","codes":{"admin_district":"E08000035"}}}', headers: {})
    end

    context "when the rake task is run" do
      let(:addresses_csv_path) { "addresses_reimport_123.csv" }
      let(:wrong_file_path) { "/test/no_csv_here.csv" }
      let!(:lettings_log) do
        create(:lettings_log,
               uprn_known: nil,
               uprn: nil,
               uprn_confirmed: nil,
               address_line1: nil,
               address_line2: nil,
               town_or_city: nil,
               county: nil,
               postcode_known: 1,
               postcode_full: "A1 1AA",
               la: "E06000064",
               is_la_inferred: true)
      end

      let!(:second_lettings_log) do
        create(:lettings_log,
               uprn_known: 1,
               uprn: "1",
               uprn_confirmed: nil,
               address_line1: "wrong address line1",
               address_line2: "wrong address 2",
               town_or_city: "wrong town",
               county: "wrong city",
               postcode_known: 1,
               postcode_full: "A1 1AA",
               la: "E06000064",
               is_la_inferred: true)
      end

      let!(:third_lettings_log) do
        create(:lettings_log,
               uprn_known: 1,
               uprn: "1",
               uprn_confirmed: nil,
               address_line1: "wrong address line1",
               address_line2: "wrong address 2",
               town_or_city: "wrong town",
               county: "wrong city",
               postcode_known: 1,
               postcode_full: "A1 1AA",
               la: "E06000064",
               is_la_inferred: true)
      end

      let!(:fourth_lettings_log) do
        create(:lettings_log,
               uprn_known: 1,
               uprn: "1",
               uprn_confirmed: nil,
               address_line1: "wrong address line1",
               address_line2: "wrong address 2",
               town_or_city: "wrong town",
               county: "wrong city",
               postcode_known: 1,
               postcode_full: "A1 1AA",
               la: "E06000064",
               is_la_inferred: true)
      end

      before do
        allow(storage_service).to receive(:get_file_io)
        .with("addresses_reimport_123.csv")
        .and_return(replace_entity_ids(lettings_log, second_lettings_log, third_lettings_log, fourth_lettings_log, File.open("./spec/fixtures/files/addresses_reimport.csv").read))
      end

      it "updates the log address when old address was not given" do
        task.invoke(addresses_csv_path)
        lettings_log.reload
        expect(lettings_log.uprn_known).to eq(0)
        expect(lettings_log.uprn).to eq(nil)
        expect(lettings_log.uprn_confirmed).to eq(nil)
        expect(lettings_log.address_line1).to eq("address 1")
        expect(lettings_log.address_line2).to eq("address 2")
        expect(lettings_log.town_or_city).to eq("town")
        expect(lettings_log.county).to eq("county")
        expect(lettings_log.postcode_known).to eq(1)
        expect(lettings_log.postcode_full).to eq("B1 1BB")
        expect(lettings_log.la).to eq("E08000035")
        expect(lettings_log.is_la_inferred).to eq(true)
      end

      it "updates the log address when old address was given" do
        task.invoke(addresses_csv_path)
        second_lettings_log.reload
        expect(second_lettings_log.uprn_known).to eq(0)
        expect(second_lettings_log.uprn).to eq(nil)
        expect(second_lettings_log.uprn_confirmed).to eq(nil)
        expect(second_lettings_log.address_line1).to eq("address 3")
        expect(second_lettings_log.address_line2).to eq(nil)
        expect(second_lettings_log.town_or_city).to eq("city")
        expect(second_lettings_log.county).to eq(nil)
        expect(second_lettings_log.postcode_known).to eq(1)
        expect(second_lettings_log.postcode_full).to eq("B1 1BB")
        expect(second_lettings_log.la).to eq("E08000035")
        expect(second_lettings_log.is_la_inferred).to eq(true)
      end

      it "does not update log address when uprn is given" do
        task.invoke(addresses_csv_path)
        third_lettings_log.reload
        expect(third_lettings_log.uprn_known).to eq(1)
        expect(third_lettings_log.uprn).to eq("1")
        expect(third_lettings_log.uprn_confirmed).to eq(nil)
        expect(third_lettings_log.address_line1).to eq("wrong address line1")
        expect(third_lettings_log.address_line2).to eq("wrong address 2")
        expect(third_lettings_log.town_or_city).to eq("wrong town")
        expect(third_lettings_log.county).to eq("wrong city")
        expect(third_lettings_log.postcode_known).to eq(1)
        expect(third_lettings_log.postcode_full).to eq("A1 1AA")
        expect(third_lettings_log.la).to eq("E06000064")
      end

      it "does not update log address when all required address fields are not present" do
        task.invoke(addresses_csv_path)
        fourth_lettings_log.reload
        expect(fourth_lettings_log.uprn_known).to eq(1)
        expect(fourth_lettings_log.uprn).to eq("1")
        expect(fourth_lettings_log.uprn_confirmed).to eq(nil)
        expect(fourth_lettings_log.address_line1).to eq("wrong address line1")
        expect(fourth_lettings_log.address_line2).to eq("wrong address 2")
        expect(fourth_lettings_log.town_or_city).to eq("wrong town")
        expect(fourth_lettings_log.county).to eq("wrong city")
        expect(fourth_lettings_log.postcode_known).to eq(1)
        expect(fourth_lettings_log.postcode_full).to eq("A1 1AA")
        expect(fourth_lettings_log.la).to eq("E06000064")
      end

      it "logs the progress of the update" do
        expect(Rails.logger).to receive(:info).with("Updated lettings log #{lettings_log.id}, with address: address 1, address 2, town, county, B1 1BB")
        expect(Rails.logger).to receive(:info).with("Updated lettings log #{second_lettings_log.id}, with address: address 3, , city, , B1 1BB")
        expect(Rails.logger).to receive(:info).with("Lettings log with ID #{third_lettings_log.id} contains uprn, skipping log")
        expect(Rails.logger).to receive(:info).with("Lettings log with ID #{fourth_lettings_log.id} is missing required address data, skipping log")
        expect(Rails.logger).to receive(:info).with("Lettings log ID not provided for address: Some Place, , Bristol, , BS1 1AD")
        expect(Rails.logger).to receive(:info).with("Could not find a lettings log with id fake_id")

        task.invoke(addresses_csv_path)
      end

      it "raises an error when no path is given" do
        expect { task.invoke(nil) }.to raise_error(RuntimeError, "Usage: rake data_import:import_lettings_addresses_from_csv['csv_file_name']")
      end
    end
  end
end
