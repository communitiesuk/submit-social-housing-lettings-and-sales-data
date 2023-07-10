require "rails_helper"

RSpec.describe DuplicateLogsController, type: :request do
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:user) { create(:user) }

  context "when a user is signed in" do
    let(:lettings_log) do
      create(
        :lettings_log,
        :completed,
        created_by: user,
      )
    end

    before do
      allow(user).to receive(:need_two_factor_authentication?).and_return(false)
      sign_in user
    end

    describe "GET" do
      context "with multiple duplicate lettings logs" do
        let(:duplicate_logs) { create_list(:lettings_log, 2, :completed) }

        before do
          allow(LettingsLog).to receive(:duplicate_logs_for_organisation).and_return(duplicate_logs)
          get "/lettings-logs/#{lettings_log.id}/duplicate-logs"
        end

        it "displays links to all the duplicate logs" do
          expect(page).to have_link("Log #{lettings_log.id}", href: "/lettings-logs/#{lettings_log.id}")
          expect(page).to have_link("Log #{duplicate_logs.first.id}", href: "/lettings-logs/#{duplicate_logs.first.id}")
          expect(page).to have_link("Log #{duplicate_logs.second.id}", href: "/lettings-logs/#{duplicate_logs.second.id}")
        end

        it "displays check your answers for each log with correct questions" do
          expect(page).to have_content("Q5 - Tenancy start date", count: 3)
          expect(page).to have_content("Q7 - Tenant code", count: 3)
          expect(page).to have_content("Q12 - Postcode", count: 3)
          expect(page).to have_content("Q32 - Lead tenant’s age", count: 3)
          expect(page).to have_content("Q33 - Lead tenant’s gender identity", count: 3)
          expect(page).to have_content("Q37 - Lead tenant’s working situation", count: 3)
          expect(page).to have_content("Household rent and charges", count: 3)
          expect(page).to have_link("Change", count: 21)
        end

        it "displays buttons to delete duplicates" do
          expect(page).to have_link("Keep this log and delete duplicates", count: 3)
        end
      end
    end
  end
end
