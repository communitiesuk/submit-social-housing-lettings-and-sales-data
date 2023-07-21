require "rails_helper"

RSpec.describe DuplicateLogsController, type: :request do
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:user) { create(:user, :data_coordinator) }
  let(:lettings_log) { create(:lettings_log, :duplicate, created_by: user) }
  let(:sales_log) { create(:sales_log, :duplicate, created_by: user) }

  describe "GET show" do
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

      context "when viewing lettings logs duplicates" do
        context "when there are multiple duplicate logs" do
          let(:duplicate_logs) { create_list(:lettings_log, 2, :completed) }

          before do
            allow(LettingsLog).to receive(:duplicate_logs).and_return(duplicate_logs)
            get "/lettings-logs/#{lettings_log.id}/duplicate-logs?original_log_id=#{lettings_log.id}"
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
            expect(page).to have_link("Change", href: "/lettings-logs/#{lettings_log.id}/tenant-code?first_remaining_duplicate_id=#{duplicate_logs[0].id}&original_log_id=#{lettings_log.id}&referrer=duplicate_logs")
            expect(page).to have_link("Change", href: "/lettings-logs/#{duplicate_logs[0].id}/tenant-code?first_remaining_duplicate_id=#{lettings_log.id}&original_log_id=#{lettings_log.id}&referrer=duplicate_logs")
            expect(page).to have_link("Change", href: "/lettings-logs/#{duplicate_logs[1].id}/tenant-code?first_remaining_duplicate_id=#{lettings_log.id}&original_log_id=#{lettings_log.id}&referrer=duplicate_logs")
          end

          it "displays buttons to delete" do
            expect(page).to have_link("Keep this log and delete duplicates", count: 3)
            expect(page).to have_link("Keep this log and delete duplicates", href: "/lettings-logs/#{lettings_log.id}/delete-duplicates?original_log_id=#{lettings_log.id}")
            expect(page).to have_link("Keep this log and delete duplicates", href: "/lettings-logs/#{duplicate_logs.first.id}/delete-duplicates?original_log_id=#{lettings_log.id}")
            expect(page).to have_link("Keep this log and delete duplicates", href: "/lettings-logs/#{duplicate_logs.second.id}/delete-duplicates?original_log_id=#{lettings_log.id}")
          end
        end

        context "when there are no more duplicate logs" do
          before do
            allow(LettingsLog).to receive(:duplicate_logs).and_return(LettingsLog.none)
            get "/lettings-logs/#{lettings_log.id}/duplicate-logs?original_log_id=#{lettings_log.id}"
          end

          it "displays check your answers for each log with correct questions" do
            expect(page).to have_content("Q5 - Tenancy start date", count: 1)
            expect(page).to have_content("Q7 - Tenant code", count: 1)
            expect(page).to have_content("Q12 - Postcode", count: 1)
            expect(page).to have_content("Q32 - Lead tenant’s age", count: 1)
            expect(page).to have_content("Q33 - Lead tenant’s gender identity", count: 1)
            expect(page).to have_content("Q37 - Lead tenant’s working situation", count: 1)
            expect(page).to have_content("Household rent and charges", count: 1)
            expect(page).to have_link("Change", count: 7)
            expect(page).to have_link("Change", href: "/lettings-logs/#{lettings_log.id}/tenant-code?original_log_id=#{lettings_log.id}&referrer=interruption_screen")
          end

          it "displays buttons to return to log" do
            expect(page).to have_link("Back to Log #{lettings_log.id}", href: "/lettings-logs/#{lettings_log.id}")
          end

          it "displays no duplicates banner" do
            expect(page).to have_content("This log had the same answers but it is no longer a duplicate. Make sure the answers are correct.")
          end
        end
      end

      context "when viewing sales logs duplicates" do
        context "when there are multiple duplicate logs" do
          let(:duplicate_logs) { create_list(:sales_log, 2, :completed) }

          before do
            allow(SalesLog).to receive(:duplicate_logs).and_return(duplicate_logs)
            get "/sales-logs/#{sales_log.id}/duplicate-logs?original_log_id=#{sales_log.id}"
          end

          it "displays links to all the duplicate logs" do
            expect(page).to have_link("Log #{sales_log.id}", href: "/sales-logs/#{sales_log.id}")
            expect(page).to have_link("Log #{duplicate_logs.first.id}", href: "/sales-logs/#{duplicate_logs.first.id}")
            expect(page).to have_link("Log #{duplicate_logs.second.id}", href: "/sales-logs/#{duplicate_logs.second.id}")
          end

          it "displays check your answers for each log with correct questions" do
            expect(page).to have_content("Q1 - Sale completion date", count: 3)
            expect(page).to have_content("Q2 - Purchaser code", count: 3)
            expect(page).to have_content("Q20 - Lead buyer’s age", count: 3)
            expect(page).to have_content("Q21 - Buyer 1’s gender identity", count: 3)
            expect(page).to have_content("Q25 - Buyer 1's working situation", count: 3)
            expect(page).to have_content("Q15 - Postcode", count: 3)
            expect(page).to have_link("Change", count: 18)
            expect(page).to have_link("Change", href: "/sales-logs/#{sales_log.id}/purchaser-code?first_remaining_duplicate_id=#{duplicate_logs[0].id}&original_log_id=#{sales_log.id}&referrer=duplicate_logs")
            expect(page).to have_link("Change", href: "/sales-logs/#{duplicate_logs[0].id}/purchaser-code?first_remaining_duplicate_id=#{sales_log.id}&original_log_id=#{sales_log.id}&referrer=duplicate_logs")
            expect(page).to have_link("Change", href: "/sales-logs/#{duplicate_logs[1].id}/purchaser-code?first_remaining_duplicate_id=#{sales_log.id}&original_log_id=#{sales_log.id}&referrer=duplicate_logs")
          end

          it "displays buttons to delete" do
            expect(page).to have_link("Keep this log and delete duplicates", count: 3)
            expect(page).to have_link("Keep this log and delete duplicates", href: "/sales-logs/#{sales_log.id}/delete-duplicates?original_log_id=#{sales_log.id}")
            expect(page).to have_link("Keep this log and delete duplicates", href: "/sales-logs/#{duplicate_logs.first.id}/delete-duplicates?original_log_id=#{sales_log.id}")
            expect(page).to have_link("Keep this log and delete duplicates", href: "/sales-logs/#{duplicate_logs.second.id}/delete-duplicates?original_log_id=#{sales_log.id}")
          end
        end

        context "when there are no more duplicate logs" do
          before do
            allow(SalesLog).to receive(:duplicate_logs).and_return(SalesLog.none)
            get "/sales-logs/#{sales_log.id}/duplicate-logs?original_log_id=#{sales_log.id}"
          end

          it "displays check your answers for each log with correct questions" do
            expect(page).to have_content("Q1 - Sale completion date", count: 1)
            expect(page).to have_content("Q2 - Purchaser code", count: 1)
            expect(page).to have_content("Q20 - Lead buyer’s age", count: 1)
            expect(page).to have_content("Q21 - Buyer 1’s gender identity", count: 1)
            expect(page).to have_content("Q25 - Buyer 1's working situation", count: 1)
            expect(page).to have_content("Q15 - Postcode", count: 1)
            expect(page).to have_link("Change", count: 6)
            expect(page).to have_link("Change", href: "/sales-logs/#{sales_log.id}/purchaser-code?original_log_id=#{sales_log.id}&referrer=interruption_screen")
          end

          it "displays buttons to return to log" do
            expect(page).to have_link("Back to Log #{sales_log.id}", href: "/sales-logs/#{sales_log.id}")
          end

          it "displays no duplicates banner" do
            expect(page).to have_content("This log had the same answers but it is no longer a duplicate. Make sure the answers are correct.")
          end
        end
      end
    end
  end

  describe "GET sales delete-duplicates" do
    let(:headers) { { "Accept" => "text/html" } }
    let(:id) { sales_log.id }
    let(:request) { get "/sales-logs/#{id}/delete-duplicates?original_log_id=#{id}" }

    before do
      allow(user).to receive(:need_two_factor_authentication?).and_return(false)
      sign_in user
    end

    context "when there are no duplicate logs" do
      it "renders not found" do
        request
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when there is 1 duplicate log being deleted" do
      let!(:duplicate_log) { create(:sales_log, :duplicate, created_by: user) }

      it "renders page" do
        request
        expect(response).to have_http_status(:ok)

        expect(page).to have_content("Are you sure you want to delete this duplicate log?")
        expect(page).to have_button(text: "Delete this log")
        expect(page).to have_link(text: "Log #{duplicate_log.id}", href: sales_log_path(duplicate_log.id))
        expect(page).not_to have_link(text: "Log #{id}", href: sales_log_path(id))
        expect(page).to have_link(text: "Cancel", href: sales_log_duplicate_logs_path(id))
        expect(page).to have_link(text: "Back", href: sales_log_duplicate_logs_path(id))
      end
    end

    context "when there are multiple duplicate logs being deleted" do
      let!(:duplicate_log) { create(:sales_log, :duplicate, created_by: user) }
      let!(:duplicate_log_2) { create(:sales_log, :duplicate, created_by: user) }

      it "renders page" do
        request
        expect(response).to have_http_status(:ok)

        expect(page).to have_content("Are you sure you want to delete these duplicate logs?")
        expect(page).to have_content("These logs will be deleted:")
        expect(page).to have_button(text: "Delete these logs")
        expect(page).to have_link(text: "Log #{duplicate_log.id}", href: sales_log_path(duplicate_log.id))
        expect(page).to have_link(text: "Log #{duplicate_log_2.id}", href: sales_log_path(duplicate_log_2.id))
        expect(page).to have_link(text: "Cancel", href: sales_log_duplicate_logs_path(id))
        expect(page).to have_link(text: "Back", href: sales_log_duplicate_logs_path(id))
      end
    end

    context "when log does not exist" do
      let(:id) { -1 }

      it "returns 404" do
        request
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is not authorised" do
      let(:other_user) { create(:user) }

      before do
        allow(other_user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in other_user
      end

      it "returns 404" do
        request
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET lettings delete-duplicates" do
    let(:id) { lettings_log.id }
    let(:request) { get "/lettings-logs/#{id}/delete-duplicates?original_log_id=#{id}" }

    before do
      allow(user).to receive(:need_two_factor_authentication?).and_return(false)
      sign_in user
    end

    context "when there are no duplicate logs" do
      it "renders page not found" do
        request
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when there is 1 duplicate log being deleted" do
      let!(:duplicate_log) { create(:lettings_log, :duplicate, created_by: user) }

      it "renders page" do
        request
        expect(response).to have_http_status(:ok)

        expect(page).to have_content("Are you sure you want to delete this duplicate log?")
        expect(page).to have_content("This log will be deleted:")
        expect(page).to have_button(text: "Delete this log")
        expect(page).to have_link(text: "Log #{duplicate_log.id}", href: lettings_log_path(duplicate_log.id))
        expect(page).not_to have_link(text: "Log #{id}", href: lettings_log_path(id))
        expect(page).to have_link(text: "Cancel", href: lettings_log_duplicate_logs_path(id))
        expect(page).to have_link(text: "Back", href: lettings_log_duplicate_logs_path(id))
      end
    end

    context "when there are multiple duplicate logs being deleted" do
      let!(:duplicate_log) { create(:lettings_log, :duplicate, created_by: user) }
      let!(:duplicate_log_2) { create(:lettings_log, :duplicate, created_by: user) }

      it "renders page" do
        request
        expect(response).to have_http_status(:ok)

        expect(page).to have_content("Are you sure you want to delete these duplicate logs?")
        expect(page).to have_content("These logs will be deleted:")
        expect(page).to have_button(text: "Delete these logs")
        expect(page).to have_link(text: "Log #{duplicate_log.id}", href: lettings_log_path(duplicate_log.id))
        expect(page).to have_link(text: "Log #{duplicate_log_2.id}", href: lettings_log_path(duplicate_log_2.id))
        expect(page).to have_link(text: "Cancel", href: lettings_log_duplicate_logs_path(id))
        expect(page).to have_link(text: "Back", href: lettings_log_duplicate_logs_path(id))
      end
    end

    context "when log does not exist" do
      let(:id) { -1 }

      it "returns 404" do
        request
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is not authorised" do
      let(:other_user) { create(:user) }

      before do
        allow(other_user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in other_user
      end

      it "returns 404" do
        request
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET #index" do
    before do
      allow(user).to receive(:need_two_factor_authentication?).and_return(false)
      sign_in user
    end

    context "when the user is support" do
      let(:user) { create(:user, :support) }

      it "renders not found" do
        get duplicate_logs_path
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the user is a data coordinator" do
      let(:user) { create(:user, :data_coordinator) }

      it "renders not found" do
        get duplicate_logs_path
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the user is a provider" do
      let(:user) { create(:user) }
      let(:duplicates) do
        {
          lettings: {
            "0" => [1, 2],
            "1" => [3, 4, 5],
          },
          sales: {
            "0" => [11, 12],
          },
        }
      end

      # rubocop:disable RSpec/AnyInstance
      context "when duplicates are not provided in the params" do
        before do
          allow_any_instance_of(DuplicateLogsHelper).to receive(:duplicates_for_user).and_return duplicates
        end

        it "calls the helper method to retrieve duplicates for the current user" do
          expect_any_instance_of(DuplicateLogsHelper).to receive(:duplicates_for_user).with(user)
          get duplicate_logs_path
        end
      end

      context "when duplicates are provided in the params" do
        it "does not call the helper method" do
          expect_any_instance_of(DuplicateLogsHelper).not_to receive :duplicates_for_user
          get duplicate_logs_path(duplicates:)
        end

        context "and either lettings or sales is not present" do
          let(:duplicates) { { lettings: { "0" => [1, 2] } } }

          it "does not throw an error" do
            expect { get duplicate_logs_path(duplicates:) }.not_to raise_error
          end
        end
      end
      # rubocop:enable RSpec/AnyInstance

      describe "viewing the page" do
        before do
          get duplicate_logs_path(duplicates:)
        end

        it "has the correct headers" do
          headers = page.find_css("th").map(&:text)
          expect(headers).to include("Type of logs", "Log IDs")
        end

        it "has the correct number of rows for each log type" do
          expect(page).to have_selector "tbody tr td", text: "Lettings", count: duplicates[:lettings].count
          expect(page).to have_selector "tbody tr td", text: "Sales", count: duplicates[:sales].count
        end

        it "shows the log ids for each set of duplicates" do
          id_strings = duplicates.values.flat_map(&:values).map do |id_set|
            id_set.map { |id| "Log #{id}" }.join(", ")
          end
          id_strings.each do |id_string|
            expect(page).to have_selector "td", text: id_string
          end
        end

        it "shows links for each set of duplciates" do
          duplicates[:lettings].each_value do |id_set|
            expect(page).to have_link "Review logs", href: lettings_log_duplicate_logs_path(id_set.first)
          end
          duplicates[:sales].each_value do |id_set|
            expect(page).to have_link "Review logs", href: sales_log_duplicate_logs_path(id_set.first)
          end
        end
      end
    end
  end
end
