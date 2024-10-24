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
          issue_explanation: "We have found this issue in your logs imported to the new version of CORE:
## Missing town or city
The town or city in some logs is missing. This data is required in the new version of CORE.\n",
          how_to_fix: "You need to:\n
- download [this spreadsheet for lettings logs](#{link}). This link will expire in one week. To request another link, [contact the CORE helpdesk](https://mhclgdigital.atlassian.net/servicedesk/customer/portal/6/group/11).
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
          issue_explanation: "We have found this issue in your logs imported to the new version of CORE:
## Incorrect UPRN\nThe UPRN in some logs may be incorrect, so the wrong address data may have been imported.

In some of your logs, the UPRN is the same as the purchaser code, but these are different things. Purchaser codes are codes that your organisation uses to identify properties. UPRNs are unique numbers assigned by the Ordnance Survey.

If a log has the correct UPRN, leave the UPRN unchanged. If the UPRN is incorrect, clear the value and provide the full address instead. Alternatively, you can change the UPRN on the CORE system.\n",
          how_to_fix: "You need to:\n
- download [this spreadsheet for sales logs](#{link}). This link will expire in one week. To request another link, [contact the CORE helpdesk](https://mhclgdigital.atlassian.net/servicedesk/customer/portal/6/group/11).
- check that the address data is correct
- correct any address errors\n",
          duration: "20 minutes",
        },
      )

      described_class.new.send_missing_sales_addresses_csv_download_mail(user, link, duration, %w[wrong_uprn])
    end
  end
end
