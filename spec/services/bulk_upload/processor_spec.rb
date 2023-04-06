require "rails_helper"

RSpec.describe BulkUpload::Processor do
  subject(:processor) { described_class.new(bulk_upload:) }

  let(:bulk_upload) { create(:bulk_upload, :lettings, user:) }
  let(:user) { create(:user, organisation: owning_org) }
  let(:owning_org) { create(:organisation, old_visible_id: 123) }

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
          errors: [],
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

    context "when processing a bulk with perfect data" do
      let(:mock_downloader) do
        instance_double(
          BulkUpload::Downloader,
          call: nil,
          path:,
          delete_local_file!: nil,
        )
      end

      let(:file) { Tempfile.new }
      let(:path) { file.path }

      let(:log) do
        build(
          :lettings_log,
          :completed,
          renttype: 3,
          age1: 20,
          owning_organisation: owning_org,
          managing_organisation: owning_org,
          created_by: nil,
          national: 18,
          waityear: 9,
          joint: 2,
          tenancy: 9,
          ppcodenk: 0,
          voiddate: nil,
          mrcdate: nil,
          startdate: Date.new(2022, 10, 1),
          tenancylength: nil,
        )
      end

      before do
        file.write(BulkUpload::LogToCsv.new(log:, col_offset: 0).to_2022_csv_row)
        file.rewind

        allow(BulkUpload::Downloader).to receive(:new).with(bulk_upload:).and_return(mock_downloader)
      end

      it "creates logs as not pending" do
        expect { processor.call }.to change(LettingsLog.completed, :count).by(1)
      end

      it "sends success email" do
        mail_double = instance_double("ActionMailer::MessageDelivery", deliver_later: nil)

        allow(BulkUploadMailer).to receive(:send_bulk_upload_complete_mail).and_return(mail_double)

        processor.call

        expect(BulkUploadMailer).to have_received(:send_bulk_upload_complete_mail)
        expect(mail_double).to have_received(:deliver_later)
      end
    end

    context "when a bulk upload has an in progress log" do
      let(:mock_downloader) do
        instance_double(
          BulkUpload::Downloader,
          call: nil,
          path:,
          delete_local_file!: nil,
        )
      end

      let(:file) { Tempfile.new }
      let(:path) { file.path }

      let(:log) do
        LettingsLog.new(
          lettype: 2,
          renttype: 3,
          owning_organisation: owning_org,
          managing_organisation: owning_org,
          startdate: Time.zone.local(2022, 10, 1),
          renewal: 2,
        )
      end

      before do
        file.write(BulkUpload::LogToCsv.new(log:, col_offset: 0).to_2022_csv_row)
        file.rewind

        allow(BulkUpload::Downloader).to receive(:new).with(bulk_upload:).and_return(mock_downloader)
      end

      it "creates pending log" do
        expect { processor.call }.to change(LettingsLog.pending, :count).by(1)
      end

      it "sends how_fix_upload_mail" do
        mail_double = instance_double("ActionMailer::MessageDelivery", deliver_later: nil)

        allow(BulkUploadMailer).to receive(:send_how_fix_upload_mail).and_return(mail_double)

        processor.call

        expect(BulkUploadMailer).to have_received(:send_how_fix_upload_mail)
        expect(mail_double).to have_received(:deliver_later)
      end
    end

    context "when upload has no setup errors something blocks log creation" do
      let(:mock_downloader) do
        instance_double(
          BulkUpload::Downloader,
          call: nil,
          path:,
          delete_local_file!: nil,
        )
      end

      let(:file) { Tempfile.new }
      let(:path) { file.path }

      let(:other_user) { create(:user) }

      let(:log) do
        LettingsLog.new(
          lettype: 2,
          renttype: 3,
          owning_organisation: owning_org,
          managing_organisation: owning_org,
          startdate: Time.zone.local(2022, 10, 1),
          renewal: 2,
          created_by: other_user, # unaffiliated user
        )
      end

      before do
        file.write(BulkUpload::LogToCsv.new(log:, col_offset: 0).to_2022_csv_row)
        file.rewind

        allow(BulkUpload::Downloader).to receive(:new).with(bulk_upload:).and_return(mock_downloader)
      end

      it "sends correct_and_upload_again_mail" do
        mail_double = instance_double("ActionMailer::MessageDelivery", deliver_later: nil)

        allow(BulkUploadMailer).to receive(:send_correct_and_upload_again_mail).and_return(mail_double)

        processor.call

        expect(BulkUploadMailer).to have_received(:send_correct_and_upload_again_mail)
        expect(mail_double).to have_received(:deliver_later)
      end
    end
  end

  describe "#approve" do
    let!(:log) { create(:lettings_log, bulk_upload:, status: "pending", skip_update_status: true, status_cache: "not_started") }

    it "makes pending logs no longer pending" do
      expect(log.status).to eql("pending")
      processor.approve
      expect(log.reload.status).to eql("not_started")
    end
  end
end
