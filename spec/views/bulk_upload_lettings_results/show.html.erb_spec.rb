require "rails_helper"

RSpec.describe "bulk_upload_lettings_results/show.html.erb" do
  let(:bulk_upload) { create(:bulk_upload, :lettings) }

  before do
    create(:bulk_upload_error, bulk_upload:, cell: "AA100", row: "100", col: "AA")
    create(:bulk_upload_error, bulk_upload:, cell: "Z100", row: "100", col: "Z")
  end

  it "renders errors ordered by cell" do
    assign(:bulk_upload, bulk_upload)

    render

    fragment = Capybara::Node::Simple.new(rendered)

    expect(fragment.find_css("table tbody th").map(&:inner_text)).to eql(%w[Z100 AA100])
  end
end
