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
      duration = 20.minutes.to_i

      expect(notify_client).to receive(:send_email).with(
        email_address: user.email,
        template_id: described_class::CSV_MISSING_LETTINGS_ADDRESSES_DOWNLOAD_TEMPLATE_ID,
        personalisation: {
          name: user.name,
          issue_explanation: "Some address data is missing or incorrect. We've detected the following issues in your logs imported to the new version of CORE:\n\n- Missing town or city: The town or city in some logs is missing. This data is required in the new version of CORE.\n",
          how_to_fix: "You need to:\n
- download [this spreadsheet for lettings logs](#{link})
- fill in the missing address data
- check that the existing address data is correct\n",
          duration: "20 minutes",
        },
      )

      described_class.new.send_missing_lettings_addresses_csv_download_mail(user, link, duration, %w[missing_town])
    end
  end

  describe "#send_missing_sales_addresses_csv_download_mail" do
    it "sends a CSV download E-mail via notify" do
      link = :link
      duration = 20.minutes.to_i

      expect(notify_client).to receive(:send_email).with(
        email_address: user.email,
        template_id: described_class::CSV_MISSING_SALES_ADDRESSES_DOWNLOAD_TEMPLATE_ID,
        personalisation: {
          name: user.name,
          issue_explanation: "Some address data is missing or incorrect. We've detected the following issues in your logs imported to the new version of CORE:\n\n- UPRN may be incorrect: The UPRN in some logs may be incorrect, so wrong address data was imported. We think this is an issue because in some logs the UPRN is the same as the tenant code or property reference, and because your organisation has submitted logs for properties in Bristol for the first time.\n",
          how_to_fix: "You need to:\n
- download [this spreadsheet for sales logs](#{link})
- check the address data
- correct any errors\n",
          duration: "20 minutes",
        },
      )

      described_class.new.send_missing_sales_addresses_csv_download_mail(user, link, duration, %w[wrong_uprn])
    end
  end
end
