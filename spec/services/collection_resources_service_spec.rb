require "rails_helper"

describe CollectionResourcesService do
  let(:service) { described_class.new }
  let(:some_file) { File.open(file_fixture("blank_bulk_upload_sales.csv")) }
  let(:storage_service) { instance_double(Storage::S3Service) }

  describe "#upload_collection_resource" do
    before do
      allow(Storage::S3Service).to receive(:new).and_return(storage_service)
      allow(storage_service).to receive(:write_file)
    end

    it "calls write_file on S3 service" do
      expect(storage_service).to receive(:write_file).with("2025_26_lettings_paper_form.pdf", some_file)
      service.upload_collection_resource("2025_26_lettings_paper_form.pdf", some_file)
    end
  end
end
