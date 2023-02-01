require "rails_helper"

RSpec.describe BulkUpload::Processor do
  subject(:processor) { described_class.new(bulk_upload:) }

  let(:bulk_upload) { create(:bulk_upload, :lettings) }

  describe "#call" do
    context "when processing a bulk upload with errors" do
      let(:mock_downloader) do
        instance_double(
          BulkUpload::Downloader,
          call: nil,
          path: file_fixture("2022_23_lettings_bulk_upload.csv"),
          delete_local_file!: nil,
        )
      end

      before do
        allow(BulkUpload::Downloader).to receive(:new).with(bulk_upload:).and_return(mock_downloader)
      end

      it "persist the validation errors" do
        expect { processor.call }.to change(BulkUploadError, :count)
      end

      it "deletes the local file afterwards" do
        processor.call

        expect(mock_downloader).to have_received(:delete_local_file!)
      end

      it "does not send success email" do
        allow(BulkUploadMailer).to receive(:send_bulk_upload_complete_mail).and_call_original

        processor.call

        expect(BulkUploadMailer).not_to have_received(:send_bulk_upload_complete_mail)
      end
    end

    context "when processing a bulk with perfect data" do
      let(:path) { file_fixture("2022_23_lettings_bulk_upload.csv") }

      let(:mock_downloader) do
        instance_double(
          BulkUpload::Downloader,
          call: nil,
          path:,
          delete_local_file!: nil,
        )
      end

      let(:mock_validator) do
        instance_double(
          BulkUpload::Lettings::Validator,
          call: nil,
          create_logs?: true,
        )
      end

      let(:mock_creator) do
        instance_double(
          BulkUpload::Lettings::LogCreator,
          call: nil,
          path:,
        )
      end

      before do
        allow(BulkUpload::Downloader).to receive(:new).with(bulk_upload:).and_return(mock_downloader)
        allow(BulkUpload::Lettings::Validator).to receive(:new).and_return(mock_validator)
        allow(BulkUpload::Lettings::LogCreator).to receive(:new).with(bulk_upload:, path:).and_return(mock_creator)
      end

      it "creates logs" do
        processor.call

        expect(mock_creator).to have_received(:call)
      end

      it "sends success email" do
        mail_double = instance_double("ActionMailer::MessageDelivery", deliver_later: nil)

        allow(BulkUploadMailer).to receive(:send_bulk_upload_complete_mail).and_return(mail_double)

        create(:lettings_log, :completed, bulk_upload:)

        processor.call

        expect(BulkUploadMailer).to have_received(:send_bulk_upload_complete_mail)
        expect(mail_double).to have_received(:deliver_later)
      end
    end
  end
end
