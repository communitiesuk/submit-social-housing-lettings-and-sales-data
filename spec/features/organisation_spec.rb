require "rails_helper"
require_relative "form/helpers"

RSpec.describe "User Features" do
  include Helpers
  let(:organisation) { user.organisation }
  let(:org_id) { organisation.id }

  before do
    sign_in user
  end

  context "User is a data coordinator" do
    let!(:user) { FactoryBot.create(:user, :data_coordinator) }

    context "Organisation page" do
      it "defaults to organisation details" do
        visit("/case-logs")
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
        expect { click_button("Continue") }.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(page).to have_current_path("/organisations/#{org_id}/users")
      end
    end
  end

  context "User is a data provider" do
    let!(:user) { FactoryBot.create(:user) }

    context "Organisation page" do
      it "can only see the details tab" do
        visit("/case-logs")
        click_link("Your organisation")
        expect(page).to have_current_path("/organisations/#{org_id}/details")
        expect(page).to have_no_link("Users")
      end
    end
  end
end
