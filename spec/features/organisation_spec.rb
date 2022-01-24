require "rails_helper"
require_relative "form/helpers"

RSpec.describe "User Features" do
  include Helpers
  let(:organisation) { user.organisation }
  let(:org_id) { organisation.id }
  let(:set_password_template_id) { DeviseNotifyMailer::SET_PASSWORD_TEMPLATE_ID }
  let(:notify_client) { double(Notifications::Client) }
  let(:reset_password_token) { "MCDH5y6Km-U7CFPgAMVS" }

  before do
    allow_any_instance_of(DeviseNotifyMailer).to receive(:notify_client).and_return(notify_client)
    allow_any_instance_of(DeviseNotifyMailer).to receive(:host).and_return("test.com")
    allow_any_instance_of(User).to receive(:set_reset_password_token).and_return(reset_password_token)
    allow(notify_client).to receive(:send_email).and_return(true)
    sign_in user
  end

  context "User is a data coordinator" do
    let!(:user) { FactoryBot.create(:user, :data_coordinator) }

    context "Organisation page" do
      it "defaults to organisation details" do
        visit("/logs")
        click_link("Your organisation")
        expect(page).to have_content(user.organisation.name)
      end

      it "can switch tabs" do
        visit("/organisations/#{org_id}")
        click_link("Users")
        expect(page).to have_current_path("/organisations/#{org_id}/users")
        click_link("Details")
        expect(page).to have_current_path("/organisations/#{org_id}/details")
      end
    end

    context "Organisation users" do
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
              link: "https://test.com/users/password/edit?reset_password_token=#{reset_password_token}",
            },
          },
        )
        click_button("Continue")
        expect(page).to have_current_path("/organisations/#{org_id}/users")
        expect(User.last.role).to eq("data_provider")
      end
    end
  end

  context "User is a data provider" do
    let!(:user) { FactoryBot.create(:user) }

    context "Organisation page" do
      it "can only see the details tab" do
        visit("/logs")
        click_link("Your organisation")
        expect(page).to have_current_path("/organisations/#{org_id}/details")
        expect(page).to have_no_link("Users")
      end
    end
  end
end
