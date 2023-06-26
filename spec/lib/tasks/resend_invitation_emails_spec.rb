require "rails_helper"
require "rake"

RSpec.describe "emails" do
  describe ":resend_invitation_emails", type: :task do
    subject(:task) { Rake::Task["emails:resend_invitation_emails"] }

    let(:notify_client) { instance_double(Notifications::Client) }
    let(:devise_notify_mailer) { DeviseNotifyMailer.new }
    let(:resend_invitation_mailer) { ResendInvitationMailer.new }
    let(:resend_invitation_email) { { deliver_later: nil } }

    before do
      allow(ResendInvitationMailer).to receive(:new).and_return(resend_invitation_mailer)
      allow(resend_invitation_mailer).to receive(:resend_invitation_email).and_return(resend_invitation_email)
      organisation.users.destroy_all
      Rake.application.rake_require("tasks/resend_invitation_emails")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let(:organisation) { create(:organisation, name: "test organisation") }
      let!(:active_user) { create(:user, name: "active user", email: "active_user@example.com", organisation:, confirmation_token: "ghi", initial_confirmation_sent: true, old_user_id: "234", sign_in_count: 0) }
      let!(:inactive_user) { create(:user, name: "inactive user", email: "inactive_user@example.com", organisation:, confirmation_token: "jkl", initial_confirmation_sent: true, old_user_id: "345", active: false, sign_in_count: 0) }
      let!(:logged_in_user) { create(:user, name: "logged in user", email: "logged_in_user@example.com", organisation:, confirmation_token: "mno", initial_confirmation_sent: true, old_user_id: "456", sign_in_count: 1) }

      context "with active user" do
        it "sends an invitation" do
          expect { task.invoke }.to enqueue_job(ActionMailer::MailDeliveryJob).with(
            "ResendInvitationMailer",
            "resend_invitation_email",
            "deliver_now",
            args: [active_user],
          )
        end
      end

      context "with inactive user" do
        it "does not send an invitation" do
          expect { task.invoke }.not_to enqueue_job(ActionMailer::MailDeliveryJob).with(
            "ResendInvitationMailer",
            "resend_invitation_email",
            "deliver_now",
            args: [inactive_user],
          )
        end
      end

      context "with logged in user" do
        it "does not send an invitation" do
          expect { task.invoke }.not_to enqueue_job(ActionMailer::MailDeliveryJob).with(
            "ResendInvitationMailer",
            "resend_invitation_email",
            "deliver_now",
            args: [logged_in_user],
          )
        end
      end

      it "prints out the total number of invitations sent" do
        expect(Rails.logger).to receive(:info).with(nil)
        expect(Rails.logger).to receive(:info).with("Sent invitation emails to 1 user.")
        task.invoke
      end
    end
  end
end
