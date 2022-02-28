require "rails_helper"

RSpec.describe Validations::TenancyValidations do
  subject(:tenancy_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::TenancyValidations } }
  let(:record) { FactoryBot.create(:case_log) }

  describe "fixed term tenancy validations" do
    context "when fixed term tenancy" do
      context "when type of tenancy is not assured or assured shorthold" do
        let(:expected_error) { I18n.t("validations.tenancy.length.fixed_term_not_required") }

        it "tenancy length should not be present" do
          record.tenancy = 4
          record.tenancylength = 10
          tenancy_validator.validate_fixed_term_tenancy(record)
          expect(record.errors["tenancylength"]).to include(match(expected_error))
          expect(record.errors["tenancy"]).to include(match(expected_error))
        end
      end

      context "when type of tenancy is assured shorthold" do
        let(:expected_error) { I18n.t("validations.tenancy.length.shorthold") }

        context "when tenancy length is greater than 1" do
          it "adds an error" do
            record.tenancy = 1
            record.tenancylength = 1
            tenancy_validator.validate_fixed_term_tenancy(record)
            expect(record.errors["tenancylength"]).to include(match(expected_error))
            expect(record.errors["tenancy"]).to include(match(expected_error))
          end
        end

        context "when tenancy length is less than 100" do
          it "adds an error" do
            record.tenancy = 1
            record.tenancylength = 100
            tenancy_validator.validate_fixed_term_tenancy(record)
            expect(record.errors["tenancylength"]).to include(match(expected_error))
            expect(record.errors["tenancy"]).to include(match(expected_error))
          end
        end

        context "when tenancy length is between 2-99" do
          it "does not add an error" do
            record.tenancy = 1
            record.tenancylength = 3
            tenancy_validator.validate_fixed_term_tenancy(record)
            expect(record.errors["tenancylength"]).to be_empty
            expect(record.errors["tenancy"]).to be_empty
          end
        end

        context "when tenancy length has not been answered" do
          it "does not add an error" do
            record.tenancy = 1
            record.tenancylength = nil
            tenancy_validator.validate_fixed_term_tenancy(record)
            expect(record.errors["tenancylength"]).to be_empty
            expect(record.errors["tenancy"]).to be_empty
          end
        end
      end

      context "when type of tenancy is secure" do
        let(:expected_error) { I18n.t("validations.tenancy.length.secure") }

        context "when tenancy length is greater than 1" do
          it "adds an error" do
            record.tenancy = 3
            record.tenancylength = 1
            tenancy_validator.validate_fixed_term_tenancy(record)
            expect(record.errors["tenancylength"]).to include(match(expected_error))
            expect(record.errors["tenancy"]).to include(match(expected_error))
          end
        end

        context "when tenancy length is less than 100" do
          it "adds an error" do
            record.tenancy = 3
            record.tenancylength = 100
            tenancy_validator.validate_fixed_term_tenancy(record)
            expect(record.errors["tenancylength"]).to include(match(expected_error))
            expect(record.errors["tenancy"]).to include(match(expected_error))
          end
        end

        context "when tenancy length is between 2-99" do
          it "does not add an error" do
            record.tenancy = 3
            record.tenancylength = 3
            tenancy_validator.validate_fixed_term_tenancy(record)
            expect(record.errors["tenancylength"]).to be_empty
            expect(record.errors["tenancy"]).to be_empty
          end
        end

        context "when tenancy length has not been answered" do
          it "does not add an error" do
            record.tenancy = 3
            record.tenancylength = nil
            tenancy_validator.validate_fixed_term_tenancy(record)
            expect(record.errors["tenancylength"]).to be_empty
            expect(record.errors["tenancy"]).to be_empty
          end
        end

        context "when referral is not internal transfer" do
          it "adds an error" do
            record.tenancy = 0
            record.referral = 1
            tenancy_validator.validate_tenancy_type(record)
            expect(record.errors["tenancy"])
              .to include(match I18n.t("validations.tenancy.internal_transfer"))
          end
        end

        context "when referral is internal transfer" do
          it "does not add an error" do
            record.tenancy = 3
            record.referral = 1
            tenancy_validator.validate_tenancy_type(record)
            expect(record.errors["tenancy"]).to be_empty
          end
        end
      end
    end
  end

  describe "tenancy type validations" do
    let(:field) { "validations.other_field_missing" }
    let(:main_field_label) { "tenancy" }
    let(:other_field_label) { "tenancyother" }
    let(:expected_error) { I18n.t(field, main_field_label:, other_field_label:) }

    context "when tenancy type is other" do
      it "validates that other tenancy type is provided" do
        record.tenancy = 4
        record.tenancyother = nil
        tenancy_validator.validate_other_tenancy_type(record)
        expect(record.errors[other_field_label]).to include(match(expected_error))
      end

      it "expects that other tenancy type is provided" do
        record.tenancy = 4
        record.tenancyother = "Some other tenancy type"
        tenancy_validator.validate_other_tenancy_type(record)
        expect(record.errors[other_field_label]).to be_empty
      end
    end

    context "when tenancy type is not other" do
      let(:field) { "validations.other_field_not_required" }

      it "validates that other tenancy type is not provided" do
        record.tenancy = 0
        record.tenancyother = "Some other tenancy type"
        tenancy_validator.validate_other_tenancy_type(record)
        expect(record.errors[other_field_label]).to include(match(expected_error))
      end

      it "expects that other tenancy type is not provided" do
        record.tenancy = 3
        record.tenancyother = nil
        tenancy_validator.validate_other_tenancy_type(record)
        expect(record.errors[other_field_label]).to be_empty
      end
    end
  end
end
