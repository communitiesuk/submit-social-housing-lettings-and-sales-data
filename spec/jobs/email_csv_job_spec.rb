require "rails_helper"

describe EmailCsvJob do
  include Helpers

  test_url = :test_url

  let(:job) { described_class.new }
  let(:user) { FactoryBot.create(:user) }
  let(:storage_service) { instance_double(Storage::S3Service) }
  let(:mailer) { instance_double(CsvDownloadMailer) }
  let(:sales_log_csv_service) { instance_double(Csv::SalesLogCsvService) }
  let(:lettings_log_csv_service) { instance_double(Csv::LettingsLogCsvService) }
  let(:search_term) { "meaning" }
  let(:filters) { { "user" => "yours", "status" => %w[in_progress] } }
  let(:all_orgs) { false }
  let(:organisation) { build(:organisation) }
  let(:codes_only_export) { true }
  let(:lettings_logs) { build_list(:lettings_log, 5) }
  let(:sales_logs) { build_list(:sales_log, 5) }

  before do
    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(storage_service).to receive(:write_file)
    allow(storage_service).to receive(:get_presigned_url).and_return(test_url)

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

    it "creates a LettingsLogCsvService with the correct export type" do
      expect(Csv::LettingsLogCsvService).to receive(:new).with(user:, export_type: "labels")
      codes_only = false
      job.perform(user, nil, {}, nil, nil, codes_only, "lettings")
      expect(Csv::LettingsLogCsvService).to receive(:new).with(user:, export_type: "codes")
      codes_only = true
      job.perform(user, nil, {}, nil, nil, codes_only, "lettings")
    end

    it "passes the logs returned by the filter manager to the csv service" do
      expect(lettings_log_csv_service).to receive(:prepare_csv).with(lettings_logs)
      job.perform(user, nil, {}, nil, nil, codes_only_export)
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

    it "creates a SalesLogCsvService with the correct export type" do
      expect(Csv::SalesLogCsvService).to receive(:new).with(export_type: "labels")
      codes_only = false
      job.perform(user, nil, {}, nil, nil, codes_only, "sales")
      expect(Csv::SalesLogCsvService).to receive(:new).with(export_type: "codes")
      codes_only = true
      job.perform(user, nil, {}, nil, nil, codes_only, "sales")
    end

    it "passes the logs returned by the filter manager to the csv service" do
      expect(sales_log_csv_service).to receive(:prepare_csv).with(sales_logs)
      job.perform(user, nil, {}, nil, nil, codes_only_export, "sales")
    end
  end

  it "sends an E-mail with the presigned URL and duration" do
    expect(mailer).to receive(:send_csv_download_mail).with(user, test_url, instance_of(Integer))
    job.perform(user)
  end
end
