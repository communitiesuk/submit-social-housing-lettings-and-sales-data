require "rails_helper"

RSpec.describe BulkUpload::Sales::Year2022::RowParser do
  subject(:parser) { described_class.new(attributes) }

  let(:now) { Time.zone.parse("01/03/2023") }

  let(:attributes) { { bulk_upload: } }
  let(:bulk_upload) { create(:bulk_upload, :sales, user:) }
  let(:user) { create(:user, organisation: owning_org) }

  let(:owning_org) { create(:organisation, :with_old_visible_id) }

  let(:setup_section_params) do
    {
      bulk_upload:,
      field_1: "test id", # purchase id
      field_92: owning_org.old_visible_id, # organisation
      field_93: user.email, # user
      field_2: now.day.to_s, # sale day
      field_3: now.month.to_s, # sale month
      field_4: now.strftime("%g"), # sale year
      field_113: "1", # owhershipsch
      field_57: "2", # shared ownership sale type
      field_116: "2", # joint purchase
      field_115: "1", # will the buyers live in the property
    }
  end

  let(:valid_attributes) do
    {
      bulk_upload:,
      field_1: "test id",
      field_2: "22",
      field_3: "2",
      field_4: "23",
      field_6: "1",
      field_7: "32",
      field_8: "32",
      field_13: "M",
      field_14: "F",
      field_19: "R",
      field_24: "1",
      field_25: "2",
      field_30: "12",
      field_31: "18",
      field_32: "30000",
      field_33: "15000",
      field_34: "1",
      field_35: "1",
      field_36: "20000",
      field_37: "3",
      field_39: "1",
      field_40: "E09000008",
      field_41: "A1",
      field_42: "1AA",
      field_43: "1",
      field_45: "1",
      field_46: "1",
      field_48: "3",
      field_49: "3",
      field_50: "2",
      field_51: "1",
      field_52: "1",
      field_53: "E09000008",
      field_54: "CR0",
      field_55: "4BB",
      field_56: "3",
      field_57: "2",
      field_58: "2",
      field_59: "23",
      field_60: "3",
      field_61: "22",
      field_62: "30",
      field_63: "3",
      field_64: "22",
      field_65: "3",
      field_66: "1",
      field_67: "1",
      field_68: "250000",
      field_69: "25",
      field_70: "42500",
      field_71: "3",
      field_72: "20000",
      field_74: "800",
      field_75: "200",
      field_92: owning_org.old_visible_id,
      field_95: "3",
      field_97: "5",
      field_98: "1",
      field_104: "4",
      field_105: "20",
      field_109: "2",
      field_110: "5",
      field_111: "1",
      field_112: "1",
      field_113: "1",
      field_115: "1",
      field_116: "1",
      field_117: "1",
      field_118: "1",
      field_119: "0",
      field_120: "10",
      field_121: "10",
      field_122: "1",
      field_123: "1",
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
          field_1: "test id",
        }
      end

      it "has errors on correct setup fields" do
        errors = parser.errors.select { |e| e.options[:category] == :setup }.map(&:attribute)

        expect(errors).to eql(%i[field_2 field_3 field_4 field_113 field_92])
      end
    end

    context "when setup section not complete and type is shared ownership" do
      let(:attributes) do
        {
          bulk_upload:,
          field_1: "test id",
          field_113: "1",
        }
      end

      it "has errors on correct setup fields" do
        errors = parser.errors.select { |e| e.options[:category] == :setup }.map(&:attribute)

        expect(errors).to eql(%i[field_2 field_3 field_4 field_57 field_116 field_92])
      end
    end

    context "when setup section not complete it's shared ownership joint purchase" do
      let(:attributes) do
        {
          bulk_upload:,
          field_1: "test id",
          field_113: "1",
          field_57: "2",
          field_116: "1",
        }
      end

      it "has errors on correct setup fields" do
        errors = parser.errors.select { |e| e.options[:category] == :setup }.map(&:attribute)

        expect(errors).to eql(%i[field_2 field_3 field_4 field_109 field_92])
      end
    end

    context "when setup section not complete and type is discounted ownership" do
      let(:attributes) do
        {
          bulk_upload:,
          field_1: "test id",
          field_113: "2",
        }
      end

      it "has errors on correct setup fields" do
        errors = parser.errors.select { |e| e.options[:category] == :setup }.map(&:attribute)

        expect(errors).to eql(%i[field_2 field_3 field_4 field_76 field_116 field_92])
      end
    end

    context "when setup section not complete it's discounted ownership joint purchase" do
      let(:attributes) do
        {
          bulk_upload:,
          field_1: "test id",
          field_113: "2",
          field_76: "8",
          field_116: "1",
        }
      end

      it "has errors on correct setup fields" do
        errors = parser.errors.select { |e| e.options[:category] == :setup }.map(&:attribute)

        expect(errors).to eql(%i[field_2 field_3 field_4 field_109 field_92])
      end
    end

    context "when setup section not complete and type is outright sale" do
      let(:attributes) do
        {
          bulk_upload:,
          field_1: "test id",
          field_113: "3",
        }
      end

      it "has errors on correct setup fields" do
        errors = parser.errors.select { |e| e.options[:category] == :setup }.map(&:attribute)

        expect(errors).to eql(%i[field_2 field_3 field_4 field_84 field_114 field_92])
      end
    end

    context "when setup section not complete outright sale buyer is not company" do
      let(:attributes) do
        {
          bulk_upload:,
          field_1: "test id",
          field_113: "3",
          field_84: "12",
          field_114: "2",
        }
      end

      it "has errors on correct setup fields" do
        errors = parser.errors.select { |e| e.options[:category] == :setup }.map(&:attribute)

        expect(errors).to eql(%i[field_2 field_3 field_4 field_115 field_116 field_92])
      end
    end

    describe "#field_92" do # owning org
      context "when no data given" do
        let(:attributes) { { bulk_upload:, field_92: "" } }

        it "is not permitted as setup error" do
          setup_errors = parser.errors.select { |e| e.options[:category] == :setup }

          expect(setup_errors.find { |e| e.attribute == :field_92 }.message).to eql("The owning organisation code is incorrect")
        end

        it "blocks log creation" do
          expect(parser).to be_block_log_creation
        end
      end

      context "when cannot find owning org" do
        let(:attributes) { { bulk_upload:, field_92: "donotexist" } }

        it "is not permitted as a setup error" do
          setup_errors = parser.errors.select { |e| e.options[:category] == :setup }

          expect(setup_errors.find { |e| e.attribute == :field_92 }.message).to eql("The owning organisation code is incorrect")
        end

        it "blocks log creation" do
          expect(parser).to be_block_log_creation
        end
      end

      context "when not affiliated with owning org" do
        let(:unaffiliated_org) { create(:organisation, :with_old_visible_id) }

        let(:attributes) { { bulk_upload:, field_92: unaffiliated_org.old_visible_id } }

        it "is not permitted as setup error" do
          setup_errors = parser.errors.select { |e| e.options[:category] == :setup }

          expect(setup_errors.find { |e| e.attribute == :field_92 }.message).to eql("You do not have permission to add logs for this owning organisation")
        end

        it "blocks log creation" do
          expect(parser).to be_block_log_creation
        end
      end
    end

    describe "#field_93" do # username for created_by
      context "when blank" do
        let(:attributes) { { bulk_upload:, field_93: "" } }

        it "is permitted" do
          expect(parser.errors[:field_93]).to be_blank
        end
      end

      context "when user could not be found" do
        let(:attributes) { { bulk_upload:, field_93: "idonotexist@example.com" } }

        it "is not permitted" do
          expect(parser.errors[:field_93]).to be_present
        end
      end

      context "when an unaffiliated user" do
        let(:other_user) { create(:user) }

        let(:attributes) { { bulk_upload:, field_92: owning_org.old_visible_id, field_93: other_user.email } }

        it "is not permitted" do
          expect(parser.errors[:field_93]).to be_present
        end

        it "blocks log creation" do
          expect(parser).to be_block_log_creation
        end
      end

      context "when an user part of owning org" do
        let(:other_user) { create(:user, organisation: owning_org) }

        let(:attributes) { { bulk_upload:, field_92: owning_org.old_visible_id, field_93: other_user.email } }

        it "is permitted" do
          expect(parser.errors[:field_93]).to be_blank
        end
      end
    end

    [
      %w[age1_known age1 field_7],
      %w[age2_known age2 field_8],
      %w[age3_known age3 field_9],
      %w[age4_known age4 field_10],
      %w[age5_known age5 field_11],
      %w[age6_known age6 field_12],
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
          let(:attributes) { setup_section_params.merge({ field.to_s => "R", field_6: "1", field_119: "5", field_112: "1" }) }

          it "sets ##{known} 1" do
            expect(parser.log.public_send(known)).to be(1)
          end

          it "sets ##{age} to nil" do
            expect(parser.log.public_send(age)).to be_nil
          end
        end

        context "when #{field} is a number" do
          let(:attributes) { setup_section_params.merge({ field.to_s => "50", field_6: "1", field_119: "5", field_112: "1" }) }

          it "sets ##{known} to 0" do
            expect(parser.log.public_send(known)).to be(0)
          end

          it "sets ##{age} to given age" do
            expect(parser.log.public_send(age)).to be(50)
          end
        end

        context "when #{field} is a non-sensical value" do
          let(:attributes) { setup_section_params.merge({ field.to_s => "A", field_6: "1", field_119: "5", field_112: "1" }) }

          it "sets ##{known} to 0" do
            expect(parser.log.public_send(known)).to be(0)
          end

          it "sets ##{age} to nil" do
            expect(parser.log.public_send(age)).to be_nil
          end
        end
      end
    end

    describe "#field_117" do
      context "when not a possible value" do
        let(:attributes) { valid_attributes.merge({ field_117: "3" }) }

        it "is not valid" do
          expect(parser.errors).to include(:field_117)
        end
      end
    end

    describe "fields 2, 3, 4 => saledate" do
      context "when all of these fields are blank" do
        let(:attributes) { setup_section_params.merge({ field_2: nil, field_3: nil, field_4: nil }) }

        it "returns them as setup errors" do
          setup_errors = parser.errors.select { |e| e.options[:category] == :setup }

          expect(setup_errors.find { |e| e.attribute == :field_2 }).to be_present
          expect(setup_errors.find { |e| e.attribute == :field_3 }).to be_present
          expect(setup_errors.find { |e| e.attribute == :field_4 }).to be_present
        end
      end

      context "when one of these fields is blank" do
        let(:attributes) { setup_section_params.merge({ field_2: "1", field_3: "1", field_4: nil }) }

        it "returns an error only on blank field" do
          expect(parser.errors[:field_2]).to be_blank
          expect(parser.errors[:field_3]).to be_blank
          expect(parser.errors[:field_4]).to be_present
        end
      end

      context "when field 4 is 4 digits instead of 2" do
        let(:attributes) { setup_section_params.merge({ bulk_upload:, field_4: "2022" }) }

        it "returns an error" do
          expect(parser.errors[:field_4]).to include("Sale completion year must be 2 digits")
        end
      end

      context "when invalid date given" do
        let(:attributes) { setup_section_params.merge({ field_2: "a", field_3: "12", field_4: "2022" }) }

        it "does not raise an error" do
          expect { parser.valid? }.not_to raise_error
        end
      end

      context "when inside of collection year" do
        let(:attributes) { setup_section_params.merge({ field_2: "1", field_3: "10", field_4: "22" }) }

        let(:bulk_upload) { create(:bulk_upload, :sales, user:, year: 2022) }

        it "does not return errors" do
          expect(parser.errors[:field_2]).not_to be_present
          expect(parser.errors[:field_3]).not_to be_present
          expect(parser.errors[:field_4]).not_to be_present
        end
      end

      context "when outside of collection year" do
        around do |example|
          Timecop.freeze(Date.new(2022, 4, 2)) do
            example.run
          end
          Timecop.return
        end

        let(:attributes) { setup_section_params.merge({ field_2: "1", field_3: "1", field_4: "22" }) }

        let(:bulk_upload) { create(:bulk_upload, :sales, user:, year: 2022) }

        it "returns errors" do
          expect(parser.errors[:field_2]).to be_present
          expect(parser.errors[:field_3]).to be_present
          expect(parser.errors[:field_4]).to be_present
        end
      end
    end
  end
end
