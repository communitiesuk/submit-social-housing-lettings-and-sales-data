require "rails_helper"

RSpec.describe Forms::BulkUploadSales::UploadYourFile do
  subject(:form) { described_class.new(year:, file:, current_user:) }

  let(:year) { 2022 }
  let(:actual_file) { File.open(file_fixture("blank_bulk_upload_sales.csv")) }
  let(:file) do
    ActionDispatch::Http::UploadedFile.new(
      tempfile: actual_file,
      filename: "my-file.csv",
    )
  end
  let(:current_user) { create(:user) }
  let(:mock_storage_service) { instance_double("S3Service") }

  before do
    vcap_services = { "aws-s3-bucket" => {} }

    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with("VCAP_SERVICES").and_return(vcap_services.to_json)

    allow(Storage::S3Service).to receive(:new).and_return(mock_storage_service)
    allow(mock_storage_service).to receive(:write_file)
  end

  describe "#save" do
    it "persists a BulkUpload" do
      expect { form.save! }.to change(BulkUpload, :count).by(1)
    end

    it "persists a BulkUpload correctly" do
      form.save!

      bulk_upload = BulkUpload.last

      expect(bulk_upload.user).to eql(current_user)
      expect(bulk_upload.log_type).to eql("sales")
      expect(bulk_upload.year).to eql(year)
      expect(bulk_upload.filename).to eql("my-file.csv")
      expect(bulk_upload.identifier).to be_present
    end

    it "uploads file via storage service" do
      form.save!

      bulk_upload = BulkUpload.last

      expect(Storage::S3Service).to have_received(:new)
      expect(mock_storage_service).to have_received(:write_file).with(bulk_upload.identifier, actual_file.read)
    end

    it "enqueues job to process bulk upload" do
      expect {
        form.save!
      }.to have_enqueued_job(ProcessBulkUploadJob)
    end
  end
end
