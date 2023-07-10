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
    let(:sales_log) do
      create(
        :sales_log,
        :completed,
        created_by: user,
      )
    end

    describe "GET" do
      context "when user is not signed in" do
        it "redirects to sign in page" do
          get "/lettings-logs/#{lettings_log.id}/duplicate-logs"
          expect(response).to redirect_to("/account/sign-in")
        end
      end

      context "when the user is from different organisation" do
        let(:other_user) { create(:user) }

        before do
          allow(other_user).to receive(:need_two_factor_authentication?).and_return(false)
          sign_in other_user
        end

        it "renders page not found" do
          get "/lettings-logs/#{lettings_log.id}/duplicate-logs"
          expect(response).to have_http_status(:not_found)
        end
      end

      context "when user is signed in" do
        before do
          allow(user).to receive(:need_two_factor_authentication?).and_return(false)
          sign_in user
        end

        context "with multiple duplicate lettings logs" do
          let(:duplicate_logs) { create_list(:lettings_log, 2, :completed) }

          before do
            allow(LettingsLog).to receive(:duplicate_logs).and_return(duplicate_logs)
            get "/lettings-logs/#{lettings_log.id}/duplicate-logs"
          end

          it "displays links to all the duplicate logs" do
            expect(page).to have_link("Log #{lettings_log.id}", href: "/lettings-logs/#{lettings_log.id}")
            expect(page).to have_link("Log #{duplicate_logs.first.id}", href: "/lettings-logs/#{duplicate_logs.first.id}")
            expect(page).to have_link("Log #{duplicate_logs.second.id}", href: "/lettings-logs/#{duplicate_logs.second.id}")
          end

          it "displays check your answers for each log with correct questions" do
            expect(page).to have_content("Q1 - Stock owner", count: 3)
            expect(page).to have_content("Q5 - Tenancy start date", count: 3)
            expect(page).to have_content("Q7 - Tenant code", count: 3)
            expect(page).to have_content("Q12 - Postcode", count: 3)
            expect(page).to have_content("Q32 - Lead tenant’s age", count: 3)
            expect(page).to have_content("Q33 - Lead tenant’s gender identity", count: 3)
            expect(page).to have_content("Q37 - Lead tenant’s working situation", count: 3)
            expect(page).to have_content("Household rent and charges", count: 3)
            expect(page).to have_link("Change", count: 24)
          end

          it "displays buttons to delete" do
            expect(page).to have_link("Keep this log and delete duplicates", count: 3)
          end
        end

        context "with multiple duplicate sales logs" do
          let(:duplicate_logs) { create_list(:sales_log, 2, :completed) }

          before do
            allow(SalesLog).to receive(:duplicate_logs).and_return(duplicate_logs)
            get "/sales-logs/#{sales_log.id}/duplicate-logs"
          end

          it "displays links to all the duplicate logs" do
            expect(page).to have_link("Log #{sales_log.id}", href: "/sales-logs/#{sales_log.id}")
            expect(page).to have_link("Log #{duplicate_logs.first.id}", href: "/sales-logs/#{duplicate_logs.first.id}")
            expect(page).to have_link("Log #{duplicate_logs.second.id}", href: "/sales-logs/#{duplicate_logs.second.id}")
          end

          it "displays check your answers for each log with correct questions" do
            expect(page).to have_content("Owning organisation", count: 3)
            expect(page).to have_content("Q1 - Sale completion date", count: 3)
            expect(page).to have_content("Q2 - Purchaser code", count: 3)
            expect(page).to have_content("Q20 - Lead buyer’s age", count: 3)
            expect(page).to have_content("Q21 - Buyer 1’s gender identity", count: 3)
            expect(page).to have_content("Q25 - Buyer 1's working situation", count: 3)
            expect(page).to have_content("Q15 - Postcode", count: 3)
            expect(page).to have_link("Change", count: 21)
          end

          it "displays buttons to delete" do
            expect(page).to have_link("Keep this log and delete duplicates", count: 3)
          end
        end
      end
    end
  end
end
