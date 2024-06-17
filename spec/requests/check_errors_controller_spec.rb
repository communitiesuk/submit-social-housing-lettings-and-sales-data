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
          expect(page).to have_link("Clear", href: "/lettings-logs/#{lettings_log.id}/confirm-clear-answer?question_id=hhmemb")
          expect(page).to have_link("Clear", href: "/lettings-logs/#{lettings_log.id}/confirm-clear-answer?question_id=ecstat1")
          expect(page).to have_link("Clear", href: "/lettings-logs/#{lettings_log.id}/confirm-clear-answer?question_id=earnings")
          expect(page).to have_link("Clear all", href: "/lettings-logs/#{lettings_log.id}/confirm-clear-all-answers")
        end
      end
    end
  end

  describe "confirm clear answer page" do
    context "when user is not signed in" do
      it "redirects to sign in page" do
        get "/lettings-logs/#{lettings_log.id}/confirm-clear-answer?original_page_id=income_amount&question_id=hhmemb&related_question_ids%5B%5D=hhmemb&related_question_ids%5B%5D=ecstat1&related_question_ids%5B%5D=earnings", params: {}
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when the user is from different organisation" do
      let(:other_user) { create(:user) }

      before do
        sign_in other_user
      end

      it "renders page not found" do
        get "/lettings-logs/#{lettings_log.id}/confirm-clear-answer?original_page_id=income_amount&question_id=hhmemb&related_question_ids%5B%5D=hhmemb&related_question_ids%5B%5D=ecstat1&related_question_ids%5B%5D=earnings", params: {}
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is signed in" do
      context "with multiple error fields and answered questions" do
        before do
          sign_in user
          get "/lettings-logs/#{lettings_log.id}/confirm-clear-answer?original_page_id=income_amount&question_id=hhmemb&related_question_ids%5B%5D=hhmemb&related_question_ids%5B%5D=ecstat1&related_question_ids%5B%5D=earnings", params: {}
        end

        it "displays correct clear links" do
          expect(page).to have_content("Are you sure you want to clear Number of household members answer?")
          expect(page).to have_content("This action is permanent")
          expect(page).to have_button("Cancel", href: "/lettings-logs/#{lettings_log.id}/income-amount")
          expect(page).to have_button("Confirm and continue", href: "/lettings-logs/#{lettings_log.id}/clear-answer?original_page_id=income_amount&question_id=hhmemb&related_question_ids%5B%5D=hhmemb&related_question_ids%5B%5D=ecstat1&related_question_ids%5B%5D=earnings")
        end
      end
    end
  end

  describe "confirm clear all answers page" do
  end

  describe "clear answer" do
  end

  describe "clear all answers" do
  end
end
