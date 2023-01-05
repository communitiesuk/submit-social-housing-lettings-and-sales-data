require "rails_helper"

RSpec.describe BulkUpload::Lettings::RowParser do
  subject(:parser) { described_class.new(attributes) }

  let(:attributes) { {} }

  describe "validations" do
    before do
      parser.valid?
    end

    describe "#valid?" do
      let(:attributes) { { field_134: 3 } }

      context "when calling the method multiple times" do
        it "does not add keep adding errors to the pile" do
          expect { parser.valid? }.not_to change(parser.errors, :count)
        end
      end
    end

    describe "field_134" do
      context "when an unpermitted value" do
        let(:attributes) { { field_134: 3 } }

        it "has errors on the field" do
          expect(parser.errors[:field_134]).to be_present
        end
      end
    end
  end
end
