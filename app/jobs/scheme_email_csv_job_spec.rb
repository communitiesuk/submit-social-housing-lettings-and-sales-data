require "rails_helper"

describe SchemeEmailCsvJob do
  include Helpers

  test_url = :test_url

  let(:job) { described_class.new }
  let(:user) { FactoryBot.create(:user) }
  let(:storage_service) { instance_double(Storage::S3Service) }
  let(:mailer) { instance_double(CsvDownloadMailer) }
  let(:scheme_csv_service) { instance_double(Csv::SchemeCsvService) }
  let(:search_term) { "meaning" }
  let(:filters) { { "user" => "you", "status" => %w[in_progress] } }
  let(:all_orgs) { false }
  let(:organisation) { build(:organisation) }
  let(:download_type) { "combined" }
  let(:schemes) { build_list(:scheme, 5, owning_organisation: organisation) }
  let(:locations) { build_list(:locations, 5, scheme: schemes.first) }

  before do
    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(storage_service).to receive(:write_file)
    allow(storage_service).to receive(:get_presigned_url).and_return(test_url)

    allow(Csv::SchemeCsvService).to receive(:new).and_return(scheme_csv_service)
    allow(scheme_csv_service).to receive(:prepare_csv).and_return("")

    allow(CsvDownloadMailer).to receive(:new).and_return(mailer)
    allow(mailer).to receive(:send_csv_download_mail)
  end

  context "when exporting" do
    before do
      allow(FilterManager).to receive(:filter_schemes).and_return(schemes)
    end

    context "when download type schemes" do
      let(:download_type) { "schemes" }

      it "uses an appropriate filename in S3" do
        expect(storage_service).to receive(:write_file).with(/schemes-.*\.csv/, anything)
        job.perform(user)
      end
    end

    context "when download type locations" do
      let(:download_type) { "locations" }

      it "uses an appropriate filename in S3" do
        expect(storage_service).to receive(:write_file).with(/locations-.*\.csv/, anything)
        job.perform(user)
      end
    end

    context "when download type combined" do
      let(:download_type) { "combined" }

      it "uses an appropriate filename in S3" do
        expect(storage_service).to receive(:write_file).with(/schemes-and-locations.*\.csv/, anything)
        job.perform(user)
      end
    end

    it "includes the organisation name in the filename when one is provided" do
      expect(storage_service).to receive(:write_file).with(/schemes-and-locations-#{organisation.name}-.*\.csv/, anything)
      job.perform(user, nil, {}, nil, organisation, "combined")
    end

    it "calls the filter manager with the arguments provided" do
      expect(FilterManager).to receive(:filter_schemes).with(a_kind_of(ActiveRecord::Relation), search_term, filters, all_orgs, user)
      job.perform(user, search_term, filters, all_orgs, organisation, "combined")
    end

    it "creates a SchemeCsvService with the correct download type" do
      expect(Csv::SchemeCsvService).to receive(:new).with(download_type: "schemes")
      job.perform(user, nil, {}, nil, nil, "schemes")
      expect(Csv::SchemeCsvService).to receive(:new).with(download_type: "locations")
      job.perform(user, nil, {}, nil, nil, "locations")
      expect(Csv::SchemeCsvService).to receive(:new).with(download_type: "combined")
      job.perform(user, nil, {}, nil, nil, "combined")
    end

    it "passes the schemes returned by the filter manager to the csv service" do
      expect(scheme_csv_service).to receive(:prepare_csv).with(schemes)
      job.perform(user, nil, {}, nil, nil, "combined")
    end
  end

  it "sends an E-mail with the presigned URL and duration" do
    expect(mailer).to receive(:send_csv_download_mail).with(user, test_url, instance_of(Integer))
    job.perform(user)
  end
end
