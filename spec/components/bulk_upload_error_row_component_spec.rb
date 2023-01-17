require "rails_helper"

RSpec.describe BulkUploadErrorRowComponent, type: :component do
  context "when a single error" do
    let(:row) { rand(9_999) }
    let(:tenant_code) { SecureRandom.hex(4) }
    let(:property_ref) { SecureRandom.hex(4) }
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
