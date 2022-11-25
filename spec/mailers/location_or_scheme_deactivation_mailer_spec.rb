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

  describe "#send_deactivation_mails" do
    let(:user_a) { FactoryBot.create(:user, email: "user_a@example.com") }
    let(:user_a_logs) { FactoryBot.create_list(:lettings_log, 1, created_by: user_a) }

    let(:user_b) { FactoryBot.create(:user, email: "user_b@example.com") }
    let(:user_b_logs) { FactoryBot.create_list(:lettings_log, 3, created_by: user_b) }

    let(:logs) { user_a_logs + user_b_logs }

    it "sends E-mails to the creators of affected logs with counts" do
      expect(notify_client).to receive(:send_email).with(hash_including({
        email_address: user_a.email,
        personalisation: hash_including({ log_count: user_a_logs.count }),
      }))

      expect(notify_client).to receive(:send_email).with(hash_including({
        email_address: user_b.email,
        personalisation: hash_including({ log_count: user_b_logs.count }),
      }))

      described_class.new.send_deactivation_mails(logs, :update_logs_url, "Test Scheme", "test postcode")
    end
  end
end
