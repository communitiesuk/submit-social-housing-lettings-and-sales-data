require "rails_helper"

RSpec.describe BulkUpload::Processor do
  subject(:processor) { described_class.new(bulk_upload:) }

  let(:bulk_upload) { create(:bulk_upload, :lettings) }

  describe "#call" do
    context "when the bulk upload itself is not considered valid" do
      let(:mock_downloader) do
        instance_double(
          BulkUpload::Downloader,
          call: nil,
          path: file_fixture("2022_23_lettings_bulk_upload.csv"),
          delete_local_file!: nil,
        )
      end

      let(:mock_validator) do
        instance_double(
          BulkUpload::Lettings::Validator,
          invalid?: true,
          call: nil,
        )
      end

      before do
        allow(BulkUpload::Downloader).to receive(:new).with(bulk_upload:).and_return(mock_downloader)
        allow(BulkUpload::Lettings::Validator).to receive(:new).and_return(mock_validator)
      end

      it "sends failure email" do
        mail_double = instance_double("ActionMailer::MessageDelivery", deliver_later: nil)

        allow(BulkUploadMailer).to receive(:send_bulk_upload_failed_service_error_mail).and_return(mail_double)

        processor.call

        expect(BulkUploadMailer).to have_received(:send_bulk_upload_failed_service_error_mail)
        expect(mail_double).to have_received(:deliver_later)
      end

      it "does not attempt to validate the contents of the file" do
        processor.call

        expect(mock_validator).not_to have_received(:call)
      end
    end

    context "when the bulk upload processing throws an error" do
      let(:mock_downloader) do
        instance_double(
          BulkUpload::Downloader,
          call: nil,
          path: file_fixture("2022_23_lettings_bulk_upload.csv"),
          delete_local_file!: nil,
        )
      end

      let(:mock_validator) do
        instance_double(
          BulkUpload::Lettings::Validator,
          invalid?: false,
        )
      end

      before do
        allow(BulkUpload::Downloader).to receive(:new).with(bulk_upload:).and_return(mock_downloader)
        allow(BulkUpload::Lettings::Validator).to receive(:new).and_return(mock_validator)

        allow(mock_validator).to receive(:call).and_raise(StandardError)
      end

      it "sends failure email" do
        mail_double = instance_double("ActionMailer::MessageDelivery", deliver_later: nil)

        allow(BulkUploadMailer).to receive(:send_bulk_upload_failed_service_error_mail).and_return(mail_double)

        processor.call

        expect(BulkUploadMailer).to have_received(:send_bulk_upload_failed_service_error_mail)
        expect(mail_double).to have_received(:deliver_later)
      end

      it "we log the failure" do
        allow(Sentry).to receive(:capture_exception)

        processor.call

        expect(Sentry).to have_received(:capture_exception)
      end
    end

    context "when a log has an incomplete setup section" do
      let(:mock_downloader) do
        instance_double(
          BulkUpload::Downloader,
          call: nil,
          path: file_fixture("2022_23_lettings_bulk_upload.csv"),
          delete_local_file!: nil,
        )
      end

      let(:mock_validator) do
        instance_double(
          BulkUpload::Lettings::Validator,
          invalid?: false,
          call: nil,
          any_setup_errors?: true,
        )
      end

      before do
        allow(BulkUpload::Downloader).to receive(:new).with(bulk_upload:).and_return(mock_downloader)
        allow(BulkUpload::Lettings::Validator).to receive(:new).and_return(mock_validator)
      end

      it "sends setup failure email" do
        mail_double = instance_double("ActionMailer::MessageDelivery", deliver_later: nil)

        allow(BulkUploadMailer).to receive(:send_bulk_upload_failed_file_setup_error_mail).and_return(mail_double)

        processor.call

        expect(BulkUploadMailer).to have_received(:send_bulk_upload_failed_file_setup_error_mail)
        expect(mail_double).to have_received(:deliver_later)
      end
    end

    context "when processing a bulk upload with errors but below threshold (therefore creates logs)" do
      let(:mock_downloader) do
        instance_double(
          BulkUpload::Downloader,
          call: nil,
          path: file_fixture("2022_23_lettings_bulk_upload.csv"),
          delete_local_file!: nil,
        )
      end

      let(:mock_validator) do
        instance_double(
          BulkUpload::Lettings::Validator,
          invalid?: false,
          call: nil,
          any_setup_errors?: false,
          create_logs?: true,
        )
      end

      before do
        allow(BulkUpload::Downloader).to receive(:new).with(bulk_upload:).and_return(mock_downloader)
        allow(BulkUpload::Lettings::Validator).to receive(:new).and_return(mock_validator)
      end

      it "deletes the local file afterwards" do
        processor.call

        expect(mock_downloader).to have_received(:delete_local_file!)
      end

      it "sends fix errors email" do
        mail_double = instance_double("ActionMailer::MessageDelivery", deliver_later: nil)

        allow(BulkUploadMailer).to receive(:send_bulk_upload_with_errors_mail).and_return(mail_double)

        processor.call

        expect(BulkUploadMailer).to have_received(:send_bulk_upload_with_errors_mail)
        expect(mail_double).to have_received(:deliver_later)
      end

      it "does not send success email" do
        allow(BulkUploadMailer).to receive(:send_bulk_upload_complete_mail).and_call_original

        processor.call

        expect(BulkUploadMailer).not_to have_received(:send_bulk_upload_complete_mail)
      end
    end

    context "when processing a bulk upload with errors but above threshold (therefore does not create logs)" do
      let(:mock_downloader) do
        instance_double(
          BulkUpload::Downloader,
          call: nil,
          path: file_fixture("2022_23_lettings_bulk_upload.csv"),
          delete_local_file!: nil,
        )
      end

      let(:mock_validator) do
        instance_double(
          BulkUpload::Lettings::Validator,
          invalid?: false,
          call: nil,
          any_setup_errors?: false,
          create_logs?: false,
        )
      end

      before do
        allow(BulkUpload::Downloader).to receive(:new).with(bulk_upload:).and_return(mock_downloader)
        allow(BulkUpload::Lettings::Validator).to receive(:new).and_return(mock_validator)
      end

      it "deletes the local file afterwards" do
        processor.call

        expect(mock_downloader).to have_received(:delete_local_file!)
      end

      it "sends correct and upload again mail" do
        mail_double = instance_double("ActionMailer::MessageDelivery", deliver_later: nil)

        allow(BulkUploadMailer).to receive(:send_correct_and_upload_again_mail).and_return(mail_double)

        processor.call

        expect(BulkUploadMailer).to have_received(:send_correct_and_upload_again_mail)
        expect(mail_double).to have_received(:deliver_later)
      end

      it "does not send fix errors email" do
        allow(BulkUploadMailer).to receive(:send_bulk_upload_with_errors_mail).and_call_original

        processor.call

        expect(BulkUploadMailer).not_to have_received(:send_bulk_upload_with_errors_mail)
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
          any_setup_errors?: false,
          invalid?: false,
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

      it "does not send fix errors email" do
        allow(BulkUploadMailer).to receive(:send_bulk_upload_with_errors_mail).and_call_original

        processor.call

        expect(BulkUploadMailer).not_to have_received(:send_bulk_upload_with_errors_mail)
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
