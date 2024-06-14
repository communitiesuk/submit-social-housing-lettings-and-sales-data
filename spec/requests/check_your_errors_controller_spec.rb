require "rails_helper"

RSpec.describe CheckYourErrorsController, type: :request do
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:user) { create(:user, :data_coordinator) }
  let(:lettings_log) { create(:lettings_log, :duplicate, assigned_to: user) }

  describe "check your errors page" do
    context "when user is not signed in" do
      it "redirects to sign in page" do
        get "/lettings-logs/#{lettings_log.id}/check-your-errors"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when the user is from different organisation" do
      let(:other_user) { create(:user) }

      before do
        sign_in other_user
      end

      it "renders page not found" do
        get "/lettings-logs/#{lettings_log.id}/check-your-errors"
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is signed in" do
      context "with multiple error fields and answered questions" do
        before do
          sign_in user
          get "/lettings-logs/#{lettings_log.id}/check-your-errors?related_question_ids[]=startdate&related_question_ids[]=needstype&original_question_id=startdate"
        end

        it "displays correct clear links" do
          expect(page).to have_link("Clear", href: "/lettings-logs/#{lettings_log.id}/confirm-clear-answer?original_question_id=startdate&question_id=startdate&related_question_ids%5B%5D=startdate&related_question_ids%5B%5D=needstype")
          expect(page).to have_link("Clear", href: "/lettings-logs/#{lettings_log.id}/confirm-clear-answer?original_question_id=startdate&question_id=needstype&related_question_ids%5B%5D=startdate&related_question_ids%5B%5D=needstype")
          expect(page).to have_link("Clear all", href: "/lettings-logs/#{lettings_log.id}/confirm-clear-all-answers?original_question_id=startdate&related_question_ids%5B%5D=startdate&related_question_ids%5B%5D=needstype")
        end
      end

      context "with multiple error fields and unanswered questions" do
        before do
          lettings_log.update!(needstype: nil, startdate: nil)
          sign_in user
          get "/lettings-logs/#{lettings_log.id}/check-your-errors?related_question_ids[]=startdate&related_question_ids[]=needstype&original_question_id=startdate"
        end

        it "displays correct clear links" do
          expect(page).to have_link("Answer", href: "/lettings-logs/#{lettings_log.id}/needs-type?original_question_id=startdate&referrer=check_your_errors&related_question_ids%5B%5D=startdate&related_question_ids%5B%5D=needstype")
          expect(page).to have_link("Answer", href: "/lettings-logs/#{lettings_log.id}/tenancy-start-date?original_question_id=startdate&referrer=check_your_errors&related_question_ids%5B%5D=startdate&related_question_ids%5B%5D=needstype")
        end
      end
    end
  end

  describe "confirm clear answer page" do
  end

  describe "confirm clear all answers page" do
  end

  describe "clear answer" do
  end

  describe "clear all answers" do
  end
end
