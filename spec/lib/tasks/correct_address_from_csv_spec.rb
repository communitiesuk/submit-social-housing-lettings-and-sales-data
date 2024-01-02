require "rails_helper"
require "rake"

RSpec.describe "data_import" do
  def replace_entity_ids(log, second_log, third_log, fourth_log, export_template)
    export_template.sub!(/\{id\}/, log.id.to_s)
    export_template.sub!(/\{id2\}/, second_log.id.to_s)
    export_template.sub!(/\{id3\}/, third_log.id.to_s)
    export_template.sub!(/\{id4\}/, fourth_log.id.to_s)
  end

  before do
    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(Configuration::EnvConfigurationService).to receive(:new).and_return(env_config_service)
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with("CSV_DOWNLOAD_PAAS_INSTANCE").and_return(instance_name)
    allow(ENV).to receive(:[]).with("VCAP_SERVICES").and_return("dummy")

    WebMock.stub_request(:get, /api\.postcodes\.io/)
      .to_return(status: 200, body: "{\"status\":404,\"error\":\"Postcode not found\"}", headers: {})
    WebMock.stub_request(:get, /api\.postcodes\.io\/postcodes\/B11BB/)
      .to_return(status: 200, body: '{"status":200,"result":{"admin_district":"Westminster","codes":{"admin_district":"E08000035"}}}', headers: {})
  end

  describe ":import_lettings_addresses_from_csv", type: :task do
    subject(:task) { Rake::Task["data_import:import_lettings_addresses_from_csv"] }

    let(:instance_name) { "import_instance" }
    let(:storage_service) { instance_double(Storage::S3Service) }
    let(:env_config_service) { instance_double(Configuration::EnvConfigurationService) }

    before do
      Rake.application.rake_require("tasks/import_address_from_csv")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let(:addresses_csv_path) { "addresses_reimport_123.csv" }
      let(:all_addresses_csv_path) { "all_addresses_reimport_123.csv" }
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

      let!(:lettings_logs) do
        logs = build_list(:lettings_log,
                          3,
                          :setup_completed,
                          uprn_known: 1,
                          uprn: "121",
                          uprn_confirmed: nil,
                          address_line1: "wrong address line1",
                          address_line2: "wrong address 2",
                          town_or_city: "wrong town",
                          county: "wrong city",
                          postcode_known: 1,
                          postcode_full: "A1 1AA",
                          la: "E06000064",
                          is_la_inferred: true)
        logs.each { |log| log.save!(validate: false) }
        logs
      end

      before do
        allow(storage_service).to receive(:get_file_io)
        .with("addresses_reimport_123.csv")
        .and_return(StringIO.new(replace_entity_ids(lettings_log, lettings_logs[0], lettings_logs[1], lettings_logs[2], File.open("./spec/fixtures/files/addresses_reimport.csv").read)))

        allow(storage_service).to receive(:get_file_io)
        .with("all_addresses_reimport_123.csv")
        .and_return(StringIO.new(replace_entity_ids(lettings_log, lettings_logs[0], lettings_logs[1], lettings_logs[2], File.open("./spec/fixtures/files/addresses_reimport_all_logs.csv").read)))
      end

      context "when the file contains issue type column" do
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
          lettings_logs[0].reload
          expect(lettings_logs[0].uprn_known).to eq(0)
          expect(lettings_logs[0].uprn).to eq(nil)
          expect(lettings_logs[0].uprn_confirmed).to eq(nil)
          expect(lettings_logs[0].address_line1).to eq("address 3")
          expect(lettings_logs[0].address_line2).to eq(nil)
          expect(lettings_logs[0].town_or_city).to eq("city")
          expect(lettings_logs[0].county).to eq(nil)
          expect(lettings_logs[0].postcode_known).to eq(1)
          expect(lettings_logs[0].postcode_full).to eq("B1 1BB")
          expect(lettings_logs[0].la).to eq("E08000035")
          expect(lettings_logs[0].is_la_inferred).to eq(true)
        end

        it "does not update log address when uprn is given" do
          task.invoke(addresses_csv_path)
          lettings_logs[1].reload
          expect(lettings_logs[1].uprn_known).to eq(1)
          expect(lettings_logs[1].uprn).to eq("121")
          expect(lettings_logs[1].uprn_confirmed).to eq(nil)
          expect(lettings_logs[1].address_line1).to eq("wrong address line1")
          expect(lettings_logs[1].address_line2).to eq("wrong address 2")
          expect(lettings_logs[1].town_or_city).to eq("wrong town")
          expect(lettings_logs[1].county).to eq("wrong city")
          expect(lettings_logs[1].postcode_known).to eq(1)
          expect(lettings_logs[1].postcode_full).to eq("A1 1AA")
          expect(lettings_logs[1].la).to eq("E06000064")
        end

        it "does not update log address when all required address fields are not present" do
          task.invoke(addresses_csv_path)
          lettings_logs[2].reload
          expect(lettings_logs[2].uprn_known).to eq(1)
          expect(lettings_logs[2].uprn).to eq("121")
          expect(lettings_logs[2].uprn_confirmed).to eq(nil)
          expect(lettings_logs[2].address_line1).to eq("wrong address line1")
          expect(lettings_logs[2].address_line2).to eq("wrong address 2")
          expect(lettings_logs[2].town_or_city).to eq("wrong town")
          expect(lettings_logs[2].county).to eq("wrong city")
          expect(lettings_logs[2].postcode_known).to eq(1)
          expect(lettings_logs[2].postcode_full).to eq("A1 1AA")
          expect(lettings_logs[2].la).to eq("E06000064")
        end

        it "reinfers the LA if the postcode doesn't change" do
          lettings_log.update!(postcode_full: "B1 1BB")
          task.invoke(addresses_csv_path)
          lettings_log.reload
          expect(lettings_log.postcode_full).to eq("B1 1BB")
          expect(lettings_log.la).to eq("E08000035")
          expect(lettings_log.is_la_inferred).to eq(true)
        end

        it "logs the progress of the update" do
          expect(Rails.logger).to receive(:info).with("Updated lettings log #{lettings_log.id}, with address: address 1, address 2, town, county, B1 1BB")
          expect(Rails.logger).to receive(:info).with("Updated lettings log #{lettings_logs[0].id}, with address: address 3, , city, , B1 1BB")
          expect(Rails.logger).to receive(:info).with("Lettings log with ID #{lettings_logs[1].id} contains uprn, skipping log")
          expect(Rails.logger).to receive(:info).with("Lettings log with ID #{lettings_logs[2].id} is missing required address data, skipping log")
          expect(Rails.logger).to receive(:info).with("Lettings log ID not provided for address: Some Place, , Bristol, , BS1 1AD")
          expect(Rails.logger).to receive(:info).with("Could not find a lettings log with id fake_id")

          task.invoke(addresses_csv_path)
        end

        it "raises an error when no path is given" do
          expect { task.invoke(nil) }.to raise_error(RuntimeError, "Usage: rake data_import:import_lettings_addresses_from_csv['csv_file_name']")
        end

        it "logs an error if a validation fails" do
          lettings_log.ppcodenk = 0
          lettings_log.ppostcode_full = "invalid_format"
          lettings_log.save!(validate: false)
          expect(Rails.logger).to receive(:error).with(/Validation failed for lettings log with ID #{lettings_log.id}: Ppostcode full/)
          task.invoke(addresses_csv_path)
        end
      end

      context "when the file does not contain issue type column" do
        it "updates the log address when old address was not given" do
          task.invoke(all_addresses_csv_path)
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
          task.invoke(all_addresses_csv_path)
          lettings_logs[0].reload
          expect(lettings_logs[0].uprn_known).to eq(0)
          expect(lettings_logs[0].uprn).to eq(nil)
          expect(lettings_logs[0].uprn_confirmed).to eq(nil)
          expect(lettings_logs[0].address_line1).to eq("address 3")
          expect(lettings_logs[0].address_line2).to eq(nil)
          expect(lettings_logs[0].town_or_city).to eq("city")
          expect(lettings_logs[0].county).to eq(nil)
          expect(lettings_logs[0].postcode_known).to eq(1)
          expect(lettings_logs[0].postcode_full).to eq("B1 1BB")
          expect(lettings_logs[0].la).to eq("E08000035")
          expect(lettings_logs[0].is_la_inferred).to eq(true)
        end

        it "does not update log address when uprn is given" do
          task.invoke(all_addresses_csv_path)
          lettings_logs[1].reload
          expect(lettings_logs[1].uprn_known).to eq(1)
          expect(lettings_logs[1].uprn).to eq("121")
          expect(lettings_logs[1].uprn_confirmed).to eq(nil)
          expect(lettings_logs[1].address_line1).to eq("wrong address line1")
          expect(lettings_logs[1].address_line2).to eq("wrong address 2")
          expect(lettings_logs[1].town_or_city).to eq("wrong town")
          expect(lettings_logs[1].county).to eq("wrong city")
          expect(lettings_logs[1].postcode_known).to eq(1)
          expect(lettings_logs[1].postcode_full).to eq("A1 1AA")
          expect(lettings_logs[1].la).to eq("E06000064")
        end

        it "does not update log address when all required address fields are not present" do
          task.invoke(all_addresses_csv_path)
          lettings_logs[2].reload
          expect(lettings_logs[2].uprn_known).to eq(1)
          expect(lettings_logs[2].uprn).to eq("121")
          expect(lettings_logs[2].uprn_confirmed).to eq(nil)
          expect(lettings_logs[2].address_line1).to eq("wrong address line1")
          expect(lettings_logs[2].address_line2).to eq("wrong address 2")
          expect(lettings_logs[2].town_or_city).to eq("wrong town")
          expect(lettings_logs[2].county).to eq("wrong city")
          expect(lettings_logs[2].postcode_known).to eq(1)
          expect(lettings_logs[2].postcode_full).to eq("A1 1AA")
          expect(lettings_logs[2].la).to eq("E06000064")
        end

        it "reinfers the LA if the postcode hasn't changed" do
          lettings_log.update!(postcode_full: "B1 1BB")
          task.invoke(all_addresses_csv_path)
          lettings_log.reload
          expect(lettings_log.postcode_full).to eq("B1 1BB")
          expect(lettings_log.la).to eq("E08000035")
          expect(lettings_log.is_la_inferred).to eq(true)
        end

        it "logs the progress of the update" do
          expect(Rails.logger).to receive(:info).with("Updated lettings log #{lettings_log.id}, with address: address 1, address 2, town, county, B1 1BB")
          expect(Rails.logger).to receive(:info).with("Updated lettings log #{lettings_logs[0].id}, with address: address 3, , city, , B1 1BB")
          expect(Rails.logger).to receive(:info).with("Lettings log with ID #{lettings_logs[1].id} contains uprn, skipping log")
          expect(Rails.logger).to receive(:info).with("Lettings log with ID #{lettings_logs[2].id} is missing required address data, skipping log")
          expect(Rails.logger).to receive(:info).with("Lettings log ID not provided for address: Some Place, , Bristol, , BS1 1AD")
          expect(Rails.logger).to receive(:info).with("Could not find a lettings log with id fake_id")

          task.invoke(all_addresses_csv_path)
        end

        it "raises an error when no path is given" do
          expect { task.invoke(nil) }.to raise_error(RuntimeError, "Usage: rake data_import:import_lettings_addresses_from_csv['csv_file_name']")
        end

        it "logs an error if a validation fails" do
          lettings_log.ppcodenk = 0
          lettings_log.ppostcode_full = "invalid_format"
          lettings_log.save!(validate: false)
          expect(Rails.logger).to receive(:error).with(/Validation failed for lettings log with ID #{lettings_log.id}: Ppostcode full/)
          task.invoke(addresses_csv_path)
        end
      end
    end
  end

  describe ":import_sales_addresses_from_csv", type: :task do
    subject(:task) { Rake::Task["data_import:import_sales_addresses_from_csv"] }

    let(:instance_name) { "import_instance" }
    let(:storage_service) { instance_double(Storage::S3Service) }
    let(:env_config_service) { instance_double(Configuration::EnvConfigurationService) }

    before do
      Rake.application.rake_require("tasks/import_address_from_csv")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let(:addresses_csv_path) { "addresses_reimport_123.csv" }
      let(:all_addresses_csv_path) { "all_addresses_reimport_123.csv" }
      let(:wrong_file_path) { "/test/no_csv_here.csv" }
      let!(:sales_log) do
        create(:sales_log,
               :completed,
               uprn_known: nil,
               uprn: nil,
               uprn_confirmed: nil,
               address_line1: nil,
               address_line2: nil,
               town_or_city: nil,
               la: "E06000064",
               is_la_inferred: true)
      end

      let!(:sales_logs) { create_list(:sales_log, 3, :completed, uprn_known: 1, uprn: "121", la: "E06000064", is_la_inferred: true) }

      before do
        allow(storage_service).to receive(:get_file_io)
        .with("addresses_reimport_123.csv")
        .and_return(StringIO.new(replace_entity_ids(sales_log, sales_logs[0], sales_logs[1], sales_logs[2], File.open("./spec/fixtures/files/sales_addresses_reimport.csv").read)))

        allow(storage_service).to receive(:get_file_io)
        .with("all_addresses_reimport_123.csv")
        .and_return(StringIO.new(replace_entity_ids(sales_log, sales_logs[0], sales_logs[1], sales_logs[2], File.open("./spec/fixtures/files/sales_addresses_reimport_all_logs.csv").read)))
      end

      context "when the file contains issue type column" do
        it "updates the log address when old address was not given" do
          task.invoke(addresses_csv_path)
          sales_log.reload
          expect(sales_log.uprn_known).to eq(0)
          expect(sales_log.uprn).to eq(nil)
          expect(sales_log.uprn_confirmed).to eq(nil)
          expect(sales_log.address_line1).to eq("address 1")
          expect(sales_log.address_line2).to eq("address 2")
          expect(sales_log.town_or_city).to eq("town")
          expect(sales_log.county).to eq("county")
          expect(sales_log.pcodenk).to eq(0)
          expect(sales_log.postcode_full).to eq("B1 1BB")
          expect(sales_log.la).to eq("E08000035")
          expect(sales_log.is_la_inferred).to eq(true)
        end

        it "updates the log address when old address was given" do
          task.invoke(addresses_csv_path)
          sales_logs[0].reload
          expect(sales_logs[0].uprn_known).to eq(0)
          expect(sales_logs[0].uprn).to eq(nil)
          expect(sales_logs[0].uprn_confirmed).to eq(nil)
          expect(sales_logs[0].address_line1).to eq("address 3")
          expect(sales_logs[0].address_line2).to eq(nil)
          expect(sales_logs[0].town_or_city).to eq("city")
          expect(sales_logs[0].county).to eq(nil)
          expect(sales_logs[0].pcodenk).to eq(0)
          expect(sales_logs[0].postcode_full).to eq("B1 1BB")
          expect(sales_logs[0].la).to eq("E08000035")
          expect(sales_logs[0].is_la_inferred).to eq(true)
        end

        it "does not update log address when uprn is given" do
          task.invoke(addresses_csv_path)
          sales_logs[1].reload
          expect(sales_logs[1].uprn_known).to eq(1)
          expect(sales_logs[1].uprn).to eq("121")
          expect(sales_logs[1].uprn_confirmed).to eq(nil)
          expect(sales_logs[1].address_line1).to eq("Wrong Address Line1")
          expect(sales_logs[1].address_line2).to eq("Double Dependent Locality")
          expect(sales_logs[1].town_or_city).to eq("Westminster")
          expect(sales_logs[1].county).to eq(nil)
          expect(sales_logs[1].pcodenk).to eq(0)
          expect(sales_logs[1].postcode_full).to eq("LS16 6FT")
          expect(sales_logs[1].la).to eq("E06000064")
        end

        it "does not update log address when all required address fields are not present" do
          task.invoke(addresses_csv_path)
          sales_logs[2].reload
          expect(sales_logs[2].uprn_known).to eq(1)
          expect(sales_logs[2].uprn).to eq("121")
          expect(sales_logs[2].uprn_confirmed).to eq(nil)
          expect(sales_logs[2].address_line1).to eq("Wrong Address Line1")
          expect(sales_logs[2].address_line2).to eq("Double Dependent Locality")
          expect(sales_logs[2].town_or_city).to eq("Westminster")
          expect(sales_logs[2].county).to eq(nil)
          expect(sales_logs[2].pcodenk).to eq(0)
          expect(sales_logs[2].postcode_full).to eq("LS16 6FT")
          expect(sales_logs[2].la).to eq("E06000064")
        end

        it "reinfers the LA if the postcode hasn't changed" do
          sales_log.update!(postcode_full: "B1 1BB")
          task.invoke(addresses_csv_path)
          sales_log.reload
          expect(sales_log.postcode_full).to eq("B1 1BB")
          expect(sales_log.la).to eq("E08000035")
          expect(sales_log.is_la_inferred).to eq(true)
        end

        it "logs the progress of the update" do
          expect(Rails.logger).to receive(:info).with("Updated sales log #{sales_log.id}, with address: address 1, address 2, town, county, B1 1BB")
          expect(Rails.logger).to receive(:info).with("Updated sales log #{sales_logs[0].id}, with address: address 3, , city, , B1 1BB")
          expect(Rails.logger).to receive(:info).with("Sales log with ID #{sales_logs[1].id} contains uprn, skipping log")
          expect(Rails.logger).to receive(:info).with("Sales log with ID #{sales_logs[2].id} is missing required address data, skipping log")
          expect(Rails.logger).to receive(:info).with("Sales log ID not provided for address: Some Place, , Bristol, , BS1 1AD")
          expect(Rails.logger).to receive(:info).with("Could not find a sales log with id fake_id")

          task.invoke(addresses_csv_path)
        end

        it "raises an error when no path is given" do
          expect { task.invoke(nil) }.to raise_error(RuntimeError, "Usage: rake data_import:import_sales_addresses_from_csv['csv_file_name']")
        end

        it "logs an error if a validation fails" do
          sales_log.ppcodenk = 0
          sales_log.ppostcode_full = "invalid_format"
          sales_log.save!(validate: false)
          expect(Rails.logger).to receive(:error).with(/Validation failed for sales log with ID #{sales_log.id}: Ppostcode full/)
          task.invoke(addresses_csv_path)
        end
      end

      context "when the file does not contain issue type column" do
        it "updates the log address when old address was not given" do
          task.invoke(all_addresses_csv_path)
          sales_log.reload
          expect(sales_log.uprn_known).to eq(0)
          expect(sales_log.uprn).to eq(nil)
          expect(sales_log.uprn_confirmed).to eq(nil)
          expect(sales_log.address_line1).to eq("address 1")
          expect(sales_log.address_line2).to eq("address 2")
          expect(sales_log.town_or_city).to eq("town")
          expect(sales_log.county).to eq("county")
          expect(sales_log.pcodenk).to eq(0)
          expect(sales_log.postcode_full).to eq("B1 1BB")
          expect(sales_log.la).to eq("E08000035")
          expect(sales_log.is_la_inferred).to eq(true)
        end

        it "updates the log address when old address was given" do
          task.invoke(all_addresses_csv_path)
          sales_logs[0].reload
          expect(sales_logs[0].uprn_known).to eq(0)
          expect(sales_logs[0].uprn).to eq(nil)
          expect(sales_logs[0].uprn_confirmed).to eq(nil)
          expect(sales_logs[0].address_line1).to eq("address 3")
          expect(sales_logs[0].address_line2).to eq(nil)
          expect(sales_logs[0].town_or_city).to eq("city")
          expect(sales_logs[0].county).to eq(nil)
          expect(sales_logs[0].pcodenk).to eq(0)
          expect(sales_logs[0].postcode_full).to eq("B1 1BB")
          expect(sales_logs[0].la).to eq("E08000035")
          expect(sales_logs[0].is_la_inferred).to eq(true)
        end

        it "does not update log address when uprn is given" do
          task.invoke(all_addresses_csv_path)
          sales_logs[1].reload
          expect(sales_logs[1].uprn_known).to eq(1)
          expect(sales_logs[1].uprn).to eq("121")
          expect(sales_logs[1].uprn_confirmed).to eq(nil)
          expect(sales_logs[1].address_line1).to eq("Wrong Address Line1")
          expect(sales_logs[1].address_line2).to eq("Double Dependent Locality")
          expect(sales_logs[1].town_or_city).to eq("Westminster")
          expect(sales_logs[1].county).to eq(nil)
          expect(sales_logs[1].pcodenk).to eq(0)
          expect(sales_logs[1].postcode_full).to eq("LS16 6FT")
          expect(sales_logs[1].la).to eq("E06000064")
        end

        it "does not update log address when all required address fields are not present" do
          task.invoke(all_addresses_csv_path)
          sales_logs[2].reload
          expect(sales_logs[2].uprn_known).to eq(1)
          expect(sales_logs[2].uprn).to eq("121")
          expect(sales_logs[2].uprn_confirmed).to eq(nil)
          expect(sales_logs[2].address_line1).to eq("Wrong Address Line1")
          expect(sales_logs[2].address_line2).to eq("Double Dependent Locality")
          expect(sales_logs[2].town_or_city).to eq("Westminster")
          expect(sales_logs[2].county).to eq(nil)
          expect(sales_logs[2].pcodenk).to eq(0)
          expect(sales_logs[2].postcode_full).to eq("LS16 6FT")
          expect(sales_logs[2].la).to eq("E06000064")
        end

        it "reinfers the LA if the postcode hasn't changed" do
          sales_log.update!(postcode_full: "B1 1BB")
          task.invoke(all_addresses_csv_path)
          sales_log.reload
          expect(sales_log.postcode_full).to eq("B1 1BB")
          expect(sales_log.la).to eq("E08000035")
          expect(sales_log.is_la_inferred).to eq(true)
        end

        it "logs the progress of the update" do
          expect(Rails.logger).to receive(:info).with("Updated sales log #{sales_log.id}, with address: address 1, address 2, town, county, B1 1BB")
          expect(Rails.logger).to receive(:info).with("Updated sales log #{sales_logs[0].id}, with address: address 3, , city, , B1 1BB")
          expect(Rails.logger).to receive(:info).with("Sales log with ID #{sales_logs[1].id} contains uprn, skipping log")
          expect(Rails.logger).to receive(:info).with("Sales log with ID #{sales_logs[2].id} is missing required address data, skipping log")
          expect(Rails.logger).to receive(:info).with("Sales log ID not provided for address: Some Place, , Bristol, , BS1 1AD")
          expect(Rails.logger).to receive(:info).with("Could not find a sales log with id fake_id")

          task.invoke(all_addresses_csv_path)
        end

        it "raises an error when no path is given" do
          expect { task.invoke(nil) }.to raise_error(RuntimeError, "Usage: rake data_import:import_sales_addresses_from_csv['csv_file_name']")
        end

        it "logs an error if a validation fails" do
          sales_log.ppcodenk = 0
          sales_log.ppostcode_full = "invalid_format"
          sales_log.save!(validate: false)
          expect(Rails.logger).to receive(:error).with(/Validation failed for sales log with ID #{sales_log.id}: Ppostcode full/)
          task.invoke(addresses_csv_path)
        end
      end
    end
  end
end
