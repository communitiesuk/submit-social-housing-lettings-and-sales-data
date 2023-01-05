require "rails_helper"

RSpec.describe BulkUpload::Lettings::RowParser do
  subject(:parser) { described_class.new(attributes) }

  let(:attributes) { {} }

  around do |example|
    FormHandler.instance.use_real_forms!

    example.run

    FormHandler.instance.use_fake_forms!
  end

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

    describe "#field_1" do
      context "when null" do
        let(:attributes) { { field_1: nil } }

        it "returns an error" do
          expect(parser.errors[:field_1]).to be_present
        end
      end

      context "when incorrect data type" do
        let(:attributes) { { field_1: "foo" } }

        it "returns an error" do
          expect(parser.errors[:field_1]).to be_present
        end
      end

      context "when unpermitted value" do
        let(:attributes) { { field_1: "101" } }

        it "returns an error" do
          expect(parser.errors[:field_1]).to be_present
        end
      end

      context "when valid" do
        let(:attributes) { { field_1: "1" } }

        it "does not return any errors" do
          expect(parser.errors[:field_1]).to be_blank
        end
      end
    end

    describe "#field_4" do
      context "when nullable permitted" do
        let(:attributes) { { field_1: "2", field_4: nil } }

        it "can be nulled" do
          expect(parser.errors[:field_4]).to be_blank
        end
      end

      context "when nullable not permitted" do
        let(:attributes) { { field_1: "1", field_4: nil } }

        it "cannot be nulled" do
          expect(parser.errors[:field_4]).to be_present
        end
      end

      context "when matching scheme cannot be found" do
        let(:attributes) { { field_1: "1", field_4: "123" } }

        xit "returns an error" do
          expect(parser.errors[:field_4]).to be_present
        end
      end
    end

    describe "#field_134" do
      context "when an unpermitted value" do
        let(:attributes) { { field_134: 3 } }

        it "has errors on the field" do
          expect(parser.errors[:field_134]).to be_present
        end
      end
    end
  end
end
