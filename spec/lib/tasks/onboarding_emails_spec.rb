require "rails_helper"
require "rake"

describe "rake onboarding_emails:send", type: task do
  subject(:task) { Rake::Task["onboarding_emails:send"] }

  context "when onboarding a new organisation to private beta" do
    let!(:user) { FactoryBot.create(:user) }
    let(:notify_client) { instance_double(Notifications::Client) }
    let(:devise_notify_mailer) { DeviseNotifyMailer.new }
    let(:reset_password_token) { "MCDH5y6Km-U7CFPgAMVS" }
    let(:host) { "http://localhost:3000" }

    before do
      Rake.application.rake_require("tasks/onboarding_emails")
      Rake::Task.define_task(:environment)
      task.reenable
      allow(DeviseNotifyMailer).to receive(:new).and_return(devise_notify_mailer)
      allow(devise_notify_mailer).to receive(:notify_client).and_return(notify_client)
      allow(notify_client).to receive(:send_email).and_return(true)
      allow(Devise.token_generator).to receive(:generate).and_return(reset_password_token)
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with("APP_HOST").and_return(host)
    end

    it "can send the onboarding emails" do
      expect(notify_client).to receive(:send_email).with(
        {
          email_address: user.email,
          template_id: "b48bc2cd-5887-4611-8296-d0ab3ed0e7fd",
          personalisation: {
            name: user.name,
            link: "#{host}/account/password/edit?reset_password_token=#{reset_password_token}",
          },
        },
      )

      task.invoke(user.organisation.id)
    end
  end
end
