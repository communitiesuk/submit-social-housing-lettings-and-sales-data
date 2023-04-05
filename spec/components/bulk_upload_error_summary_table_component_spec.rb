require "rails_helper"

RSpec.describe BulkUploadErrorSummaryTableComponent, type: :component do
  subject(:component) { described_class.new(bulk_upload:) }

  let(:bulk_upload) { create(:bulk_upload, :lettings) }

  before do
    stub_const("BulkUploadErrorSummaryTableComponent::DISPLAY_THRESHOLD", 0)
  end

  describe "#sorted_errors" do
    context "when no errors" do
      it "does not renders any tables" do
        result = render_inline(component)
        expect(result).not_to have_selector("table")
      end
    end

    context "when below threshold" do
      before do
        stub_const("BulkUploadErrorSummaryTableComponent::DISPLAY_THRESHOLD", 16)

        create(:bulk_upload_error, bulk_upload:, col: "A", row: 1)
      end

      it "does not render tables" do
        result = render_inline(component)
        expect(result).to have_selector("table", count: 0)
      end
    end

    context "when on threshold" do
      before do
        stub_const("BulkUploadErrorSummaryTableComponent::DISPLAY_THRESHOLD", 1)

        create(:bulk_upload_error, bulk_upload:, col: "A", row: 1)
      end

      it "renders tables" do
        result = render_inline(component)
        expect(result).to have_selector("table", count: 1)
      end

      it "renders intro with threshold" do
        result = render_inline(component)

        expect(result).to have_content("This summary shows questions that have more than 0 errors. See full error report for more details.")
      end
    end

    context "when there are 2 independent errors" do
      let!(:error_2) { create(:bulk_upload_error, bulk_upload:, col: "B", row: 2) }
      let!(:error_1) { create(:bulk_upload_error, bulk_upload:, col: "A", row: 1) }

      it "renders table for each error" do
        result = render_inline(component)
        expect(result).to have_selector("table", count: 2)
      end

      it "renders by col order" do
        result = render_inline(component)
        order = result.css("table thead th:nth-of-type(2)").map(&:content)
        expect(order).to eql(["Column A", "Column B"])
      end

      it "render correct data" do
        result = render_inline(component)

        table_1 = result.css("table").first.css("th, td").map(&:content)

        expect(table_1).to eql([
          bulk_upload.prefix_namespace::RowParser.question_for_field(error_1.field.to_sym).to_s,
          "Column A",
          error_1.error,
          "1 error",
        ])

        table_2 = result.css("table")[1].css("th, td").map(&:content)

        expect(table_2).to eql([
          bulk_upload.prefix_namespace::RowParser.question_for_field(error_2.field.to_sym).to_s,
          "Column B",
          error_2.error,
          "1 error",
        ])
      end
    end

    context "when there are 2 grouped errors" do
      let!(:error_1) { create(:bulk_upload_error, bulk_upload:, col: "A", row: 1, field: "field_1") }

      before do
        create(:bulk_upload_error, bulk_upload:, col: "A", row: 2, field: "field_1")
      end

      it "renders 1 table combining the errors" do
        result = render_inline(component)
        expect(result).to have_selector("table", count: 1)
      end

      it "render correct data" do
        result = render_inline(component)

        table_1 = result.css("table").css("th, td").map(&:content)

        expect(table_1).to eql([
          bulk_upload.prefix_namespace::RowParser.question_for_field(error_1.field.to_sym).to_s,
          "Column A",
          error_1.error,
          "2 errors",
        ])
      end
    end

    context "when mix of setup and other errors" do
      let!(:error_1) { create(:bulk_upload_error, bulk_upload:, col: "A", row: 1, category: "setup") }

      before do
        create(:bulk_upload_error, bulk_upload:, col: "B", row: 2, category: nil)

        stub_const("BulkUploadErrorSummaryTableComponent::DISPLAY_THRESHOLD", 16)
      end

      it "only returns the setup errors" do
        result = render_inline(component)

        tables = result.css("table")

        expect(tables.size).to be(1)

        table = result.css("table").css("th, td").map(&:content)

        expect(table).to eql([
          bulk_upload.prefix_namespace::RowParser.question_for_field(error_1.field.to_sym).to_s,
          "Column A",
          error_1.error,
          "1 error",
        ])
      end

      it "renders intro with setup errors" do
        result = render_inline(component)

        expect(result).to have_content("This summary shows important questions that have errors. See full error report for more details.")
      end
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
