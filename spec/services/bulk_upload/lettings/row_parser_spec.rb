require "rails_helper"

RSpec.describe BulkUpload::Lettings::RowParser do
  subject(:parser) { described_class.new(attributes) }

  let(:now) { Time.zone.today }

  let(:attributes) { { bulk_upload: } }
  let(:bulk_upload) { create(:bulk_upload, :lettings, user:) }
  let(:user) { create(:user, organisation: owning_org) }
  let(:owning_org) { create(:organisation, :with_old_visible_id) }
  let(:managing_org) { create(:organisation, :with_old_visible_id) }
  let(:setup_section_params) do
    {
      bulk_upload:,
      field_1: "2",
      field_111: owning_org.old_visible_id,
      field_113: managing_org.old_visible_id,
      field_96: now.day.to_s,
      field_97: now.month.to_s,
      field_98: now.strftime("%g"),
      field_134: "2",
    }
  end

  around do |example|
    FormHandler.instance.use_real_forms!

    example.run

    FormHandler.instance.use_fake_forms!
  end

  describe "validations" do
    before do
      stub_request(:get, /api.postcodes.io/)
      .to_return(status: 200, body: "{\"status\":200,\"result\":{\"admin_district\":\"Manchester\", \"codes\":{\"admin_district\": \"E08000003\"}}}", headers: {})

      parser.valid?
    end

    describe "#valid?" do
      context "when calling the method multiple times" do
        let(:attributes) { { bulk_upload:, field_134: 2 } }

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
            field_96: now.day.to_s,
            field_97: now.month.to_s,
            field_98: now.strftime("%g"),
            field_108: "EC1N",
            field_109: "2TD",
            field_111: owning_org.old_visible_id,
            field_113: managing_org.old_visible_id,
            field_130: "1",
            field_134: "2",
            field_102: "2",
            field_103: "1",
            field_104: "1",
            field_101: "1",
            field_133: "2",
            field_8: "1",
            field_9: "2",
            field_132: "1",

            field_12: "42",
            field_13: "41",
            field_14: "20",
            field_15: "18",
            field_16: "16",
            field_17: "14",
            field_18: "12",
            field_19: "20",

            field_20: "F",
            field_21: "M",
            field_22: "F",
            field_23: "M",
            field_24: "F",
            field_25: "M",
            field_26: "F",
            field_27: "M",

            field_43: "17",
            field_44: "18",

            field_28: "P",
            field_29: "C",
            field_30: "X",
            field_31: "R",
            field_32: "C",
            field_33: "C",
            field_34: "X",

            field_35: "1",
            field_36: "2",
            field_37: "6",
            field_38: "7",
            field_39: "8",
            field_40: "9",
            field_41: "0",
            field_42: "10",

            field_45: "1",
            field_114: "4",
            field_46: "1",

            field_47: "1",

            field_118: "2",

            field_66: "5",
            field_67: "2",
            field_52: "31",
            field_61: "3",
            field_68: "12",

            field_65: "1",
            field_63: "EC1N",
            field_64: "2TD",

            field_69: "1",
            field_70: "1",
            field_71: "",
            field_72: "1",
            field_73: "",
            field_74: "",

            field_75: "1",
            field_76: "2",
            field_77: "2",

            field_78: "2",

            field_51: "1",
            field_50: "2000",
            field_116: "2",
            field_48: "1",
            field_49: "1",

            field_79: "4",
            field_80: "1234.56",
            field_87: "1",
            field_88: "234.56",
          }
        end

        it "returns true" do
          expect(parser).to be_valid
        end

        it "instantiates a log with everything completed", aggregate_failures: true do
          questions = parser.send(:questions).reject do |q|
            parser.send(:log).optional_fields.include?(q.id) || q.completed?(parser.send(:log))
          end

          expect(questions.map(&:id).size).to eq(0)
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

      context "when bulk upload is for general needs" do
        let(:bulk_upload) { create(:bulk_upload, :lettings, user:, needstype: "1") }

        context "when general needs option selected" do
          let(:attributes) { { bulk_upload:, field_1: "1" } }

          it "is permitted" do
            expect(parser.errors[:field_1]).to be_blank
          end
        end

        context "when supported housing option selected" do
          let(:attributes) { { bulk_upload:, field_1: "2" } }

          it "is not permitted" do
            expect(parser.errors[:field_1]).to include("Lettings type must be a general needs type")
          end
        end
      end

      context "when bulk upload is for supported housing" do
        let(:bulk_upload) { create(:bulk_upload, :lettings, user:, needstype: "2") }

        context "when general needs option selected" do
          let(:attributes) { { bulk_upload:, field_1: "1" } }

          it "is not permitted" do
            expect(parser.errors[:field_1]).to include("Lettings type must be a supported housing type")
          end
        end

        context "when supported housing option selected" do
          let(:attributes) { { bulk_upload:, field_1: "2" } }

          it "is permitted" do
            expect(parser.errors[:field_1]).to be_blank
          end
        end
      end
    end

    describe "#field_4" do
      context "when nullable not permitted" do
        let(:attributes) { { bulk_upload:, field_1: "2", field_4: nil } }

        it "cannot be nulled" do
          expect(parser.errors[:field_4]).to be_present
        end
      end

      context "when nullable permitted" do
        let(:attributes) { { bulk_upload:, field_1: "1", field_4: nil } }

        it "can be nulled" do
          expect(parser.errors[:field_4]).to be_blank
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

    describe "#field_10" do
      context "when field_9 is 3 aka other" do
        let(:attributes) { { bulk_upload:, field_9: "3" } }

        xit "returns an error" do
          expect(parser.errors[:field_10]).to be_present
        end
      end
    end

    describe "#field_52" do # leaving reason
      context "when field_134 is 1 meaning it is a renewal" do
        context "when field_52 is 40" do
          let(:attributes) { { bulk_upload:, field_52: "40", field_134: "1" } }

          it "is permitted" do
            expect(parser.errors[:field_52]).to be_blank
          end
        end

        context "when field_52 is 42" do
          let(:attributes) { { bulk_upload:, field_52: "42", field_134: "1" } }

          it "is permitted" do
            expect(parser.errors[:field_52]).to be_blank
          end
        end

        context "when field_52 is not 40 or 42" do
          let(:attributes) { { bulk_upload:, field_52: "1", field_134: "1" } }

          it "is not permitted" do
            expect(parser.errors[:field_52]).to be_present
          end
        end
      end
    end

    describe "#field_78" do # referral
      context "when 3 ie PRP nominated by LA and owning org is LA" do
        let(:attributes) { { bulk_upload:, field_78: "3", field_111: owning_org.old_visible_id } }

        it "is not permitted" do
          expect(parser.errors[:field_78]).to be_present
        end
      end

      context "when 4 ie referred by LA and is general needs" do
        let(:attributes) { { bulk_upload:, field_78: "4" } }

        it "is not permitted" do
          expect(parser.errors[:field_78]).to be_present
        end
      end

      context "when 4 ie referred by LA and is not general needs" do
        let(:bulk_upload) { create(:bulk_upload, :lettings, user:, needstype: 2) }
        let(:attributes) { { bulk_upload:, field_78: "4" } }

        it "is permitted" do
          expect(parser.errors[:field_78]).to be_blank
        end
      end
    end

    describe "fields 96, 97, 98 => startdate" do
      context "when any one of these fields is blank" do
        let(:attributes) { { bulk_upload:, field_96: nil, field_97: nil, field_98: nil } }

        it "returns an error" do
          parser.valid?

          expect(parser.errors[:field_96]).to be_present
          expect(parser.errors[:field_97]).to be_present
          expect(parser.errors[:field_98]).to be_present
        end
      end

      context "when inside of collection year" do
        let(:attributes) { { bulk_upload:, field_96: "1", field_97: "10", field_98: "22" } }

        let(:bulk_upload) { create(:bulk_upload, :lettings, user:, year: 2022) }

        it "does not return errors" do
          parser.valid?

          expect(parser.errors[:field_96]).not_to be_present
          expect(parser.errors[:field_97]).not_to be_present
          expect(parser.errors[:field_98]).not_to be_present
        end
      end

      context "when outside of collection year" do
        around do |example|
          Timecop.freeze(Date.new(2022, 4, 2)) do
            example.run
          end
        end

        let(:attributes) { { bulk_upload:, field_96: "1", field_97: "1", field_98: "22" } }

        let(:bulk_upload) { create(:bulk_upload, :lettings, user:, year: 2022) }

        it "returns errors" do
          parser.valid?

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

    describe "#field_103" do
      context "when null" do
        let(:attributes) { setup_section_params.merge({ field_103: nil }) }

        it "returns an error" do
          expect(parser.errors[:field_103]).to be_present
        end

        it "populates with correct error message" do
          expect(parser.errors[:field_103]).to eql(["You must answer type of building"])
        end
      end

      context "when unpermitted values" do
        let(:attributes) { setup_section_params.merge({ field_103: "4" }) }

        it "returns an error" do
          expect(parser.errors[:field_103]).to be_present
        end
      end
    end
  end

  describe "#log" do
    describe "#cbl" do
      context "when field_75 is yes ie 1" do
        let(:attributes) { { bulk_upload:, field_75: 1 } }

        it "sets value to 1" do
          expect(parser.log.cbl).to be(1)
        end
      end

      context "when field_75 is no ie 2" do
        let(:attributes) { { bulk_upload:, field_75: 2 } }

        it "sets value to 0" do
          expect(parser.log.cbl).to be(0)
        end
      end
    end

    describe "#chr" do
      context "when field_76 is yes ie 1" do
        let(:attributes) { { bulk_upload:, field_76: 1 } }

        it "sets value to 1" do
          expect(parser.log.chr).to be(1)
        end
      end

      context "when field_76 is no ie 2" do
        let(:attributes) { { bulk_upload:, field_76: 2 } }

        it "sets value to 0" do
          expect(parser.log.chr).to be(0)
        end
      end
    end

    describe "#cap" do
      context "when field_77 is yes ie 1" do
        let(:attributes) { { bulk_upload:, field_77: 1 } }

        it "sets value to 1" do
          expect(parser.log.cap).to be(1)
        end
      end

      context "when field_77 is no ie 2" do
        let(:attributes) { { bulk_upload:, field_77: 2 } }

        it "sets value to 0" do
          expect(parser.log.cap).to be(0)
        end
      end
    end

    describe "#letting_allocation_unknown" do
      context "when field_75, 76, 77 are no ie 2" do
        let(:attributes) { { bulk_upload:, field_75: 2, field_76: 2, field_77: 2 } }

        it "sets value to 1" do
          expect(parser.log.letting_allocation_unknown).to be(1)
        end
      end

      context "when any one of field_75, 76, 77 is yes ie 1" do
        let(:attributes) { { bulk_upload:, field_75: 1 } }

        it "sets value to 0" do
          expect(parser.log.letting_allocation_unknown).to be(0)
        end
      end
    end

    describe "#renewal" do
      context "when field_134 is no ie 2" do
        let(:attributes) { { bulk_upload:, field_134: 2 } }

        it "sets value to 0" do
          expect(parser.log.renewal).to eq(0)
        end
      end

      context "when field_134 is null but rsnvac/field_106 is 14" do
        let(:attributes) { { bulk_upload:, field_134: "", field_106: "14" } }

        it "sets renewal to 1" do
          expect(parser.log.renewal).to eq(1)
        end
      end
    end

    describe "#sexN fields" do
      let(:attributes) do
        {
          bulk_upload:,
          field_20: "F",
          field_21: "M",
          field_22: "X",
          field_23: "R",
          field_24: "F",
          field_25: "M",
          field_26: "X",
          field_27: "R",
        }
      end

      it "sets value from correct mapping" do
        expect(parser.log.sex1).to eql("F")
        expect(parser.log.sex2).to eql("M")
        expect(parser.log.sex3).to eql("X")
        expect(parser.log.sex4).to eql("R")
        expect(parser.log.sex5).to eql("F")
        expect(parser.log.sex6).to eql("M")
        expect(parser.log.sex7).to eql("X")
        expect(parser.log.sex8).to eql("R")
      end
    end

    describe "#ecstatN fields" do
      let(:attributes) do
        {
          bulk_upload:,
          field_35: "1",
          field_36: "2",
          field_37: "6",
          field_38: "7",
          field_39: "8",
          field_40: "9",
          field_41: "0",
          field_42: "10",
        }
      end

      it "sets value from correct mapping", aggregate_failures: true do
        expect(parser.log.ecstat1).to eq(1)
        expect(parser.log.ecstat2).to eq(2)
        expect(parser.log.ecstat3).to eq(6)
        expect(parser.log.ecstat4).to eq(7)
        expect(parser.log.ecstat5).to eq(8)
        expect(parser.log.ecstat6).to eq(9)
        expect(parser.log.ecstat7).to eq(0)
        expect(parser.log.ecstat8).to eq(10)
      end
    end

    describe "#relatN fields" do
      let(:attributes) do
        {
          bulk_upload:,
          field_28: "P",
          field_29: "C",
          field_30: "X",
          field_31: "R",
          field_32: "P",
          field_33: "C",
          field_34: "X",
        }
      end

      it "sets value from correct mapping", aggregate_failures: true do
        expect(parser.log.relat2).to eq("P")
        expect(parser.log.relat3).to eq("C")
        expect(parser.log.relat4).to eq("X")
        expect(parser.log.relat5).to eq("R")
        expect(parser.log.relat6).to eq("P")
        expect(parser.log.relat7).to eq("C")
        expect(parser.log.relat8).to eq("X")
      end
    end

    describe "#net_income_known" do
      let(:attributes) { { bulk_upload:, field_51: "1" } }

      it "sets value from correct mapping" do
        expect(parser.log.net_income_known).to eq(0)
      end
    end

    describe "#unitletas" do
      let(:attributes) { { bulk_upload:, field_105: "1" } }

      it "sets value from correct mapping" do
        expect(parser.log.unitletas).to eq(1)
      end
    end

    describe "#rsnvac" do
      let(:attributes) { { bulk_upload:, field_106: "5" } }

      it "sets value from correct mapping" do
        expect(parser.log.rsnvac).to eq(5)
      end
    end

    describe "#sheltered" do
      let(:attributes) { { bulk_upload:, field_117: "1" } }

      it "sets value from correct mapping" do
        expect(parser.log.sheltered).to eq(1)
      end
    end

    describe "illness fields" do
      mapping = [
        { attribute: :illness_type_1, field: :field_119 },
        { attribute: :illness_type_2, field: :field_120 },
        { attribute: :illness_type_3, field: :field_121 },
        { attribute: :illness_type_4, field: :field_122 },
        { attribute: :illness_type_5, field: :field_123 },
        { attribute: :illness_type_6, field: :field_124 },
        { attribute: :illness_type_7, field: :field_125 },
        { attribute: :illness_type_8, field: :field_126 },
        { attribute: :illness_type_9, field: :field_127 },
        { attribute: :illness_type_10, field: :field_128 },
      ]

      mapping.each do |hash|
        describe "##{hash[:attribute]}" do
          context "when yes" do
            let(:attributes) { { bulk_upload:, hash[:field] => "1" } }

            it "sets value from correct mapping" do
              expect(parser.log.public_send(hash[:attribute])).to eq(1)
            end
          end

          context "when no" do
            let(:attributes) { { bulk_upload:, hash[:field] => "" } }

            it "sets value from correct mapping" do
              expect(parser.log.public_send(hash[:attribute])).to be_nil
            end
          end
        end
      end
    end

    describe "#irproduct_other" do
      let(:attributes) { { bulk_upload:, field_131: "some other product" } }

      it "sets value to given free text string" do
        expect(parser.log.irproduct_other).to eql("some other product")
      end
    end

    describe "#tenancyother" do
      let(:attributes) { { bulk_upload:, field_10: "some other tenancy" } }

      it "sets value to given free text string" do
        expect(parser.log.tenancyother).to eql("some other tenancy")
      end
    end

    describe "#tenancylength" do
      let(:attributes) { { bulk_upload:, field_11: "2" } }

      it "sets value to given free text string" do
        expect(parser.log.tenancylength).to eq(2)
      end
    end

    describe "#earnings" do
      let(:attributes) { { bulk_upload:, field_50: "104.50" } }

      it "rounds to the nearest whole pound" do
        expect(parser.log.earnings).to eq(105)
      end
    end

    describe "#reasonother" do
      let(:attributes) { { bulk_upload:, field_53: "some other reason" } }

      it "sets value to given free text string" do
        expect(parser.log.reasonother).to eql("some other reason")
      end
    end

    describe "#ppcodenk" do
      let(:attributes) { { bulk_upload:, field_65: "2" } }

      it "sets correct value from mapping" do
        expect(parser.log.ppcodenk).to eq(0)
      end
    end

    describe "#household_charge" do
      let(:attributes) { { bulk_upload:, field_86: "1" } }

      it "sets correct value from mapping" do
        expect(parser.log.household_charge).to eq(1)
      end
    end

    describe "#chcharge" do
      let(:attributes) { { bulk_upload:, field_85: "123.45" } }

      it "sets value given" do
        expect(parser.log.chcharge).to eq(123.45)
      end
    end

    describe "#tcharge" do
      let(:attributes) { { bulk_upload:, field_84: "123.45" } }

      it "sets value given" do
        expect(parser.log.tcharge).to eq(123.45)
      end
    end

    describe "#supcharg" do
      let(:attributes) { { bulk_upload:, field_83: "123.45" } }

      it "sets value given" do
        expect(parser.log.supcharg).to eq(123.45)
      end
    end

    describe "#pscharge" do
      let(:attributes) { { bulk_upload:, field_82: "123.45" } }

      it "sets value given" do
        expect(parser.log.pscharge).to eq(123.45)
      end
    end

    describe "#scharge" do
      let(:attributes) { { bulk_upload:, field_81: "123.45" } }

      it "sets value given" do
        expect(parser.log.scharge).to eq(123.45)
      end
    end

    describe "#offered" do
      let(:attributes) { { bulk_upload:, field_99: "3" } }

      it "sets value given" do
        expect(parser.log.offered).to eq(3)
      end
    end

    describe "#propcode" do
      let(:attributes) { { bulk_upload:, field_100: "abc123" } }

      it "sets value given" do
        expect(parser.log.propcode).to eq("abc123")
      end
    end

    describe "#mrcdate" do
      let(:attributes) { { bulk_upload:, field_92: "13", field_93: "12", field_94: "22" } }

      it "sets value given" do
        expect(parser.log.mrcdate).to eq(Date.new(2022, 12, 13))
      end
    end

    describe "#majorrepairs" do
      context "when mrcdate given" do
        let(:attributes) { { bulk_upload:, field_92: "13", field_93: "12", field_94: "22" } }

        it "sets #majorrepairs to 1" do
          expect(parser.log.majorrepairs).to eq(1)
        end
      end

      context "when mrcdate not given" do
        let(:attributes) { { bulk_upload:, field_92: "", field_93: "", field_94: "" } }

        it "sets #majorrepairs to 0" do
          expect(parser.log.majorrepairs).to eq(0)
        end
      end
    end

    describe "#voiddate" do
      let(:attributes) { { bulk_upload:, field_89: "13", field_90: "12", field_91: "22" } }

      it "sets value given" do
        expect(parser.log.voiddate).to eq(Date.new(2022, 12, 13))
      end
    end

    describe "#startdate" do
      let(:attributes) { { bulk_upload:, field_96: now.day.to_s, field_97: now.month.to_s, field_98: now.strftime("%g") } }

      it "sets value given" do
        expect(parser.log.startdate).to eq(now)
      end
    end

    describe "#postcode_full" do
      let(:attributes) { { bulk_upload:, field_108: " EC1N ", field_109: " 2TD " } }

      it "strips whitespace" do
        expect(parser.log.postcode_full).to eql("EC1N 2TD")
      end
    end

    describe "#la" do
      let(:attributes) { { bulk_upload:, field_107: "E07000223" } }

      it "sets to given value" do
        expect(parser.log.la).to eql("E07000223")
      end
    end

    describe "#prevloc" do
      let(:attributes) { { bulk_upload:, field_62: "E07000223" } }

      it "sets to given value" do
        expect(parser.log.prevloc).to eql("E07000223")
      end
    end

    describe "#previous_la_known" do
      context "when known" do
        let(:attributes) { { bulk_upload:, field_62: "E07000223" } }

        it "sets to 1" do
          expect(parser.log.previous_la_known).to eq(1)
        end
      end

      context "when not known" do
        let(:attributes) { { bulk_upload:, field_62: "" } }

        it "sets to 0" do
          expect(parser.log.previous_la_known).to eq(0)
        end
      end
    end

    describe "#first_time_property_let_as_social_housing" do
      context "when field_106 is 15, 16, or 17" do
        let(:attributes) { { bulk_upload:, field_106: %w[15 16 17].sample } }

        it "sets to 1" do
          expect(parser.log.first_time_property_let_as_social_housing).to eq(1)
        end
      end
    end
  end

  describe "#start_date" do
    context "when year of 9 is passed to represent 2009" do
      let(:attributes) { { bulk_upload:, field_96: "1", field_97: "1", field_98: "9" } }

      it "uses the year 2009" do
        expect(parser.send(:start_date)).to eql(Date.new(2009, 1, 1))
      end
    end
  end
end
