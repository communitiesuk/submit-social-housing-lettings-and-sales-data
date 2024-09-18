require "rails_helper"
require_relative "form/helpers"

RSpec.describe "Start Page Features" do
  include Helpers
  let(:user) { FactoryBot.create(:user) }

  context "when the user is signed in" do
    before do
      sign_in user
    end

    it "takes you to the home page" do
      visit(root_path)
      expect(page).to have_current_path("/")
      expect(page).to have_content("Welcome back")
    end
  end

  context "when the user is not signed in" do
    it "takes you to sign in and then to the home page" do
      visit(root_path)
      click_link("Start now")
      expect(page).to have_current_path("/account/sign-in?start=true")
      fill_in("user[email]", with: user.email)
      fill_in("user[password]", with: user.password)
      click_button("Sign in")
      expect(page).to have_current_path("/")
      expect(page).to have_content("Welcome back")
    end

    context "when the unauthenticated user clicks a notification link" do
      let!(:notification) { create(:notification, title: "Notification title", link_text: "link", page_content: "Some html content", show_on_unauthenticated_pages: true) }

      before do
        visit(root_path)
        click_link("link")
      end

      it "takes them to the notification details page" do
        expect(page).to have_current_path(notification_path(notification))
        expect(page).to have_content("Notification title")
        expect(page).to have_content("Some html content")
        expect(page).to have_link("Back to Start")
      end
    end
  end
end
