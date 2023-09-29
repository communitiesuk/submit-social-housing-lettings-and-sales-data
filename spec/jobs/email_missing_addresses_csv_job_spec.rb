require "rails_helper"

describe EmailMissingAddressesCsvJob do
  include Helpers

  test_url = :test_url

  let(:job) { described_class.new }
  let(:storage_service) { instance_double(Storage::S3Service) }
  let(:mailer) { instance_double(CsvDownloadMailer) }
  let(:missing_addresses_csv_service) { instance_double(Csv::MissingAddressesCsvService) }
  let(:organisation) { build(:organisation) }
  let(:users) { create_list(:user, 2) }

  before do
    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(storage_service).to receive(:write_file)
    allow(storage_service).to receive(:get_presigned_url).and_return(test_url)

    allow(Csv::MissingAddressesCsvService).to receive(:new).and_return(missing_addresses_csv_service)
    allow(missing_addresses_csv_service).to receive(:create_missing_lettings_addresses_csv).and_return("")
    allow(missing_addresses_csv_service).to receive(:create_missing_sales_addresses_csv).and_return("")
    allow(missing_addresses_csv_service).to receive(:create_missing_lettings_town_or_city_csv).and_return("")
    allow(missing_addresses_csv_service).to receive(:create_missing_sales_town_or_city_csv).and_return("")

    allow(CsvDownloadMailer).to receive(:new).and_return(mailer)
    allow(mailer).to receive(:send_missing_lettings_addresses_csv_download_mail)
    allow(mailer).to receive(:send_missing_sales_addresses_csv_download_mail)
  end

  context "when sending missing lettings logs csv" do
    it "uses an appropriate filename in S3" do
      expect(storage_service).to receive(:write_file).with(/missing-lettings-logs-addresses-#{organisation.name}-.*\.csv/, anything)
      job.perform(users.map(&:id), organisation, "lettings", "addresses")
    end

    it "creates a MissingAddressesCsvService with the correct organisation and calls create missing lettings logs adresses csv" do
      expect(Csv::MissingAddressesCsvService).to receive(:new).with(organisation:)
      expect(missing_addresses_csv_service).to receive(:create_missing_lettings_addresses_csv)
      job.perform(users.map(&:id), organisation, "lettings", "addresses")
    end

    it "sends emails to all the provided users" do
      expect(mailer).to receive(:send_missing_lettings_addresses_csv_download_mail).with(users[0], test_url, "addresses")
      expect(mailer).to receive(:send_missing_lettings_addresses_csv_download_mail).with(users[1], test_url, "addresses")
      job.perform(users.map(&:id), organisation, "lettings", "addresses")
    end
  end

  context "when sending missing sales logs csv" do
    it "uses an appropriate filename in S3" do
      expect(storage_service).to receive(:write_file).with(/missing-sales-logs-addresses-#{organisation.name}-.*\.csv/, anything)
      job.perform(users.map(&:id), organisation, "sales", "addresses")
    end

    it "creates a MissingAddressesCsvService with the correct organisation and calls create missing sales logs adresses csv" do
      expect(Csv::MissingAddressesCsvService).to receive(:new).with(organisation:)
      expect(missing_addresses_csv_service).to receive(:create_missing_sales_addresses_csv)
      job.perform(users.map(&:id), organisation, "sales", "addresses")
    end

    it "sends emails to all the provided users" do
      expect(mailer).to receive(:send_missing_sales_addresses_csv_download_mail).with(users[0], test_url, "addresses")
      expect(mailer).to receive(:send_missing_sales_addresses_csv_download_mail).with(users[1], test_url, "addresses")
      job.perform(users.map(&:id), organisation, "sales", "addresses")
    end
  end

  context "when sending missing lettings town or city logs csv" do
    it "uses an appropriate filename in S3" do
      expect(storage_service).to receive(:write_file).with(/missing-lettings-logs-town-or-city-#{organisation.name}-.*\.csv/, anything)
      job.perform(users.map(&:id), organisation, "lettings", "town-or-city")
    end

    it "creates a MissingAddressesCsvService with the correct organisation and calls create missing lettings logs adresses csv" do
      expect(Csv::MissingAddressesCsvService).to receive(:new).with(organisation:)
      expect(missing_addresses_csv_service).to receive(:create_missing_lettings_town_or_city_csv)
      job.perform(users.map(&:id), organisation, "lettings", "town-or-city")
    end

    it "sends emails to all the provided users" do
      expect(mailer).to receive(:send_missing_lettings_addresses_csv_download_mail).with(users[0], test_url, "town-or-city")
      expect(mailer).to receive(:send_missing_lettings_addresses_csv_download_mail).with(users[1], test_url, "town-or-city")
      job.perform(users.map(&:id), organisation, "lettings", "town-or-city")
    end
  end

  context "when sending missing sales town or city logs csv" do
    it "uses an appropriate filename in S3" do
      expect(storage_service).to receive(:write_file).with(/missing-sales-logs-town-or-city-#{organisation.name}-.*\.csv/, anything)
      job.perform(users.map(&:id), organisation, "sales", "town-or-city")
    end

    it "creates a MissingAddressesCsvService with the correct organisation and calls create missing sales logs adresses csv" do
      expect(Csv::MissingAddressesCsvService).to receive(:new).with(organisation:)
      expect(missing_addresses_csv_service).to receive(:create_missing_sales_town_or_city_csv)
      job.perform(users.map(&:id), organisation, "sales", "town-or-city")
    end

    it "sends emails to all the provided users" do
      expect(mailer).to receive(:send_missing_sales_addresses_csv_download_mail).with(users[0], test_url, "town-or-city")
      expect(mailer).to receive(:send_missing_sales_addresses_csv_download_mail).with(users[1], test_url, "town-or-city")
      job.perform(users.map(&:id), organisation, "sales", "town-or-city")
    end
  end
end
