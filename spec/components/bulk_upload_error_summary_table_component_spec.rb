require "rails_helper"

RSpec.describe BulkUploadErrorSummaryTableComponent, type: :component do
  subject(:component) { described_class.new(bulk_upload:) }

  let(:bulk_upload) { create(:bulk_upload, :lettings) }

  before do
    stub_const("BulkUploadErrorSummaryTableComponent::DISPLAY_THRESHOLD", 0)
  end

  context "when no errors" do
    it "does not renders any rows" do
      result = render_inline(component)
      expect(result).not_to have_selector("tbody tr")
    end
  end

  context "when below threshold" do
    before do
      stub_const("BulkUploadErrorSummaryTableComponent::DISPLAY_THRESHOLD", 16)

      create(:bulk_upload_error, bulk_upload:, col: "A", row: 1)
    end

    it "does not render rows" do
      result = render_inline(component)
      expect(result).to have_selector("tbody tr", count: 0)
    end
  end

  context "when there are 2 independent errors" do
    let!(:error_2) { create(:bulk_upload_error, bulk_upload:, col: "B", row: 2) }
    let!(:error_1) { create(:bulk_upload_error, bulk_upload:, col: "A", row: 1) }

    it "renders rows for each error" do
      result = render_inline(component)
      expect(result).to have_selector("tbody tr", count: 2)
    end

    it "renders rows by col order" do
      result = render_inline(component)
      order = result.css("tbody tr td:nth-of-type(1)").map(&:content)
      expect(order).to eql(%w[A B])
    end

    it "render correct data" do
      result = render_inline(component)

      row_1 = result.css("tbody tr:nth-of-type(1) td").map(&:content)

      expect(row_1).to eql([
        "A",
        "1",
        BulkUpload::Lettings::RowParser.question_for_field(error_1.field.to_sym),
        error_1.error,
        error_1.field,
      ])

      row_2 = result.css("tbody tr:nth-of-type(2) td").map(&:content)

      expect(row_2).to eql([
        "B",
        "1",
        BulkUpload::Lettings::RowParser.question_for_field(error_2.field.to_sym),
        error_2.error,
        error_2.field,
      ])
    end
  end

  context "when there are 2 grouped errors" do
    let!(:error_1) { create(:bulk_upload_error, bulk_upload:, col: "A", row: 1, field: "field_1") }

    before do
      create(:bulk_upload_error, bulk_upload:, col: "A", row: 2, field: "field_1")
    end

    it "renders 1 row combining the errors" do
      result = render_inline(component)
      expect(result).to have_selector("tbody tr", count: 1)
    end

    it "render correct data" do
      result = render_inline(component)

      row_1 = result.css("tbody tr:nth-of-type(1) td").map(&:content)

      expect(row_1).to eql([
        "A",
        "2",
        BulkUpload::Lettings::RowParser.question_for_field(error_1.field.to_sym),
        error_1.error,
        error_1.field,
      ])
    end
  end

  describe "#errors?" do
    context "when there are no errors" do
      it "returns false" do
        expect(component).not_to be_errors
      end
    end

    context "when there are errors" do
      before do
        create(:bulk_upload_error, bulk_upload:, col: "A", row: 2, field: "field_1")
      end

      it "returns true" do
        expect(component).to be_errors
      end
    end
  end
end
