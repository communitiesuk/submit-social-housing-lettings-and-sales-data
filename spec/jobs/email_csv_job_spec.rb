require "rails_helper"

describe EmailCsvJob do
  include Helpers

  let(:job) { described_class.new }
  let(:user) { FactoryBot.create(:user) }
  let(:storage_service) { instance_double(Storage::S3Service) }
  let(:mailer) { instance_double(CsvDownloadMailer) }
  let(:sales_log_csv_service) { instance_double(Csv::SalesLogCsvService) }
  let(:lettings_log_csv_service) { instance_double(Csv::LettingsLogCsvService) }
  let(:search_term) { "meaning" }
  let(:filters) { { "user" => "you", "status" => %w[in_progress] } }
  let(:all_orgs) { false }
  let(:organisation) { build(:organisation) }
  let(:codes_only_export) { true }
  let(:lettings_logs) { build_list(:lettings_log, 5) }
  let(:sales_logs) { build_list(:sales_log, 5) }

  before do
    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(storage_service).to receive(:write_file)

    allow(Csv::SalesLogCsvService).to receive(:new).and_return(sales_log_csv_service)
    allow(sales_log_csv_service).to receive(:prepare_csv).and_return("")

    allow(Csv::LettingsLogCsvService).to receive(:new).and_return(lettings_log_csv_service)
    allow(lettings_log_csv_service).to receive(:prepare_csv).and_return("")

    allow(CsvDownloadMailer).to receive(:new).and_return(mailer)
    allow(mailer).to receive(:send_csv_download_mail)
  end

  context "when exporting lettings logs" do
    before do
      allow(FilterManager).to receive(:filter_logs).and_return(lettings_logs)
    end

    it "uses an appropriate filename in S3" do
      expect(storage_service).to receive(:write_file).with(/lettings-logs-.*\.csv/, anything)
      job.perform(user)
    end

    it "includes the organisation name in the filename when one is provided" do
      expect(storage_service).to receive(:write_file).with(/lettings-logs-#{organisation.name}-.*\.csv/, anything)
      job.perform(user, nil, {}, nil, organisation)
    end

    it "calls the filter manager with the arguments provided" do
      expect(FilterManager).to receive(:filter_logs).with(a_kind_of(ActiveRecord::Relation), search_term, filters, all_orgs, user)
      job.perform(user, search_term, filters, all_orgs, organisation, codes_only_export)
    end

    it "creates a LettingsLogCsvService with the correct export type and year" do
      expect(Csv::LettingsLogCsvService).to receive(:new).with(user:, export_type: "labels", year: 2023)
      codes_only = false
      job.perform(user, nil, {}, nil, nil, codes_only, "lettings", 2023)
      expect(Csv::LettingsLogCsvService).to receive(:new).with(user:, export_type: "codes", year: 2024)
      codes_only = true
      job.perform(user, nil, {}, nil, nil, codes_only, "lettings", 2024)
    end

    it "passes the logs returned by the filter manager to the csv service" do
      expect(lettings_log_csv_service).to receive(:prepare_csv).with(lettings_logs)
      job.perform(user, nil, {}, nil, nil, codes_only_export)
    end

    it "creates a CsvDownload record" do
      job.perform(user, nil, {}, nil, nil, codes_only_export, "lettings")
      expect(CsvDownload.count).to eq(1)
      expect(CsvDownload.first.user).to eq(user)
      expect(CsvDownload.first.organisation).to eq(user.organisation)
      expect(CsvDownload.first.filename).to match(/lettings-logs-.*\.csv/)
      expect(CsvDownload.first.download_type).to eq("lettings")
    end
  end

  context "when exporting sales logs" do
    before do
      allow(FilterManager).to receive(:filter_logs).and_return(sales_logs)
    end

    it "uses an appropriate filename in S3" do
      expect(storage_service).to receive(:write_file).with(/sales-logs-.*\.csv/, anything)
      job.perform(user, nil, {}, nil, nil, nil, "sales")
    end

    it "includes the organisation name in the filename when one is provided" do
      expect(storage_service).to receive(:write_file).with(/sales-logs-#{organisation.name}-.*\.csv/, anything)
      job.perform(user, nil, {}, nil, organisation, nil, "sales")
    end

    it "calls the filter manager with the arguments provided" do
      expect(FilterManager).to receive(:filter_logs).with(a_kind_of(ActiveRecord::Relation), search_term, filters, all_orgs, user)
      job.perform(user, search_term, filters, all_orgs, organisation, codes_only_export, "sales")
    end

    it "creates a SalesLogCsvService with the correct export type and year" do
      expect(Csv::SalesLogCsvService).to receive(:new).with(user:, export_type: "labels", year: 2022)
      codes_only = false
      job.perform(user, nil, {}, nil, nil, codes_only, "sales", 2022)
      expect(Csv::SalesLogCsvService).to receive(:new).with(user:, export_type: "codes", year: 2023)
      codes_only = true
      job.perform(user, nil, {}, nil, nil, codes_only, "sales", 2023)
    end

    it "passes the logs returned by the filter manager to the csv service" do
      expect(sales_log_csv_service).to receive(:prepare_csv).with(sales_logs)
      job.perform(user, nil, {}, nil, nil, codes_only_export, "sales")
    end

    it "creates a CsvDownload record" do
      job.perform(user, nil, {}, nil, nil, codes_only_export, "sales")
      expect(CsvDownload.count).to eq(1)
      expect(CsvDownload.first.user).to eq(user)
      expect(CsvDownload.first.organisation).to eq(user.organisation)
      expect(CsvDownload.first.filename).to match(/sales-logs-.*\.csv/)
      expect(CsvDownload.first.download_type).to eq("sales")
    end
  end

  it "sends an E-mail with the presigned URL and duration" do
    expect(mailer).to receive(:send_csv_download_mail).with(user, /csv-downloads/, instance_of(Integer))
    job.perform(user)
  end
end
