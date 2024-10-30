require "rails_helper"

RSpec.describe Validations::TenancyValidations do
  subject(:tenancy_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::TenancyValidations } }

  describe "tenancy length validations" do
    let(:record) { FactoryBot.build(:lettings_log, :setup_completed) }

    shared_examples "adds expected errors based on the tenancy length" do |tenancy_type_case, error_fields, min_tenancy_length|
      context "and tenancy type is #{tenancy_type_case[:name]}" do
        let(:expected_error) { tenancy_type_case[:expected_error].call(min_tenancy_length) }

        before { record.tenancy = tenancy_type_case[:code] }

        context "and tenancy length is less than #{min_tenancy_length}" do
          before { record.tenancylength = min_tenancy_length - 1 }

          it "adds errors to #{error_fields.join(', ')}" do
            validation.call(record)
            error_fields.each do |field|
              expect(record.errors[field]).to include(match(expected_error))
            end
            expect(record.errors.size).to be(error_fields.length)
          end
        end

        context "and tenancy length is more than 99" do
          before { record.tenancylength = 100 }

          it "adds errors to #{error_fields.join(', ')}" do
            validation.call(record)
            error_fields.each do |field|
              expect(record.errors[field]).to include(match(expected_error))
            end
            expect(record.errors.size).to be(error_fields.length)
          end
        end

        context "and tenancy length is between #{min_tenancy_length} and 99" do
          before { record.tenancylength = min_tenancy_length }

          it "does not add errors" do
            validation.call(record)
            expect(record.errors).to be_empty
          end
        end

        context "and tenancy length is not set" do
          before { record.tenancylength = nil }

          it "does not add errors" do
            validation.call(record)
            expect(record.errors).to be_empty
          end
        end
      end
    end

    shared_examples "does not add errors when tenancy type is not fixed term" do
      context "and tenancy type is not fixed term" do
        before do
          record.tenancy = 8
          record.tenancylength = 0
        end

        it "does not add errors" do
          validation.call(record)
          expect(record.errors).to be_empty
        end
      end
    end

    fixed_term_tenancy_type_cases = [
      {
        name: "assured shorthold",
        code: 4,
        expected_error: ->(min_tenancy_length) { I18n.t("validations.tenancy.length.invalid_fixed", min_tenancy_length:) },
      },
      {
        name: "secure fixed term",
        code: 6,
        expected_error: ->(min_tenancy_length) { I18n.t("validations.tenancy.length.invalid_fixed", min_tenancy_length:) },
      },
    ]

    describe "#validate_supported_housing_fixed_tenancy_length" do
      subject(:validation) { ->(record) { tenancy_validator.validate_supported_housing_fixed_tenancy_length(record) } }

      context "when needs type is supported housing" do
        before { record.needstype = 2 }

        error_fields = %w[needstype tenancylength tenancy]
        fixed_term_tenancy_type_cases.each do |tenancy_type_case|
          include_examples "adds expected errors based on the tenancy length", tenancy_type_case, error_fields, 1
        end

        include_examples "does not add errors when tenancy type is not fixed term"
      end

      context "when needs type is general needs" do
        before do
          record.needstype = 1
          record.tenancy = 4
          record.tenancylength = 0
        end

        it "does not add errors" do
          validation.call(record)
          expect(record.errors).to be_empty
        end
      end
    end

    describe "#validate_general_needs_fixed_tenancy_length_affordable_social_rent" do
      subject(:validation) { ->(record) { tenancy_validator.validate_general_needs_fixed_tenancy_length_affordable_social_rent(record) } }

      context "when needs type is general needs" do
        before { record.needstype = 1 }

        context "and rent type is affordable or social rent" do
          before { record.renttype = 1 }

          error_fields = %w[needstype rent_type tenancylength tenancy]
          fixed_term_tenancy_type_cases.each do |tenancy_type_case|
            include_examples "adds expected errors based on the tenancy length", tenancy_type_case, error_fields, 2
          end

          include_examples "does not add errors when tenancy type is not fixed term"
        end

        context "and rent type is intermediate rent" do
          before do
            record.renttype = 3
            record.tenancy = 4
            record.tenancylength = 0
          end

          it "does not add errors" do
            validation.call(record)
            expect(record.errors).to be_empty
          end
        end
      end

      context "when needs type is supported housing" do
        before do
          record.needstype = 2
          record.renttype = 1
          record.tenancy = 4
          record.tenancylength = 0
        end

        it "does not add errors" do
          validation.call(record)
          expect(record.errors).to be_empty
        end
      end
    end

    describe "#validate_general_needs_fixed_tenancy_length_intermediate_rent" do
      subject(:validation) { ->(record) { tenancy_validator.validate_general_needs_fixed_tenancy_length_intermediate_rent(record) } }

      context "when needs type is general needs" do
        before { record.needstype = 1 }

        context "and rent type is intermediate rent" do
          before { record.renttype = 3 }

          error_fields = %w[needstype rent_type tenancylength tenancy]
          fixed_term_tenancy_type_cases.each do |tenancy_type_case|
            include_examples "adds expected errors based on the tenancy length", tenancy_type_case, error_fields, 1
          end

          include_examples "does not add errors when tenancy type is not fixed term"
        end

        context "and rent type is not intermediate rent" do
          before do
            record.renttype = 2
            record.tenancy = 4
            record.tenancylength = 0
          end

          it "does not add errors" do
            validation.call(record)
            expect(record.errors).to be_empty
          end
        end
      end

      context "when needs type is supported housing" do
        before do
          record.needstype = 2
          record.renttype = 3
          record.tenancy = 4
          record.tenancylength = 0
        end

        it "does not add errors" do
          validation.call(record)
          expect(record.errors).to be_empty
        end
      end
    end

    describe "#validate_periodic_tenancy_length" do
      subject(:validation) { ->(record) { tenancy_validator.validate_periodic_tenancy_length(record) } }

      periodic_tenancy_case = {
        name: "periodic",
        code: 8,
        expected_error: ->(min_tenancy_length) { I18n.t("validations.tenancy.length.invalid_periodic", min_tenancy_length:) },
      }
      error_fields = %w[tenancylength tenancy]
      include_examples "adds expected errors based on the tenancy length", periodic_tenancy_case, error_fields, 1

      context "when tenancy type is not periodic" do
        before do
          record.tenancy = 6
          record.tenancylength = 0
        end

        it "does not add errors" do
          validation.call(record)
          expect(record.errors).to be_empty
        end
      end

      describe "#validate_tenancy_length_blank_when_not_required" do
        context "when a tenancy length is provided" do
          before { record.tenancylength = 10 }

          context "and tenancy type is not fixed term or periodic" do
            before { record.tenancy = 5 }

            it "adds errors to tenancylength and tenancy" do
              tenancy_validator.validate_tenancy_length_blank_when_not_required(record)
              expected_error = I18n.t("validations.tenancy.length.fixed_term_not_required")
              expect(record.errors["tenancylength"]).to include(expected_error)
              expect(record.errors["tenancy"]).to include(expected_error)
            end
          end

          tenancy_types_with_length = [
            { name: "assured shorthold", code: 4 },
            { name: "secure fixed term", code: 6 },
            { name: "periodic", code: 8 },
          ]
          tenancy_types_with_length.each do |type|
            context "and tenancy type is #{type[:name]}" do
              before { record.tenancy = type[:code] }

              it "does not add errors" do
                tenancy_validator.validate_tenancy_length_blank_when_not_required(record)
                expect(record.errors).to be_empty
              end
            end
          end
        end

        context "when tenancy length is not provided" do
          before do
            record.tenancylength = nil
            record.tenancy = 5
          end

          it "does not add errors" do
            tenancy_validator.validate_tenancy_length_blank_when_not_required(record)
            expect(record.errors).to be_empty
          end
        end
      end
    end
  end

  describe "tenancy type validations" do
    let(:record) { FactoryBot.build(:lettings_log, :setup_completed) }
    let(:field) { "validations.shared.other_field_missing" }
    let(:main_field_label) { "tenancy type" }
    let(:other_field) { "tenancyother" }
    let(:other_field_label) { "other tenancy type" }
    let(:expected_error) { I18n.t(field, main_field_label:, other_field_label:) }

    context "when tenancy type is other" do
      before { record.tenancy = 3 }

      it "validates that other tenancy type is provided" do
        record.tenancyother = nil
        tenancy_validator.validate_other_tenancy_type(record)
        expect(record.errors[other_field]).to include(match(expected_error))
      end

      it "expects that other tenancy type is provided" do
        record.tenancyother = "Some other tenancy type"
        tenancy_validator.validate_other_tenancy_type(record)
        expect(record.errors[other_field]).to be_empty
      end
    end

    context "when tenancy type is not other" do
      let(:field) { "validations.shared.other_field_not_required" }

      it "validates that other tenancy type is not provided" do
        record.tenancy = 2
        record.tenancyother = "Some other tenancy type"
        tenancy_validator.validate_other_tenancy_type(record)
        expect(record.errors[other_field]).to include(match(expected_error))
      end

      it "expects that other tenancy type is not provided" do
        record.tenancy = 1
        record.tenancyother = nil
        tenancy_validator.validate_other_tenancy_type(record)
        expect(record.errors[other_field]).to be_empty
      end
    end
  end

  describe "joint tenancy validation" do
    context "when the data inputter has said that there is only one member in the household" do
      let(:record) { FactoryBot.build(:lettings_log, :setup_completed, hhmemb: 1) }
      let(:expected_error) { I18n.t("validations.tenancy.not_joint") }
      let(:hhmemb_expected_error) { I18n.t("validations.tenancy.joint_more_than_one_member") }

      it "displays an error if the data inputter says the letting is a joint tenancy" do
        record.joint = 1
        tenancy_validator.validate_joint_tenancy(record)
        expect(record.errors["joint"]).to include(match(expected_error))
        expect(record.errors["hhmemb"]).to include(match(hhmemb_expected_error))
      end

      it "does not display an error if the data inputter says the letting is not a joint tenancy" do
        record.joint = 2
        tenancy_validator.validate_joint_tenancy(record)
        expect(record.errors["joint"]).to be_empty
        expect(record.errors["hhmemb"]).to be_empty
      end

      it "does not display an error if the data inputter has given the household members but not input if it is a joint tenancy" do
        record.joint = nil
        tenancy_validator.validate_joint_tenancy(record)
        expect(record.errors["joint"]).to be_empty
        expect(record.errors["hhmemb"]).to be_empty
      end

      it "does not error when don't know answer to joint" do
        record.joint = 3

        tenancy_validator.validate_joint_tenancy(record)

        expect(record.errors["joint"]).to be_empty
        expect(record.errors["hhmemb"]).to be_empty
      end
    end
  end
end
