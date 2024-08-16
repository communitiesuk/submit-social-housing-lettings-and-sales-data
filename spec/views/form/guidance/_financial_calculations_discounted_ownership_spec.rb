require "rails_helper"

RSpec.describe "form/guidance/_financial_calculations_discounted_ownership.html.erb" do
  let(:log) { create(:sales_log) }

  let(:fragment) { Capybara::Node::Simple.new(rendered) }

  context "when mortgage used is not answered" do
    let(:log) { create(:sales_log, :completed, ownershipsch: 2, type: 9, mortgageused: nil, discount: 30) }

    it "renders correct content" do
      render partial: "form/guidance/financial_calculations_discounted_ownership", locals: { log:, current_user: log.assigned_to }
      expect(fragment).to have_content("The mortgage amount")
      expect(fragment).to have_content("and cash deposit")
      expect(fragment).to have_content("added together must equal")
      expect(fragment).to have_content("the purchase price")
      expect(fragment).to have_content("subtracted by the sum of the purchase price")
      expect(fragment).to have_content("multiplied by the discount")
    end
  end

  context "when mortgage used is no" do
    let(:log) { create(:sales_log, :completed, ownershipsch: 2, type: 9, mortgageused: 2, discount: nil) }

    it "renders correct content" do
      render partial: "form/guidance/financial_calculations_discounted_ownership", locals: { log:, current_user: log.assigned_to }
      expect(fragment).to have_content("Cash deposit")
      expect(fragment).to have_content("must equal")
      expect(fragment).to have_content("the purchase price")
      expect(fragment).to have_content("subtracted by the sum of the purchase price")
      expect(fragment).to have_content("multiplied by the discount")

      expect(fragment).not_to have_content("The mortgage amount")
      expect(fragment).not_to have_content("added together must equal")
    end
  end

  context "when mortgage used is yes" do
    let(:log) { create(:sales_log, :completed, ownershipsch: 2, type: 9, mortgageused: 1, mortgage: nil, discount: 30) }

    it "renders correct content" do
      render partial: "form/guidance/financial_calculations_discounted_ownership", locals: { log:, current_user: log.assigned_to }
      expect(fragment).to have_content("The mortgage amount")
      expect(fragment).to have_content("and cash deposit")
      expect(fragment).to have_content("added together must equal")
      expect(fragment).to have_content("the purchase price")
      expect(fragment).to have_content("subtracted by the sum of the purchase price")
      expect(fragment).to have_content("multiplied by the discount")
    end
  end

  context "when grant is routed to" do
    context "and morgage used" do
      let(:log) { create(:sales_log, :completed, ownershipsch: 2, type: 22, mortgageused: 1, mortgage: nil, discount: 30) }

      it "renders correct content" do
        render partial: "form/guidance/financial_calculations_discounted_ownership", locals: { log:, current_user: log.assigned_to }
        expect(fragment).to have_content("The mortgage amount")
        expect(fragment).to have_content("cash deposit")
        expect(fragment).to have_content("and grant")
        expect(fragment).to have_content("added together must equal")
        expect(fragment).to have_content("the purchase price")

        expect(fragment).not_to have_content("subtracted by the sum of the purchase price")
        expect(fragment).not_to have_content("multiplied by the discount")
      end
    end

    context "and morgage not used" do
      let(:log) { create(:sales_log, :completed, ownershipsch: 2, type: 22, mortgageused: 2, grant: nil) }

      it "renders correct content" do
        render partial: "form/guidance/financial_calculations_discounted_ownership", locals: { log:, current_user: log.assigned_to }
        expect(fragment).to have_content("Cash deposit")
        expect(fragment).to have_content("and grant")
        expect(fragment).to have_content("added together must equal")
        expect(fragment).to have_content("the purchase price")

        expect(fragment).not_to have_content("The mortgage amount")
        expect(fragment).not_to have_content("subtracted by the sum of the purchase price")
        expect(fragment).not_to have_content("multiplied by the discount")
      end
    end
  end
end
