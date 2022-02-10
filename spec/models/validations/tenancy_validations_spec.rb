require "rails_helper"

RSpec.describe Validations::TenancyValidations do
  subject(:tenancy_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::TenancyValidations } }
  let(:record) { FactoryBot.create(:case_log) }

  describe "#validate_fixed_term_tenancy" do
    context "when fixed term tenancy" do
      context "when type of tenancy is not assured or assured shorthold" do
        let(:expected_error) { I18n.t("validations.tenancy.length.fixed_term_not_required") }

        it "tenancy length should not be present" do
          record.tenancy = "Other"
          record.tenancylength = 10
          subject.validate_fixed_term_tenancy(record)
          expect(record.errors["tenancylength"]).to include(match(expected_error))
          expect(record.errors["tenancy"]).to include(match(expected_error))
        end
      end

      context "when type of tenancy is assured shorthold" do
        let(:expected_error) { I18n.t("validations.tenancy.length.shorthold") }

        context "when tenancy length is greater than 1" do
          it "adds an error" do
            record.tenancy = "Assured Shorthold"
            record.tenancylength = 1
            subject.validate_fixed_term_tenancy(record)
            expect(record.errors["tenancylength"]).to include(match(expected_error))
            expect(record.errors["tenancy"]).to include(match(expected_error))
          end
        end

        context "when tenancy length is less than 100" do
          it "adds an error" do
            record.tenancy = "Assured Shorthold"
            record.tenancylength = 100
            subject.validate_fixed_term_tenancy(record)
            expect(record.errors["tenancylength"]).to include(match(expected_error))
            expect(record.errors["tenancy"]).to include(match(expected_error))
          end
        end

        context "when tenancy length is between 2-99" do
          it "does not add an error" do
            record.tenancy = "Assured Shorthold"
            record.tenancylength = 3
            subject.validate_fixed_term_tenancy(record)
            expect(record.errors["tenancylength"]).to be_empty
            expect(record.errors["tenancy"]).to be_empty
          end
        end

        context "when tenancy length has not been answered" do
          it "does not add an error" do
            record.tenancy = "Assured Shorthold"
            record.tenancylength = nil
            subject.validate_fixed_term_tenancy(record)
            expect(record.errors["tenancylength"]).to be_empty
            expect(record.errors["tenancy"]).to be_empty
          end
        end
      end

      context "when type of tenancy is secure" do
        let(:expected_error) { I18n.t("validations.tenancy.length.secure") }

        context "when tenancy length is greater than 1" do
          it "adds an error" do
            record.tenancy = "Secure (including flexible)"
            record.tenancylength = 1
            subject.validate_fixed_term_tenancy(record)
            expect(record.errors["tenancylength"]).to include(match(expected_error))
            expect(record.errors["tenancy"]).to include(match(expected_error))
          end
        end

        context "when tenancy length is less than 100" do
          it "adds an error" do
            record.tenancy = "Secure (including flexible)"
            record.tenancylength = 100
            subject.validate_fixed_term_tenancy(record)
            expect(record.errors["tenancylength"]).to include(match(expected_error))
            expect(record.errors["tenancy"]).to include(match(expected_error))
          end
        end

        context "when tenancy length is between 2-99" do
          it "does not add an error" do
            record.tenancy = "Secure (including flexible)"
            record.tenancylength = 3
            subject.validate_fixed_term_tenancy(record)
            expect(record.errors["tenancylength"]).to be_empty
            expect(record.errors["tenancy"]).to be_empty
          end
        end

        context "when tenancy length has not been answered" do
          it "does not add an error" do
            record.tenancy = "Secure (including flexible)"
            record.tenancylength = nil
            subject.validate_fixed_term_tenancy(record)
            expect(record.errors["tenancylength"]).to be_empty
            expect(record.errors["tenancy"]).to be_empty
          end
        end
      end
    end
  end
end
