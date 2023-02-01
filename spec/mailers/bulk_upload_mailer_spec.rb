require "rails_helper"

RSpec.describe BulkUploadMailer do
  subject(:mailer) { described_class.new }

  let(:notify_client) { instance_double(Notifications::Client) }
  let(:user) { create(:user, email: "user@example.com") }
  let(:bulk_upload) { build(:bulk_upload, :lettings) }

  before do
    allow(Notifications::Client).to receive(:new).and_return(notify_client)
    allow(notify_client).to receive(:send_email).and_return(true)
  end

  describe "#send_bulk_upload_complete_mail" do
    it "sends correctly formed email" do
      expect(notify_client).to receive(:send_email).with(
        email_address: user.email,
        template_id: described_class::BULK_UPLOAD_COMPLETE_TEMPLATE_ID,
        personalisation: {
          title: "You’ve successfully uploaded 0 logs",
          filename: bulk_upload.filename,
          upload_timestamp: bulk_upload.created_at,
          success_description: "The lettings 2022/23 data you uploaded has been checked. The 0 logs you uploaded are now complete.",
          logs_link: lettings_logs_url,
        },
      )

      mailer.send_bulk_upload_complete_mail(user:, bulk_upload:)
    end
  end
end
