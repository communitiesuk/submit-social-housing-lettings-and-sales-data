require "rails_helper"
require_relative "helpers"

RSpec.describe "Sales Log Check Answers Page" do
  include Helpers
  let(:user) { FactoryBot.create(:user) }
  let(:subsection) { "household-characteristics" }
  let(:conditional_subsection) { "conditional-question" }

  let(:completed_sales_log_joint_purchase) do
    FactoryBot.create(
      :sales_log,
      :completed,
      created_by: user,
      jointpur: 1,
    )
  end

  let(:completed_sales_log_non_joint_purchase) do
    FactoryBot.create(
      :sales_log,
      :completed,
      created_by: user,
      jointpur: 2,
    )
  end

  before do
    sign_in user
  end

  context "when the user needs to check their answers for a subsection" do
    let(:last_question_for_subsection) { "propcode" }

    it "does not group questions into summary cards if the questions in the subsection don't have a check_answers_card_number attribute" do
      visit("/sales-logs/#{completed_sales_log_joint_purchase.id}/household-needs/check-answers")
      assert_selector ".x-govuk-summary-card__title", count: 0
    end

    context "when the user is checking their answers for the household characteristics subsection" do
      context "for a joint purchase" do
        it "they see a seperate summary card for each member of the household" do
          visit("/sales-logs/#{completed_sales_log_joint_purchase.id}/#{subsection}/check-answers")
          assert_selector ".x-govuk-summary-card__title", text: "Buyer 1", count: 1
          assert_selector ".x-govuk-summary-card__title", text: "Buyer 2", count: 1
          assert_selector ".x-govuk-summary-card__title", text: "Person 1", count: 1
          assert_selector ".x-govuk-summary-card__title", text: "Person 2", count: 0
        end
      end

      context "for a non-joint purchase" do
        it "they see a seperate summary card for each member of the household" do
          visit("/sales-logs/#{completed_sales_log_non_joint_purchase.id}/#{subsection}/check-answers")
          assert_selector ".x-govuk-summary-card__title", text: "Buyer 1", count: 1
          assert_selector ".x-govuk-summary-card__title", text: "Buyer 2", count: 0
          assert_selector ".x-govuk-summary-card__title", text: "Person 1", count: 1
          assert_selector ".x-govuk-summary-card__title", text: "Person 2", count: 0
        end
      end
    end
  end
end
