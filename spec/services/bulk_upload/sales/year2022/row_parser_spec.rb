require "rails_helper"

RSpec.describe BulkUpload::Sales::Year2022::RowParser do
  subject(:parser) { described_class.new(attributes) }

  describe "validations" do
    before do
      parser.valid?
    end

    describe "#field_117" do
      context "when not a possible value" do
        let(:attributes) { { field_117: "3" } }

        it "is not valid" do
          expect(parser.errors).to include(:field_117)
        end
      end
    end
  end
end
