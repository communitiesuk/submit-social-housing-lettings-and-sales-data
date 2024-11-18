require "rails_helper"

describe SchemeEmailCsvJob do
  include Helpers

  let(:job) { described_class.new }
  let(:storage_service) { instance_double(Storage::S3Service, write_file: nil) }
  let(:mailer) { instance_double(CsvDownloadMailer, send_csv_download_mail: nil) }
  let(:user) { FactoryBot.create(:user) }

  before do
    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(CsvDownloadMailer).to receive(:new).and_return(mailer)
  end

  context "when exporting" do
    let(:scheme_csv_service) { instance_double(Csv::SchemeCsvService) }
    let(:organisation) { user.organisation }
    let(:download_type) { "combined" }
    let(:schemes) { create_list(:scheme, 1, owning_organisation: organisation) }

    before do
      create_list(:location, 2, scheme: schemes.first)
    end

    context "when download type schemes" do
      let(:download_type) { "schemes" }

      it "uses an appropriate filename in S3 and exports the correct schemes" do
        expect(storage_service).to receive(:write_file).with(/schemes-.*\.csv/, anything) do |_, content|
          expect(content).not_to be_nil
          expect(content).not_to be_nil
          expect(CSV.parse(content).count).to eq(2)
        end
        job.perform(user, nil, {}, nil, nil, download_type)
      end

      context "and there are stock owner schemes" do
        let(:parent_organisation) { create(:organisation) }

        before do
          create(:scheme, owning_organisation: parent_organisation)
          create(:organisation_relationship, parent_organisation:, child_organisation: organisation)
        end

        it "exports the correct number of schemes" do
          expect(storage_service).to receive(:write_file).with(/schemes-.*\.csv/, anything) do |_, content|
            expect(content).not_to be_nil
            expect(CSV.parse(content).count).to eq(3)
          end
          job.perform(user, nil, {}, nil, nil, download_type)
        end
      end

      it "creates a CsvDownload record" do
        job.perform(user, nil, {}, nil, nil, download_type)
        expect(CsvDownload.count).to eq(1)
        expect(CsvDownload.first.user).to eq(user)
        expect(CsvDownload.first.organisation).to eq(user.organisation)
        expect(CsvDownload.first.filename).to match(/schemes-.*\.csv/)
        expect(CsvDownload.first.download_type).to eq("schemes")
      end
    end

    context "when download type locations" do
      let(:download_type) { "locations" }

      it "uses an appropriate filename in S3" do
        expect(storage_service).to receive(:write_file).with(/locations-.*\.csv/, anything)
        job.perform(user, nil, {}, nil, nil, download_type)
      end

      it "creates a CsvDownload record" do
        job.perform(user, nil, {}, nil, nil, download_type)
        expect(CsvDownload.count).to eq(1)
        expect(CsvDownload.first.user).to eq(user)
        expect(CsvDownload.first.organisation).to eq(user.organisation)
        expect(CsvDownload.first.filename).to match(/locations-.*\.csv/)
        expect(CsvDownload.first.download_type).to eq("locations")
      end
    end

    context "when download type combined" do
      let(:download_type) { "combined" }

      it "uses an appropriate filename in S3" do
        expect(storage_service).to receive(:write_file).with(/schemes-and-locations.*\.csv/, anything)
        job.perform(user, nil, {}, nil, nil, download_type)
      end

      it "creates a CsvDownload record" do
        job.perform(user, nil, {}, nil, nil, download_type)
        expect(CsvDownload.count).to eq(1)
        expect(CsvDownload.first.user).to eq(user)
        expect(CsvDownload.first.organisation).to eq(user.organisation)
        expect(CsvDownload.first.filename).to match(/schemes-and-locations-.*\.csv/)
        expect(CsvDownload.first.download_type).to eq("combined")
      end
    end

    it "includes the organisation name in the filename when one is provided" do
      expect(storage_service).to receive(:write_file).with(/schemes-and-locations-#{organisation.name}-.*\.csv/, anything)
      job.perform(user, nil, {}, nil, organisation, "combined")
    end

    context "when resources are filtered" do
      let(:search_term) { "meaning" }
      let(:filters) { { "owning_organisation" => organisation.id, "status" => %w[active] } }
      let(:all_orgs) { false }

      before do
        allow(Csv::SchemeCsvService).to receive(:new).and_return(scheme_csv_service)
        allow(scheme_csv_service).to receive(:prepare_csv).and_return("")
        allow(FilterManager).to receive(:filter_schemes).and_return(schemes)
      end

      it "calls the filter manager with the arguments provided" do
        expect(FilterManager).to receive(:filter_schemes).with(a_kind_of(ActiveRecord::Relation), search_term, filters, all_orgs, user)
        job.perform(user, search_term, filters, all_orgs, organisation, "combined")
      end
    end

    it "creates a SchemeCsvService with the correct download type" do
      allow(Csv::SchemeCsvService).to receive(:new).and_return(scheme_csv_service)
      allow(scheme_csv_service).to receive(:prepare_csv).and_return("")

      expect(Csv::SchemeCsvService).to receive(:new).with(download_type: "schemes")
      job.perform(user, nil, {}, nil, nil, "schemes")
      expect(Csv::SchemeCsvService).to receive(:new).with(download_type: "locations")
      job.perform(user, nil, {}, nil, nil, "locations")
      expect(Csv::SchemeCsvService).to receive(:new).with(download_type: "combined")
      job.perform(user, nil, {}, nil, nil, "combined")
    end

    it "passes the schemes returned by the filter manager to the csv service" do
      allow(Csv::SchemeCsvService).to receive(:new).and_return(scheme_csv_service)
      allow(scheme_csv_service).to receive(:prepare_csv).and_return("")

      expect(scheme_csv_service).to receive(:prepare_csv).with(schemes)
      job.perform(user, nil, {}, nil, nil, "combined")
    end
  end

  it "sends an E-mail with the presigned URL and duration" do
    expect(mailer).to receive(:send_csv_download_mail).with(user, /csv-downloads/, instance_of(Integer))
    job.perform(user)
  end
end
