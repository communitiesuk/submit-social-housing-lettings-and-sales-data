require "rails_helper"

RSpec.describe BulkUpload::Lettings::RowParser do
  subject(:parser) { described_class.new(attributes) }

  describe "validations" do
    before do
      parser.valid?
    end

    describe "field_1" do
      context "when null" do
        let(:attributes) { { field_1: nil } }

        it "returns an error" do
          expect(parser.errors).to include(:field_1)
        end
      end

      context "when outside permited range" do
        let(:attributes) { { field_1: "13" } }

        it "returns an error" do
          expect(parser.errors).to include(:field_1)
        end
      end

      context "when valid" do
        let(:attributes) { { field_1: 1 } }

        it "is valid" do
          expect(parser.errors).not_to include(:field_1)
        end
      end
    end

    describe "field_4" do
      context "when text" do
        let(:attributes) { { field_4: "R" } }

        it "is not valid" do
          expect(parser.errors).to include(:field_4)
        end
      end

      context "when valid" do
        let(:attributes) { { field_4: "3" } }

        it "is valid" do
          expect(parser.errors).not_to include(:field_4)
        end
      end

      context "when allowed to be null" do
        let(:attributes) { { field_1: "2", field_4: "" } }

        it "is valid" do
          expect(parser.errors).not_to include(:field_4)
        end
      end

      context "when not allowed to be null" do
        let(:attributes) { { field_1: "3", field_4: "" } }

        it "is not valid" do
          expect(parser.errors).to include(:field_4)
        end
      end
    end

    describe "#field_134" do
      context "when not a possible value" do
        let(:attributes) { { field_134: "3" } }

        it "is not valid" do
          expect(parser.errors).to include(:field_134)
        end
      end
    end
  end
end
