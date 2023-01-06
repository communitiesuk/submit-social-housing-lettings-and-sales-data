require "rails_helper"

RSpec.describe BulkUpload::Lettings::RowParser do
  subject(:parser) { described_class.new(attributes) }

  let(:attributes) { { bulk_upload: } }
  let(:bulk_upload) { create(:bulk_upload, :lettings) }
  let(:owning_org) { create(:organisation) }
  let(:managing_org) { create(:organisation) }

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
      context "when calling the method multiple times" do
        let(:attributes) { { bulk_upload:, field_134: 3 } }

        it "does not add keep adding errors to the pile" do
          expect { parser.valid? }.not_to change(parser.errors, :count)
        end
      end

      context "when valid row" do
        let(:attributes) do
          {
            bulk_upload:,
            field_1: "1",
            field_4: "1",
            field_7: "123",
            field_96: "1",
            field_97: "1",
            field_98: "2023",
            field_108: "EC1N",
            field_109: "2TD",
            field_111: owning_org.old_visible_id,
            field_113: managing_org.old_visible_id,
            field_130: "1",
            field_134: "0",
          }
        end

        it "returns true" do
          expect(parser).to be_valid
        end

        it "instantiates a log with everything completed" do
          questions = parser.send(:questions).reject do |q|
            parser.send(:log).optional_fields.include?(q.id) || q.completed?(parser.send(:log))
          end

          expect(questions.map(&:id)).to eql([])
        end
      end
    end

    describe "#field_1" do
      context "when null" do
        let(:attributes) { { bulk_upload:, field_1: nil } }

        it "returns an error" do
          expect(parser.errors[:field_1]).to be_present
        end
      end

      context "when incorrect data type" do
        let(:attributes) { { bulk_upload:, field_1: "foo" } }

        it "returns an error" do
          expect(parser.errors[:field_1]).to be_present
        end
      end

      context "when unpermitted value" do
        let(:attributes) { { bulk_upload:, field_1: "101" } }

        it "returns an error" do
          expect(parser.errors[:field_1]).to be_present
        end
      end

      context "when valid" do
        let(:attributes) { { bulk_upload:, field_1: "1" } }

        it "does not return any errors" do
          expect(parser.errors[:field_1]).to be_blank
        end
      end
    end

    describe "#field_4" do
      context "when nullable permitted" do
        let(:attributes) { { bulk_upload:, field_1: "2", field_4: nil } }

        it "can be nulled" do
          expect(parser.errors[:field_4]).to be_blank
        end
      end

      context "when nullable not permitted" do
        let(:attributes) { { bulk_upload:, field_1: "1", field_4: nil } }

        it "cannot be nulled" do
          expect(parser.errors[:field_4]).to be_present
        end
      end

      context "when matching scheme cannot be found" do
        let(:attributes) { { bulk_upload:, field_1: "1", field_4: "123" } }

        xit "returns an error" do
          expect(parser.errors[:field_4]).to be_present
        end
      end
    end

    describe "#field_7" do
      context "when null" do
        let(:attributes) { { bulk_upload:, field_7: nil } }

        xit "returns an error" do
          expect(parser.errors[:field_7]).to be_present
        end
      end
    end

    describe "fields 96, 97, 98 => startdate" do
      context "when any one of these fields is blank" do
        let(:attributes) { { bulk_upload:, field_96: nil, field_97: nil, field_98: nil } }

        it "returns an error" do
          expect(parser.errors[:field_96]).to be_present
          expect(parser.errors[:field_97]).to be_present
          expect(parser.errors[:field_98]).to be_present
        end
      end
    end

    describe "#field_134" do
      context "when an unpermitted value" do
        let(:attributes) { { bulk_upload:, field_134: 3 } }

        it "has errors on the field" do
          expect(parser.errors[:field_134]).to be_present
        end
      end
    end
  end
end
