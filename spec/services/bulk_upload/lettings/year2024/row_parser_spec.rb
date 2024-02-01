require "rails_helper"

RSpec.describe BulkUpload::Lettings::Year2024::RowParser do
  subject(:parser) { described_class.new(attributes) }

  let(:now) { Time.zone.local(2024, 4, 5) }

  let(:attributes) { { bulk_upload: } }
  let(:bulk_upload) { create(:bulk_upload, :lettings, user:, needstype: nil, year: 2024) }
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
      field_7: "2",
      field_8: now.day.to_s,
      field_9: now.month.to_s,
      field_10: now.strftime("%g"),
      field_11: "0",
      field_15: "1",
    }
  end

  before do
    allow(FormHandler.instance).to receive(:lettings_in_crossover_period?).and_return(true)
    create(:organisation_relationship, parent_organisation: owning_org, child_organisation: managing_org)

    LaRentRange.create!(
      ranges_rent_id: "1",
      la: "E09000008",
      beds: 1,
      lettype: 7,
      soft_min: 12.41,
      soft_max: 118.85,
      hard_min: 9.87,
      hard_max: 200.99,
      start_year: 2024,
    )
  end

  around do |example|
    Timecop.freeze(Date.new(2024, 10, 1)) do
      FormHandler.instance.use_real_forms!
      example.run
    end
    Timecop.return
  end

  describe "#blank_row?" do
    context "when a new object" do
      it "returns true" do
        expect(parser).to be_blank_row
      end
    end

    context "when the only populated fields are whitespace" do
      before do
        parser.field_16 = " "
      end

      it "returns true" do
        expect(parser).to be_blank_row
      end
    end

    context "when any field is populated with something other than whitespace" do
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
      stub_request(:get, /api\.postcodes\.io/)
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
        let(:attributes) { { bulk_upload:, field_130: 2 } }

        it "does not add keep adding errors to the pile" do
          expect { parser.valid? }.not_to change(parser.errors, :count)
        end
      end

      context "when testing valid/invalid attributes" do
        let(:valid_attributes) do
          {
            bulk_upload:,
            field_13: "123",
            field_8: now.day.to_s,
            field_9: now.month.to_s,
            field_10: now.strftime("%g"),
            field_21: "EC1N",
            field_22: "2TD",
            field_1: owning_org.old_visible_id,
            field_2: managing_org.old_visible_id,
            field_11: "0",
            field_7: "2",
            field_26: "2",
            field_27: "1",
            field_28: "1",
            field_29: "1",
            field_36: "2",
            field_37: "1",
            field_38: "2",
            field_15: "1",

            field_42: "42",
            field_48: "41",
            field_52: "20",
            field_56: "18",
            field_60: "16",
            field_64: "14",
            field_68: "12",
            field_72: "20",

            field_43: "F",
            field_49: "M",
            field_53: "F",
            field_57: "M",
            field_61: "F",
            field_65: "M",
            field_69: "F",
            field_73: "M",

            field_44: "17",
            field_45: "18",

            field_47: "P",
            field_51: "C",
            field_55: "X",
            field_59: "R",
            field_63: "C",
            field_67: "C",
            field_71: "X",

            field_46: "1",
            field_50: "2",
            field_54: "6",
            field_58: "7",
            field_62: "8",
            field_66: "9",
            field_70: "0",
            field_74: "10",

            field_75: "1",
            field_76: "4",
            field_77: "1",

            field_78: "1",

            field_79: "1",
            field_80: "0",
            field_81: "0",
            field_82: "1",
            field_83: "0",

            field_85: "2",

            field_96: "11",
            field_97: "2",
            field_98: "31",
            field_100: "3",
            field_101: "11",

            field_102: "1",
            field_103: "EC1N",
            field_104: "2TD",

            field_106: "1",
            field_107: "1",
            field_108: "",
            field_109: "1",
            field_110: "",
            field_111: "",

            field_112: "1",
            field_113: "2",
            field_114: "2",

            field_116: "2",

            field_117: "1",
            field_118: "2300",
            field_119: "2",
            field_120: "1",
            field_121: "1",

            field_123: "4",
            field_125: "1234.56",
            field_126: "43.32",
            field_127: "13.14",
            field_128: "101.11",
            field_129: "1",
            field_130: "234.56",

            field_24: "15",
            field_30: now.day.to_s,
            field_31: now.month.to_s,
            field_32: now.strftime("%g"),

            field_4: "1",

            field_16: "12",
          }
        end

        context "when valid row" do
          before do
            allow(FeatureToggle).to receive(:bulk_upload_duplicate_log_check_enabled?).and_return(true)
          end

          let(:attributes) { valid_attributes }

          it "returns true" do
            expect(parser).to be_valid
          end

          xit "instantiates a log with everything completed", aggregate_failures: true do
            questions = parser.send(:questions).reject do |q|
              parser.send(:log).optional_fields.include?(q.id) || q.completed?(parser.send(:log))
            end

            expect(questions.map(&:id).size).to eq(0)
            expect(questions.map(&:id)).to eql([])
          end

          context "when a general needs log already exists in the db" do
            let(:attributes) do
              valid_attributes.merge({ field_4: "1",
                                       field_11: "0",
                                       field_1: owning_org.old_visible_id,
                                       field_123: 1,
                                       field_125: 250,
                                       field_126: 50,
                                       field_127: 50,
                                       field_128: 50,
                                       field_13: "tenant_code" })
            end

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
                :field_1, # owning_organisation
                :field_8, # startdate
                :field_9, # startdate
                :field_10, # startdate
                :field_13, # tenancycode
                :field_21, # postcode_full
                :field_22, # postcode_full
                :field_23, # postcode_full
                :field_42, # age1
                :field_43, # sex1
                :field_46, # ecstat1
                :field_125, # brent
                :field_126, # scharge
                :field_127, # pscharge
                :field_128, # supcharg
              ].each do |field|
                expect(parser.errors[field]).to include(error_message)
              end

              expect(parser.errors[:field_6]).not_to include(error_message)
            end
          end

          context "when a general needs log already exists in the db but has a different tcharge" do
            let(:attributes) do
              valid_attributes.merge({ field_4: "1",
                                       field_11: "0",
                                       field_1: owning_org.old_visible_id,
                                       field_123: 1,
                                       field_125: 250,
                                       field_126: 50,
                                       field_127: 50,
                                       field_128: 50,
                                       field_13: "tenant_code" })
            end

            before do
              parser.log.save!
              saved_log = LettingsLog.find_by(tenancycode: "tenant_code")
              saved_log.update!(brent: saved_log.brent + 5)
              parser.instance_variable_set(:@valid, nil)
            end

            it "is not a valid row" do
              expect(parser).not_to be_valid
            end

            it "adds an error to all (and only) the fields used to determine duplicates" do
              parser.valid?

              error_message = "This is a duplicate log"

              [
                :field_1, # owning_organisation
                :field_8, # startdate
                :field_9, # startdate
                :field_10, # startdate
                :field_13, # tenancycode
                :field_21, # postcode_full
                :field_22, # postcode_full
                :field_23, # postcode_full
                :field_42, # age1
                :field_43, # sex1
                :field_46, # ecstat1
                :field_125, # brent
                :field_126, # scharge
                :field_127, # pscharge
                :field_128, # supcharg
              ].each do |field|
                expect(parser.errors[field]).not_to include(error_message)
              end
            end
          end

          context "when a supported housing log already exists in the db" do
            let(:attributes) { { bulk_upload:, field_4: "2" } }

            before do
              parser.log.save!
              parser.instance_variable_set(:@valid, nil)
            end

            it "is not a valid row" do
              expect(parser).not_to be_valid
            end

            it "adds an error to all the fields used to determine duplicates" do
              parser.valid?

              error_message = "This is a duplicate log"

              [
                :field_1, # owning_organisation
                :field_8, # startdate
                :field_9, # startdate
                :field_10, # startdate
                :field_13, # tenancycode
                :field_6, # location
                :field_42, # age1
                :field_43, # sex1
                :field_46, # ecstat1
                :field_125, # brent
                :field_126, # scharge
                :field_127, # pscharge
                :field_128, # supcharg
              ].each do |field|
                expect(parser.errors[field]).to include(error_message)
              end

              expect(parser.errors[:field_21]).not_to include(error_message)
              expect(parser.errors[:field_22]).not_to include(error_message)
              expect(parser.errors[:field_23]).not_to include(error_message)
            end
          end

          context "with old core scheme and location ids" do
            context "when a supported housing log already exists in the db" do
              let(:attributes) { { bulk_upload:, field_4: "2", field_5: "123" } }

              before do
                parser.log.save!
                parser.instance_variable_set(:@valid, nil)
              end

              it "is not a valid row" do
                expect(parser).not_to be_valid
              end

              it "adds an error to all the fields used to determine duplicates" do
                parser.valid?

                error_message = "This is a duplicate log"

                [
                  :field_1, # owning_organisation
                  :field_8, # startdate
                  :field_9, # startdate
                  :field_10, # startdate
                  :field_13, # tenancycode
                  :field_6, # location
                  :field_42, # age1
                  :field_43, # sex1
                  :field_46, # ecstat1
                  :field_125, # brent
                  :field_126, # scharge
                  :field_127, # pscharge
                  :field_128, # supcharg
                ].each do |field|
                  expect(parser.errors[field]).to include(error_message)
                end

                expect(parser.errors[:field_21]).not_to include(error_message)
                expect(parser.errors[:field_22]).not_to include(error_message)
                expect(parser.errors[:field_23]).not_to include(error_message)
              end
            end

            context "when a supported housing log with chcharges already exists in the db" do
              let(:bulk_upload) { create(:bulk_upload, :lettings, user:, needstype: 2) }
              let(:attributes) do
                valid_attributes.merge({ field_5: "S#{scheme.id}",
                                         field_4: "2",
                                         field_11: "1",
                                         field_6: location.old_visible_id,
                                         field_1: owning_org.old_visible_id,
                                         field_122: 0,
                                         field_41: 4,
                                         field_124: "88" })
              end

              before do
                parser.log.save!
                parser.instance_variable_set(:@valid, nil)
              end

              it "is not a valid row" do
                expect(parser).not_to be_valid
              end

              it "adds an error to all the fields used to determine duplicates" do
                parser.valid?

                error_message = "This is a duplicate log"

                [
                  :field_1, # owning_organisation
                  :field_8, # startdate
                  :field_9, # startdate
                  :field_10, # startdate
                  :field_13, # tenancycode
                  :field_6, # location
                  :field_42, # age1
                  :field_43, # sex1
                  :field_46, # ecstat1
                  :field_124, # chcharge
                  :field_122, # household_charge
                ].each do |field|
                  expect(parser.errors[field]).to include(error_message)
                end

                expect(parser.errors[:field_21]).not_to include(error_message)
                expect(parser.errors[:field_22]).not_to include(error_message)
                expect(parser.errors[:field_23]).not_to include(error_message)
              end
            end

            context "when a supported housing log different chcharges already exists in the db" do
              let(:bulk_upload) { create(:bulk_upload, :lettings, user:, needstype: 2) }
              let(:attributes) do
                valid_attributes.merge({ field_5: "S#{scheme.id}",
                                         field_4: "2",
                                         field_11: "1",
                                         field_6: location.old_visible_id,
                                         field_1: owning_org.old_visible_id,
                                         field_122: 0,
                                         field_41: 4,
                                         field_124: "88" })
              end
              let(:attributes_too) do
                valid_attributes.merge({ field_5: "S#{scheme.id}",
                                         field_4: "2",
                                         field_11: "1",
                                         field_6: location.old_visible_id,
                                         field_1: owning_org.old_visible_id,
                                         field_122: 0,
                                         field_41: 4,
                                         field_124: "98" })
              end
              let(:parser_too) { described_class.new(attributes_too) }

              before do
                parser.log.save!
                parser.instance_variable_set(:@valid, nil)
              end

              it "is a valid row" do
                expect(parser_too).to be_valid
              end

              it "does not add an error to all the fields used to determine duplicates" do
                parser_too.valid?

                error_message = "This is a duplicate log"

                [
                  :field_1, # owning_organisation
                  :field_8, # startdate
                  :field_9, # startdate
                  :field_10, # startdate
                  :field_13, # tenancycode
                  :field_5, # location
                  :field_42, # age1
                  :field_43, # sex1
                  :field_46, # ecstat1
                ].each do |field|
                  expect(parser_too.errors[field]).not_to include(error_message)
                end
              end
            end
          end

          context "with new core scheme and location ids" do
            context "when a supported housing log already exists in the db" do
              let(:attributes) { { bulk_upload:, field_4: "2", field_5: "S123" } }

              before do
                parser.log.save!
                parser.instance_variable_set(:@valid, nil)
              end

              it "is not a valid row" do
                expect(parser).not_to be_valid
              end

              it "adds an error to all the fields used to determine duplicates" do
                parser.valid?

                error_message = "This is a duplicate log"

                [
                  :field_1, # owning_organisation
                  :field_8, # startdate
                  :field_9, # startdate
                  :field_10, # startdate
                  :field_13, # tenancycode
                  :field_6, # location
                  :field_42, # age1
                  :field_43, # sex1
                  :field_46, # ecstat1
                ].each do |field|
                  expect(parser.errors[field]).to include(error_message)
                end

                expect(parser.errors[:field_21]).not_to include(error_message)
                expect(parser.errors[:field_22]).not_to include(error_message)
                expect(parser.errors[:field_23]).not_to include(error_message)
              end
            end

            context "when a supported housing log with chcharges already exists in the db" do
              let(:bulk_upload) { create(:bulk_upload, :lettings, user:, needstype: 2) }
              let(:attributes) do
                valid_attributes.merge({ field_5: "S#{scheme.id}",
                                         field_4: "2",
                                         field_11: "1",
                                         field_6: location.id,
                                         field_1: owning_org.old_visible_id,
                                         field_122: 0,
                                         field_41: 4,
                                         field_124: "88" })
              end

              before do
                parser.log.save!
                parser.instance_variable_set(:@valid, nil)
              end

              it "is not a valid row" do
                expect(parser).not_to be_valid
              end

              it "adds an error to all the fields used to determine duplicates" do
                parser.valid?

                error_message = "This is a duplicate log"

                [
                  :field_1, # owning_organisation
                  :field_8, # startdate
                  :field_9, # startdate
                  :field_10, # startdate
                  :field_13, # tenancycode
                  :field_6, # location
                  :field_42, # age1
                  :field_43, # sex1
                  :field_46, # ecstat1
                  :field_124, # chcharge
                  :field_122, # household_charge
                ].each do |field|
                  expect(parser.errors[field]).to include(error_message)
                end

                expect(parser.errors[:field_21]).not_to include(error_message)
                expect(parser.errors[:field_22]).not_to include(error_message)
                expect(parser.errors[:field_23]).not_to include(error_message)
              end
            end

            context "when a supported housing log different chcharges already exists in the db" do
              let(:bulk_upload) { create(:bulk_upload, :lettings, user:, needstype: 2) }
              let(:attributes) do
                valid_attributes.merge({ field_5: "S#{scheme.id}",
                                         field_4: "2",
                                         field_11: "1",
                                         field_6: location.id,
                                         field_1: owning_org.old_visible_id,
                                         field_122: 0,
                                         field_41: 4,
                                         field_124: "88" })
              end
              let(:attributes_too) do
                valid_attributes.merge({ field_5: "S#{scheme.id}",
                                         field_4: "2",
                                         field_11: "1",
                                         field_6: location.id,
                                         field_1: owning_org.old_visible_id,
                                         field_122: 0,
                                         field_41: 4,
                                         field_124: "98" })
              end
              let(:parser_too) { described_class.new(attributes_too) }

              before do
                parser.log.save!
                parser.instance_variable_set(:@valid, nil)
              end

              it "is a valid row" do
                expect(parser_too).to be_valid
              end

              it "does not add an error to all the fields used to determine duplicates" do
                parser_too.valid?

                error_message = "This is a duplicate log"

                [
                  :field_1, # owning_organisation
                  :field_8, # startdate
                  :field_9, # startdate
                  :field_10, # startdate
                  :field_13, # tenancycode
                  :field_6, # location
                  :field_42, # age1
                  :field_43, # sex1
                  :field_46, # ecstat1
                  :field_125, # brent
                  :field_126, # scharge
                  :field_127, # pscharge
                  :field_128, # supcharg
                ].each do |field|
                  expect(parser_too.errors[field]).not_to include(error_message)
                end
              end
            end
          end

          context "when the rent range validation is triggered but the log has no scheme or location id" do
            let(:attributes) do
              setup_section_params.merge({ field_5: nil,
                                           field_6: nil,
                                           field_125: 300,
                                           field_123: 1,
                                           field_29: 1,
                                           field_4: 1,
                                           field_11: "1",
                                           field_23: "E09000008" })
            end

            it "is not a valid row" do
              expect(parser).not_to be_valid
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
                :field_1, # owning_organisation
                :field_8, # startdate
                :field_9, # startdate
                :field_10, # startdate
                :field_6, # location
                :field_21, # postcode_full
                :field_22, # postcode_full
                :field_23, # postcode_full
                :field_42, # age1
                :field_43, # sex1
                :field_46, # ecstat1
              ].each do |field|
                expect(parser.errors[field]).to be_blank
              end
            end
          end
        end

        context "when valid row with valid decimal (integer) field_11" do
          before do
            allow(FeatureToggle).to receive(:bulk_upload_duplicate_log_check_enabled?).and_return(true)
          end

          let(:attributes) { valid_attributes.merge(field_11: "0.00") }

          it "returns true" do
            expect(parser).to be_valid
          end
        end

        context "when valid row with invalid decimal (non-integer) field_11" do
          before do
            allow(FeatureToggle).to receive(:bulk_upload_duplicate_log_check_enabled?).and_return(true)
          end

          let(:attributes) { valid_attributes.merge(field_11: "0.56") }

          it "returns false" do
            expect(parser).not_to be_valid
          end
        end
      end

      describe "#validate_nulls" do
        context "when non-setup questions are null" do
          let(:attributes) { setup_section_params.merge({ field_16: "", field_17: "", field_19: "" }) }

          it "fetches the question's check_answer_label if it exists, otherwise it gets the question's header" do
            parser.valid?
            expect(parser.errors[:field_17]).to eql(["You must answer address line 1"])
            expect(parser.errors[:field_19]).to eql(["You must answer town or city"])
          end
        end
      end
    end

    context "when setup section not complete" do
      let(:attributes) { { bulk_upload:, field_13: "123" } }

      it "has errors on setup fields" do
        errors = parser.errors.select { |e| e.options[:category] == :setup }.map(&:attribute).sort

        expect(errors).to eql(%i[field_1 field_10 field_11 field_15 field_2 field_4 field_7 field_8 field_9])
      end
    end

    describe "#field_3" do # created_by
      context "when blank" do
        let(:attributes) { { bulk_upload:, field_3: "", field_4: 1 } }

        it "is permitted" do
          expect(parser.errors[:field_3]).to be_blank
        end
      end

      context "when user could not be found" do
        let(:attributes) { { bulk_upload:, field_3: "idonotexist@example.com" } }

        it "is not permitted" do
          expect(parser.errors[:field_3]).to be_present
        end
      end

      context "when an unaffiliated user" do
        let(:other_user) { create(:user) }

        let(:attributes) { { bulk_upload:, field_1: owning_org.old_visible_id, field_3: other_user.email, field_2: managing_org.old_visible_id } }

        it "is not permitted" do
          expect(parser.errors[:field_3]).to be_present
        end

        it "blocks log creation" do
          expect(parser).to be_block_log_creation
        end
      end

      context "when an user part of owning org" do
        let(:other_user) { create(:user, organisation: owning_org) }

        let(:attributes) { { bulk_upload:, field_1: owning_org.old_visible_id, field_3: other_user.email, field_2: managing_org.old_visible_id } }

        it "is permitted" do
          expect(parser.errors[:field_3]).to be_blank
        end
      end

      context "when email matches other than casing" do
        let(:other_user) { create(:user, organisation: owning_org) }

        let(:attributes) { { bulk_upload:, field_1: owning_org.old_visible_id, field_3: other_user.email.upcase!, field_2: managing_org.old_visible_id } }

        it "is permitted" do
          expect(parser.errors[:field_3]).to be_blank
        end
      end

      context "when an user part of managing org" do
        let(:other_user) { create(:user, organisation: managing_org) }

        let(:attributes) { { bulk_upload:, field_1: owning_org.old_visible_id, field_3: other_user.email, field_2: managing_org.old_visible_id } }

        it "is permitted" do
          expect(parser.errors[:field_3]).to be_blank
        end
      end
    end

    describe "#field_5, field_6" do # scheme and location fields
      context "when nullable not permitted" do
        let(:attributes) { { bulk_upload:, field_4: "2", field_11: "1", field_5: nil, field_6: nil } }

        it "cannot be nulled" do
          expect(parser.errors[:field_5]).to eq(["You must answer scheme code"])
          expect(parser.errors[:field_6]).to eq(["You must answer location code"])
        end
      end

      context "when nullable permitted" do
        let(:attributes) { { bulk_upload:, field_4: "1", field_11: "0", field_5: nil, field_6: nil } }

        it "can be nulled" do
          expect(parser.errors[:field_5]).to be_blank
          expect(parser.errors[:field_6]).to be_blank
        end
      end

      context "when using New CORE ids" do
        let(:scheme) { create(:scheme, :with_old_visible_id, owning_organisation: owning_org) }
        let!(:location) { create(:location, :with_old_visible_id, scheme:) }

        before do
          parser.valid?
        end

        context "when matching scheme cannot be found" do
          let(:attributes) { { bulk_upload:, field_1: owning_org.old_visible_id, field_2: owning_org.old_visible_id, field_4: "2", field_11: "1", field_5: "S123", field_6: location.id } }

          it "returns a setup error" do
            expect(parser.errors.where(:field_5, category: :setup).map(&:message)).to eq(["This scheme code does not belong to the owning organisation or managing organisation"])
            expect(parser.errors[:field_6]).to be_blank
          end
        end

        context "when missing location" do
          let(:attributes) { { bulk_upload:, field_1: owning_org.old_visible_id, field_2: owning_org.old_visible_id, field_4: "2", field_11: "1", field_5: "S#{scheme.id}", field_6: nil } }

          it "returns a setup error" do
            expect(parser.errors[:field_5]).to be_blank
            expect(parser.errors.where(:field_6, category: :setup).map(&:message)).to eq(["You must answer location code"])
            expect(parser.errors[:field_6].count).to eq(1)
          end
        end

        context "when matching location cannot be found" do
          let(:attributes) { { bulk_upload:, field_1: owning_org.old_visible_id, field_2: owning_org.old_visible_id, field_4: "2", field_11: "1", field_5: "S#{scheme.id}", field_6: "123" } }

          it "returns a setup error" do
            expect(parser.errors[:field_5]).to be_blank
            expect(parser.errors.where(:field_6, category: :setup).map(&:message)).to eq(["Location code must relate to a location that is owned by the owning organisation or managing organisation"])
          end
        end

        context "when matching location exists" do
          let(:attributes) { { bulk_upload:, field_1: owning_org.old_visible_id, field_2: owning_org.old_visible_id, field_4: "2", field_11: "1", field_5: "S#{scheme.id}", field_6: location.id } }

          it "does not return an error" do
            expect(parser.errors[:field_5]).to be_blank
            expect(parser.errors[:field_6]).to be_blank
          end
        end

        context "when location exists but not related" do
          let(:other_scheme) { create(:scheme, :with_old_visible_id) }
          let(:other_location) { create(:location, :with_old_visible_id, scheme: other_scheme) }
          let(:attributes) { { bulk_upload:, field_1: owning_org.old_visible_id, field_2: owning_org.old_visible_id, field_4: "2", field_11: "1", field_5: "S#{scheme.id}", field_6: other_location.id } }

          it "returns a setup error" do
            expect(parser.errors[:field_5]).to be_blank
            expect(parser.errors.where(:field_6, category: :setup).map(&:message)).to eq(["Location code must relate to a location that is owned by the owning organisation or managing organisation"])
          end
        end

        context "when scheme belongs to someone else" do
          let(:other_scheme) { create(:scheme, :with_old_visible_id) }
          let(:other_location) { create(:location, :with_old_visible_id, scheme: other_scheme) }
          let(:attributes) { { bulk_upload:, field_4: "2", field_11: "1", field_5: "S#{other_scheme.id}", field_6: other_location.id, field_1: owning_org.old_visible_id, field_2: owning_org.old_visible_id } }

          it "returns a setup error" do
            expect(parser.errors.where(:field_5, category: :setup).map(&:message)).to eq(["This scheme code does not belong to the owning organisation or managing organisation"])
            expect(parser.errors[:field_6]).to be_blank
          end
        end

        context "when scheme belongs to owning org" do
          let(:attributes) { { bulk_upload:, field_4: "2", field_11: "1", field_5: "S#{scheme.id}", field_6: location.id, field_1: owning_org.old_visible_id, field_2: owning_org.old_visible_id } }

          it "does not return an error" do
            expect(parser.errors[:field_5]).to be_blank
            expect(parser.errors[:field_6]).to be_blank
          end
        end

        context "when scheme belongs to managing org" do
          let(:managing_org_scheme) { create(:scheme, :with_old_visible_id, owning_organisation: managing_org) }
          let(:managing_org_location) { create(:location, :with_old_visible_id, scheme: managing_org_scheme) }
          let(:attributes) { { bulk_upload:, field_4: "2", field_11: "1", field_5: "S#{managing_org_scheme.id}", field_6: managing_org_location.id, field_2: managing_org.old_visible_id } }

          it "clears the scheme answer" do
            expect(parser.errors[:field_5]).to include("You must answer scheme name")
            expect(parser.errors[:field_6]).to be_blank
          end
        end

        context "when matching location exists but is incomplete" do
          let(:incomplete_location) { create(:location, :with_old_visible_id, :incomplete, scheme:) }
          let(:attributes) { { bulk_upload:, field_1: owning_org.old_visible_id, field_2: owning_org.old_visible_id, field_4: "2", field_11: "1", field_5: "S#{scheme.id}", field_6: incomplete_location.id } }

          it "returns a setup error for scheme" do
            expect(parser.errors.where(:field_5).map(&:message)).to eq(["This location is incomplete. Select another location or update this one"])
            expect(parser.errors.where(:field_6).map(&:message)).to eq(["This location is incomplete. Select another location or update this one"])
          end
        end
      end
    end

    describe "#field_98" do # leaving reason
      context "when field_7 is 1 meaning it is a renewal" do
        context "when field_98 is 40" do
          let(:attributes) { { bulk_upload:, field_98: "40", field_7: "1" } }

          it "is permitted" do
            expect(parser.errors[:field_98]).to be_blank
          end
        end

        context "when field_98 is 42" do
          let(:attributes) { { bulk_upload:, field_98: "42", field_7: "1" } }

          it "is permitted" do
            expect(parser.errors[:field_98]).to be_blank
          end
        end

        context "when field_98 is not 40 or 42" do
          let(:attributes) { { bulk_upload:, field_98: "1", field_7: "1" } }

          it "is not permitted" do
            expect(parser.errors[:field_98]).to be_present
          end
        end
      end

      context "when no longer a valid option from previous year" do
        let(:attributes) { setup_section_params.merge({ field_98: "7" }) }

        it "returns an error" do
          expect(parser.errors[:field_98]).to include("Enter a valid value for What is the tenant’s main reason for the household leaving their last settled home?")
        end
      end
    end

    describe "#field_79, #field_80, #field_81" do
      context "when one item selected" do
        let(:attributes) { { bulk_upload:, field_79: "1" } }

        it "is permitted" do
          expect(parser.errors[:field_79]).to be_blank
          expect(parser.errors[:field_80]).to be_blank
          expect(parser.errors[:field_81]).to be_blank
        end
      end

      context "when more than one item selected" do
        let(:attributes) { { bulk_upload:, field_79: "1", field_80: "1" } }

        it "is not permitted" do
          expect(parser.errors[:field_79]).to be_present
          expect(parser.errors[:field_80]).to be_present
        end
      end
    end

    describe "#field_83" do
      context "when 1 and another disability field selected" do
        let(:attributes) { { bulk_upload:, field_83: "1", field_82: "1" } }

        it "is not permitted" do
          expect(parser.errors[:field_83]).to be_present
        end
      end
    end

    describe "#field_84" do
      context "when 1 and another disability field selected" do
        let(:attributes) { { bulk_upload:, field_84: "1", field_82: "1" } }

        it "is not permitted" do
          expect(parser.errors[:field_84]).to be_present
        end
      end
    end

    describe "#field_83, #field_84" do
      context "when both 1" do
        let(:attributes) { { bulk_upload:, field_83: "1", field_84: "1" } }

        it "is not permitted" do
          expect(parser.errors[:field_83]).to be_present
          expect(parser.errors[:field_84]).to be_present
        end
      end
    end

    describe "#field_79 - #field_84" do
      context "when all blank" do
        let(:attributes) { setup_section_params.merge({ field_79: nil, field_80: nil, field_81: nil, field_82: nil, field_83: nil, field_84: nil }) }

        it "adds errors to correct fields" do
          expect(parser.errors[:field_79]).to be_present
          expect(parser.errors[:field_80]).to be_present
          expect(parser.errors[:field_81]).to be_present
          expect(parser.errors[:field_82]).to be_present
          expect(parser.errors[:field_83]).to be_present
        end
      end

      context "when one item selected and field_82 is blank" do
        let(:attributes) { setup_section_params.merge({ field_79: "1", field_82: nil }) }

        it "sets other disabled access needs as no" do
          expect(parser.errors[:field_79]).to be_blank
          expect(parser.errors[:field_82]).to be_blank
          expect(parser.log.housingneeds_other).to eq(0)
        end
      end
    end

    describe "#field_85, field_94 - 99" do
      context "when no illness but illnesses answered" do
        let(:attributes) { { bulk_upload:, field_85: "2", field_86: "1", field_87: "1", field_88: "1" } }

        it "errors added to correct fields" do
          expect(parser.errors[:field_86]).to be_present
          expect(parser.errors[:field_87]).to be_present
          expect(parser.errors[:field_88]).to be_present
          expect(parser.errors[:field_89]).not_to be_present
          expect(parser.errors[:field_90]).not_to be_present
          expect(parser.errors[:field_91]).not_to be_present
          expect(parser.errors[:field_92]).not_to be_present
          expect(parser.errors[:field_93]).not_to be_present
          expect(parser.errors[:field_94]).not_to be_present
          expect(parser.errors[:field_95]).not_to be_present
        end
      end

      context "when illness but no illnesses answered" do
        let(:attributes) { { bulk_upload:, field_85: "1", field_86: nil, field_87: nil, field_88: nil, field_89: nil, field_90: nil, field_91: nil, field_92: nil, field_93: nil, field_94: nil, field_95: nil } }

        it "errors added to correct fields" do
          expect(parser.errors[:field_86]).to be_present
          expect(parser.errors[:field_87]).to be_present
          expect(parser.errors[:field_88]).to be_present
          expect(parser.errors[:field_89]).to be_present
          expect(parser.errors[:field_90]).to be_present
          expect(parser.errors[:field_91]).to be_present
          expect(parser.errors[:field_92]).to be_present
          expect(parser.errors[:field_93]).to be_present
          expect(parser.errors[:field_94]).to be_present
          expect(parser.errors[:field_95]).to be_present
        end
      end
    end

    describe "#field_112, 117, 118" do
      context "when none of field_112, 117, 118 are given" do
        let(:attributes) { { bulk_upload:, field_112: "", field_113: "", field_114: "", field_85: "1" } }

        it "sets correct errors" do
          expect(parser.errors[:field_112]).to include("You must answer was the letting made under the Choice-Based Lettings (CBL)?")
          expect(parser.errors[:field_113]).to include("You must answer was the letting made under the Common Allocation Policy (CAP)?")
          expect(parser.errors[:field_114]).to include("You must answer was the letting made under the Common Housing Register (CHR)?")
        end
      end
    end

    describe "#field_101, field_106 - 15" do
      context "when there is a reasonable preference but none is given" do
        let(:attributes) { { bulk_upload:, field_106: "1", field_107: nil, field_108: nil, field_109: nil, field_110: nil, field_111: nil } }

        it "is not permitted" do
          expect(parser.errors[:field_107]).to be_present
          expect(parser.errors[:field_108]).to be_present
          expect(parser.errors[:field_109]).to be_present
          expect(parser.errors[:field_110]).to be_present
          expect(parser.errors[:field_111]).to be_present
        end
      end
    end

    describe "#field_116" do # referral
      context "when 3 ie PRP nominated by LA and owning org is LA" do
        let(:attributes) { { bulk_upload:, field_116: "3", field_1: owning_org.old_visible_id, field_2: owning_org.old_visible_id } }

        it "is not permitted" do
          expect(parser.errors[:field_116]).to be_present
        end
      end

      context "when 4 ie referred by LA and is general needs and owning org is LA" do
        let(:attributes) { { bulk_upload:, field_116: "4", field_1: owning_org.old_visible_id, field_2: owning_org.old_visible_id, field_4: "1" } }

        it "is not permitted" do
          expect(parser.errors[:field_116]).to be_present
        end
      end

      context "when 4 ie referred by LA and is general needs and owning org is PRP" do
        let(:owning_org) { create(:organisation, :prp, :with_old_visible_id) }

        let(:attributes) { { bulk_upload:, field_116: "4", field_1: owning_org.old_visible_id, field_2: owning_org.old_visible_id } }

        it "is permitted" do
          expect(parser.errors[:field_116]).to be_blank
        end
      end

      context "when 4 ie referred by LA and is not general needs" do
        let(:bulk_upload) { create(:bulk_upload, :lettings, user:) }
        let(:attributes) { { bulk_upload:, field_116: "4", field_4: "2" } }

        it "is permitted" do
          expect(parser.errors[:field_116]).to be_blank
        end
      end
    end

    describe "fields 7, 8, 9 => startdate" do
      context "when any one of these fields is blank" do
        let(:attributes) { { bulk_upload:, field_11: "0", field_8: nil, field_9: nil, field_10: nil } }

        it "returns an error" do
          expect(parser.errors[:field_8]).to be_present
          expect(parser.errors[:field_9]).to be_present
          expect(parser.errors[:field_10]).to be_present
        end
      end

      context "when field_10 is 4 digits instead of 2" do
        let(:attributes) { { bulk_upload:, field_10: "2023" } }

        it "returns an error" do
          expect(parser.errors[:field_10]).to include("Tenancy start year must be 2 digits")
        end
      end

      context "when invalid date given" do
        let(:attributes) { { bulk_upload:, field_11: "0", field_8: "a", field_9: "12", field_10: "23" } }

        it "does not raise an error" do
          expect { parser.valid? }.not_to raise_error
        end
      end

      context "when inside of collection year" do
        let(:attributes) { { bulk_upload:, field_8: "1", field_9: "10", field_10: "23" } }

        let(:bulk_upload) { create(:bulk_upload, :lettings, user:, year: 2022) }

        it "does not return errors" do
          expect(parser.errors[:field_8]).not_to be_present
          expect(parser.errors[:field_9]).not_to be_present
          expect(parser.errors[:field_10]).not_to be_present
        end
      end

      context "when outside of collection year" do
        around do |example|
          Timecop.freeze(Date.new(2023, 4, 2)) do
            example.run
          end
        end

        let(:attributes) { { bulk_upload:, field_8: "1", field_9: "1", field_10: "23" } }

        let(:bulk_upload) { create(:bulk_upload, :lettings, user:, year: 2023) }

        it "returns setup errors" do
          expect(parser.errors.where(:field_8, category: :setup)).to be_present
          expect(parser.errors.where(:field_9, category: :setup)).to be_present
          expect(parser.errors.where(:field_10, category: :setup)).to be_present
        end
      end
    end

    describe "#field_1" do # owning org
      context "when blank" do
        let(:attributes) { { bulk_upload:, field_1: "", field_4: 1 } }

        it "is not permitted as setup error" do
          expect(parser.errors.where(:field_1, category: :setup).map(&:message)).to eql(["You must answer owning organisation"])
        end

        it "blocks log creation" do
          expect(parser).to be_block_log_creation
        end
      end

      context "when cannot find owning org" do
        let(:attributes) { { bulk_upload:, field_1: "donotexist" } }

        it "is not permitted as setup error" do
          setup_errors = parser.errors.select { |e| e.options[:category] == :setup }

          expect(setup_errors.find { |e| e.attribute == :field_1 }.message).to eql("The owning organisation code is incorrect")
        end

        it "blocks log creation" do
          expect(parser).to be_block_log_creation
        end
      end

      context "when org is not stock owning" do
        let(:owning_org) { create(:organisation, :with_old_visible_id, :does_not_own_stock) }

        let(:attributes) { { bulk_upload:, field_1: owning_org.old_visible_id, field_2: owning_org.old_visible_id } }

        it "is not permitted as setup error" do
          setup_errors = parser.errors.select { |e| e.options[:category] == :setup }

          expect(setup_errors.find { |e| e.attribute == :field_1 }.message).to eql("The owning organisation code provided is for an organisation that does not own stock")
        end

        it "blocks log creation" do
          expect(parser).to be_block_log_creation
        end
      end

      context "when not affiliated with owning org" do
        let(:unaffiliated_org) { create(:organisation, :with_old_visible_id) }

        let(:attributes) { { bulk_upload:, field_1: unaffiliated_org.old_visible_id } }

        it "is not permitted as setup error" do
          setup_errors = parser.errors.select { |e| e.options[:category] == :setup }

          expect(setup_errors.find { |e| e.attribute == :field_1 }.message).to eql("You do not have permission to add logs for this owning organisation")
        end

        it "blocks log creation" do
          expect(parser).to be_block_log_creation
        end
      end

      context "when user's org has absorbed owning organisation" do
        let(:merged_org) { create(:organisation, :with_old_visible_id, holds_own_stock: true) }
        let(:merged_org_stock_owner) { create(:organisation, :with_old_visible_id, holds_own_stock: true) }

        let(:attributes) { { bulk_upload:, field_1: merged_org_stock_owner.old_visible_id, field_2: merged_org.old_visible_id, field_3: user.email } }

        before do
          create(:organisation_relationship, parent_organisation: merged_org_stock_owner, child_organisation: merged_org)
          merged_org.update!(absorbing_organisation: user.organisation, merge_date: Time.zone.today)
          merged_org.reload
          user.organisation.reload
        end

        it "is permitted" do
          parser = described_class.new(attributes)

          parser.valid?
          expect(parser.errors.where(:field_1)).not_to be_present
          expect(parser.errors.where(:field_3)).not_to be_present
        end
      end

      context "when user's org has absorbed owning organisation before the startdate" do
        let(:merged_org) { create(:organisation, :with_old_visible_id, holds_own_stock: true) }

        let(:attributes) { setup_section_params.merge({ field_1: merged_org.old_visible_id, field_2: merged_org.old_visible_id, field_3: user.email }) }

        before do
          merged_org.update!(absorbing_organisation: user.organisation, merge_date: Time.zone.today - 5.years)
          merged_org.reload
          user.organisation.reload
        end

        it "is not permitted" do
          parser = described_class.new(attributes)

          parser.valid?
          expect(parser.errors[:field_1]).to include(/The owning organisation must be active on the tenancy start date/)
          expect(parser.errors[:field_2]).to include(/The managing organisation must be active on the tenancy start date/)
          expect(parser.errors[:field_8]).to include(/Enter a date when the owning and managing organisation was active/)
          expect(parser.errors[:field_9]).to include(/Enter a date when the owning and managing organisation was active/)
          expect(parser.errors[:field_10]).to include(/Enter a date when the owning and managing organisation was active/)
        end
      end
    end

    describe "#field_2" do # managing org
      context "when blank" do
        let(:attributes) { { bulk_upload:, field_2: "", field_4: 1 } }

        it "is not permitted as setup error" do
          setup_errors = parser.errors.select { |e| e.options[:category] == :setup }

          expect(setup_errors.find { |e| e.attribute == :field_2 }.message).to eql("The managing organisation code is incorrect")
        end

        it "blocks log creation" do
          expect(parser).to be_block_log_creation
        end
      end

      context "when cannot find managing org" do
        let(:attributes) { { bulk_upload:, field_2: "donotexist" } }

        it "is not permitted as setup error" do
          setup_errors = parser.errors.select { |e| e.options[:category] == :setup }

          expect(setup_errors.find { |e| e.attribute == :field_2 }.message).to eql("The managing organisation code is incorrect")
        end

        it "blocks log creation" do
          expect(parser).to be_block_log_creation
        end
      end

      context "when not affiliated with managing org" do
        let(:unaffiliated_org) { create(:organisation, :with_old_visible_id) }

        let(:attributes) { { bulk_upload:, field_1: owning_org.old_visible_id, field_2: unaffiliated_org.old_visible_id } }

        it "is not permitted as setup error" do
          setup_errors = parser.errors.select { |e| e.options[:category] == :setup }

          expect(setup_errors.find { |e| e.attribute == :field_2 }.message).to eql("This managing organisation does not have a relationship with the owning organisation")
        end

        it "blocks log creation" do
          expect(parser).to be_block_log_creation
        end
      end
    end

    describe "#field_4" do # needs type
      context "when blank" do
        let(:attributes) { { bulk_upload:, field_4: nil, field_13: "123" } }

        it "is reported as a setup error" do
          expect(parser.errors.where(:field_4, category: :setup).map(&:message)).to eql(["You must answer needs type"])
        end
      end
    end

    describe "#field_7" do # renewal
      context "when blank" do
        let(:attributes) { { bulk_upload:, field_1: owning_org.old_visible_id, field_2: owning_org.old_visible_id, field_7: "" } }

        it "has setup errors on the field" do
          expect(parser.errors.where(:field_7, category: :setup).map(&:message)).to eql(["You must answer property renewal"])
        end
      end

      context "when none possible option selected" do
        let(:attributes) { setup_section_params.merge({ field_7: "101" }) }

        it "adds a setup error" do
          expect(parser.errors.where(:field_7, category: :setup).map(&:message)).to include("Enter a valid value for Is this letting a renewal?")
        end
      end
    end

    describe "#field_16" do # UPRN
      context "when over 12 characters" do
        let(:attributes) { setup_section_params.merge({ field_16: "1234567890123" }) }

        it "adds an appropriate error" do
          expect(parser.errors[:field_16]).to eql(["UPRN is not recognised. Check the number, or enter the address"])
        end
      end

      context "when neither UPRN nor address fields are given" do
        let(:attributes) { setup_section_params }

        it "adds appropriate errors" do
          expect(parser.errors[:field_16]).to eql(["You must answer UPRN"])
          expect(parser.errors[:field_17]).to eql(["You must answer address line 1"])
          expect(parser.errors[:field_19]).to eql(["You must answer town or city"])
        end
      end

      context "when neither UPRN nor address fields are given for a supported housing record" do
        let(:bulk_upload) { create(:bulk_upload, :lettings, user:, needstype: 2) }
        let(:attributes) do
          { bulk_upload:,
            field_5: "S#{scheme.id}",
            field_4: "2",
            field_11: "1",
            field_6: location.old_visible_id,
            field_1: "1" }
        end

        it "does not add UPRN errors" do
          expect(parser.errors[:field_16]).to be_empty
          expect(parser.errors[:field_17]).to be_empty
          expect(parser.errors[:field_19]).to be_empty
        end
      end

      context "when UPRN is given but address fields are not" do
        let(:attributes) do
          {
            bulk_upload:,
            field_16: "123456789012",
          }
        end

        it "doesn't add an error" do
          expect(parser.errors[:field_16]).to be_empty
        end
      end

      context "when address is given but UPRN is not" do
        let(:attributes) do
          {
            bulk_upload:,
            field_17: "1 Example Rd",
            field_19: "Example Town/City",
          }
        end

        it "doesn't add an error" do
          expect(parser.errors[:field_16]).to be_empty
        end
      end
    end

    describe "#field_25" do # unitletas
      context "when no longer a valid option from previous year" do
        let(:attributes) { setup_section_params.merge({ field_25: "4" }) }

        it "returns an error" do
          expect(parser.errors[:field_25]).to be_present
        end
      end
    end

    describe "#field_27" do
      context "when null" do
        let(:attributes) { setup_section_params.merge({ field_27: nil }) }

        it "returns an error" do
          expect(parser.errors[:field_27]).to be_present
        end

        it "populates with correct error message" do
          expect(parser.errors[:field_27]).to eql(["You must answer type of building"])
        end
      end
    end

    describe "#field_48" do # age2
      context "when null but gender given" do
        let(:attributes) { setup_section_params.merge({ field_48: "", field_49: "F" }) }

        it "returns an error" do
          expect(parser.errors[:field_48]).to be_present
        end
      end
    end

    describe "soft validations" do
      context "when soft validation is triggered" do
        let(:attributes) { setup_section_params.merge({ field_42: 22, field_46: 5 }) }

        it "adds an error to the relevant fields" do
          expect(parser.errors.where(:field_42, category: :soft_validation)).to be_present
          expect(parser.errors.where(:field_46, category: :soft_validation)).to be_present
        end

        it "populates with correct error message" do
          expect(parser.errors.where(:field_42, category: :soft_validation).first.message).to eql("You told us this person is aged 22 years and retired.")
          expect(parser.errors.where(:field_46, category: :soft_validation).first.message).to eql("You told us this person is aged 22 years and retired.")
        end
      end

      context "when a soft validation is triggered that relates both to fields that are and are not routed to" do
        let(:attributes) { setup_section_params.merge({ field_78: "1", field_43: "M", field_49: "M", field_53: "M" }) }

        it "adds errors to fields that are routed to" do
          expect(parser.errors.where(:field_49, category: :soft_validation)).to be_present
          expect(parser.errors.where(:field_53, category: :soft_validation)).to be_present
        end

        it "does not add errors to fields that are not routed to" do
          expect(parser.errors.where(:field_57, category: :soft_validation)).not_to be_present
          expect(parser.errors.where(:field_61, category: :soft_validation)).not_to be_present
        end
      end

      context "when soft validation is triggered and not required" do
        let(:attributes) { setup_section_params.merge({ field_125: 120, field_123: 1, field_29: 1, field_4: 1, field_11: "1", field_23: "E09000008" }) }

        it "adds an error to the relevant fields" do
          expect(parser.errors.where(:field_125, category: :soft_validation)).to be_present
        end

        it "populates with correct error message" do
          expect(parser.errors.where(:field_125, category: :soft_validation).count).to be(1)
          expect(parser.errors.where(:field_125, category: :soft_validation).first.message).to eql("You told us the rent is £120.00 every week. This is higher than we would expect.")
        end
      end
    end
  end

  describe "#log" do
    describe "#created_by" do
      context "when blank" do
        let(:attributes) { setup_section_params }

        it "takes the user that is uploading" do
          expect(parser.log.created_by).to eql(bulk_upload.user)
        end
      end

      context "when email specified" do
        let(:other_user) { create(:user, organisation: owning_org) }

        let(:attributes) { setup_section_params.merge(field_3: other_user.email) }

        it "sets to user with specified email" do
          expect(parser.log.created_by).to eql(other_user)
        end
      end
    end

    describe "#uprn" do
      let(:attributes) { { bulk_upload:, field_16: "12" } }

      it "sets to given value" do
        expect(parser.log.uprn).to eql("12")
      end
    end

    describe "#uprn_known" do
      context "when uprn specified" do
        let(:attributes) { { bulk_upload:, field_16: "12" } }

        it "sets to 1" do
          expect(parser.log.uprn_known).to be(1)
          expect(parser.log.uprn_confirmed).to be(1)
        end
      end

      context "when uprn blank" do
        let(:attributes) { { bulk_upload:, field_16: "", field_4: 1 } }

        it "sets to 0" do
          expect(parser.log.uprn_known).to be(0)
        end
      end
    end

    describe "#address_line1" do
      let(:attributes) { { bulk_upload:, field_17: "123 Sesame Street" } }

      it "sets to given value" do
        expect(parser.log.address_line1).to eql("123 Sesame Street")
      end
    end

    describe "#address_line2" do
      let(:attributes) { { bulk_upload:, field_18: "Cookie Town" } }

      it "sets to given value" do
        expect(parser.log.address_line2).to eql("Cookie Town")
      end
    end

    describe "#town_or_city" do
      let(:attributes) { { bulk_upload:, field_19: "London" } }

      it "sets to given value" do
        expect(parser.log.town_or_city).to eql("London")
      end
    end

    describe "#county" do
      let(:attributes) { { bulk_upload:, field_20: "Greater London" } }

      it "sets to given value" do
        expect(parser.log.county).to eql("Greater London")
      end
    end

    [
      %w[age1_known details_known_1 age1 field_42 field_47 field_49],
      %w[age2_known details_known_2 age2 field_48 field_47 field_49],
      %w[age3_known details_known_3 age3 field_52 field_51 field_53],
      %w[age4_known details_known_4 age4 field_56 field_55 field_57],
      %w[age5_known details_known_5 age5 field_60 field_59 field_61],
      %w[age6_known details_known_6 age6 field_64 field_63 field_65],
      %w[age7_known details_known_7 age7 field_68 field_67 field_69],
      %w[age8_known details_known_8 age8 field_72 field_71 field_73],
    ].each do |known, details_known, age, field, relationship, gender|
      describe "##{known} and ##{age}" do
        context "when #{field} is blank" do
          context "and person details are not given" do
            let(:attributes) { { bulk_upload:, field.to_sym => nil, field_4: 1, relationship.to_sym => nil, gender.to_sym => nil } }

            it "does not set ##{known}" do
              unless known == "age1_known"
                expect(parser.log.public_send(known)).to be_nil
              end
            end

            it "sets ##{details_known} to no" do
              unless details_known == "details_known_1"
                expect(parser.log.public_send(details_known)).to eq(1)
              end
            end

            it "sets ##{age} to nil" do
              expect(parser.log.public_send(age)).to be_nil
            end
          end

          context "and person details are given" do
            let(:attributes) { { bulk_upload:, field.to_sym => nil, field_4: 1, relationship.to_sym => "C", gender.to_sym => "X" } }

            it "does not set ##{age}" do
              parser.valid?
              expect(parser.errors[field.to_sym]).to include(/must be a number or the letter R/)
            end
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
        let(:attributes) { { bulk_upload:, field_5: "S#{scheme.id}", field_6: location.id, field_1: "ORG#{owning_org.id}", field_2: "ORG#{owning_org.id}" } }

        it "assigns the correct location" do
          expect(parser.log.location).to eql(location)
        end
      end
    end

    describe "#scheme" do
      context "when lookup is via new core id" do
        let(:attributes) { { bulk_upload:, field_5: "S#{scheme.id}", field_1: "ORG#{owning_org.id}", field_2: "ORG#{owning_org.id}" } }

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
      context "when field_112 is yes ie 1" do
        let(:attributes) { { bulk_upload:, field_112: 1 } }

        it "sets value to 1" do
          expect(parser.log.cbl).to be(1)
        end
      end

      context "when field_112 is no ie 2" do
        let(:attributes) { { bulk_upload:, field_112: 2 } }

        it "sets value to 0" do
          expect(parser.log.cbl).to be(0)
        end
      end
    end

    describe "#chr" do
      context "when field_114 is yes ie 1" do
        let(:attributes) { { bulk_upload:, field_114: 1 } }

        it "sets value to 1" do
          expect(parser.log.chr).to be(1)
        end
      end

      context "when field_114 is no ie 2" do
        let(:attributes) { { bulk_upload:, field_114: 2 } }

        it "sets value to 0" do
          expect(parser.log.chr).to be(0)
        end
      end
    end

    describe "#cap" do
      context "when field_113 is yes ie 1" do
        let(:attributes) { { bulk_upload:, field_113: 1 } }

        it "sets value to 1" do
          expect(parser.log.cap).to be(1)
        end
      end

      context "when field_113 is no ie 2" do
        let(:attributes) { { bulk_upload:, field_113: 2 } }

        it "sets value to 0" do
          expect(parser.log.cap).to be(0)
        end
      end
    end

    describe "#letting_allocation_unknown" do
      context "when field_112, 117, 118 are no ie 2" do
        let(:attributes) { { bulk_upload:, field_112: 2, field_113: 2, field_114: 2 } }

        it "sets value to 1" do
          expect(parser.log.letting_allocation_unknown).to be(1)
        end
      end

      context "when any one of field_112, 117, 118 is yes ie 1" do
        let(:attributes) { { bulk_upload:, field_112: 1 } }

        it "sets value to 0" do
          expect(parser.log.letting_allocation_unknown).to be(0)
        end
      end
    end

    describe "#renewal" do
      context "when field_7 is no ie 2" do
        let(:attributes) { { bulk_upload:, field_7: 2 } }

        it "sets value to 0" do
          expect(parser.log.renewal).to eq(0)
        end
      end
    end

    describe "#sexN fields" do
      let(:attributes) do
        {
          bulk_upload:,
          field_43: "F",
          field_49: "M",
          field_53: "X",
          field_57: "R",
          field_61: "F",
          field_65: "M",
          field_69: "X",
          field_73: "R",
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
          field_46: "1",
          field_50: "2",
          field_54: "6",
          field_58: "7",
          field_62: "8",
          field_66: "9",
          field_70: "0",
          field_74: "10",
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
          field_47: "P",
          field_51: "C",
          field_55: "X",
          field_59: "R",
          field_63: "P",
          field_67: "C",
          field_71: "X",
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
      context "when 1" do
        let(:attributes) { { bulk_upload:, field_117: "1" } }

        it "sets value from correct mapping" do
          expect(parser.log.net_income_known).to eq(0)
        end
      end

      context "when 2" do
        let(:attributes) { { bulk_upload:, field_117: "2" } }

        it "sets value from correct mapping" do
          expect(parser.log.net_income_known).to eq(1)
        end
      end

      context "when 3" do
        let(:attributes) { { bulk_upload:, field_117: "3" } }

        it "sets value from correct mapping" do
          expect(parser.log.net_income_known).to eq(2)
        end
      end
    end

    describe "#unitletas" do
      let(:attributes) { { bulk_upload:, field_25: "1" } }

      it "sets value from correct mapping" do
        expect(parser.log.unitletas).to eq(1)
      end
    end

    describe "#rsnvac" do
      let(:attributes) { { bulk_upload:, field_24: "5" } }

      it "sets value from correct mapping" do
        expect(parser.log.rsnvac).to eq(5)
      end
    end

    describe "#sheltered" do
      let(:attributes) { { bulk_upload:, field_41: "1" } }

      it "sets value from correct mapping" do
        expect(parser.log.sheltered).to eq(1)
      end
    end

    describe "illness fields" do
      mapping = [
        { attribute: :illness_type_1, field: :field_94 },
        { attribute: :illness_type_2, field: :field_88 },
        { attribute: :illness_type_3, field: :field_91 },
        { attribute: :illness_type_4, field: :field_86 },
        { attribute: :illness_type_5, field: :field_87 },
        { attribute: :illness_type_6, field: :field_89 },
        { attribute: :illness_type_7, field: :field_90 },
        { attribute: :illness_type_8, field: :field_93 },
        { attribute: :illness_type_9, field: :field_92 },
        { attribute: :illness_type_10, field: :field_95 },
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
            let(:attributes) { { bulk_upload:, hash[:field] => "", field_4: 1 } }

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
      let(:attributes) { { bulk_upload:, field_39: "some other tenancy" } }

      it "sets value to given free text string" do
        expect(parser.log.tenancyother).to eql("some other tenancy")
      end
    end

    describe "#tenancylength" do
      let(:attributes) { { bulk_upload:, field_40: "2" } }

      it "sets value to given free text string" do
        expect(parser.log.tenancylength).to eq(2)
      end
    end

    describe "#earnings" do
      let(:attributes) { { bulk_upload:, field_118: "104.50" } }

      it "rounds to the nearest whole pound" do
        expect(parser.log.earnings).to eq(105)
      end
    end

    describe "#reasonother" do
      let(:attributes) { { bulk_upload:, field_99: "some other reason" } }

      it "sets value to given free text string" do
        expect(parser.log.reasonother).to eql("some other reason")
      end
    end

    describe "#ppcodenk" do
      let(:attributes) { { bulk_upload:, field_102: "2" } }

      it "sets correct value from mapping" do
        expect(parser.log.ppcodenk).to eq(1)
      end
    end

    describe "#household_charge" do
      context "when log is general needs" do
        let(:attributes) { { bulk_upload:, field_4: 1, field_122: "1" } }

        it "sets correct value from mapping" do
          expect(parser.log.household_charge).to eq(nil)
        end
      end

      context "when log is supported housing" do
        let(:attributes) { { bulk_upload:, field_4: 2, field_122: "1" } }

        it "sets correct value from mapping" do
          expect(parser.log.household_charge).to eq(1)
        end
      end
    end

    describe "#chcharge" do
      let(:attributes) { { bulk_upload:, field_124: "123.45" } }

      it "sets value given" do
        expect(parser.log.chcharge).to eq(123.45)
      end
    end

    describe "#supcharg" do
      let(:attributes) { { bulk_upload:, field_128: "123.45" } }

      it "sets value given" do
        expect(parser.log.supcharg).to eq(123.45)
      end
    end

    describe "#pscharge" do
      let(:attributes) { { bulk_upload:, field_127: "123.45" } }

      it "sets value given" do
        expect(parser.log.pscharge).to eq(123.45)
      end
    end

    describe "#scharge" do
      let(:attributes) { { bulk_upload:, field_126: "123.45" } }

      it "sets value given" do
        expect(parser.log.scharge).to eq(123.45)
      end
    end

    describe "#propcode" do
      let(:attributes) { { bulk_upload:, field_14: "abc123" } }

      it "sets value given" do
        expect(parser.log.propcode).to eq("abc123")
      end
    end

    describe "#mrcdate" do
      context "when valid" do
        let(:attributes) { { bulk_upload:, field_33: "13", field_34: "12", field_35: "22" } }

        it "sets value given" do
          expect(parser.log.mrcdate).to eq(Date.new(2022, 12, 13))
        end
      end

      context "when invalid" do
        let(:attributes) { { bulk_upload:, field_33: "13", field_34: "13", field_35: "22" } }

        it "does not raise an error" do
          expect { parser.log.mrcdate }.not_to raise_error
        end
      end
    end

    describe "#majorrepairs" do
      context "when mrcdate given" do
        let(:attributes) { { bulk_upload:, field_33: "13", field_34: "12", field_35: "22" } }

        it "sets #majorrepairs to 1" do
          expect(parser.log.majorrepairs).to eq(1)
        end
      end

      context "when mrcdate not given" do
        let(:attributes) { { bulk_upload:, field_33: "", field_34: "", field_35: "", field_4: 1 } }

        it "sets #majorrepairs to 0" do
          expect(parser.log.majorrepairs).to eq(0)
        end
      end
    end

    describe "#voiddate" do
      context "when valid" do
        let(:attributes) { { bulk_upload:, field_30: "13", field_31: "12", field_32: "22" } }

        it "sets value given" do
          expect(parser.log.voiddate).to eq(Date.new(2022, 12, 13))
        end
      end

      context "when invalid" do
        let(:attributes) { { bulk_upload:, field_30: "13", field_31: "13", field_32: "22" } }

        it "does not raise an error" do
          expect { parser.log.voiddate }.not_to raise_error
        end
      end
    end

    describe "#startdate" do
      let(:attributes) { { bulk_upload:, field_8: now.day.to_s, field_9: now.month.to_s, field_10: now.strftime("%g") } }

      it "sets value given" do
        expect(parser.log.startdate).to eq(now)
      end
    end

    describe "#postcode_full" do
      let(:attributes) { { bulk_upload:, field_21: " EC1N ", field_22: " 2TD " } }

      it "strips whitespace" do
        expect(parser.log.postcode_full).to eql("EC1N 2TD")
      end
    end

    describe "#la" do
      let(:attributes) { { bulk_upload:, field_23: "E07000223" } }

      it "sets to given value" do
        expect(parser.log.la).to eql("E07000223")
      end
    end

    describe "#prevloc" do
      let(:attributes) { { bulk_upload:, field_105: "E07000223" } }

      it "sets to given value" do
        expect(parser.log.prevloc).to eql("E07000223")
      end
    end

    describe "#previous_la_known" do
      context "when known" do
        let(:attributes) { { bulk_upload:, field_105: "E07000223" } }

        it "sets to 1" do
          expect(parser.log.previous_la_known).to eq(1)
        end
      end

      context "when not known" do
        let(:attributes) { { bulk_upload:, field_105: "", field_4: 1 } }

        it "sets to 0" do
          expect(parser.log.previous_la_known).to eq(0)
        end
      end
    end

    describe "#first_time_property_let_as_social_housing" do
      context "when field_24 is 15, 16, or 17" do
        let(:attributes) { { bulk_upload:, field_24: %w[15 16 17].sample } }

        it "sets to 1" do
          expect(parser.log.first_time_property_let_as_social_housing).to eq(1)
        end
      end

      context "when field_24 is not 15, 16, or 17" do
        let(:attributes) { { bulk_upload:, field_24: "1" } }

        it "sets to 0" do
          expect(parser.log.first_time_property_let_as_social_housing).to eq(0)
        end
      end
    end

    describe "#housingneeds" do
      context "when no disabled needs" do
        let(:attributes) { { bulk_upload:, field_83: "1" } }

        it "sets to 2" do
          expect(parser.log.housingneeds).to eq(2)
        end
      end

      context "when dont know about disabled needs" do
        let(:attributes) { { bulk_upload:, field_84: "1" } }

        it "sets to 3" do
          expect(parser.log.housingneeds).to eq(3)
        end
      end

      context "when housingneeds are given" do
        let(:attributes) { { bulk_upload:, field_83: "0", field_81: "1", field_82: "1" } }

        it "sets correct housingneeds" do
          expect(parser.log.housingneeds).to eq(1)
          expect(parser.log.housingneeds_type).to eq(2)
          expect(parser.log.housingneeds_other).to eq(1)
        end
      end

      context "when housingneeds are given and field_82 is nil" do
        let(:attributes) { { bulk_upload:, field_83: nil, field_81: "1", field_82: "1" } }

        it "sets correct housingneeds" do
          expect(parser.log.housingneeds).to eq(1)
          expect(parser.log.housingneeds_type).to eq(2)
          expect(parser.log.housingneeds_other).to eq(1)
        end
      end

      context "when housingneeds are not given" do
        let(:attributes) { { bulk_upload:, field_79: nil, field_80: nil, field_81: nil, field_83: nil } }

        it "sets correct housingneeds" do
          expect(parser.log.housingneeds).to eq(1)
          expect(parser.log.housingneeds_type).to eq(3)
        end
      end

      context "when housingneeds a and b are selected" do
        let(:attributes) { { bulk_upload:, field_79: "1", field_80: "1" } }

        it "sets error on housingneeds a and b" do
          parser.valid?
          expect(parser.errors[:field_79]).to include("Only one disabled access need: fully wheelchair-accessible housing, wheelchair access to essential rooms or level access housing, can be selected")
          expect(parser.errors[:field_80]).to include("Only one disabled access need: fully wheelchair-accessible housing, wheelchair access to essential rooms or level access housing, can be selected")
          expect(parser.errors[:field_81]).to be_blank
        end
      end

      context "when housingneeds a and c are selected" do
        let(:attributes) { { bulk_upload:, field_79: "1", field_81: "1" } }

        it "sets error on housingneeds a and c" do
          parser.valid?
          expect(parser.errors[:field_79]).to include("Only one disabled access need: fully wheelchair-accessible housing, wheelchair access to essential rooms or level access housing, can be selected")
          expect(parser.errors[:field_81]).to include("Only one disabled access need: fully wheelchair-accessible housing, wheelchair access to essential rooms or level access housing, can be selected")
          expect(parser.errors[:field_80]).to be_blank
        end
      end

      context "when housingneeds b and c are selected" do
        let(:attributes) { { bulk_upload:, field_80: "1", field_81: "1" } }

        it "sets error on housingneeds b and c" do
          parser.valid?
          expect(parser.errors[:field_80]).to include("Only one disabled access need: fully wheelchair-accessible housing, wheelchair access to essential rooms or level access housing, can be selected")
          expect(parser.errors[:field_81]).to include("Only one disabled access need: fully wheelchair-accessible housing, wheelchair access to essential rooms or level access housing, can be selected")
          expect(parser.errors[:field_79]).to be_blank
        end
      end

      context "when housingneeds a and g are selected" do
        let(:attributes) { { bulk_upload:, field_79: "1", field_83: "1" } }

        it "sets error on housingneeds a and g" do
          parser.valid?
          expect(parser.errors[:field_83]).to include("No disabled access needs can’t be selected if you have selected fully wheelchair-accessible housing, wheelchair access to essential rooms, level access housing or other disabled access needs")
          expect(parser.errors[:field_79]).to include("No disabled access needs can’t be selected if you have selected fully wheelchair-accessible housing, wheelchair access to essential rooms, level access housing or other disabled access needs")
          expect(parser.errors[:field_80]).to be_blank
          expect(parser.errors[:field_81]).to be_blank
        end
      end

      context "when only housingneeds g is selected" do
        let(:attributes) { { bulk_upload:, field_79: "0", field_83: "1" } }

        it "does not add any housingneeds errors" do
          parser.valid?
          expect(parser.errors[:field_55]).to be_blank
          expect(parser.errors[:field_79]).to be_blank
          expect(parser.errors[:field_80]).to be_blank
          expect(parser.errors[:field_81]).to be_blank
        end
      end

      context "when housingneeds a and h are selected" do
        let(:attributes) { { bulk_upload:, field_79: "1", field_84: "1" } }

        it "sets error on housingneeds a and h" do
          parser.valid?
          expect(parser.errors[:field_84]).to include("Don’t know disabled access needs can’t be selected if you have selected fully wheelchair-accessible housing, wheelchair access to essential rooms, level access housing or other disabled access needs")
          expect(parser.errors[:field_79]).to include("Don’t know disabled access needs can’t be selected if you have selected fully wheelchair-accessible housing, wheelchair access to essential rooms, level access housing or other disabled access needs")
          expect(parser.errors[:field_80]).to be_blank
          expect(parser.errors[:field_81]).to be_blank
        end
      end

      context "when only housingneeds h is selected" do
        let(:attributes) { { bulk_upload:, field_79: "0", field_84: "1" } }

        it "does not add any housingneeds errors" do
          parser.valid?
          expect(parser.errors[:field_84]).to be_blank
          expect(parser.errors[:field_79]).to be_blank
          expect(parser.errors[:field_80]).to be_blank
          expect(parser.errors[:field_81]).to be_blank
        end
      end
    end

    describe "#housingneeds_type" do
      context "when field_79 is 1" do
        let(:attributes) { { bulk_upload:, field_79: "1" } }

        it "set to 0" do
          expect(parser.log.housingneeds_type).to eq(0)
        end
      end

      context "when field_80 is 1" do
        let(:attributes) { { bulk_upload:, field_80: "1" } }

        it "set to 1" do
          expect(parser.log.housingneeds_type).to eq(1)
        end
      end

      context "when field_81 is 1" do
        let(:attributes) { { bulk_upload:, field_81: "1" } }

        it "set to 2" do
          expect(parser.log.housingneeds_type).to eq(2)
        end
      end
    end

    describe "#housingneeds_other" do
      context "when field_54 is 1" do
        let(:attributes) { { bulk_upload:, field_82: "1" } }

        it "sets to 1" do
          expect(parser.log.housingneeds_other).to eq(1)
        end
      end
    end
  end

  describe "#start_date" do
    context "when year of 9 is passed to represent 2009" do
      let(:attributes) { { bulk_upload:, field_8: "1", field_9: "1", field_10: "9" } }

      it "uses the year 2009" do
        expect(parser.send(:start_date)).to eql(Date.new(2009, 1, 1))
      end
    end
  end

  describe "#spreadsheet_duplicate_hash" do
    it "returns a hash" do
      expect(parser.spreadsheet_duplicate_hash).to be_a(Hash)
    end
  end

  describe "#add_duplicate_found_in_spreadsheet_errors" do
    it "adds errors" do
      expect { parser.add_duplicate_found_in_spreadsheet_errors }.to change(parser.errors, :size)
    end
  end
end