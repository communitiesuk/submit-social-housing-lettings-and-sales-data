require "rails_helper"

RSpec.describe "Sales Log Features" do
  context "when searching for specific sales logs" do
    context "when I am signed in and there are sales logs in the database" do
      let(:user) { FactoryBot.create(:user, last_sign_in_at: Time.zone.now) }
      let!(:log_to_search) { FactoryBot.create(:sales_log, owning_organisation: user.organisation) }
      let!(:same_organisation_log) { FactoryBot.create(:sales_log, owning_organisation: user.organisation) }
      let!(:another_organisation_log) { FactoryBot.create(:sales_log) }

      before do
        visit("/sales-logs")
        fill_in("user[email]", with: user.email)
        fill_in("user[password]", with: user.password)
        click_button("Sign in")
      end

      it "displays the logs belonging to the same organisation" do
        expect(page).to have_link(log_to_search.id.to_s)
        expect(page).to have_link(same_organisation_log.id.to_s)
        expect(page).not_to have_link(another_organisation_log.id.to_s)
      end

      context "when returning to the list of logs via breadcrumbs link" do
        before do
          visit("/sales-logs")
          click_button("Create a new sales log")
          click_link("Logs")
        end

        it "navigates you to the lettings logs page" do
          expect(page).to have_current_path("/sales-logs")
        end
      end

      context "when completing the setup sales log section" do
        it "includes the purchaser code and sale completion date questions" do
          visit("/sales-logs")
          click_button("Create a new sales log")
          click_link("Set up this sales log")
          fill_in("sales_log[purchid]", with: "PC123")
          click_button("Save and continue")
          fill_in("sales_log[saledate(1i)]", with: "2022")
          fill_in("sales_log[saledate(2i)]", with: "08")
          fill_in("sales_log[saledate(3i)]", with: "10")
          click_button("Save and continue")
          log_id = page.current_path.scan(/\d/).join
          visit("sales-logs/#{log_id}/setup/check-answers")
          expect(page).to have_content("Purchaser code")
          expect(page).to have_content("PC123")
          expect(page).to have_content("Sale completion date")
          expect(page).to have_content("2022")
        end
      end

      context "when the sales log feature flag is toggled" do
        before do
          allow(Rails.env).to receive(:production?).and_return(true)
        end

        it "hides the create sales log button in production" do
          visit("/sales-logs")
          expect(page).not_to have_content("Create a new sales log")
        end
      end
    end
  end
end
