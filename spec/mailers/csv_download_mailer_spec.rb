require "rails_helper"

RSpec.describe CsvDownloadMailer do
  let(:notify_client) { instance_double(Notifications::Client) }
  let(:user) { FactoryBot.create(:user, email: "user@example.com") }

  before do
    allow(Notifications::Client).to receive(:new).and_return(notify_client)
    allow(notify_client).to receive(:send_email).and_return(true)
  end

  describe "#send_csv_download_mail" do
    it "sends a CSV download E-mail via notify" do
      link = :link
      duration = 20.minutes.to_i

      expect(notify_client).to receive(:send_email).with(
        email_address: user.email,
        template_id: described_class::CSV_DOWNLOAD_TEMPLATE_ID,
        personalisation: {
          name: user.name,
          link:,
          duration: "20 minutes",
        },
      )

      described_class.new.send_csv_download_mail(user, link, duration)
    end
  end

  describe "#send_missing_lettings_addresses_csv_download_mail" do
    it "sends a CSV download E-mail via notify" do
      link = :link

      expect(notify_client).to receive(:send_email).with(
        email_address: user.email,
        template_id: described_class::CSV_MISSING_LETTINGS_ADDRESSES_DOWNLOAD_TEMPLATE_ID,
        personalisation: {
          name: user.name,
          link:,
        },
      )

      described_class.new.send_missing_lettings_addresses_csv_download_mail(user, link)
    end
  end

  describe "#send_missing_sales_addresses_csv_download_mail" do
    it "sends a CSV download E-mail via notify" do
      link = :link

      expect(notify_client).to receive(:send_email).with(
        email_address: user.email,
        template_id: described_class::CSV_MISSING_SALES_ADDRESSES_DOWNLOAD_TEMPLATE_ID,
        personalisation: {
          name: user.name,
          link:,
        },
      )

      described_class.new.send_missing_sales_addresses_csv_download_mail(user, link)
    end
  end
end
