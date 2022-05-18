require "rails_helper"
require_relative "../../support/devise"

RSpec.describe Auth::ConfirmationsController, type: :request do
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:notify_client) { instance_double(Notifications::Client) }
  let(:devise_notify_mailer) { DeviseNotifyMailer.new }

  before do
    allow(DeviseNotifyMailer).to receive(:new).and_return(devise_notify_mailer)
    allow(devise_notify_mailer).to receive(:notify_client).and_return(notify_client)
    allow(notify_client).to receive(:send_email).and_return(true)
  end

  context "when a confirmation link is clicked by a new user" do
    let(:user) { FactoryBot.create(:user, :data_provider, sign_in_count: 0, confirmed_at: nil) }

    before do
      user.send_confirmation_instructions
      get "/account/confirmation?confirmation_token=#{user.confirmation_token}"
    end

    it "marks the user as confirmed" do
      expect(user.reload.confirmed_at).to be_a(Time)
    end

    it "redirects to the set password page" do
      follow_redirect!
      expect(page).to have_content(I18n.t("user.create_password"))
    end
  end
end
