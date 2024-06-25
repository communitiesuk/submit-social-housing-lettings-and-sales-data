require "rails_helper"

RSpec.describe CheckErrorsController, type: :request do
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:user) { create(:user, :data_coordinator) }
  let(:lettings_log) { create(:lettings_log, :setup_completed, assigned_to: user) }
  let(:sales_log) { create(:sales_log, :shared_ownership_setup_complete, assigned_to: user) }

  describe "check errors page" do
    context "when user is not signed in" do
      it "redirects to sign in page for lettings" do
        post "/lettings-logs/#{lettings_log.id}/net-income", params: {}
        expect(response).to redirect_to("/account/sign-in")
      end

      it "redirects to sign in page for sales" do
        post "/sales-logs/#{sales_log.id}/buyer-1-income", params: {}
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when the user is from different organisation" do
      let(:other_user) { create(:user) }

      before do
        sign_in other_user
      end

      it "renders page not found for lettings" do
        post "/lettings-logs/#{lettings_log.id}/net-income", params: {}
        expect(response).to have_http_status(:not_found)
      end

      it "renders page not found for sales" do
        post "/sales-logs/#{sales_log.id}/buyer-1-income", params: {}
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is signed in" do
      context "with multiple error fields and answered questions for lettings" do
        let(:params) do
          {
            id: lettings_log.id,
            lettings_log: {
              page: "income_amount",
              earnings: "100000",
              incfreq: "1",
            },
            check_errors: "",
          }
        end

        before do
          lettings_log.update!(needstype: 1, declaration: 1, ecstat1: 10, hhmemb: 2, net_income_known: 0, incfreq: 1, earnings: 1000)
          sign_in user
          post "/lettings-logs/#{lettings_log.id}/income-amount", params: params
        end

        it "displays correct clear links" do
          expect(page).to have_selector("input[type=submit][value='Clear']", count: 3)
          expect(page).to have_link("Clear all", href: "/lettings-logs/#{lettings_log.id}/confirm-clear-all-answers")
        end
      end

      context "with multiple error fields and answered questions for sales" do
        let(:params) do
          {
            id: sales_log.id,
            sales_log: {
              page: "buyer_1_income",
              income1: "100000",
              la: "E09000001",
              ownershipsch: "1",
            },
            check_errors: "",
          }
        end

        before do
          sales_log.update!(income1: 1000, la: "E09000001")
          sign_in user
          post "/sales-logs/#{sales_log.id}/buyer-1-income", params: params
        end

        it "displays correct clear links" do
          expect(page).to have_button("Clear", count: 3)
          expect(page).to have_link("Clear all", href: "/sales-logs/#{sales_log.id}/confirm-clear-all-answers")
        end
      end
    end
  end

  describe "confirm clear answer page" do
    context "when user is not signed in" do
      it "redirects to sign in page for lettings" do
        post "/lettings-logs/#{lettings_log.id}/confirm-clear-answer", params: {}
        expect(response).to redirect_to("/account/sign-in")
      end

      it "redirects to sign in page for sales" do
        post "/sales-logs/#{sales_log.id}/confirm-clear-answer", params: {}
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when the user is from different organisation" do
      let(:other_user) { create(:user) }

      before do
        sign_in other_user
      end

      it "renders page not found for lettings" do
        post "/lettings-logs/#{lettings_log.id}/confirm-clear-answer", params: {}
        expect(response).to have_http_status(:not_found)
      end

      it "renders page not found for sales" do
        post "/sales-logs/#{sales_log.id}/confirm-clear-answer", params: {}
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is signed in" do
      context "and clearing specific lettings question" do
        let(:params) do
          {
            id: lettings_log.id,
            lettings_log: {
              earnings: "100000",
              incfreq: "1",
              hhmemb: "2",
              page_id: "income_amount",
            },
            hhmemb: "",
          }
        end

        before do
          sign_in user
          post "/lettings-logs/#{lettings_log.id}/confirm-clear-answer", params:
        end

        it "displays correct clear links" do
          expect(page).to have_content("Are you sure you want to clear Number of household members?")
          expect(page).to have_content("This action is permanent")
          expect(page).to have_link("Cancel")
          expect(page).to have_button("Confirm and continue")
        end
      end

      context "and clearing specific sales question" do
        let(:params) do
          {
            id: sales_log.id,
            sales_log: {
              income1: "100000",
              la: "E09000001",
              ownershipsch: "1",
              page_id: "buyer_1_income",
            },
            income1: "",
          }
        end

        before do
          sign_in user
          post "/sales-logs/#{sales_log.id}/confirm-clear-answer", params:
        end

        it "displays correct clear links" do
          expect(page).to have_content("Are you sure you want to clear Buyer 1’s gross annual income?")
          expect(page).to have_content("This action is permanent")
          expect(page).to have_link("Cancel")
          expect(page).to have_button("Confirm and continue")
        end
      end
    end
  end

  describe "clear answer" do
    context "when user is not signed in" do
      it "redirects to sign in page for lettings" do
        post "/lettings-logs/#{lettings_log.id}/income-amount", params: {}
        expect(response).to redirect_to("/account/sign-in")
      end

      it "redirects to sign in page for sales" do
        post "/sales-logs/#{sales_log.id}/buyer-1-income", params: {}
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when the user is from different organisation" do
      let(:other_user) { create(:user) }

      before do
        sign_in other_user
      end

      it "renders page not found for lettings" do
        post "/lettings-logs/#{lettings_log.id}/income-amount", params: {}
        expect(response).to have_http_status(:not_found)
      end

      it "renders page not found for sales" do
        post "/sales-logs/#{lettings_log.id}/buyer-1-income", params: {}
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is signed in" do
      context "and clearing specific lettings question" do
        let(:params) do
          {
            id: lettings_log.id,
            lettings_log: {
              earnings: "100000",
              incfreq: "1",
              hhmemb: "2",
              clear_question_id: "hhmemb",
              page: "income_amount",
            },
            check_errors: "",
          }
        end

        before do
          sign_in user
          post "/lettings-logs/#{lettings_log.id}/income-amount", params:
        end

        it "displays correct clear links" do
          expect(page).to have_content("Make sure these answers are correct")
          expect(page).to have_content("You didn’t answer this question")
          expect(page).to have_link("Answer")
          expect(lettings_log.reload.earnings).to eq(nil)
        end
      end

      context "and clearing specific sales question" do
        let(:params) do
          {
            id: sales_log.id,
            sales_log: {
              income1: "100000",
              la: "E09000001",
              ownershipsch: "1",
              clear_question_id: "income1",
              page: "buyer_1_income",
            },
            check_errors: "",
          }
        end

        before do
          sign_in user
          post "/sales-logs/#{sales_log.id}/buyer-1-income", params:
        end

        it "displays correct clear links" do
          expect(page).to have_content("Make sure these answers are correct")
          expect(page).to have_content("You didn’t answer this question")
          expect(page).to have_link("Answer")
          expect(sales_log.reload.income1).to eq(nil)
        end
      end
    end
  end

  describe "answer incomplete question" do
    context "when user is signed in" do
      context "and answering specific lettings question" do
        let(:params) do
          {
            original_page_id: "income_amount",
            referrer: "check_errors",
            related_question_ids: %w[hhmemb ecstat1 earnings],
            lettings_log: {
              page: "household_members",
              hhmemb: "2",
            },
          }
        end

        before do
          sign_in user
          post "/lettings-logs/#{lettings_log.id}/household-members", params:
        end

        it "maintains original check_errors data in query params" do
          follow_redirect!
          expect(request.query_parameters["check_errors"]).to eq("true")
          expect(request.query_parameters["related_question_ids"]).to eq(%w[hhmemb ecstat1 earnings])
        end
      end

      context "and answering specific sales question" do
        let(:params) do
          {
            original_page_id: "buyer_1_income",
            referrer: "check_errors",
            related_question_ids: %w[income1 la ownershipsch],
            sales_log: {
              page: "buyer_1_income",
              income1: "1000",
              income1nk: "0",
            },
          }
        end

        before do
          sign_in user
          post "/sales-logs/#{sales_log.id}/buyer-1-income", params:
        end

        it "maintains original check_errors data in query params" do
          follow_redirect!
          expect(request.query_parameters["check_errors"]).to eq("true")
          expect(request.query_parameters["related_question_ids"]).to eq(%w[income1 la ownershipsch])
        end
      end
    end
  end
end
