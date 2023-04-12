require "rails_helper"

RSpec.describe BulkUploadErrorRowComponent, type: :component do
  context "when a single error" do
    let(:row) { rand(9_999) }
    let(:tenant_code) { SecureRandom.hex(4) }
    let(:property_ref) { SecureRandom.hex(4) }
    let(:purchaser_code) { nil }
    let(:field) { :field_134 }
    let(:error) { "some error" }
    let(:bulk_upload) { create(:bulk_upload, :lettings) }
    let(:bulk_upload_errors) do
      [
        FactoryBot.build(
          :bulk_upload_error,
          bulk_upload:,
          row:,
          tenant_code:,
          property_ref:,
          purchaser_code:,
          field:,
          error:,
        ),
      ]
    end

    it "renders the row number" do
      result = render_inline(described_class.new(bulk_upload_errors:))
      expect(result).to have_content("Row #{row}")
    end

    it "renders the tenant_code" do
      result = render_inline(described_class.new(bulk_upload_errors:))
      expect(result).to have_content("Tenant code: #{tenant_code}")
    end

    it "renders the property_ref" do
      result = render_inline(described_class.new(bulk_upload_errors:))
      expect(result).to have_content("Property reference: #{property_ref}")
    end

    it "renders the cell of error" do
      expected = bulk_upload_errors.first.cell
      result = render_inline(described_class.new(bulk_upload_errors:))
      expect(result).to have_content(expected)
    end

    it "renders the question for lettings" do
      expected = "Is this letting a renewal?"
      result = render_inline(described_class.new(bulk_upload_errors:))
      expect(result).to have_content(expected)
    end

    context "when tenant_code not present" do
      let(:tenant_code) { nil }

      it "does not render tenant code label" do
        result = render_inline(described_class.new(bulk_upload_errors:))
        expect(result).not_to have_content("Tenant code")
      end
    end

    context "when property_ref not present" do
      let(:property_ref) { nil }

      it "does not render the property_ref label" do
        result = render_inline(described_class.new(bulk_upload_errors:))
        expect(result).not_to have_content("Property reference")
      end
    end

    context "when purchaser_code not present" do
      let(:bulk_upload) { create(:bulk_upload, :sales) }

      it "does not render the purchaser_code label" do
        result = render_inline(described_class.new(bulk_upload_errors:))
        expect(result).not_to have_content("Purchaser code")
      end
    end

    context "when multiple errors for a row" do
      subject(:component) { described_class.new(bulk_upload_errors:) }

      let(:bulk_upload_errors) do
        [
          build(:bulk_upload_error, cell: "Z1"),
          build(:bulk_upload_error, cell: "AB1"),
          build(:bulk_upload_error, cell: "A1"),
        ]
      end

      it "is sorted by cell" do
        expect(component.bulk_upload_errors.map(&:cell)).to eql(%w[A1 Z1 AB1])
      end
    end

    context "when a sales bulk upload" do
      let(:bulk_upload) { create(:bulk_upload, :sales) }
      let(:field) { :field_87 }

      it "renders the question for sales" do
        expected = "What is the full purchase price?"
        result = render_inline(described_class.new(bulk_upload_errors:))
        expect(result).to have_content(expected)
      end
    end

    it "renders the error" do
      expected = error
      result = render_inline(described_class.new(bulk_upload_errors:))
      expect(result).to have_content(expected)
    end

    it "renders the field number" do
      expected = bulk_upload_errors.first.field.humanize
      result = render_inline(described_class.new(bulk_upload_errors:))
      expect(result).to have_content(expected)
    end
  end
end
