require "rails_helper"

RSpec.describe Validations::Sales::FinancialValidations do
  subject(:financial_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::Sales::FinancialValidations } }

  describe "income validations" do
    let(:record) { FactoryBot.create(:sales_log, ownershipsch: 1) }

    context "with shared ownership" do
      context "and non london borough" do
        (0..8).each do |ecstat|
          it "adds an error when buyer 1 income is over hard max for ecstat #{ecstat}" do
            record.income1 = 85_000
            record.ecstat1 = ecstat
            financial_validator.validate_income1(record)
            expect(record.errors["income1"])
                .to include(match I18n.t("validations.financial.income1.over_hard_max", hard_max: 80_000))
          end
        end

        it "validates that the income is within the expected range for the tenant’s employment status" do
          record.income1 = 75_000
          record.ecstat1 = 1
          financial_validator.validate_income1(record)
          expect(record.errors["income1"]).to be_empty
        end

        it "validates income correctly if the ecstat is child" do
          record.income1 = 1
          record.ecstat1 = 9
          financial_validator.validate_income1(record)
          expect(record.errors["income1"])
              .to include(match I18n.t("validations.financial.income1.child_income"))
        end
      end

      context "and a london borough" do
        before do
          record.update!(la: "E09000030")
          record.reload
        end

        (0..8).each do |ecstat|
          it "adds an error when buyer 1 income is over hard max for ecstat #{ecstat}" do
            record.income1 = 95_000
            record.ecstat1 = ecstat
            financial_validator.validate_income1(record)
            expect(record.errors["income1"])
                .to include(match I18n.t("validations.financial.income1.over_hard_max", hard_max: 90_000))
          end
        end

        it "validates that the income is within the expected range for the tenant’s employment status" do
          record.income1 = 85_000
          record.ecstat1 = 1
          financial_validator.validate_income1(record)
          expect(record.errors["income1"]).to be_empty
        end

        it "validates income correctly if the ecstat is child" do
          record.income1 = 1
          record.ecstat1 = 9
          financial_validator.validate_income1(record)
          expect(record.errors["income1"])
              .to include(match I18n.t("validations.financial.income1.child_income"))
        end
      end
    end
  end
end
