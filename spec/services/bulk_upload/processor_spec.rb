require "rails_helper"

RSpec.describe BulkUpload::Processor do
  subject(:processor) { described_class.new(bulk_upload:) }

  let(:bulk_upload) { create(:bulk_upload, :lettings, user:) }
  let(:user) { create(:user, organisation: owning_org) }
  let(:owning_org) { create(:organisation, old_visible_id: 123) }

  around do |example|
    Timecop.freeze(Time.utc(2023, 1, 1)) do
      Singleton.__init__(FormHandler)
      example.run
    end
  end

  describe "#call" do
    before do
      Timecop.freeze(Time.zone.local(2023, 11, 10))
      Singleton.__init__(FormHandler)
    end

    after do
      Timecop.return
    end

    context "when errors exist from prior job run" do
      let!(:existing_error) { create(:bulk_upload_error, bulk_upload:) }

      it "destroys existing errors" do
        processor.call

        expect { existing_error.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

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
          total_logs_count: 1,
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

      it "sets total number of logs on bulk upload" do
        processor.call

        bulk_upload.reload
        expect(bulk_upload.total_logs_count).to eq(1)
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
          total_logs_count: 1,
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
          total_logs_count: 1,
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
          ppcodenk: 1,
          voiddate: nil,
          mrcdate: nil,
          startdate: Date.new(2022, 10, 1),
          tenancylength: nil,
        )
      end

      before do
        file.write(BulkUpload::LettingsLogToCsv.new(log:, col_offset: 0).to_2022_csv_row)
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

    context "when processing an empty file" do
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

      before do
        allow(BulkUpload::Downloader).to receive(:new).with(bulk_upload:).and_return(mock_downloader)
      end

      it "sends failure email" do
        mail_double = instance_double("ActionMailer::MessageDelivery", deliver_later: nil)

        allow(BulkUploadMailer).to receive(:send_bulk_upload_failed_service_error_mail).and_return(mail_double)

        processor.call

        expect(BulkUploadMailer).to have_received(:send_bulk_upload_failed_service_error_mail).with(
          bulk_upload:,
          errors: ["Template is blank - The template must be filled in for us to create the logs and check if data is correct."],
        )
        expect(mail_double).to have_received(:deliver_later)
      end
    end

    context "when processing an empty file with headers" do
      context "when 2022-23" do
        let(:mock_downloader) do
          instance_double(
            BulkUpload::Downloader,
            call: nil,
            path: file_fixture("2022_23_lettings_bulk_upload_empty_with_headers.csv"),
            delete_local_file!: nil,
          )
        end

        before do
          allow(BulkUpload::Downloader).to receive(:new).with(bulk_upload:).and_return(mock_downloader)
        end

        it "sends failure email" do
          mail_double = instance_double("ActionMailer::MessageDelivery", deliver_later: nil)

          allow(BulkUploadMailer).to receive(:send_bulk_upload_failed_service_error_mail).and_return(mail_double)

          processor.call

          expect(BulkUploadMailer).to have_received(:send_bulk_upload_failed_service_error_mail).with(
            bulk_upload:,
            errors: ["Template is blank - The template must be filled in for us to create the logs and check if data is correct."],
          )
          expect(mail_double).to have_received(:deliver_later)
        end
      end
    end

    context "when 2023-24" do
      let(:mock_downloader) do
        instance_double(
          BulkUpload::Downloader,
          call: nil,
          path: file_fixture("2023_24_lettings_bulk_upload_empty_with_headers.csv"),
          delete_local_file!: nil,
        )
      end

      before do
        allow(BulkUpload::Downloader).to receive(:new).with(bulk_upload:).and_return(mock_downloader)
      end

      it "sends failure email" do
        mail_double = instance_double("ActionMailer::MessageDelivery", deliver_later: nil)

        allow(BulkUploadMailer).to receive(:send_bulk_upload_failed_service_error_mail).and_return(mail_double)

        processor.call

        expect(BulkUploadMailer).to have_received(:send_bulk_upload_failed_service_error_mail).with(
          bulk_upload:,
          errors: ["Template is blank - The template must be filled in for us to create the logs and check if data is correct."],
        )
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
          declaration: 1,
        )
      end

      before do
        file.write(BulkUpload::LettingsLogToCsv.new(log:, col_offset: 0).to_2022_csv_row)
        file.rewind

        allow(BulkUpload::Downloader).to receive(:new).with(bulk_upload:).and_return(mock_downloader)
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
          ecstat1: 5,
          owning_organisation: owning_org,
          managing_organisation: owning_org,
          created_by: nil,
          national: 18,
          waityear: 9,
          joint: 2,
          tenancy: 2,
          ppcodenk: 1,
          voiddate: Date.new(2022, 1, 1),
          reason: 40,
          leftreg: 3,
          mrcdate: nil,
          startdate: Date.new(2022, 10, 1),
          tenancylength: nil,
        )
      end

      before do
        FormHandler.instance.use_real_forms!
        file.write(BulkUpload::LettingsLogToCsv.new(log:, col_offset: 0).to_2022_csv_row)
        file.rewind

        allow(BulkUpload::Downloader).to receive(:new).with(bulk_upload:).and_return(mock_downloader)
        allow(FeatureToggle).to receive(:bulk_upload_duplicate_log_check_enabled?).and_return(true)
      end

      after do
        FormHandler.instance.use_fake_forms!
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
          declaration: 1,
        )
      end

      before do
        file.write(BulkUpload::LettingsLogToCsv.new(log:, col_offset: 0).to_2022_csv_row)
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
