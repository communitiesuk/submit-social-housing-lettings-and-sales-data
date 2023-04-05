require "rails_helper"

RSpec.describe BulkUploadMailer do
  subject(:mailer) { described_class.new }

  let(:notify_client) { instance_double(Notifications::Client) }
  let(:user) { create(:user, email: "user@example.com") }
  let(:bulk_upload) { create(:bulk_upload, :lettings, user:) }

  before do
    allow(Notifications::Client).to receive(:new).and_return(notify_client)
    allow(notify_client).to receive(:send_email).and_return(true)
  end

  describe "#send_bulk_upload_failed_file_setup_error_mail" do
    before do
      create(:bulk_upload_error, bulk_upload:, col: "A", field: "field_1", category: "setup")
      create(:bulk_upload_error, bulk_upload:, col: "E", field: "field_4", category: "setup")
      create(:bulk_upload_error, bulk_upload:, col: "F", field: "field_5")
    end

    let(:expected_errors) do
      [
        "- What is the letting type? (Column A)",
        "- Management group code (Column E)",
      ]
    end

    it "sends correctly formed email" do
      expect(notify_client).to receive(:send_email).with(
        email_address: bulk_upload.user.email,
        template_id: described_class::FAILED_FILE_SETUP_ERROR_TEMPLATE_ID,
        personalisation: {
          filename: bulk_upload.filename,
          upload_timestamp: bulk_upload.created_at.to_fs(:govuk_date_and_time),
          lettings_or_sales: bulk_upload.log_type,
          year_combo: bulk_upload.year_combo,
          errors_list: expected_errors.join("\n"),
          bulk_upload_link: start_bulk_upload_lettings_logs_url,
        },
      )

      mailer.send_bulk_upload_failed_file_setup_error_mail(bulk_upload:)
    end
  end

  describe "#send_bulk_upload_complete_mail" do
    it "sends correctly formed email" do
      expect(notify_client).to receive(:send_email).with(
        email_address: user.email,
        template_id: described_class::COMPLETE_TEMPLATE_ID,
        personalisation: {
          title: "You’ve successfully uploaded 0 logs",
          filename: bulk_upload.filename,
          upload_timestamp: bulk_upload.created_at.to_fs(:govuk_date_and_time),
          success_description: "The lettings 2022/23 data you uploaded has been checked. The 0 logs you uploaded are now complete.",
          logs_link: lettings_logs_url,
        },
      )

      mailer.send_bulk_upload_complete_mail(user:, bulk_upload:)
    end
  end

  describe "#send_bulk_upload_failed_service_error_mail" do
    it "sends correctly formed email" do
      expect(notify_client).to receive(:send_email).with(
        email_address: user.email,
        template_id: described_class::FAILED_SERVICE_ERROR_TEMPLATE_ID,
        personalisation: {
          filename: bulk_upload.filename,
          upload_timestamp: bulk_upload.created_at.to_fs(:govuk_date_and_time),
          lettings_or_sales: bulk_upload.log_type,
          year_combo: bulk_upload.year_combo,
          errors: "- foo\n- bar",
          bulk_upload_link: start_bulk_upload_lettings_logs_url,
        },
      )

      mailer.send_bulk_upload_failed_service_error_mail(bulk_upload:, errors: %w[foo bar])
    end
  end

  describe "#send_correct_and_upload_again_mail" do
    context "when 2 columns with errors" do
      before do
        create(:bulk_upload_error, bulk_upload:, col: "A")
        create(:bulk_upload_error, bulk_upload:, col: "B")
      end

      it "sends correctly formed email" do
        expect(notify_client).to receive(:send_email).with(
          email_address: user.email,
          template_id: described_class::FAILED_CSV_ERRORS_TEMPLATE_ID,
          personalisation: {
            filename: bulk_upload.filename,
            upload_timestamp: bulk_upload.created_at.to_fs(:govuk_date_and_time),
            year_combo: bulk_upload.year_combo,
            lettings_or_sales: bulk_upload.log_type,
            summary_report_link: "http://localhost:3000/lettings-logs/bulk-upload-results/#{bulk_upload.id}",
          },
        )

        mailer.send_correct_and_upload_again_mail(bulk_upload:)
      end
    end
  end
end
