require "rails_helper"

describe CreateAddressesCsvJob do
  include Helpers

  let(:job) { described_class.new }
  let(:storage_service) { instance_double(Storage::S3Service) }
  let(:mailer) { instance_double(CsvDownloadMailer) }
  let(:missing_addresses_csv_service) { instance_double(Csv::MissingAddressesCsvService) }
  let(:organisation) { build(:organisation) }
  let(:users) { create_list(:user, 2) }

  before do
    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(storage_service).to receive(:write_file)

    allow(Csv::MissingAddressesCsvService).to receive(:new).and_return(missing_addresses_csv_service)
    allow(missing_addresses_csv_service).to receive(:create_lettings_addresses_csv).and_return("")
    allow(missing_addresses_csv_service).to receive(:create_sales_addresses_csv).and_return("")
  end

  context "when sending all lettings logs csv" do
    it "uses an appropriate filename in S3" do
      expect(storage_service).to receive(:write_file).with(/lettings-logs-addresses-#{organisation.name}-.*\.csv/, anything)
      expect(Rails.logger).to receive(:info).with(/Created addresses file: lettings-logs-addresses-#{organisation.name}-.*\.csv/)
      job.perform(organisation, "lettings")
    end

    it "creates a MissingAddressesCsvService with the correct organisation and calls create all lettings logs adresses csv" do
      expect(Csv::MissingAddressesCsvService).to receive(:new).with(organisation, [])
      expect(missing_addresses_csv_service).to receive(:create_lettings_addresses_csv)
      job.perform(organisation, "lettings")
    end
  end

  context "when sending all sales logs csv" do
    it "uses an appropriate filename in S3" do
      expect(storage_service).to receive(:write_file).with(/sales-logs-addresses-#{organisation.name}-.*\.csv/, anything)
      expect(Rails.logger).to receive(:info).with(/Created addresses file: sales-logs-addresses-#{organisation.name}-.*\.csv/)
      job.perform(organisation, "sales")
    end

    it "creates a MissingAddressesCsvService with the correct organisation and calls create all sales logs adresses csv" do
      expect(Csv::MissingAddressesCsvService).to receive(:new).with(organisation, [])
      expect(missing_addresses_csv_service).to receive(:create_sales_addresses_csv)
      job.perform(organisation, "sales")
    end
  end
end
