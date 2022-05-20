require "rails_helper"
require_relative "../../support/devise"

RSpec.describe Auth::ConfirmationsController, type: :request do
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:notify_client) { instance_double(Notifications::Client) }
  let(:devise_notify_mailer) { DeviseNotifyMailer.new }
  let(:user) { FactoryBot.create(:user, :data_provider, sign_in_count: 0, confirmed_at: nil) }

  before do
    allow(DeviseNotifyMailer).to receive(:new).and_return(devise_notify_mailer)
    allow(devise_notify_mailer).to receive(:notify_client).and_return(notify_client)
    allow(notify_client).to receive(:send_email).and_return(true)
  end

  context "when a confirmation link is clicked by a new user" do
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

  context "when the token has expired" do
    let(:period) { Devise::TimeInflector.time_ago_in_words(User.confirm_within.ago) }

    before do
      user.send_confirmation_instructions
      allow(User).to receive(:find_first_by_auth_conditions).and_return(user)
      allow(user).to receive(:confirmation_period_expired?).and_return(true)
      get "/account/confirmation?confirmation_token=#{user.confirmation_token}"
    end

    it "shows the error page" do
      expect(page).to have_content("Your invitation link has expired")
    end
  end

  context "when the user has already been confirmed" do
    let(:user) { FactoryBot.create(:user, :data_provider, sign_in_count: 0, confirmed_at: Time.zone.now) }

    before do
      user.send_confirmation_instructions
      get "/account/confirmation?confirmation_token=#{user.confirmation_token}"
    end

    it "redirects to the login page" do
      follow_redirect!
      expect(page).to have_content("Sign in to your account to submit CORE data")
    end

    it "does not show an error message" do
      follow_redirect!
      expect(page).not_to have_selector("#error-summary-title")
    end
  end
end
