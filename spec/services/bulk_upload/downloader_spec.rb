require "rails_helper"

RSpec.describe BulkUpload::Downloader do
  subject(:downloader) { described_class.new(bulk_upload:) }

  let(:bulk_upload) { build(:bulk_upload) }

  let(:get_file_io) do
    io = StringIO.new
    io.write("hello")
    io.rewind
    io
  end

  describe "#call" do
    let(:mock_storage_service) { instance_double(Storage::S3Service, get_file_io:) }

    it "downloads the file as a temporary file" do
      allow(Storage::S3Service).to receive(:new).and_return(mock_storage_service)

      downloader.call

      expect(mock_storage_service).to have_received(:get_file_io).with(bulk_upload.identifier)

      expect(File).to exist(downloader.path)
      expect(File.read(downloader.path)).to eql("hello")
    end
  end

  describe "#delete_local_file!" do
    let(:mock_storage_service) { instance_double(Storage::S3Service, get_file_io:) }

    it "deletes the local file" do
      allow(Storage::S3Service).to receive(:new).and_return(mock_storage_service)

      downloader.call

      expect(File).to exist(downloader.path)
      expect(File.read(downloader.path)).to eql("hello")

      path = downloader.path

      downloader.delete_local_file!

      expect(File).not_to exist(path)
    end
  end
end
