require "rails_helper"

describe CreateIllnessCsvJob do
  include Helpers

  let(:job) { described_class.new }
  let(:storage_service) { instance_double(Storage::S3Service) }
  let(:mailer) { instance_double(CsvDownloadMailer) }
  let(:missing_illness_csv_service) { instance_double(Csv::MissingIllnessCsvService) }
  let(:organisation) { build(:organisation) }
  let(:users) { create_list(:user, 2) }

  before do
    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(storage_service).to receive(:write_file)

    allow(Csv::MissingIllnessCsvService).to receive(:new).and_return(missing_illness_csv_service)
    allow(missing_illness_csv_service).to receive(:create_illness_csv).and_return("")
  end

  context "when creating illness logs csv" do
    it "uses an appropriate filename in S3" do
      expect(storage_service).to receive(:write_file).with(/missing-illness-#{organisation.name}-.*\.csv/, anything)
      job.perform(organisation)
    end

    it "creates a MissingIllnessCsvService with the correct organisation and calls create illness csv" do
      expect(Csv::MissingIllnessCsvService).to receive(:new).with(organisation)
      expect(missing_illness_csv_service).to receive(:create_illness_csv)
      job.perform(organisation)
    end
  end
end
