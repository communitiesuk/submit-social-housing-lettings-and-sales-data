require "rails_helper"
require "rake"

RSpec.describe "emails" do
  describe ":resend_invitation_emails", type: :task do
    subject(:task) { Rake::Task["emails:resend_invitation_emails"] }

    let(:notify_client) { instance_double(Notifications::Client) }
    let(:devise_notify_mailer) { DeviseNotifyMailer.new }

    before do
      Rake.application.rake_require("tasks/resend_invitation_emails")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let(:organisation) { create(:organisation, name: "test organisation") }

      before do
        allow(DeviseNotifyMailer).to receive(:new).and_return(devise_notify_mailer)
        allow(devise_notify_mailer).to receive(:notify_client).and_return(notify_client)
        allow(notify_client).to receive(:send_email).and_return(true)

        organisation.users.destroy_all
        create(:user, name: "new active user", email: "new_active_user@example.com", organisation:, confirmation_token: "abc", initial_confirmation_sent: false, old_user_id: nil, sign_in_count: 0)
        create(:user, name: "active user", email: "active_user@example.com", organisation:, confirmation_token: "ghi", initial_confirmation_sent: true, old_user_id: "234", sign_in_count: 0)
        LegacyUser.destroy_all
        create(:user, name: "new active migrated user", email: "new_active_migrated_user@example.com", organisation:, confirmation_token: "def", initial_confirmation_sent: false, old_user_id: "123", sign_in_count: 0)
        create(:user, name: "inactive user", email: "inactive_user@example.com", organisation:, confirmation_token: "jkl", initial_confirmation_sent: true, old_user_id: "345", active: false, sign_in_count: 0)
        create(:user, name: "logged in user", email: "logged_in_user@example.com", organisation:, confirmation_token: "mno", initial_confirmation_sent: true, old_user_id: "456", sign_in_count: 1)
      end

      context "with active non migrated user before the initial invitation has been sent" do
        let(:personalisation) do
          {
            name: "new active user",
            email: "new_active_user@example.com",
            organisation: "test organisation",
            link: include("/account/confirmation?confirmation_token=abc"),
          }
        end

        it "sends an initial invitation" do
          expect(notify_client).to receive(:send_email).with(email_address: "new_active_user@example.com", template_id: User::CONFIRMABLE_TEMPLATE_ID, personalisation:).once
          task.invoke
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
          expect(notify_client).to receive(:send_email).with(email_address: "new_active_migrated_user@example.com", template_id: User::BETA_ONBOARDING_TEMPLATE_ID, personalisation:).once
          task.invoke
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
          expect(notify_client).to receive(:send_email).with(email_address: "active_user@example.com", template_id: User::RECONFIRMABLE_TEMPLATE_ID, personalisation:).once
          task.invoke
        end
      end

      context "with inactive user" do
        let(:personalisation) do
          {
            name: "inactive user",
            email: "inactive_user@example.com",
            organisation: "test organisation",
            link: include("/account/confirmation?confirmation_token=jkl"),
          }
        end

        it "does not send an invitation" do
          expect(notify_client).not_to receive(:send_email).with(email_address: "inactive_user@example.com", template_id: User::CONFIRMABLE_TEMPLATE_ID, personalisation:)
          expect(notify_client).not_to receive(:send_email).with(email_address: "inactive_user@example.com", template_id: User::RECONFIRMABLE_TEMPLATE_ID, personalisation:)
          expect(notify_client).not_to receive(:send_email).with(email_address: "inactive_user@example.com", template_id: User::BETA_ONBOARDING_TEMPLATE_ID, personalisation:)
          task.invoke
        end
      end

      context "with logged in user" do
        let(:personalisation) do
          {
            name: "logged in user",
            email: "logged_in_user@example.com",
            organisation: "test organisation",
            link: include("/account/confirmation?confirmation_token=mno"),
          }
        end

        it "does not send an invitation" do
          expect(notify_client).not_to receive(:send_email).with(email_address: "logged_in_user@example.com", template_id: User::CONFIRMABLE_TEMPLATE_ID, personalisation:)
          expect(notify_client).not_to receive(:send_email).with(email_address: "logged_in_user@example.com", template_id: User::RECONFIRMABLE_TEMPLATE_ID, personalisation:)
          expect(notify_client).not_to receive(:send_email).with(email_address: "logged_in_user@example.com", template_id: User::BETA_ONBOARDING_TEMPLATE_ID, personalisation:)
          task.invoke
        end
      end

      it "prints out the total number of invitations sent" do
        expect(Rails.logger).to receive(:info).with("Sent invitation emails to 3 users.")
        task.invoke
      end
    end
  end
end
