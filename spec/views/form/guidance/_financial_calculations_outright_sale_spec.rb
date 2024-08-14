require "rails_helper"

RSpec.describe "form/guidance/_financial_calculations_outright_sale.html.erb" do
  let(:log) { create(:sales_log) }

  let(:fragment) { Capybara::Node::Simple.new(rendered) }

  context "when mortgage used is not answered" do
    let(:log) { create(:sales_log, :outright_sale_setup_complete, ownershipsch: 3, type: 10, mortgageused: nil, discount: 30) }

    it "renders correct content" do
      render partial: "form/guidance/financial_calculations_outright_sale", locals: { log:, current_user: log.assigned_to }
      expect(fragment).to have_content("The mortgage amount")
      expect(fragment).to have_content("and cash deposit")
      expect(fragment).to have_content("added together must equal")
      expect(fragment).to have_content("the purchase price")
    end
  end

  context "when mortgage used is no" do
    let(:log) { create(:sales_log, :outright_sale_setup_complete, ownershipsch: 3, type: 10, mortgageused: 2, discount: nil) }

    it "renders correct content" do
      render partial: "form/guidance/financial_calculations_outright_sale", locals: { log:, current_user: log.assigned_to }
      expect(fragment).to have_content("Cash deposit")
      expect(fragment).to have_content("must equal")
      expect(fragment).to have_content("the purchase price")

      expect(fragment).not_to have_content("The mortgage amount")
      expect(fragment).not_to have_content("added together must equal")
    end
  end

  context "when mortgage used is yes" do
    let(:log) { create(:sales_log, :outright_sale_setup_complete, ownershipsch: 3, type: 10, mortgageused: 1, mortgage: nil, discount: 30) }

    it "renders correct content" do
      render partial: "form/guidance/financial_calculations_outright_sale", locals: { log:, current_user: log.assigned_to }
      expect(fragment).to have_content("The mortgage amount")
      expect(fragment).to have_content("and cash deposit")
      expect(fragment).to have_content("added together must equal")
      expect(fragment).to have_content("the purchase price")
    end
  end
end
