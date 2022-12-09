require "rails_helper"

RSpec.describe LocationOrSchemeDeactivationMailer do
  let(:notify_client) { instance_double(Notifications::Client) }

  before do
    allow(Notifications::Client).to receive(:new).and_return(notify_client)
    allow(notify_client).to receive(:send_email).and_return(true)
  end

  describe "#send_deactivation_mail" do
    let(:user) { FactoryBot.create(:user, email: "user@example.com") }

    it "sends a deactivation E-mail via notify" do
      update_logs_url = :update_logs_url

      expect(notify_client).to receive(:send_email).with(hash_including({
        email_address: user.email,
        template_id: described_class::DEACTIVATION_TEMPLATE_ID,
        personalisation: hash_including({ update_logs_url: }),
      }))

      described_class.new.send_deactivation_mail(user, 3, update_logs_url, "Test Scheme Name", "test postcode")
    end

    it "singularises 'logs' correctly" do
      expect(notify_client).to receive(:send_email).with(hash_including({
        personalisation: hash_including({
          log_count: 1,
          log_or_logs: "log",
        }),
      }))

      described_class.new.send_deactivation_mail(user, 1, :update_logs_url, :scheme_name)
    end

    it "pluralises 'logs' correctly" do
      expect(notify_client).to receive(:send_email).with(hash_including({
        personalisation: hash_including({
          log_count: 2,
          log_or_logs: "logs",
        }),
      }))

      described_class.new.send_deactivation_mail(user, 2, :update_logs_url, :scheme_name)
    end

    it "describes a scheme" do
      scheme_name = "Test Scheme"

      expect(notify_client).to receive(:send_email).with(hash_including({
        personalisation: hash_including({
          location_or_scheme_description: "the #{scheme_name} scheme",
        }),
      }))

      described_class.new.send_deactivation_mail(user, 3, :update_logs_url, scheme_name)
    end

    it "describes a location within a scheme" do
      scheme_name = "Test Scheme"
      postcode = "test postcode"

      expect(notify_client).to receive(:send_email).with(hash_including({
        personalisation: hash_including({
          location_or_scheme_description: "the #{postcode} location from the #{scheme_name} scheme",
        }),
      }))

      described_class.new.send_deactivation_mail(user, 3, :update_logs_url, scheme_name, postcode)
    end
  end
end
