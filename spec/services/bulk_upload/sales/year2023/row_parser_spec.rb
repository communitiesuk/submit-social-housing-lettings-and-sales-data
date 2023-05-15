require "rails_helper"

RSpec.describe BulkUpload::Sales::Year2023::RowParser do
  subject(:parser) { described_class.new(attributes) }

  let(:now) { Time.zone.parse("01/03/2023") }

  let(:attributes) { { bulk_upload: } }
  let(:bulk_upload) { create(:bulk_upload, :sales, user:) }
  let(:user) { create(:user, organisation: owning_org) }

  let(:owning_org) { create(:organisation, :with_old_visible_id) }

  let(:setup_section_params) do
    {
      bulk_upload:,
      field_1: owning_org.old_visible_id, # organisation
      field_2: user.email, # user
      field_3: now.day.to_s, # sale day
      field_4: now.month.to_s, # sale month
      field_5: now.strftime("%g"), # sale year
      field_6: "test id", # purchase id
      field_7: "1", # owhershipsch
      field_8: "2", # shared ownership sale type
      field_13: "1", # will the buyers live in the property
      field_14: "2", # joint purchase
    }
  end

  let(:valid_attributes) do
    {
      bulk_upload:,

      field_1: owning_org.old_visible_id,
      field_3: "22",
      field_4: "2",
      field_5: "23",
      field_6: "test id",
      field_7: "1",
      field_8: "2",
      field_13: "1",
      field_14: "1",
      field_15: "2",
      field_16: "2",
      field_17: "1",
      field_18: "1",
      field_19: "100023336956",
      field_24: "CR0",
      field_25: "4BB",
      field_26: "E09000008",
      field_27: "3",
      field_28: "1",
      field_29: "1",
      field_30: "32",
      field_31: "M",
      field_32: "12",
      field_33: "18",
      field_35: "1",
      field_36: "1",
      field_37: "R",
      field_38: "32",
      field_39: "F",
      field_43: "2",
      field_44: "1",
      field_45: "0",
      field_62: "1",
      field_63: "1",
      field_64: "A1",
      field_65: "1AA",
      field_66: "E09000008",
      field_69: "1",
      field_70: "1",
      field_73: "3",
      field_75: "5",
      field_76: "3",
      field_77: "3",
      field_78: "30000",
      field_79: "1",
      field_80: "15000",
      field_81: "1",
      field_82: "4",
      field_83: "20000",
      field_84: "3",
      field_86: "5",
      field_87: "1",
      field_88: "10",
      field_89: "10",
      field_91: "2",
      field_92: "30",
      field_93: "3",
      field_94: "22",
      field_95: "23",
      field_96: "3",
      field_97: "22",
      field_98: "3",
      field_99: "1",
      field_100: "1",
      field_101: "1",
      field_102: "1",
      field_103: "250000",
      field_104: "25",
      field_105: "1",
      field_106: "42500",
      field_107: "1",
      field_109: "20",
      field_110: "3",
      field_111: "20000",
      field_113: "800",
      field_114: "200",
    }
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

      body = {
        results: [
          {
            DPA: {
              "POSTCODE": "EC1N 2TD",
              "POST_TOWN": "Newcastle",
              "ORGANISATION_NAME": "Some place",
            },
          },
        ],
      }.to_json

      stub_request(:get, "https://api.os.uk/search/places/v1/uprn?key=OS_DATA_KEY&uprn=100023336956")
        .to_return(status: 200, body:, headers: {})

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
        let(:attributes) { { bulk_upload:, field_7: 2 } }

        it "does not add keep adding errors to the pile" do
          expect { parser.valid? }.not_to change(parser.errors, :count)
        end
      end

      context "when valid row" do
        let(:attributes) { valid_attributes }

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

    context "when setup section not complete and type is not given" do
      let(:attributes) do
        {
          bulk_upload:,
          field_6: "test id",
        }
      end

      it "has errors on correct setup fields" do
        errors = parser.errors.select { |e| e.options[:category] == :setup }.map(&:attribute).sort

        expect(errors).to eql(%i[field_1 field_3 field_4 field_5 field_7])
      end
    end

    context "when setup section not complete and type is shared ownership" do
      let(:attributes) do
        {
          bulk_upload:,
          field_6: "test id",
          field_7: "1",
        }
      end

      it "has errors on correct setup fields" do
        errors = parser.errors.select { |e| e.options[:category] == :setup }.map(&:attribute).sort

        expect(errors).to eql(%i[field_1 field_14 field_3 field_4 field_5 field_8])
      end
    end

    context "when setup section not complete it's shared ownership joint purchase" do
      let(:attributes) do
        {
          bulk_upload:,
          field_6: "test id",
          field_7: "1",
          field_8: "2",
          field_14: "1",
        }
      end

      it "has errors on correct setup fields" do
        errors = parser.errors.select { |e| e.options[:category] == :setup }.map(&:attribute).sort

        expect(errors).to eql(%i[field_1 field_15 field_3 field_4 field_5])
      end
    end

    context "when setup section not complete and type is discounted ownership" do
      let(:attributes) do
        {
          bulk_upload:,
          field_6: "test id",
          field_7: "2",
        }
      end

      it "has errors on correct setup fields" do
        errors = parser.errors.select { |e| e.options[:category] == :setup }.map(&:attribute).sort

        expect(errors).to eql(%i[field_1 field_14 field_3 field_4 field_5 field_9])
      end
    end

    context "when setup section not complete it's discounted ownership joint purchase" do
      let(:attributes) do
        {
          bulk_upload:,
          field_28: "test id",
          field_30: "2",
          field_47: "8",
          field_39: "1",
        }
      end

      it "has errors on correct setup fields" do
        errors = parser.errors.select { |e| e.options[:category] == :setup }.map(&:attribute).sort

        expect(errors).to eql(%i[field_1 field_3 field_4 field_5 field_7])
      end
    end

    context "when setup section not complete and type is outright sale" do
      let(:attributes) do
        {
          bulk_upload:,
          field_6: "test id",
          field_7: "3",
        }
      end

      it "has errors on correct setup fields" do
        errors = parser.errors.select { |e| e.options[:category] == :setup }.map(&:attribute).sort

        expect(errors).to eql(%i[field_1 field_10 field_12 field_13 field_3 field_4 field_5])
      end
    end

    context "when setup section not complete outright sale buyer is not company" do
      let(:attributes) do
        {
          bulk_upload:,
          field_6: "test id",
          field_7: "3",
          field_10: "12",
          field_12: "2",
        }
      end

      it "has errors on correct setup fields" do
        errors = parser.errors.select { |e| e.options[:category] == :setup }.map(&:attribute).sort

        expect(errors).to eql(%i[field_1 field_13 field_14 field_3 field_4 field_5])
      end
    end

    describe "#field_1" do # owning org
      context "when no data given" do
        let(:attributes) { setup_section_params.merge(field_1: nil) }

        it "is not permitted as setup error" do
          expect(parser.errors.where(:field_1, category: :setup).map(&:message)).to eql(["The owning organisation code is incorrect"])
        end

        it "blocks log creation" do
          expect(parser).to be_block_log_creation
        end
      end

      context "when cannot find owning org" do
        let(:attributes) { { bulk_upload:, field_1: "donotexist" } }

        it "is not permitted as a setup error" do
          expect(parser.errors.where(:field_1, category: :setup).map(&:message)).to eql(["The owning organisation code is incorrect"])
        end

        it "blocks log creation" do
          expect(parser).to be_block_log_creation
        end
      end

      context "when not affiliated with owning org" do
        let(:unaffiliated_org) { create(:organisation, :with_old_visible_id) }

        let(:attributes) { { bulk_upload:, field_1: unaffiliated_org.old_visible_id } }

        it "is not permitted as setup error" do
          expect(parser.errors.where(:field_1, category: :setup).map(&:message)).to eql(["You do not have permission to add logs for this owning organisation"])
        end

        it "blocks log creation" do
          expect(parser).to be_block_log_creation
        end
      end
    end

    describe "#field_2" do # username for created_by
      context "when blank" do
        let(:attributes) { setup_section_params.merge(bulk_upload:, field_2: nil) }

        it "is permitted" do
          expect(parser.errors[:field_2]).to be_blank
        end
      end

      context "when user could not be found" do
        let(:attributes) { { bulk_upload:, field_2: "idonotexist@example.com" } }

        it "is not permitted" do
          expect(parser.errors[:field_2]).to be_present
        end
      end

      context "when an unaffiliated user" do
        let(:other_user) { create(:user) }

        let(:attributes) { { bulk_upload:, field_1: owning_org.old_visible_id, field_2: other_user.email } }

        it "is not permitted as a setup error" do
          expect(parser.errors.where(:field_2, category: :setup)).to be_present
        end

        it "blocks log creation" do
          expect(parser).to be_block_log_creation
        end
      end

      context "when an user part of owning org" do
        let(:other_user) { create(:user, organisation: owning_org) }

        let(:attributes) { { bulk_upload:, field_1: owning_org.old_visible_id, field_2: other_user.email } }

        it "is permitted" do
          expect(parser.errors[:field_2]).to be_blank
        end
      end
    end

    describe "fields 3, 4, 5 => saledate" do
      context "when all of these fields are blank" do
        let(:attributes) { setup_section_params.merge({ field_3: nil, field_4: nil, field_5: nil }) }

        it "returns them as setup errors" do
          expect(parser.errors.where(:field_3, category: :setup)).to be_present
          expect(parser.errors.where(:field_4, category: :setup)).to be_present
          expect(parser.errors.where(:field_5, category: :setup)).to be_present
        end
      end

      context "when one of these fields is blank" do
        let(:attributes) { setup_section_params.merge({ field_3: "1", field_4: "1", field_5: nil }) }

        it "returns an error only on blank field as setup error" do
          expect(parser.errors[:field_3]).to be_blank
          expect(parser.errors[:field_4]).to be_blank
          expect(parser.errors.where(:field_5, category: :setup)).to be_present
        end
      end

      context "when field 5 is 4 digits instead of 2" do
        let(:attributes) { setup_section_params.merge({ bulk_upload:, field_5: "2022" }) }

        it "returns a setup error" do
          expect(parser.errors.where(:field_5, category: :setup).map(&:message)).to include("Sale completion year must be 2 digits")
        end
      end

      context "when invalid date given" do
        let(:attributes) { setup_section_params.merge({ field_3: "a", field_4: "12", field_5: "2022" }) }

        it "does not raise an error" do
          expect { parser.valid? }.not_to raise_error
        end
      end

      context "when inside of collection year" do
        around do |example|
          Timecop.freeze(Date.new(2023, 10, 1)) do
            example.run
          end
        end

        let(:attributes) { setup_section_params.merge({ field_3: "1", field_4: "10", field_5: "23" }) }

        let(:bulk_upload) { create(:bulk_upload, :sales, user:, year: 2023) }

        it "does not return errors" do
          expect(parser.errors[:field_3]).not_to be_present
          expect(parser.errors[:field_4]).not_to be_present
          expect(parser.errors[:field_5]).not_to be_present
        end
      end

      context "when outside of collection year" do
        around do |example|
          Timecop.freeze(Date.new(2022, 4, 2)) do
            example.run
          end
        end

        let(:attributes) { setup_section_params.merge({ field_3: "1", field_4: "1", field_5: "22" }) }

        let(:bulk_upload) { create(:bulk_upload, :sales, user:, year: 2022) }

        it "returns setup errors" do
          expect(parser.errors.where(:field_3, category: :setup)).to be_present
          expect(parser.errors.where(:field_4, category: :setup)).to be_present
          expect(parser.errors.where(:field_5, category: :setup)).to be_present
        end
      end
    end

    context "when the log already exists in the db" do
      let(:attributes) { valid_attributes }

      before do
        parser.log.save!
        parser.instance_variable_set(:@valid, nil)
      end

      it "is not a valid row" do
        expect(parser).not_to be_valid
      end

      it "adds an error to all (and only) the fields used to determine duplicates" do
        parser.valid?

        error_message = "This is a duplicate log"

        [
          :field_1, # Owning org
          :field_3, # Sale completion date
          :field_4, # Sale completion date
          :field_5, # Sale completion date
          :field_24, # Postcode
          :field_25, # Postcode
          :field_30, # Buyer 1 age
          :field_31, # Buyer 1 gender
          :field_35, # Buyer 1 working situation
          :field_6, # Purchaser code
        ].each do |field|
          expect(parser.errors[field]).to include(error_message)
        end
      end
    end

    context "when a hidden log already exists in db" do
      before do
        parser.log.status = "pending"
        parser.log.skip_update_status = true
        parser.log.save!
      end

      it "is a valid row" do
        expect(parser).to be_valid
      end

      it "does not add duplicate errors" do
        parser.valid?

        [
          :field_1, # Owning org
          :field_3, # Sale completion date
          :field_4, # Sale completion date
          :field_5, # Sale completion date
          :field_24, # Postcode
          :field_25, # Postcode
          :field_30, # Buyer 1 age
          :field_31, # Buyer 1 gender
          :field_35, # Buyer 1 working situation
          :field_6, # Purchaser code
        ].each do |field|
          expect(parser.errors[field]).to be_blank
        end
      end
    end

    describe "#field_19" do # UPRN
      context "when UPRN known" do
        let(:attributes) { setup_section_params.merge({ field_19: "100023336956" }) }

        it "is valid" do
          expect(parser.errors[:field_19]).to be_blank
        end

        it "sets UPRN and UPRN known" do
          expect(parser.log.uprn).to eq("100023336956")
          expect(parser.log.uprn_known).to eq(1)
          expect(parser.log.uprn_confirmed).to eq(1)
        end
      end

      context "when UPRN not known but address known" do
        let(:attributes) { setup_section_params.merge({ field_19: nil, field_20: "some street", field_22: "some town", field_24: "EC1N", field_25: "2TD" }) }

        it "is valid" do
          expect(parser.errors[:field_19]).to be_blank
        end
      end

      context "when neither UPRN or address known" do
        let(:attributes) { setup_section_params.merge({ field_19: nil, field_20: nil, field_22: nil, field_24: nil, field_25: nil }) }

        it "is not valid" do
          expect(parser.errors[:field_19]).to be_present
        end
      end
    end

    [
      { field: :field_20, name: "address line 1" },
      { field: :field_22, name: "town or city" },
      { field: :field_24, name: "postcode part 1" },
      { field: :field_25, name: "postcode part 2" },
    ].each do |data|
      describe "##{data[:field]} (#{data[:name]})" do
        context "when UPRN present" do
          let(:attributes) { setup_section_params.merge({ field_19: "100023336956", data[:field] => nil }) }

          it "can be blank" do
            expect(parser.errors[data[:field]]).to be_blank
          end
        end

        context "when UPRN not present" do
          let(:attributes) { setup_section_params.merge({ field_19: nil, data[:field] => nil }) }

          it "cannot be blank" do
            expect(parser.errors[data[:field]]).to be_present
          end
        end
      end
    end

    [
      %w[age1_known age1 field_30],
      %w[age2_known age2 field_38],
      %w[age3_known age3 field_47],
      %w[age4_known age4 field_51],
      %w[age5_known age5 field_55],
      %w[age6_known age6 field_59],
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
          let(:attributes) { setup_section_params.merge({ field.to_s => "R", field_28: "1", field_45: "5", field_29: "1" }) }

          it "sets ##{known} 1" do
            expect(parser.log.public_send(known)).to be(1)
          end

          it "sets ##{age} to nil" do
            expect(parser.log.public_send(age)).to be_nil
          end
        end

        context "when #{field} is a number" do
          let(:attributes) { setup_section_params.merge({ field.to_s => "50", field_28: "1", field_45: "5", field_29: "1" }) }

          it "sets ##{known} to 0" do
            expect(parser.log.public_send(known)).to be(0)
          end

          it "sets ##{age} to given age" do
            expect(parser.log.public_send(age)).to be(50)
          end
        end

        context "when #{field} is a non-sensical value" do
          let(:attributes) { setup_section_params.merge({ field.to_s => "A", field_28: "1", field_45: "5", field_29: "1" }) }

          it "sets ##{known} to 0" do
            expect(parser.log.public_send(known)).to be(0)
          end

          it "sets ##{age} to nil" do
            expect(parser.log.public_send(age)).to be_nil
          end
        end
      end
    end

    describe "#field_36" do # will buyer1 live in property?
      context "when not a possible value" do
        let(:attributes) { valid_attributes.merge({ field_36: "3" }) }

        it "is not valid" do
          expect(parser.errors).to include(:field_36)
        end
      end
    end
  end

  describe "#log" do
    describe "#uprn" do
      let(:attributes) { setup_section_params.merge({ field_19: "100023336956" }) }

      it "is correctly set" do
        expect(parser.log.uprn).to eql("100023336956")
      end
    end

    describe "#uprn_known" do
      context "when uprn known" do
        let(:attributes) { setup_section_params.merge({ field_19: "100023336956" }) }

        it "is correctly set" do
          expect(parser.log.uprn_known).to be(1)
        end
      end

      context "when uprn not known" do
        let(:attributes) { setup_section_params.merge({ field_19: nil }) }

        it "is correctly set" do
          expect(parser.log.uprn_known).to be(0)
        end
      end
    end

    describe "#address_line1" do
      let(:attributes) { setup_section_params.merge({ field_20: "some street" }) }

      it "is correctly set" do
        expect(parser.log.address_line1).to eql("some street")
      end
    end

    describe "#address_line2" do
      let(:attributes) { setup_section_params.merge({ field_21: "some other street" }) }

      it "is correctly set" do
        expect(parser.log.address_line2).to eql("some other street")
      end
    end

    describe "#town_or_city" do
      let(:attributes) { setup_section_params.merge({ field_22: "some town" }) }

      it "is correctly set" do
        expect(parser.log.town_or_city).to eql("some town")
      end
    end

    describe "#county" do
      let(:attributes) { setup_section_params.merge({ field_23: "some county" }) }

      it "is correctly set" do
        expect(parser.log.county).to eql("some county")
      end
    end

    describe "#ethnic_group2" do
      let(:attributes) { setup_section_params.merge({ field_40: "1" }) }

      it "is correctly set" do
        expect(parser.log.ethnic_group2).to be(0)
      end
    end

    describe "#ethnicbuy2" do
      let(:attributes) { setup_section_params.merge({ field_40: "1" }) }

      it "is correctly set" do
        expect(parser.log.ethnicbuy2).to be(1)
      end
    end

    describe "#nationalbuy2" do
      let(:attributes) { setup_section_params.merge({ field_41: "18" }) }

      it "is correctly set" do
        expect(parser.log.nationalbuy2).to be(18)
      end
    end

    describe "#buy2living" do
      let(:attributes) { setup_section_params.merge({ field_71: "1" }) }

      it "is correctly set" do
        expect(parser.log.buy2living).to be(1)
      end
    end

    describe "#prevtenbuy2" do
      let(:attributes) { setup_section_params.merge({ field_72: "R" }) }

      it "is correctly set" do
        expect(parser.log.prevtenbuy2).to be(0)
      end
    end

    describe "#hhregresstill" do
      let(:attributes) { setup_section_params.merge({ field_74: "4" }) }

      it "is correctly set" do
        expect(parser.log.hhregresstill).to be(4)
      end
    end

    describe "#prevshared" do
      let(:attributes) { setup_section_params.merge({ field_85: "3" }) }

      it "is correctly set" do
        expect(parser.log.prevshared).to be(3)
      end
    end

    describe "#staircasesale" do
      let(:attributes) { setup_section_params.merge({ field_90: "1" }) }

      it "is correctly set" do
        expect(parser.log.staircasesale).to be(1)
      end
    end

    describe "#soctenant" do
      let(:attributes) { setup_section_params.merge({ field_99: "1" }) }

      it "is correctly set" do
        expect(parser.log.soctenant).to be(1)
      end
    end

    describe "with living before purchase years for shared ownership more than 0" do
      let(:attributes) { setup_section_params.merge({ field_7: "1", field_86: "1" }) }

      it "is sets living before purchase asked to yes and sets the correct living before purchase years" do
        expect(parser.log.proplen_asked).to be(0)
        expect(parser.log.proplen).to be(1)
      end
    end

    describe "with living before purchase years for discounted ownership more than 0" do
      let(:attributes) { setup_section_params.merge({ field_7: "2", field_115: "1" }) }

      it "is sets living before purchase asked to yes and sets the correct living before purchase years" do
        expect(parser.log.proplen_asked).to be(0)
        expect(parser.log.proplen).to be(1)
      end
    end

    describe "with living before purchase years for shared ownership set to 0" do
      let(:attributes) { setup_section_params.merge({ field_7: "1", field_86: "0" }) }

      it "is sets living before purchase asked to no" do
        expect(parser.log.proplen_asked).to be(1)
        expect(parser.log.proplen).to be_nil
      end
    end

    describe "with living before purchase 0 years for discounted ownership set to 0" do
      let(:attributes) { setup_section_params.merge({ field_7: "2", field_115: "0" }) }

      it "is sets living before purchase asked to no" do
        expect(parser.log.proplen_asked).to be(1)
        expect(parser.log.proplen).to be_nil
      end
    end

    context "when mscharge is given, but is set to 0 for shared ownership" do
      let(:attributes) { valid_attributes.merge(field_114: "0") }

      it "does not override variables correctly" do
        log = parser.log
        expect(log["has_mscharge"]).to eq(0) # no
        expect(log["mscharge"]).to be_nil
      end
    end

    context "when mscharge is given, but is set to 0 for discounted ownership" do
      let(:attributes) { valid_attributes.merge(field_7: "2", field_126: "0") }

      it "does not override variables correctly" do
        log = parser.log
        expect(log["has_mscharge"]).to eq(0) # no
        expect(log["mscharge"]).to be_nil
      end
    end

    context "when mscharge is given, but is set to 0 for outright sale" do
      let(:attributes) { valid_attributes.merge(field_7: "3", field_135: "0") }

      it "does not override variables correctly" do
        log = parser.log
        expect(log["has_mscharge"]).to eq(0) # no
        expect(log["mscharge"]).to be_nil
      end
    end
  end
end
