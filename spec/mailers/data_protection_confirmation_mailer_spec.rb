require "rails_helper"

RSpec.describe DataProtectionConfirmationMailer do
  describe "#send_csv_download_mail" do
    let(:notify_client) { instance_double(Notifications::Client) }
    let(:user) { create(:user, email: "user@example.com") }
    let(:organisation) { user.organisation }

    before do
      allow(Notifications::Client).to receive(:new).and_return(notify_client)
      allow(notify_client).to receive(:send_email).and_return(true)
    end

    it "sends confirmation email to user" do
      expect(notify_client).to receive(:send_email).with(
        email_address: user.email,
        template_id: "3dbf78fe-a2c8-4d65-aa19-e4d62695d4a9",
        personalisation: {
          organisation_name: organisation.name,
          link: "#{ENV['APP_HOST']}/organisations/#{organisation.id}/data-sharing-agreement",
        },
      )

      described_class.new.send_confirmation_email(user)
    end
  end
end
