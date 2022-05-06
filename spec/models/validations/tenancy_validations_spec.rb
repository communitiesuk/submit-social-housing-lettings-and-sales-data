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
          record.tenancy = 3
          record.tenancylength = 10
          tenancy_validator.validate_fixed_term_tenancy(record)
          expect(record.errors["tenancylength"]).to include(match(expected_error))
          expect(record.errors["tenancy"]).to include(match(expected_error))
        end
      end

      context "when type of tenancy is assured shorthold" do
        let(:expected_error) { I18n.t("validations.tenancy.length.shorthold") }

        before { record.tenancy = 4 }

        context "when tenancy length is greater than 1" do
          it "adds an error" do
            record.tenancylength = 1
            tenancy_validator.validate_fixed_term_tenancy(record)
            expect(record.errors["tenancylength"]).to include(match(expected_error))
            expect(record.errors["tenancy"]).to include(match(expected_error))
          end
        end

        context "when tenancy length is less than 100" do
          it "adds an error" do
            record.tenancylength = 100
            tenancy_validator.validate_fixed_term_tenancy(record)
            expect(record.errors["tenancylength"]).to include(match(expected_error))
            expect(record.errors["tenancy"]).to include(match(expected_error))
          end
        end

        context "when tenancy length is between 2-99" do
          it "does not add an error" do
            record.tenancylength = 3
            tenancy_validator.validate_fixed_term_tenancy(record)
            expect(record.errors["tenancylength"]).to be_empty
            expect(record.errors["tenancy"]).to be_empty
          end
        end

        context "when tenancy length has not been answered" do
          it "does not add an error" do
            record.tenancylength = nil
            tenancy_validator.validate_fixed_term_tenancy(record)
            expect(record.errors["tenancylength"]).to be_empty
            expect(record.errors["tenancy"]).to be_empty
          end
        end
      end

      context "when type of tenancy is secure" do
        let(:expected_error) { I18n.t("validations.tenancy.length.secure") }

        before { record.tenancy = 1 }

        context "when tenancy length is greater than 1" do
          it "adds an error" do
            record.tenancylength = 1
            tenancy_validator.validate_fixed_term_tenancy(record)
            expect(record.errors["tenancylength"]).to include(match(expected_error))
            expect(record.errors["tenancy"]).to include(match(expected_error))
          end
        end

        context "when tenancy length is less than 100" do
          it "adds an error" do
            record.tenancylength = 100
            tenancy_validator.validate_fixed_term_tenancy(record)
            expect(record.errors["tenancylength"]).to include(match(expected_error))
            expect(record.errors["tenancy"]).to include(match(expected_error))
          end
        end

        context "when tenancy length is between 2-99" do
          it "does not add an error" do
            record.tenancylength = 3
            tenancy_validator.validate_fixed_term_tenancy(record)
            expect(record.errors["tenancylength"]).to be_empty
            expect(record.errors["tenancy"]).to be_empty
          end
        end

        context "when tenancy length has not been answered" do
          it "does not add an error" do
            record.tenancylength = nil
            tenancy_validator.validate_fixed_term_tenancy(record)
            expect(record.errors["tenancylength"]).to be_empty
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
      before { record.tenancy = 3 }

      it "validates that other tenancy type is provided" do
        record.tenancyother = nil
        tenancy_validator.validate_other_tenancy_type(record)
        expect(record.errors[other_field_label]).to include(match(expected_error))
      end

      it "expects that other tenancy type is provided" do
        record.tenancyother = "Some other tenancy type"
        tenancy_validator.validate_other_tenancy_type(record)
        expect(record.errors[other_field_label]).to be_empty
      end
    end

    context "when tenancy type is not other" do
      let(:field) { "validations.other_field_not_required" }

      it "validates that other tenancy type is not provided" do
        record.tenancy = 2
        record.tenancyother = "Some other tenancy type"
        tenancy_validator.validate_other_tenancy_type(record)
        expect(record.errors[other_field_label]).to include(match(expected_error))
      end

      it "expects that other tenancy type is not provided" do
        record.tenancy = 1
        record.tenancyother = nil
        tenancy_validator.validate_other_tenancy_type(record)
        expect(record.errors[other_field_label]).to be_empty
      end
    end
  end

  describe "joint tenancy validation" do
    context "when the data inputter has said that there is only one member in the household" do
      let(:record) { FactoryBot.create(:case_log, startdate: Time.zone.local(2022, 5, 1)) }
      let(:expected_error) { I18n.t("validations.tenancy.not_joint") }
      let(:hhmemb_expected_error) { I18n.t("validations.tenancy.joint_more_than_one_member") }

      it "displays an error if the data inputter says the letting is a joint tenancy" do
        record.hhmemb = 1
        record.joint = 1
        tenancy_validator.validate_joint_tenancy(record)
        expect(record.errors["joint"]).to include(match(expected_error))
        expect(record.errors["hhmemb"]).to include(match(hhmemb_expected_error))
      end

      it "does not display an error if the data inputter says the letting is not a joint tenancy" do
        record.hhmemb = 1
        record.joint = 2
        tenancy_validator.validate_joint_tenancy(record)
        expect(record.errors["joint"]).to be_empty
        expect(record.errors["hhmemb"]).to be_empty
      end
    end
  end
end
