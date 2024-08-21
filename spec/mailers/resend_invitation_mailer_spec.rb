require "rails_helper"

RSpec.describe ResendInvitationMailer do
  describe "#resend_invitation_email" do
    let(:notify_client) { instance_double(Notifications::Client) }
    let(:organisation) { create(:organisation, name: "test organisation") }
    let!(:active_user) { create(:user, name: "active user", email: "active_user@example.com", organisation:, confirmation_token: "ghi", initial_confirmation_sent: true, old_user_id: "234", sign_in_count: 0) }
    let!(:new_active_user) { create(:user, name: "new active user", email: "new_active_user@example.com", organisation:, confirmation_token: "abc", initial_confirmation_sent: false, old_user_id: nil, sign_in_count: 0) }
    let(:new_active_migrated_user) { create(:user, name: "new active migrated user", email: "new_active_migrated_user@example.com", organisation:, confirmation_token: "def", initial_confirmation_sent: false, old_user_id: "123", sign_in_count: 0) }

    before do
      LegacyUser.destroy_all
      allow(Notifications::Client).to receive(:new).and_return(notify_client)
      allow(notify_client).to receive(:send_email).and_return(true)
    end

    context "with a new active user" do
      let(:personalisation) do
        {
          name: "new active user",
          email: "new_active_user@example.com",
          organisation: "test organisation",
          link: include("/account/confirmation?confirmation_token=abc"),
        }
      end

      it "sends invitation email to user" do
        expect(notify_client).to receive(:send_email).with(email_address: "new_active_user@example.com", template_id: User::CONFIRMABLE_TEMPLATE_ID, personalisation:).once
        described_class.new.resend_invitation_email(new_active_user)
      end
    end

    context "with active migrated user before the initial invitation has been sent" do
      let(:personalisation) do
        {
          name: "new active migrated user",
          email: "new_active_migrated_user@example.com",
          organisation: "test organisation",
          link: include("/account/confirmation?confirmation_token=def"),
        }
      end

      it "sends an initial invitation" do
        FactoryBot.create(:legacy_user, old_user_id: new_active_migrated_user.old_user_id, user: new_active_migrated_user)
        expect(notify_client).to receive(:send_email).with(email_address: "new_active_migrated_user@example.com", template_id: User::CONFIRMABLE_TEMPLATE_ID, personalisation:).once
        described_class.new.resend_invitation_email(new_active_migrated_user)
      end
    end

    context "with active user after the initial invitation has been sent" do
      let(:personalisation) do
        {
          name: "active user",
          email: "active_user@example.com",
          organisation: "test organisation",
          link: include("/account/confirmation?confirmation_token=ghi"),
        }
      end

      it "sends a reinvitation" do
        expect(notify_client).to receive(:send_email).with(email_address: "active_user@example.com", template_id: User::CONFIRMABLE_TEMPLATE_ID, personalisation:).once
        described_class.new.resend_invitation_email(active_user)
      end
    end

    context "with unconfirmed user after the initial invitation has been sent" do
      let!(:unconfirmed_user) { create(:user, organisation:, confirmation_token: "dluch", initial_confirmation_sent: true, old_user_id: "234", sign_in_count: 0, confirmed_at: nil) }

      let(:personalisation) do
        {
          name: unconfirmed_user.name,
          email: unconfirmed_user.email,
          organisation: unconfirmed_user.organisation.name,
          link: include("/account/confirmation?confirmation_token=#{unconfirmed_user.confirmation_token}"),
        }
      end

      before do
        LegacyUser.destroy_all
      end

      it "sends a reinvitation" do
        expect(notify_client).to receive(:send_email).with(email_address: unconfirmed_user.email, template_id: User::RECONFIRMABLE_TEMPLATE_ID, personalisation:).once
        described_class.new.resend_invitation_email(unconfirmed_user)
      end
    end
  end
end
