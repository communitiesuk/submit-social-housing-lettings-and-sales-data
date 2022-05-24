require "rails_helper"

RSpec.describe "Log Features" do
  context "Searching for specific logs" do
    context "I am logged in" do
      let!(:user) { FactoryBot.create(:user, last_sign_in_at: Time.zone.now) }
      let!(:log) { FactoryBot.create(:case_log, owning_organisation: user.organisation) }
      let!(:unwanted_logs) { FactoryBot.create_list(:case_log, 4, owning_organisation: user.organisation) }

      before do
        visit("/logs")
        fill_in("user[email]", with: user.email)
        fill_in("user[password]", with: "pAssword1")
        click_button("Sign in")
      end

      context "I can search for a specific log" do
        it "there is a search bar with a message and search button for logs" do
          expect(page).to have_field("search-field")
          expect(page).to have_content("Search by log ID, tenant code, property reference or postcode")
          expect(page).to have_button("Search")
        end

        it "displays log matching the search" do
          fill_in("search-field", with: log.id)
          click_button("Search")
          expect(page).to have_content(log.id)
          expect(page).not_to have_content(unwanted_logs.first.id)
        end
      end
    end
  end
end
