require "rails_helper"

RSpec.describe CheckErrorsController, type: :request do
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:user) { create(:user, :data_coordinator) }
  let(:lettings_log) { create(:lettings_log, :duplicate, assigned_to: user) }

  describe "check errors page" do
    context "when user is not signed in" do
      it "redirects to sign in page" do
        post "/lettings-logs/#{lettings_log.id}/net-income", params: {}
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when the user is from different organisation" do
      let(:other_user) { create(:user) }

      before do
        sign_in other_user
      end

      it "renders page not found" do
        post "/lettings-logs/#{lettings_log.id}/net-income", params: {}
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is signed in" do
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
        lettings_log.update(needstype: 1, declaration: 1, ecstat1: 10, hhmemb: 2, net_income_known: 0, incfreq: 1, earnings: 1000)
      end

      context "with multiple error fields and answered questions" do
        before do
          sign_in user
          post "/lettings-logs/#{lettings_log.id}/income-amount", params: params
        end

        it "displays correct clear links" do
          expect(page).to have_button("Clear", count: 3)
          expect(page).to have_link("Clear all", href: "/lettings-logs/#{lettings_log.id}/confirm-clear-all-answers")
        end
      end
    end
  end

  describe "confirm clear answer page" do
    context "when user is not signed in" do
      it "redirects to sign in page" do
        post "/lettings-logs/#{lettings_log.id}/confirm-clear-answer", params: {}
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when the user is from different organisation" do
      let(:other_user) { create(:user) }

      before do
        sign_in other_user
      end

      it "renders page not found" do
        post "/lettings-logs/#{lettings_log.id}/confirm-clear-answer", params: {}
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is signed in" do
      context "and clearing specific question" do
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
    end
  end

  describe "confirm clear all answers page" do
  end

  describe "clear answer" do
    context "when user is not signed in" do
      it "redirects to sign in page" do
        post "/lettings-logs/#{lettings_log.id}/income-amount", params: {}
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when the user is from different organisation" do
      let(:other_user) { create(:user) }

      before do
        sign_in other_user
      end

      it "renders page not found" do
        post "/lettings-logs/#{lettings_log.id}/income-amount", params: {}
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is signed in" do
      context "and clearing specific question" do
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
        end
      end
    end
  end

  describe "clear all answers" do
  end
end
