require "rails_helper"

RSpec.describe BulkUpload::Lettings::Year2023::RowParser do
  subject(:parser) { described_class.new(attributes) }

  let(:now) { Time.zone.today }

  let(:attributes) { { bulk_upload: } }
  let(:bulk_upload) { create(:bulk_upload, :lettings, user:, needstype: nil) }
  let(:user) { create(:user, organisation: owning_org) }

  let(:owning_org) { create(:organisation, :with_old_visible_id) }
  let(:managing_org) { create(:organisation, :with_old_visible_id) }
  let(:scheme) { create(:scheme, :with_old_visible_id, owning_organisation: owning_org) }
  let(:location) { create(:location, :with_old_visible_id, scheme:) }

  let(:setup_section_params) do
    {
      bulk_upload:,
      field_1: owning_org.old_visible_id,
      field_2: managing_org.old_visible_id,
      field_4: "1",
      field_5: "2",
      field_6: "2",
      field_7: now.day.to_s,
      field_8: now.month.to_s,
      field_9: now.strftime("%g"),
    }
  end

  before do
    create(:organisation_relationship, parent_organisation: owning_org, child_organisation: managing_org)
  end

  around do |example|
    FormHandler.instance.use_real_forms!

    example.run

    FormHandler.instance.use_fake_forms!
  end

  describe "#blank_row?" do
    context "when a new object" do
      it "returns true" do
        expect(parser).to be_blank_row
      end
    end

    context "when any field is populated" do
      before do
        parser.field_1 = "1"
      end

      it "returns false" do
        expect(parser).not_to be_blank_row
      end
    end
  end

  describe "validations" do
    before do
      stub_request(:get, /api.postcodes.io/)
      .to_return(status: 200, body: "{\"status\":200,\"result\":{\"admin_district\":\"Manchester\", \"codes\":{\"admin_district\": \"E08000003\"}}}", headers: {})

      stub_request(:get, "https://api.os.uk/search/places/v1/uprn?key=OS_DATA_KEY&uprn=100023336956")
        .to_return(status: 200, body: "{}", headers: {})

      parser.valid?
    end

    describe "#valid?" do
      context "when the row is blank" do
        let(:attributes) { { bulk_upload: } }

        it "returns true" do
          expect(parser).to be_valid
        end
      end

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
            field_5: "1",
            field_13: "123",
            field_7: now.day.to_s,
            field_8: now.month.to_s,
            field_9: now.strftime("%g"),
            field_23: "EC1N",
            field_24: "2TD",
            field_1: owning_org.old_visible_id,
            field_2: managing_org.old_visible_id,
            field_11: "1",
            field_6: "2",
            field_29: "2",
            field_30: "1",
            field_31: "1",
            field_32: "1",
            field_39: "2",
            field_40: "1",
            field_41: "2",
            field_45: "1",

            field_46: "42",
            field_52: "41",
            field_56: "20",
            field_60: "18",
            field_64: "16",
            field_68: "14",
            field_72: "12",
            field_76: "20",

            field_47: "F",
            field_53: "M",
            field_57: "F",
            field_61: "M",
            field_65: "F",
            field_69: "M",
            field_73: "F",
            field_77: "M",

            field_48: "17",
            field_49: "18",

            field_51: "P",
            field_55: "C",
            field_59: "X",
            field_63: "R",
            field_67: "C",
            field_71: "C",
            field_75: "X",

            field_50: "1",
            field_54: "2",
            field_58: "6",
            field_62: "7",
            field_66: "8",
            field_70: "9",
            field_74: "0",
            field_78: "10",

            field_79: "1",
            field_80: "4",
            field_81: "1",

            field_82: "1",

            field_89: "2",

            field_100: "5",
            field_101: "2",
            field_102: "31",
            field_104: "3",
            field_105: "12",

            field_106: "1",
            field_107: "EC1N",
            field_108: "2TD",

            field_110: "1",
            field_111: "1",
            field_112: "",
            field_113: "1",
            field_114: "",
            field_115: "",

            field_116: "1",
            field_117: "2",
            field_118: "2",

            field_119: "2",

            field_120: "1",
            field_122: "2000",
            field_121: "2",
            field_123: "1",
            field_124: "1",

            field_126: "4",
            field_128: "1234.56",
            field_129: "43.32",
            field_130: "13.14",
            field_131: "101.11",
            field_132: "1500.19",
            field_133: "1",
            field_134: "234.56",

            field_27: "15",
            field_28: "0",
            field_33: now.day.to_s,
            field_34: now.month.to_s,
            field_35: now.strftime("%g"),

            field_4: "1",

            field_18: "100023336956",
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

    context "when setup section not complete" do
      let(:attributes) { { bulk_upload:, field_13: "123" } }

      it "has errors on setup fields" do
        errors = parser.errors.select { |e| e.options[:category] == :setup }.map(&:attribute)

        expect(errors).to eql(%i[field_4 field_5 field_7 field_8 field_9 field_1 field_2])
      end
    end

    describe "#field_5" do
      context "when null" do
        let(:attributes) { { bulk_upload:, field_5: nil, field_15: "1" } }

        it "returns an error" do
          expect(parser.errors[:field_5]).to be_present
        end
      end

      context "when incorrect data type" do
        let(:attributes) { { bulk_upload:, field_5: "foo" } }

        it "returns an error" do
          expect(parser.errors[:field_5]).to be_present
        end
      end

      context "when unpermitted value" do
        let(:attributes) { { bulk_upload:, field_5: "101" } }

        it "returns an error" do
          expect(parser.errors[:field_5]).to be_present
        end
      end

      context "when valid" do
        let(:attributes) { { bulk_upload:, field_5: "1", field_4: "1" } }

        it "does not return any errors" do
          expect(parser.errors[:field_5]).to be_blank
        end
      end

      context "when bulk upload is for general needs" do
        context "when general needs option selected" do
          let(:attributes) { { bulk_upload:, field_5: "1", field_4: "1" } }

          it "is permitted" do
            expect(parser.errors[:field_5]).to be_blank
          end
        end

        context "when supported housing option selected" do
          let(:attributes) { { bulk_upload:, field_5: "2", field_4: "1" } }

          it "is not permitted" do
            expect(parser.errors[:field_5]).to include("Lettings type must be a general needs type because you selected general needs when uploading the file")
          end
        end
      end

      context "when bulk upload is for supported housing" do
        let(:bulk_upload) { create(:bulk_upload, :lettings, user:) }

        context "when general needs option selected" do
          let(:attributes) { { bulk_upload:, field_5: "1", field_4: "2" } }

          it "is not permitted" do
            expect(parser.errors[:field_5]).to include("Lettings type must be a supported housing type because you selected supported housing when uploading the file")
          end
        end

        context "when supported housing option selected" do
          let(:attributes) { { bulk_upload:, field_5: "2", field_4: "2" } }

          it "is permitted" do
            expect(parser.errors[:field_5]).to be_blank
          end
        end
      end
    end

    describe "#field_16" do
      context "when nullable not permitted" do
        let(:attributes) { { bulk_upload:, field_5: "2", field_16: nil } }

        it "cannot be nulled" do
          expect(parser.errors[:field_16]).to be_present
        end
      end

      context "when nullable permitted" do
        let(:attributes) { { bulk_upload:, field_5: "1", field_16: nil } }

        it "can be nulled" do
          expect(parser.errors[:field_15]).to be_blank
        end
      end

      context "when matching scheme cannot be found" do
        let(:attributes) { { bulk_upload:, field_5: "1", field_16: "123" } }

        it "returns an error" do
          expect(parser.errors[:field_16]).to be_present
        end
      end

      context "when scheme belongs to someone else" do
        let(:other_scheme) { create(:scheme, :with_old_visible_id) }
        let(:attributes) { { bulk_upload:, field_5: "1", field_16: other_scheme.old_visible_id, field_1: owning_org.old_visible_id } }

        it "returns an error" do
          expect(parser.errors[:field_16]).to include("This management group code does not belong to your organisation, or any of your stock owners / managing agents")
        end
      end

      context "when scheme belongs to owning org" do
        let(:scheme) { create(:scheme, :with_old_visible_id, owning_organisation: owning_org) }
        let(:attributes) { { bulk_upload:, field_5: "1", field_16: scheme.old_visible_id, field_1: owning_org.old_visible_id } }

        it "does not return an error" do
          expect(parser.errors[:field_16]).to be_blank
        end
      end

      context "when scheme belongs to managing org" do
        let(:scheme) { create(:scheme, :with_old_visible_id, owning_organisation: managing_org) }
        let(:attributes) { { bulk_upload:, field_5: "1", field_16: scheme.old_visible_id, field_2: managing_org.old_visible_id } }

        it "does not return an error" do
          expect(parser.errors[:field_16]).to be_blank
        end
      end
    end

    describe "#field_17" do
      context "when location does not exist" do
        let(:scheme) { create(:scheme, :with_old_visible_id, owning_organisation: owning_org) }
        let(:attributes) do
          {
            bulk_upload:,
            field_5: "1",
            field_16: scheme.old_visible_id,
            field_17: "dontexist",
            field_1: owning_org.old_visible_id,
          }
        end

        it "returns an error" do
          expect(parser.errors[:field_17]).to be_present
        end
      end

      context "when location exists" do
        let(:scheme) { create(:scheme, :with_old_visible_id, owning_organisation: owning_org) }
        let(:attributes) do
          {
            bulk_upload:,
            field_5: "1",
            field_16: scheme.old_visible_id,
            field_17: location.old_visible_id,
            field_1: owning_org.old_visible_id,
          }
        end

        it "does not return an error" do
          expect(parser.errors[:field_17]).to be_blank
        end
      end

      context "when location exists but not related" do
        let(:location) { create(:scheme, :with_old_visible_id) }
        let(:attributes) do
          {
            bulk_upload:,
            field_5: "1",
            field_16: scheme.old_visible_id,
            field_17: location.old_visible_id,
            field_1: owning_org.old_visible_id,
          }
        end

        it "returns an error" do
          expect(parser.errors[:field_17]).to be_present
        end
      end
    end

    describe "#field_102" do # leaving reason
      context "when field_6 is 1 meaning it is a renewal" do
        context "when field_102 is 40" do
          let(:attributes) { { bulk_upload:, field_102: "40", field_6: "1" } }

          it "is permitted" do
            expect(parser.errors[:field_102]).to be_blank
          end
        end

        context "when field_102 is 42" do
          let(:attributes) { { bulk_upload:, field_102: "42", field_6: "1" } }

          it "is permitted" do
            expect(parser.errors[:field_102]).to be_blank
          end
        end

        context "when field_102 is not 40 or 42" do
          let(:attributes) { { bulk_upload:, field_102: "1", field_6: "1" } }

          it "is not permitted" do
            expect(parser.errors[:field_102]).to be_present
          end
        end
      end
    end

    describe "#field_83, #field_84, #field_85" do
      context "when more than one item selected" do
        let(:attributes) { { bulk_upload:, field_83: "1", field_84: "1" } }

        it "is not permitted" do
          expect(parser.errors[:field_83]).to be_present
          expect(parser.errors[:field_84]).to be_present
          expect(parser.errors[:field_85]).to be_present
        end
      end
    end

    describe "#field_87" do
      context "when 1 and another disability field selected" do
        let(:attributes) { { bulk_upload:, field_87: "1", field_86: "1" } }

        it "is not permitted" do
          expect(parser.errors[:field_87]).to be_present
        end
      end
    end

    describe "#field_88" do
      context "when 1 and another disability field selected" do
        let(:attributes) { { bulk_upload:, field_88: "1", field_86: "1" } }

        it "is not permitted" do
          expect(parser.errors[:field_88]).to be_present
        end
      end
    end

    describe "#field_87, #field_88" do
      context "when both 1" do
        let(:attributes) { { bulk_upload:, field_87: "1", field_88: "1" } }

        it "is not permitted" do
          expect(parser.errors[:field_87]).to be_present
          expect(parser.errors[:field_88]).to be_present
        end
      end
    end

    describe "#field_119" do # referral
      context "when 3 ie PRP nominated by LA and owning org is LA" do
        let(:attributes) { { bulk_upload:, field_119: "3", field_1: owning_org.old_visible_id } }

        it "is not permitted" do
          expect(parser.errors[:field_119]).to be_present
        end
      end

      context "when 4 ie referred by LA and is general needs and owning org is LA" do
        let(:attributes) { { bulk_upload:, field_119: "4", field_1: owning_org.old_visible_id.to_s, field_4: "1" } }

        it "is not permitted" do
          expect(parser.errors[:field_119]).to be_present
        end
      end

      context "when 4 ie referred by LA and is general needs and owning org is PRP" do
        let(:owning_org) { create(:organisation, :prp, :with_old_visible_id) }

        let(:attributes) { { bulk_upload:, field_119: "4", field_1: owning_org.old_visible_id.to_s } }

        it "is permitted" do
          expect(parser.errors[:field_119]).to be_blank
        end
      end

      context "when 4 ie referred by LA and is not general needs" do
        let(:bulk_upload) { create(:bulk_upload, :lettings, user:) }
        let(:attributes) { { bulk_upload:, field_119: "4", field_4: "2" } }

        it "is permitted" do
          expect(parser.errors[:field_119]).to be_blank
        end
      end
    end

    describe "fields 7, 8, 9 => startdate" do
      context "when any one of these fields is blank" do
        let(:attributes) { { bulk_upload:, field_5: "1", field_7: nil, field_8: nil, field_9: nil } }

        it "returns an error" do
          parser.valid?

          expect(parser.errors[:field_7]).to be_present
          expect(parser.errors[:field_8]).to be_present
          expect(parser.errors[:field_9]).to be_present
        end
      end

      context "when field_9 is 4 digits instead of 2" do
        let(:attributes) { { bulk_upload:, field_9: "2022" } }

        it "returns an error" do
          parser.valid?

          expect(parser.errors[:field_9]).to include("Tenancy start year must be 2 digits")
        end
      end

      context "when invalid date given" do
        let(:attributes) { { bulk_upload:, field_5: "1", field_7: "a", field_8: "12", field_9: "22" } }

        it "does not raise an error" do
          expect { parser.valid? }.not_to raise_error
        end
      end

      context "when inside of collection year" do
        let(:attributes) { { bulk_upload:, field_7: "1", field_8: "10", field_9: "22" } }

        let(:bulk_upload) { create(:bulk_upload, :lettings, user:, year: 2022) }

        it "does not return errors" do
          parser.valid?

          expect(parser.errors[:field_7]).not_to be_present
          expect(parser.errors[:field_8]).not_to be_present
          expect(parser.errors[:field_9]).not_to be_present
        end
      end

      context "when outside of collection year" do
        around do |example|
          Timecop.freeze(Date.new(2022, 4, 2)) do
            example.run
          end
          Timecop.return
        end

        let(:attributes) { { bulk_upload:, field_7: "1", field_8: "1", field_9: "22" } }

        let(:bulk_upload) { create(:bulk_upload, :lettings, user:, year: 2022) }

        it "returns errors" do
          parser.valid?

          expect(parser.errors[:field_7]).to be_present
          expect(parser.errors[:field_8]).to be_present
          expect(parser.errors[:field_9]).to be_present
        end
      end
    end

    describe "#field_1" do # owning org
      context "when blank" do
        let(:attributes) { { bulk_upload:, field_1: "" } }

        it "is not permitted" do
          expect(parser.errors[:field_1]).to eql(["The owning organisation code is incorrect"])
        end

        it "blocks log creation" do
          expect(parser).to be_block_log_creation
        end
      end

      context "when cannot find owning org" do
        let(:attributes) { { bulk_upload:, field_1: "donotexist" } }

        it "is not permitted" do
          expect(parser.errors[:field_1]).to eql(["The owning organisation code is incorrect"])
        end

        it "blocks log creation" do
          expect(parser).to be_block_log_creation
        end
      end

      context "when org is not stock owning" do
        let(:owning_org) { create(:organisation, :with_old_visible_id, :does_not_own_stock) }

        let(:attributes) { { bulk_upload:, field_1: owning_org.old_visible_id } }

        it "is not permitted" do
          expect(parser.errors[:field_1]).to eql(["The owning organisation code provided is for an organisation that does not own stock"])
        end

        it "blocks log creation" do
          expect(parser).to be_block_log_creation
        end
      end

      context "when not affiliated with owning org" do
        let(:unaffiliated_org) { create(:organisation, :with_old_visible_id) }

        let(:attributes) { { bulk_upload:, field_1: unaffiliated_org.old_visible_id } }

        it "is not permitted" do
          expect(parser.errors[:field_1]).to eql(["You do not have permission to add logs for this owning organisation"])
        end

        it "blocks log creation" do
          expect(parser).to be_block_log_creation
        end
      end
    end

    describe "#field_2" do # managing org
      context "when blank" do
        let(:attributes) { { bulk_upload:, field_2: "" } }

        it "is not permitted" do
          expect(parser.errors[:field_2]).to eql(["The managing organisation code is incorrect"])
        end

        it "blocks log creation" do
          expect(parser).to be_block_log_creation
        end
      end

      context "when cannot find managing org" do
        let(:attributes) { { bulk_upload:, field_2: "donotexist" } }

        it "is not permitted" do
          expect(parser.errors[:field_2]).to eql(["The managing organisation code is incorrect"])
        end

        it "blocks log creation" do
          expect(parser).to be_block_log_creation
        end
      end

      context "when not affiliated with managing org" do
        let(:unaffiliated_org) { create(:organisation, :with_old_visible_id) }

        let(:attributes) { { bulk_upload:, field_1: owning_org.old_visible_id, field_2: unaffiliated_org.old_visible_id } }

        it "is not permitted" do
          expect(parser.errors[:field_2]).to eql(["This managing organisation does not have a relationship with the owning organisation"])
        end

        it "blocks log creation" do
          expect(parser).to be_block_log_creation
        end
      end
    end

    describe "#field_4" do
      context "when blank" do
        let(:attributes) { { bulk_upload:, field_4: nil, field_13: "123" } }

        it "is reported as a setup error" do
          errors = parser.errors.select { |e| e.options[:category] == :setup }
          error = errors.find { |e| e.attribute == :field_4 }

          expect(error).to be_present
          expect(error.type).to eql("You must answer needs type")
        end
      end
    end

    describe "#field_6" do
      context "when an unpermitted value" do
        let(:attributes) { { bulk_upload:, field_6: "3" } }

        it "has errors on the field" do
          expect(parser.errors[:field_6]).to be_present
        end
      end
    end

    describe "#field_30" do
      context "when null" do
        let(:attributes) { setup_section_params.merge({ field_30: nil }) }

        it "returns an error" do
          expect(parser.errors[:field_30]).to be_present
        end

        it "populates with correct error message" do
          expect(parser.errors[:field_30]).to eql(["You must answer type of building"])
        end
      end

      context "when unpermitted values" do
        let(:attributes) { setup_section_params.merge({ field_30: "4" }) }

        it "returns an error" do
          expect(parser.errors[:field_30]).to be_present
        end
      end
    end

    describe "#field_56" do # age3
      context "when null but gender given" do
        let(:attributes) { setup_section_params.merge({ field_56: "", field_57: "F" }) }

        it "returns an error" do
          expect(parser.errors[:field_56]).to be_present
        end
      end
    end
  end

  describe "#log" do
    describe "#uprn" do
      let(:attributes) { { bulk_upload:, field_18: "100023336956" } }

      it "sets to given value" do
        expect(parser.log.uprn).to eql("100023336956")
      end
    end

    describe "#uprn_known" do
      context "when uprn specified" do
        let(:attributes) { { bulk_upload:, field_18: "100023336956" } }

        it "sets to 1" do
          expect(parser.log.uprn_known).to be(1)
        end
      end

      context "when uprn blank" do
        let(:attributes) { { bulk_upload:, field_18: "" } }

        it "sets to 0" do
          expect(parser.log.uprn_known).to be(0)
        end
      end
    end

    describe "#address_line1" do
      let(:attributes) { { bulk_upload:, field_19: "123 Sesame Street" } }

      it "sets to given value" do
        expect(parser.log.address_line1).to eql("123 Sesame Street")
      end
    end

    describe "#address_line2" do
      let(:attributes) { { bulk_upload:, field_20: "Cookie Town" } }

      it "sets to given value" do
        expect(parser.log.address_line2).to eql("Cookie Town")
      end
    end

    describe "#town_or_city" do
      let(:attributes) { { bulk_upload:, field_21: "London" } }

      it "sets to given value" do
        expect(parser.log.town_or_city).to eql("London")
      end
    end

    describe "#county" do
      let(:attributes) { { bulk_upload:, field_22: "Greater London" } }

      it "sets to given value" do
        expect(parser.log.county).to eql("Greater London")
      end
    end

    [
      %w[age1_known age1 field_46],
      %w[age2_known age2 field_52],
      %w[age3_known age3 field_56],
      %w[age4_known age4 field_60],
      %w[age5_known age5 field_64],
      %w[age6_known age6 field_68],
      %w[age7_known age7 field_72],
      %w[age8_known age8 field_76],
    ].each do |known, age, field|
      describe "##{known} and ##{age}" do
        context "when #{field} is blank" do
          let(:attributes) { { bulk_upload:, field.to_s => nil } }

          it "sets ##{known} 1" do
            expect(parser.log.public_send(known)).to be(1)
          end

          it "sets ##{age} to nil" do
            expect(parser.log.public_send(age)).to be_nil
          end
        end

        context "when #{field} is R" do
          let(:attributes) { { bulk_upload:, field.to_s => "R" } }

          it "sets ##{known} 1" do
            expect(parser.log.public_send(known)).to be(1)
          end

          it "sets ##{age} to nil" do
            expect(parser.log.public_send(age)).to be_nil
          end
        end

        context "when #{field} is a number" do
          let(:attributes) { { bulk_upload:, field.to_s => "50" } }

          it "sets ##{known} to 0" do
            expect(parser.log.public_send(known)).to be(0)
          end

          it "sets ##{age} to given age" do
            expect(parser.log.public_send(age)).to be(50)
          end
        end
      end
    end

    describe "#location" do
      context "when lookup is via new core id" do
        let(:attributes) { { bulk_upload:, field_16: scheme.old_visible_id, field_17: location.id, field_1: owning_org } }

        it "assigns the correct location" do
          expect(parser.log.location).to eql(location)
        end
      end
    end

    describe "#scheme" do
      context "when lookup is via id prefixed with S" do
        let(:attributes) { { bulk_upload:, field_16: "S#{scheme.id}", field_1: owning_org } }

        it "assigns the correct scheme" do
          expect(parser.log.scheme).to eql(scheme)
        end
      end
    end

    describe "#owning_organisation" do
      context "when lookup is via id prefixed with ORG" do
        let(:attributes) { { bulk_upload:, field_1: "ORG#{owning_org.id}" } }

        it "assigns the correct org" do
          expect(parser.log.owning_organisation).to eql(owning_org)
        end
      end
    end

    describe "#managing_organisation" do
      context "when lookup is via id prefixed with ORG" do
        let(:attributes) { { bulk_upload:, field_2: "ORG#{managing_org.id}" } }

        it "assigns the correct org" do
          expect(parser.log.managing_organisation).to eql(managing_org)
        end
      end
    end

    describe "#cbl" do
      context "when field_116 is yes ie 1" do
        let(:attributes) { { bulk_upload:, field_116: 1 } }

        it "sets value to 1" do
          expect(parser.log.cbl).to be(1)
        end
      end

      context "when field_116 is no ie 2" do
        let(:attributes) { { bulk_upload:, field_116: 2 } }

        it "sets value to 0" do
          expect(parser.log.cbl).to be(0)
        end
      end
    end

    describe "#chr" do
      context "when field_118 is yes ie 1" do
        let(:attributes) { { bulk_upload:, field_118: 1 } }

        it "sets value to 1" do
          expect(parser.log.chr).to be(1)
        end
      end

      context "when field_118 is no ie 2" do
        let(:attributes) { { bulk_upload:, field_118: 2 } }

        it "sets value to 0" do
          expect(parser.log.chr).to be(0)
        end
      end
    end

    describe "#cap" do
      context "when field_117 is yes ie 1" do
        let(:attributes) { { bulk_upload:, field_117: 1 } }

        it "sets value to 1" do
          expect(parser.log.cap).to be(1)
        end
      end

      context "when field_117 is no ie 2" do
        let(:attributes) { { bulk_upload:, field_117: 2 } }

        it "sets value to 0" do
          expect(parser.log.cap).to be(0)
        end
      end
    end

    describe "#letting_allocation_unknown" do
      context "when field_116, 117, 118 are no ie 2" do
        let(:attributes) { { bulk_upload:, field_116: 2, field_117: 2, field_118: 2 } }

        it "sets value to 1" do
          expect(parser.log.letting_allocation_unknown).to be(1)
        end
      end

      context "when any one of field_116, 117, 118 is yes ie 1" do
        let(:attributes) { { bulk_upload:, field_116: 1 } }

        it "sets value to 0" do
          expect(parser.log.letting_allocation_unknown).to be(0)
        end
      end
    end

    describe "#renewal" do
      context "when field_6 is no ie 2" do
        let(:attributes) { { bulk_upload:, field_6: 2 } }

        it "sets value to 0" do
          expect(parser.log.renewal).to eq(0)
        end
      end

      context "when field_6 is null but rsnvac/field_27 is 14" do
        let(:attributes) { { bulk_upload:, field_6: "", field_27: "14" } }

        it "sets renewal to 1" do
          expect(parser.log.renewal).to eq(1)
        end
      end
    end

    describe "#sexN fields" do
      let(:attributes) do
        {
          bulk_upload:,
          field_47: "F",
          field_53: "M",
          field_57: "X",
          field_61: "R",
          field_65: "F",
          field_69: "M",
          field_73: "X",
          field_77: "R",
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
          field_50: "1",
          field_54: "2",
          field_58: "6",
          field_62: "7",
          field_66: "8",
          field_70: "9",
          field_74: "0",
          field_78: "10",
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
          field_51: "P",
          field_55: "C",
          field_59: "X",
          field_63: "R",
          field_67: "P",
          field_71: "C",
          field_75: "X",
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
      let(:attributes) { { bulk_upload:, field_120: "1" } }

      it "sets value from correct mapping" do
        expect(parser.log.net_income_known).to eq(0)
      end
    end

    describe "#unitletas" do
      let(:attributes) { { bulk_upload:, field_26: "1" } }

      it "sets value from correct mapping" do
        expect(parser.log.unitletas).to eq(1)
      end
    end

    describe "#rsnvac" do
      let(:attributes) { { bulk_upload:, field_27: "5" } }

      it "sets value from correct mapping" do
        expect(parser.log.rsnvac).to eq(5)
      end
    end

    describe "#sheltered" do
      let(:attributes) { { bulk_upload:, field_44: "1" } }

      it "sets value from correct mapping" do
        expect(parser.log.sheltered).to eq(1)
      end
    end

    describe "illness fields" do
      mapping = [
        { attribute: :illness_type_1, field: :field_98 },
        { attribute: :illness_type_2, field: :field_92 },
        { attribute: :illness_type_3, field: :field_95 },
        { attribute: :illness_type_4, field: :field_90 },
        { attribute: :illness_type_5, field: :field_91 },
        { attribute: :illness_type_6, field: :field_93 },
        { attribute: :illness_type_7, field: :field_94 },
        { attribute: :illness_type_8, field: :field_97 },
        { attribute: :illness_type_9, field: :field_96 },
        { attribute: :illness_type_10, field: :field_99 },
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
      let(:attributes) { { bulk_upload:, field_12: "some other product" } }

      it "sets value to given free text string" do
        expect(parser.log.irproduct_other).to eql("some other product")
      end
    end

    describe "#tenancyother" do
      let(:attributes) { { bulk_upload:, field_42: "some other tenancy" } }

      it "sets value to given free text string" do
        expect(parser.log.tenancyother).to eql("some other tenancy")
      end
    end

    describe "#tenancylength" do
      let(:attributes) { { bulk_upload:, field_43: "2" } }

      it "sets value to given free text string" do
        expect(parser.log.tenancylength).to eq(2)
      end
    end

    describe "#earnings" do
      let(:attributes) { { bulk_upload:, field_122: "104.50" } }

      it "rounds to the nearest whole pound" do
        expect(parser.log.earnings).to eq(105)
      end
    end

    describe "#reasonother" do
      let(:attributes) { { bulk_upload:, field_103: "some other reason" } }

      it "sets value to given free text string" do
        expect(parser.log.reasonother).to eql("some other reason")
      end
    end

    describe "#ppcodenk" do
      let(:attributes) { { bulk_upload:, field_106: "2" } }

      it "sets correct value from mapping" do
        expect(parser.log.ppcodenk).to eq(0)
      end
    end

    describe "#household_charge" do
      let(:attributes) { { bulk_upload:, field_125: "1" } }

      it "sets correct value from mapping" do
        expect(parser.log.household_charge).to eq(1)
      end
    end

    describe "#chcharge" do
      let(:attributes) { { bulk_upload:, field_127: "123.45" } }

      it "sets value given" do
        expect(parser.log.chcharge).to eq(123.45)
      end
    end

    describe "#tcharge" do
      let(:attributes) { { bulk_upload:, field_132: "123.45" } }

      it "sets value given" do
        expect(parser.log.tcharge).to eq(123.45)
      end
    end

    describe "#supcharg" do
      let(:attributes) { { bulk_upload:, field_131: "123.45" } }

      it "sets value given" do
        expect(parser.log.supcharg).to eq(123.45)
      end
    end

    describe "#pscharge" do
      let(:attributes) { { bulk_upload:, field_130: "123.45" } }

      it "sets value given" do
        expect(parser.log.pscharge).to eq(123.45)
      end
    end

    describe "#scharge" do
      let(:attributes) { { bulk_upload:, field_129: "123.45" } }

      it "sets value given" do
        expect(parser.log.scharge).to eq(123.45)
      end
    end

    describe "#offered" do
      let(:attributes) { { bulk_upload:, field_28: "3" } }

      it "sets value given" do
        expect(parser.log.offered).to eq(3)
      end
    end

    describe "#propcode" do
      let(:attributes) { { bulk_upload:, field_14: "abc123" } }

      it "sets value given" do
        expect(parser.log.propcode).to eq("abc123")
      end
    end

    describe "#mrcdate" do
      let(:attributes) { { bulk_upload:, field_36: "13", field_37: "12", field_38: "22" } }

      it "sets value given" do
        expect(parser.log.mrcdate).to eq(Date.new(2022, 12, 13))
      end
    end

    describe "#majorrepairs" do
      context "when mrcdate given" do
        let(:attributes) { { bulk_upload:, field_36: "13", field_37: "12", field_38: "22" } }

        it "sets #majorrepairs to 1" do
          expect(parser.log.majorrepairs).to eq(1)
        end
      end

      context "when mrcdate not given" do
        let(:attributes) { { bulk_upload:, field_36: "", field_37: "", field_38: "" } }

        it "sets #majorrepairs to 0" do
          expect(parser.log.majorrepairs).to eq(0)
        end
      end
    end

    describe "#voiddate" do
      let(:attributes) { { bulk_upload:, field_33: "13", field_34: "12", field_35: "22" } }

      it "sets value given" do
        expect(parser.log.voiddate).to eq(Date.new(2022, 12, 13))
      end
    end

    describe "#startdate" do
      let(:attributes) { { bulk_upload:, field_7: now.day.to_s, field_8: now.month.to_s, field_9: now.strftime("%g") } }

      it "sets value given" do
        expect(parser.log.startdate).to eq(now)
      end
    end

    describe "#postcode_full" do
      let(:attributes) { { bulk_upload:, field_23: " EC1N ", field_24: " 2TD " } }

      it "strips whitespace" do
        expect(parser.log.postcode_full).to eql("EC1N 2TD")
      end
    end

    describe "#la" do
      let(:attributes) { { bulk_upload:, field_25: "E07000223" } }

      it "sets to given value" do
        expect(parser.log.la).to eql("E07000223")
      end
    end

    describe "#prevloc" do
      let(:attributes) { { bulk_upload:, field_109: "E07000223" } }

      it "sets to given value" do
        expect(parser.log.prevloc).to eql("E07000223")
      end
    end

    describe "#previous_la_known" do
      context "when known" do
        let(:attributes) { { bulk_upload:, field_109: "E07000223" } }

        it "sets to 1" do
          expect(parser.log.previous_la_known).to eq(1)
        end
      end

      context "when not known" do
        let(:attributes) { { bulk_upload:, field_109: "" } }

        it "sets to 0" do
          expect(parser.log.previous_la_known).to eq(0)
        end
      end
    end

    describe "#first_time_property_let_as_social_housing" do
      context "when field_27 is 15, 16, or 17" do
        let(:attributes) { { bulk_upload:, field_27: %w[15 16 17].sample } }

        it "sets to 1" do
          expect(parser.log.first_time_property_let_as_social_housing).to eq(1)
        end
      end

      context "when field_27 is not 15, 16, or 17" do
        let(:attributes) { { bulk_upload:, field_27: "1" } }

        it "sets to 0" do
          expect(parser.log.first_time_property_let_as_social_housing).to eq(0)
        end
      end
    end

    describe "#housingneeds" do
      context "when no disabled needs" do
        let(:attributes) { { bulk_upload:, field_87: "1" } }

        it "sets to 2" do
          expect(parser.log.housingneeds).to eq(2)
        end
      end

      context "when dont know about disabled needs" do
        let(:attributes) { { bulk_upload:, field_88: "1" } }

        it "sets to 3" do
          expect(parser.log.housingneeds).to eq(3)
        end
      end
    end

    describe "#housingneeds_type" do
      context "when field_83 is 1" do
        let(:attributes) { { bulk_upload:, field_83: "1" } }

        it "set to 0" do
          expect(parser.log.housingneeds_type).to eq(0)
        end
      end

      context "when field_84 is 1" do
        let(:attributes) { { bulk_upload:, field_84: "1" } }

        it "set to 1" do
          expect(parser.log.housingneeds_type).to eq(1)
        end
      end

      context "when field_85 is 1" do
        let(:attributes) { { bulk_upload:, field_85: "1" } }

        it "set to 2" do
          expect(parser.log.housingneeds_type).to eq(2)
        end
      end
    end

    describe "#housingneeds_other" do
      context "when field_58 is 1" do
        let(:attributes) { { bulk_upload:, field_86: "1" } }

        it "sets to 1" do
          expect(parser.log.housingneeds_other).to eq(1)
        end
      end
    end
  end

  describe "#start_date" do
    context "when year of 9 is passed to represent 2009" do
      let(:attributes) { { bulk_upload:, field_7: "1", field_8: "1", field_9: "9" } }

      it "uses the year 2009" do
        expect(parser.send(:start_date)).to eql(Date.new(2009, 1, 1))
      end
    end
  end
end
