require "rails_helper"
require_relative "form/helpers"

RSpec.describe "User Features" do
  include Helpers
  let(:organisation) { user.organisation }
  let(:org_id) { organisation.id }
  let(:set_password_template_id) { User::SET_PASSWORD_TEMPLATE_ID }
  let(:notify_client) { instance_double(Notifications::Client) }
  let(:reset_password_token) { "MCDH5y6Km-U7CFPgAMVS" }
  let(:devise_notify_mailer) { DeviseNotifyMailer.new }

  before do
    allow(DeviseNotifyMailer).to receive(:new).and_return(devise_notify_mailer)
    allow(devise_notify_mailer).to receive(:notify_client).and_return(notify_client)
    allow(Devise.token_generator).to receive(:generate).and_return(reset_password_token)
    allow(notify_client).to receive(:send_email).and_return(true)
    sign_in user
  end

  context "when user is a data coordinator" do
    let!(:user) { FactoryBot.create(:user, :data_coordinator) }

    context "when viewing organisation page" do
      it "defaults to organisation details" do
        visit("/logs")
        click_link("About Your Organisation")
        expect(page).to have_content(user.organisation.name)
      end

      it "can switch tabs" do
        visit("/organisations/#{org_id}")
        click_link("Users")
        expect(page).to have_current_path("/organisations/#{org_id}/users")
        click_link("About Your Organisation")
        expect(page).to have_current_path("/organisations/#{org_id}/details")
      end
    end

    context "when users are part of organisation" do
      it "users can be added" do
        visit("/organisations/#{org_id}")
        click_link("Users")
        click_link("Invite user")
        expect(page).to have_current_path("/users/new")
        expect(page).to have_content("Invite user to submit CORE data")
        fill_in("user[name]", with: "New User")
        fill_in("user[email]", with: "new_user@example.com")
        choose("user-role-data-provider-field")
        expect(notify_client).to receive(:send_email).with(
          {
            email_address: "new_user@example.com",
            template_id: set_password_template_id,
            personalisation: {
              name: "New User",
              email: "new_user@example.com",
              organisation: organisation.name,
              link: "http://localhost:3000/account/password/edit?reset_password_token=#{reset_password_token}",
            },
          },
        )
        click_button("Continue")
        expect(page).to have_current_path("/organisations/#{org_id}/users")
        expect(User.last.role).to eq("data_provider")
      end
    end
  end

  context "when the user is a data provider" do
    let(:user) { FactoryBot.create(:user) }

    context "when viewing organisation page" do
      it "can see the details tab and users tab" do
        visit("/logs")
        click_link("About Your Organisation")
        expect(page).to have_current_path("/organisations/#{org_id}/details")
        expect(page).to have_link("Logs")
        expect(page).to have_link("Users")
        expect(page).to have_link("About Your Organisation")
      end
    end
  end
end
