require "rails_helper"

RSpec.describe BulkUploadErrorRowComponent, type: :component do
  context "when a single error" do
    let(:row) { rand(9_999) }
    let(:tenant_code) { SecureRandom.hex(4) }
    let(:property_ref) { SecureRandom.hex(4) }
    let(:purchaser_code) { nil }
    let(:field) { :field_130 }
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

    context "when the bulk upload is for 2024" do
      context "with  a lettings bulk upload" do
        let(:bulk_upload) { build(:bulk_upload, :lettings, year: 2024) }
        let(:field) { :field_130 }

        it "renders the expected question" do
          expected = "What do you expect the outstanding amount to be?"
          result = render_inline(described_class.new(bulk_upload_errors:))
          expect(result).to have_content(expected)
        end
      end

      context "with a sales bulk upload" do
        let(:bulk_upload) { create(:bulk_upload, :sales, year: 2024) }
        let(:field) { :field_86 }

        it "renders the expected question" do
          expected = "Is this a staircasing transaction?"
          result = render_inline(described_class.new(bulk_upload_errors:))
          expect(result).to have_content(expected)
        end
      end
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

  context "when there are potential errors" do
    let(:row) { rand(9_999) }
    let(:tenant_code) { SecureRandom.hex(4) }
    let(:property_ref) { SecureRandom.hex(4) }
    let(:purchaser_code) { nil }
    let(:category) { "soft_validation" }
    let(:field_46) { 40 }
    let(:field_50) { 5 }
    let(:error) { "You told us this person is aged 40 years and retired." }
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
          field: :field_46,
          error:,
          category:,
        ),
        FactoryBot.build(
          :bulk_upload_error,
          bulk_upload:,
          row:,
          tenant_code:,
          property_ref:,
          purchaser_code:,
          field: :field_50,
          error:,
          category:,
        ),
      ]
    end

    it "renders the potential errors section" do
      result = render_inline(described_class.new(bulk_upload_errors:))
      expect(result).to have_content("Potential errors")
    end

    it "renders the potential error message" do
      expected = error
      result = render_inline(described_class.new(bulk_upload_errors:))
      expect(result).to have_content(expected, count: 1)
    end
  end
end
