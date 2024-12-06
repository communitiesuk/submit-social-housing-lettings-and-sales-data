require "rails_helper"

RSpec.describe BulkUpload::Processor do
  subject(:processor) { described_class.new(bulk_upload:) }

  let(:bulk_upload) { create(:bulk_upload, :lettings, user:) }
  let(:user) { create(:user, organisation: owning_org) }
  let(:owning_org) { create(:organisation, old_visible_id: 123, rent_periods: [2]) }

  let(:mock_validator) do
    instance_double(
      BulkUpload::Lettings::Validator,
      invalid?: false,
      call: nil,
      total_logs_count: 1,
      any_setup_errors?: false,
      create_logs?: true,
      soft_validation_errors_only?: false,
    )
  end
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

  let(:log) { build(:lettings_log, :completed, assigned_to: user) }

  before do
    allow(BulkUpload::Lettings::Validator).to receive(:new).and_return(mock_validator)
    log_to_csv = BulkUpload::LettingsLogToCsv.new(log:)
    file.write(log_to_csv.default_field_numbers_row)
    file.write(log_to_csv.to_csv_row)
    file.rewind

    allow(BulkUpload::Downloader).to receive(:new).with(bulk_upload:).and_return(mock_downloader)
  end

  describe "#call" do
    it "changes processing from true to false" do
      bulk_upload.update!(processing: true)
      expect {
        processor.call
      }.to change { bulk_upload.reload.processing }.from(true).to(false)
    end

    context "when errors exist from prior job run" do
      let!(:existing_error) { create(:bulk_upload_error, bulk_upload:) }

      it "destroys existing errors" do
        processor.call

        expect { existing_error.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when the bulk upload itself is not considered valid" do
      let(:mock_validator) do
        instance_double(
          BulkUpload::Lettings::Validator,
          invalid?: true,
          call: nil,
          total_logs_count: 1,
          errors: [],
        )
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

      it "sets total number of logs on bulk upload" do
        processor.call

        bulk_upload.reload
        expect(bulk_upload.total_logs_count).to eq(1)
      end
    end

    context "when the bulk upload processing throws an error" do
      before do
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

    context "when a log has a setup error" do
      let(:mock_validator) do
        instance_double(
          BulkUpload::Lettings::Validator,
          invalid?: false,
          call: nil,
          total_logs_count: 1,
          any_setup_errors?: true,
        )
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
      let(:log) { build(:lettings_log, :setup_completed, assigned_to: user) }

      before do
        allow(mock_validator).to receive(:create_logs?).and_return(true)
        allow(mock_validator).to receive(:soft_validation_errors_only?).and_return(false)
        allow(FeatureToggle).to receive(:bulk_upload_duplicate_log_check_enabled?).and_return(true)
      end

      it "creates pending log" do
        expect { processor.call }.to change(LettingsLog.pending, :count).by(1)
      end

      it "sends how_to_fix_upload_mail" do
        mail_double = instance_double("ActionMailer::MessageDelivery", deliver_later: nil)

        allow(BulkUploadMailer).to receive(:send_how_to_fix_upload_mail).and_return(mail_double)

        processor.call

        expect(BulkUploadMailer).to have_received(:send_how_to_fix_upload_mail)
        expect(mail_double).to have_received(:deliver_later)
      end

      it "calls log creator" do
        log_creator_double = instance_double(BulkUpload::Lettings::LogCreator, call: nil)

        allow(BulkUpload::Lettings::LogCreator).to receive(:new).and_return(log_creator_double)

        processor.call

        expect(BulkUpload::Lettings::LogCreator).to have_received(:new).with(bulk_upload:, path:)
      end
    end

    context "when a bulk upload has logs with only soft validations triggered" do
      before do
        allow(mock_validator).to receive(:create_logs?).and_return(true)
        allow(mock_validator).to receive(:soft_validation_errors_only?).and_return(true)
        allow(FeatureToggle).to receive(:bulk_upload_duplicate_log_check_enabled?).and_return(true)
      end

      it "creates pending log" do
        expect { processor.call }.to change(LettingsLog.pending, :count).by(1)
      end

      it "sends check_soft_validations_mail" do
        mail_double = instance_double("ActionMailer::MessageDelivery", deliver_later: nil)

        allow(BulkUploadMailer).to receive(:send_check_soft_validations_mail).and_return(mail_double)
        allow(BulkUploadMailer).to receive(:send_how_to_fix_upload_mail).and_return(mail_double)

        processor.call

        expect(BulkUploadMailer).to have_received(:send_check_soft_validations_mail)
        expect(BulkUploadMailer).not_to have_received(:send_how_to_fix_upload_mail)
        expect(mail_double).to have_received(:deliver_later)
      end

      it "calls log creator" do
        log_creator_double = instance_double(BulkUpload::Lettings::LogCreator, call: nil)

        allow(BulkUpload::Lettings::LogCreator).to receive(:new).and_return(log_creator_double)

        processor.call

        expect(BulkUpload::Lettings::LogCreator).to have_received(:new).with(bulk_upload:, path:)
      end
    end

    context "when upload has something blocking log creation" do
      let(:mock_validator) do
        instance_double(
          BulkUpload::Lettings::Validator,
          invalid?: false,
          call: nil,
          total_logs_count: 1,
          any_setup_errors?: false,
          create_logs?: false,
        )
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
    let!(:log) { create(:lettings_log, :in_progress, bulk_upload:, status: "pending", status_cache: "in_progress") }

    it "makes pending logs no longer pending" do
      expect(log.status).to eql("pending")
      processor.approve
      expect(log.reload.status).to eql("in_progress")
    end
  end
end
