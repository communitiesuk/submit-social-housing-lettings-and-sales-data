require "rails_helper"

RSpec.describe "Supported housing scheme Features" do
  context "when viewing list of schemes" do
    context "when I am signed as a support user in there are schemes in the database" do
      let(:user) { FactoryBot.create(:user, :support, last_sign_in_at: Time.zone.now) }
      let!(:schemes) { FactoryBot.create(:scheme) }
      let(:notify_client) { instance_double(Notifications::Client) }
      let(:confirmation_token) { "MCDH5y6Km-U7CFPgAMVS" }
      let(:devise_notify_mailer) { DeviseNotifyMailer.new }
      let(:otp) { "999111" }

      before do
        allow(DeviseNotifyMailer).to receive(:new).and_return(devise_notify_mailer)
        allow(devise_notify_mailer).to receive(:notify_client).and_return(notify_client)
        allow(Devise).to receive(:friendly_token).and_return(confirmation_token)
        allow(notify_client).to receive(:send_email).and_return(true)
        allow(SecureRandom).to receive(:random_number).and_return(otp)
        visit("/logs")
        fill_in("user[email]", with: user.email)
        fill_in("user[password]", with: user.password)
        click_button("Sign in")
        fill_in("code", with: otp)
        click_button("Submit")
      end

      it "displays the link to the supported housing" do
        expect(page).to have_link("Supported housing")
      end
    end
  end
end
