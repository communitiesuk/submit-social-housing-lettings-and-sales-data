require "rails_helper"
require_relative "../../support/devise"

RSpec.describe Auth::PasswordsController, type: :request do
  let(:params) { { user: { email: email } } }

  context "when a password reset is requested for a valid email" do
    let(:user) { FactoryBot.create(:user) }
    let(:email) { user.email }

    it "redirects to the email sent page anyway" do
      post "/users/password", params: params
      expect(response).to have_http_status(:redirect)
      follow_redirect!
      expect(response.body).to match(/Check your email/)
    end
  end

  context "when a password reset is requested with an email that doesn't exist in the system" do
    before do
      allow_any_instance_of(Auth::PasswordsController).to receive(:is_navigational_format?).and_return(false)
    end

    let(:email) { "madeup_email@test.com" }

    it "redirects to the email sent page anyway" do
      post "/users/password", params: params
      expect(response).to have_http_status(:redirect)
      follow_redirect!
      expect(response.body).to match(/Check your email/)
    end
  end

  context "when a password reset is requested the email" do
    let(:user) { FactoryBot.create(:user) }
    let(:email) { user.email }

    it "should contain the correct email" do
      post "/users/password", params: params
      follow_redirect!
      email_ascii_content = ActionMailer::Base.deliveries.last.body.raw_source
      email_content = email_ascii_content.encode("ASCII", "UTF-8", undef: :replace)
      expect(email_content).to match(email)
    end
  end
end
