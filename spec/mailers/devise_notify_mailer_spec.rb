require "rails_helper"

RSpec.describe DeviseNotifyMailer do
  describe "Intercept mail" do
    let(:notify_client) { instance_double(Notifications::Client) }
    let(:devise_notify_mailer) { described_class.new }
    let(:organisation) { FactoryBot.create(:organisation) }
    let(:name) { "test" }
    let(:password) { "password" }
    let(:role) { "data_coordinator" }

    before do
      allow(described_class).to receive(:new).and_return(devise_notify_mailer)
      allow(devise_notify_mailer).to receive(:notify_client).and_return(notify_client)
      allow(notify_client).to receive(:send_email).and_return(true)
    end

    context "when the rails environment is staging" do
      before do
        allow(Rails.env).to receive(:test?).and_return(false)
        allow(Rails.env).to receive(:staging?).and_return(true)
      end

      context "when the email domain is not in the allowlist" do
        let(:email) { "test@example.com" }

        it "does not send emails" do
          expect(notify_client).not_to receive(:send_email)
          User.create!(name:, organisation:, email:, password:, role:)
        end
      end

      context "when the email domain is in the allowlist" do
        let(:domain) { Rails.application.credentials[:email_allowlist].first }
        let(:email) { "test@#{domain}" }

        it "does send emails" do
          expect(notify_client).to receive(:send_email).once
          User.create!(name:, organisation:, email:, password:, role:)
        end
      end
    end

    context "when the rails environment is not staging" do
      context "when the email domain is not in the allowlist" do
        let(:email) { "test@example.com" }

        it "does send emails" do
          expect(notify_client).to receive(:send_email).once
          User.create!(name:, organisation:, email:, password:, role:)
        end
      end
    end

    context "when a user is invited for the first time" do
      let(:email) { "test@example.com" }

      it "sends initial confirmation template" do
        expect(notify_client).to receive(:send_email).with(hash_including(template_id: User::CONFIRMABLE_TEMPLATE_ID))
        User.create!(name:, organisation:, email:, password:, role:)
      end
    end

    context "when a user requests a new confirmation link" do
      let(:email) { "test@example.com" }


      it "sends re-confirmation template" do
        user = User.create!(name:, organisation:, email:, password:, role:)
        expect(notify_client).to receive(:send_email).with(hash_including(template_id: User::RECONFIRMABLE_TEMPLATE_ID))
        user.send_confirmation_instructions
      end
    end
  end
end
