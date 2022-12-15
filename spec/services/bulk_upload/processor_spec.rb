require "rails_helper"

RSpec.describe BulkUpload::Processor do
  subject(:processor) { described_class.new(bulk_upload:) }

  let(:bulk_upload) { create(:bulk_upload) }

  context "when processing a bulk upload with errors" do
    describe "#call" do
      let(:mock_downloader) { instance_double(BulkUpload::Downloader, call: nil) }

      it "persist the validation errors" do
        allow(BulkUpload::Downloader).to receive(:new).with(bulk_upload:).and_return(mock_downloader)

        expect { processor.call }.to change(BulkUploadError, :count).by(103)
      end
    end
  end
end
