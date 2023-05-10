require "rails_helper"

RSpec.describe "User sign in" do
  let(:user) { FactoryBot.create(:user) }

  context "when wrong credentials" do
    it "shows correct error message" do
      visit("/account/sign-in")
      fill_in("user[email]", with: user.email)
      fill_in("user[password]", with: "wrong_password")
      click_button("Sign in")
      expect(page).to have_content("Incorrect email or password")
    end
  end
end
