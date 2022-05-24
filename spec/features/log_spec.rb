require "rails_helper"

RSpec.describe "Log Features" do
  context "Searching for specific logs" do
    context "I am logged in and there are logs in the database" do
      let!(:user) { FactoryBot.create(:user, last_sign_in_at: Time.zone.now) }
      let!(:log_to_search) { FactoryBot.create(:case_log, owning_organisation: user.organisation, tenancy_code: "111") }
      let!(:same_organisation_log) { FactoryBot.create(:case_log, owning_organisation: user.organisation, tenancy_code: "222") }
      let!(:another_organisation_log) { FactoryBot.create(:case_log, tenancy_code: "333") }

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

        context "using log ID" do
          it "it displays log matching the log ID" do
            fill_in("search-field", with: log_to_search.id)
            click_button("Search")
            expect(page).to have_content(log_to_search.id)
            expect(page).not_to have_content(same_organisation_log.id)
            expect(page).not_to have_content(another_organisation_log.id)
          end
        end

        context "using log tenancy code" do
          it "it displays log matching the tenancy code" do
            fill_in("search-field", with: log_to_search.tenancy_code)
            click_button("Search")
            expect(page).to have_content(log_to_search.id)
            expect(page).not_to have_content(same_organisation_log.id)
            expect(page).not_to have_content(another_organisation_log.id)
          end
        end
      end
    end
  end
end
