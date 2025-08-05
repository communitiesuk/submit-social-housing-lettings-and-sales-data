require "rails_helper"

RSpec.describe "form/guidance/_financial_calculations_outright_sale.html.erb" do
  include CollectionTimeHelper

  let(:log) { create(:sales_log) }
  let(:current_date) { current_collection_start_date }
  let(:fragment) { Capybara::Node::Simple.new(rendered) }

  context "when mortgage used is not answered" do
    let(:log) { create(:sales_log, :shared_ownership_setup_complete, mortgageused: nil, saledate: current_date) }

    it "renders correct content" do
      render partial: "form/guidance/financial_calculations_outright_sale", locals: { log:, current_user: log.assigned_to }
      expect(fragment).to have_content("The mortgage amount")
      expect(fragment).to have_content("and cash deposit")
      expect(fragment).to have_content("added together must equal")
      expect(fragment).to have_content("the purchase price")
    end
  end

  context "when mortgage used is no" do
    let(:log) { create(:sales_log, :shared_ownership_setup_complete, mortgageused: 2, saledate: current_date) }

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
    let(:log) { create(:sales_log, :shared_ownership_setup_complete, mortgageused: 1, saledate: current_date) }

    it "renders correct content" do
      render partial: "form/guidance/financial_calculations_outright_sale", locals: { log:, current_user: log.assigned_to }
      expect(fragment).to have_content("The mortgage amount")
      expect(fragment).to have_content("and cash deposit")
      expect(fragment).to have_content("added together must equal")
      expect(fragment).to have_content("the purchase price")
    end
  end
end
