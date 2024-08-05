require "rails_helper"

RSpec.describe "bulk_upload_sales_results/show.html.erb" do
  let(:bulk_upload) { create(:bulk_upload, :sales) }

  context "when mutiple rows in wrong order" do
    before do
      create(:bulk_upload_error, bulk_upload:, cell: "C14", row: "14", col: "C")
      create(:bulk_upload_error, bulk_upload:, cell: "D10", row: "10", col: "D")
    end

    it "renders errors order by row" do
      assign(:bulk_upload, bulk_upload)

      render

      fragment = Capybara::Node::Simple.new(rendered)

      expect(fragment.find_css(".govuk-summary-card__title strong").map(&:inner_text)).to eql(["Row 10", "Row 14"])
    end
  end

  context "when 1 row with 2 errors" do
    before do
      create(:bulk_upload_error, bulk_upload:, cell: "AA100", row: "100", col: "AA")
      create(:bulk_upload_error, bulk_upload:, cell: "Z100", row: "100", col: "Z")
    end

    it "renders errors ordered by cell" do
      assign(:bulk_upload, bulk_upload)

      render

      fragment = Capybara::Node::Simple.new(rendered)
      expect(fragment.find_css("table tbody td").map(&:inner_text).values_at(0, 3)).to eql(%w[Z100 AA100])
    end
  end
end
