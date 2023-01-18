require "rails_helper"

RSpec.describe BulkUpload::Processor do
  subject(:processor) { described_class.new(bulk_upload:) }

  let(:bulk_upload) { create(:bulk_upload, :lettings) }

  context "when processing a bulk upload with errors" do
    describe "#call" do
      let(:mock_downloader) do
        instance_double(
          BulkUpload::Downloader,
          call: nil,
          path: file_fixture("2022_23_lettings_bulk_upload.csv"),
          delete_local_file!: nil,
        )
      end

      it "persist the validation errors" do
        allow(BulkUpload::Downloader).to receive(:new).with(bulk_upload:).and_return(mock_downloader)

        expect { processor.call }.to change(BulkUploadError, :count)
      end

      it "deletes the local file afterwards" do
        allow(BulkUpload::Downloader).to receive(:new).with(bulk_upload:).and_return(mock_downloader)

        processor.call

        expect(mock_downloader).to have_received(:delete_local_file!)
      end
    end
  end
end
