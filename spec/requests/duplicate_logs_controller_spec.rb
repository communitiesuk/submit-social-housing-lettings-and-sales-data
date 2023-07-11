require "rails_helper"

RSpec.describe DuplicateLogsController, type: :request do
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:user) { create(:user, :data_coordinator) }
  let(:lettings_log) do
    create(
      :lettings_log,
      :completed,
      created_by: user,
      owning_organisation: user.organisation,
    )
  end
  let(:sales_log) do
    create(
      :sales_log,
      :completed,
      created_by: user,
      owning_organisation: user.organisation,
    )
  end

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
          expect(page).to have_content("Q5 - Tenancy start date", count: 3)
          expect(page).to have_content("Q7 - Tenant code", count: 3)
          expect(page).to have_content("Q12 - Postcode", count: 3)
          expect(page).to have_content("Q32 - Lead tenant’s age", count: 3)
          expect(page).to have_content("Q33 - Lead tenant’s gender identity", count: 3)
          expect(page).to have_content("Q37 - Lead tenant’s working situation", count: 3)
          expect(page).to have_content("Household rent and charges", count: 3)
          expect(page).to have_link("Change", count: 21)
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
          expect(page).to have_content("Q1 - Sale completion date", count: 3)
          expect(page).to have_content("Q2 - Purchaser code", count: 3)
          expect(page).to have_content("Q20 - Lead buyer’s age", count: 3)
          expect(page).to have_content("Q21 - Buyer 1’s gender identity", count: 3)
          expect(page).to have_content("Q25 - Buyer 1's working situation", count: 3)
          expect(page).to have_content("Q15 - Postcode", count: 3)
          expect(page).to have_link("Change", count: 18)
        end

        it "displays buttons to delete" do
          expect(page).to have_link("Keep this log and delete duplicates", count: 3)
        end
      end
    end
  end

  describe "GET sales delete-duplicates" do
    let(:headers) { { "Accept" => "text/html" } }
    let(:id) { sales_log.id }
    let(:request) { get "/sales-logs/#{id}/delete-duplicates" }

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
      let!(:duplicate_log) do
        duplicate = sales_log.dup
        duplicate.id = nil
        duplicate.save!
        duplicate
      end

      it "renders page" do
        request
        expect(response).to have_http_status(:ok)

        expect(page).to have_content("Are you sure you want to delete this duplicate log?")
        expect(page).to have_button(text: "Delete this log")
        expect(page).to have_link(text: "Log #{duplicate_log.id}", href: sales_log_path(duplicate_log.id))
        expect(page).not_to have_link(text: "Log #{id}", href: sales_log_path(id))
        expect(page).to have_link(text: "Cancel", href: sales_log_path(id)) # update with correct path when known
      end
    end

    context "when there are multiple duplicate logs being deleted" do
      let!(:duplicate_log) do
        duplicate = sales_log.dup
        duplicate.id = nil
        duplicate.save!
        duplicate
      end
      let!(:duplicate_log_2) do
        duplicate = sales_log.dup
        duplicate.id = nil
        duplicate.save!
        duplicate
      end

      it "renders page" do
        request
        expect(response).to have_http_status(:ok)

        expect(page).to have_content("Are you sure you want to delete these duplicate logs?")
        expect(page).to have_content("These logs will be deleted:")
        expect(page).to have_button(text: "Delete these logs")
        expect(page).to have_link(text: "Log #{duplicate_log.id}", href: sales_log_path(duplicate_log.id))
        expect(page).to have_link(text: "Log #{duplicate_log_2.id}", href: sales_log_path(duplicate_log_2.id))
        expect(page).to have_link(text: "Cancel", href: sales_log_path(id)) # update with correct path when known
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
    let(:request) { get "/lettings-logs/#{id}/delete-duplicates" }

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
      let!(:duplicate_log) do
        duplicate = lettings_log.dup
        duplicate.id = nil
        duplicate.save!
        duplicate
      end

      it "renders page" do
        request
        expect(response).to have_http_status(:ok)

        expect(page).to have_content("Are you sure you want to delete this duplicate log?")
        expect(page).to have_content("This log will be deleted:")
        expect(page).to have_button(text: "Delete this log")
        expect(page).to have_link(text: "Log #{duplicate_log.id}", href: lettings_log_path(duplicate_log.id))
        expect(page).not_to have_link(text: "Log #{id}", href: lettings_log_path(id))
        expect(page).to have_link(text: "Cancel", href: lettings_log_path(id)) # update with correct path when known
      end
    end

    context "when there are multiple duplicate logs being deleted" do
      let!(:duplicate_log) do
        duplicate = lettings_log.dup
        duplicate.id = nil
        duplicate.save!
        duplicate
      end
      let!(:duplicate_log_2) do
        duplicate = lettings_log.dup
        duplicate.id = nil
        duplicate.save!
        duplicate
      end

      it "renders page" do
        request
        expect(response).to have_http_status(:ok)

        expect(page).to have_content("Are you sure you want to delete these duplicate logs?")
        expect(page).to have_content("These logs will be deleted:")
        expect(page).to have_button(text: "Delete these logs")
        expect(page).to have_link(text: "Log #{duplicate_log.id}", href: lettings_log_path(duplicate_log.id))
        expect(page).to have_link(text: "Log #{duplicate_log_2.id}", href: lettings_log_path(duplicate_log_2.id))
        expect(page).to have_link(text: "Cancel", href: lettings_log_path(id)) # update with correct path when known
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
end
