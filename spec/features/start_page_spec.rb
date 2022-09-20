require "rails_helper"
require_relative "form/helpers"

RSpec.describe "Start Page Features" do
  include Helpers
  let(:user) { FactoryBot.create(:user) }

  context "when the user is signed in" do
    before do
      sign_in user
    end

    it "takes you to logs" do
      visit("/")
      expect(page).to have_current_path("/logs")
    end
  end

  context "when the user is not signed in" do
    it "takes you to sign in and then to logs" do
      visit("/")
      click_link("Start now")
      expect(page).to have_current_path("/account/sign-in?start=true")
      fill_in("user[email]", with: user.email)
      fill_in("user[password]", with: user.password)
      click_button("Sign in")
      expect(page).to have_current_path("/logs")
    end
  end
end
