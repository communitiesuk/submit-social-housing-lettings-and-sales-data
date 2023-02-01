require "rails_helper"

RSpec.describe Validations::Sales::FinancialValidations do
  subject(:financial_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::Sales::FinancialValidations } }

  describe "income validations" do
    let(:record) { FactoryBot.create(:sales_log, ownershipsch: 1, la: "E08000035") }

    context "with shared ownership" do
      context "and non london borough" do
        (0..8).each do |ecstat|
          it "adds an error when buyer 1 income is over hard max for ecstat #{ecstat}" do
            record.income1 = 85_000
            record.ecstat1 = ecstat
            financial_validator.validate_income1(record)
            expect(record.errors["income1"])
                .to include(match I18n.t("validations.financial.income1.over_hard_max.outside_london"))
            expect(record.errors["ecstat1"])
                .to include(match I18n.t("validations.financial.income1.over_hard_max.outside_london"))
            expect(record.errors["ownershipsch"])
                .to include(match I18n.t("validations.financial.income1.over_hard_max.outside_london"))
            expect(record.errors["la"])
                .to include(match I18n.t("validations.financial.income1.over_hard_max.outside_london"))
            expect(record.errors["postcode_full"])
                .to include(match I18n.t("validations.financial.income1.over_hard_max.outside_london"))
          end
        end

        it "validates that the income is within the expected range for the tenant’s employment status" do
          record.income1 = 75_000
          record.ecstat1 = 1
          financial_validator.validate_income1(record)
          expect(record.errors["income1"]).to be_empty
          expect(record.errors["ecstat1"]).to be_empty
          expect(record.errors["ownershipsch"]).to be_empty
          expect(record.errors["la"]).to be_empty
          expect(record.errors["postcode_full"]).to be_empty
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
                .to include(match I18n.t("validations.financial.income1.over_hard_max.inside_london"))
            expect(record.errors["ecstat1"])
                .to include(match I18n.t("validations.financial.income1.over_hard_max.inside_london"))
            expect(record.errors["ownershipsch"])
                .to include(match I18n.t("validations.financial.income1.over_hard_max.inside_london"))
            expect(record.errors["la"])
                .to include(match I18n.t("validations.financial.income1.over_hard_max.inside_london"))
            expect(record.errors["postcode_full"])
                .to include(match I18n.t("validations.financial.income1.over_hard_max.inside_london"))
          end
        end

        it "validates that the income is within the expected range for the tenant’s employment status" do
          record.income1 = 85_000
          record.ecstat1 = 1
          financial_validator.validate_income1(record)
          expect(record.errors["income1"]).to be_empty
          expect(record.errors["ecstat1"]).to be_empty
          expect(record.errors["ownershipsch"]).to be_empty
          expect(record.errors["la"]).to be_empty
          expect(record.errors["postcode_full"]).to be_empty
        end
      end
    end
  end

  describe "#validate_cash_discount" do
    let(:record) { FactoryBot.create(:sales_log) }

    it "adds an error if the cash discount is below zero" do
      record.cashdis = -1
      financial_validator.validate_cash_discount(record)
      expect(record.errors["cashdis"]).to include(match I18n.t("validations.financial.cash_discount_invalid"))
    end

    it "adds an error if the cash discount is one million or more" do
      record.cashdis = 1_000_000
      financial_validator.validate_cash_discount(record)
      expect(record.errors["cashdis"]).to include(match I18n.t("validations.financial.cash_discount_invalid"))
    end

    it "does not add an error if the cash discount is in the expected range" do
      record.cashdis = 10_000
      financial_validator.validate_cash_discount(record)
      expect(record.errors["cashdis"]).to be_empty
    end
  end

  describe "#validate_percentage_bought_not_greater_than_percentage_owned" do
    let(:record) { FactoryBot.create(:sales_log) }

    it "does not add an error if the percentage bought is less than the percentage owned" do
      record.stairbought = 20
      record.stairowned = 40
      financial_validator.validate_percentage_bought_not_greater_than_percentage_owned(record)
      expect(record.errors["stairbought"]).to be_empty
      expect(record.errors["stairowned"]).to be_empty
    end

    it "does not add an error if the percentage bought is equal to the percentage owned" do
      record.stairbought = 30
      record.stairowned = 30
      financial_validator.validate_percentage_bought_not_greater_than_percentage_owned(record)
      expect(record.errors["stairbought"]).to be_empty
      expect(record.errors["stairowned"]).to be_empty
    end

    it "adds an error to stairowned and not stairbought if the percentage bought is more than the percentage owned" do
      record.stairbought = 50
      record.stairowned = 40
      financial_validator.validate_percentage_bought_not_greater_than_percentage_owned(record)
      expect(record.errors["stairowned"]).to include(match I18n.t("validations.financial.staircasing.percentage_bought_must_be_greater_than_percentage_owned"))
    end
  end

  describe "#validate_percentage_owned_not_too_much_if_older_person" do
    let(:record) { FactoryBot.create(:sales_log) }

    context "when log type is not older persons shared ownership" do
      it "does not add an error when percentage owned after staircasing transaction exceeds 75%" do
        record.type = 2
        record.stairowned = 80
        financial_validator.validate_percentage_owned_not_too_much_if_older_person(record)
        expect(record.errors["stairowned"]).to be_empty
        expect(record.errors["type"]).to be_empty
      end
    end

    context "when log type is older persons shared ownership" do
      it "does not add an error when percentage owned after staircasing transaction is less than 75%" do
        record.type = 24
        record.stairowned = 50
        financial_validator.validate_percentage_owned_not_too_much_if_older_person(record)
        expect(record.errors["stairowned"]).to be_empty
        expect(record.errors["type"]).to be_empty
      end

      it "adds an error when percentage owned after staircasing transaction exceeds 75%" do
        record.type = 24
        record.stairowned = 90
        financial_validator.validate_percentage_owned_not_too_much_if_older_person(record)
        expect(record.errors["stairowned"]).to include(match I18n.t("validations.financial.staircasing.older_person_percentage_owned_maximum_75"))
        expect(record.errors["type"]).to include(match I18n.t("validations.financial.staircasing.older_person_percentage_owned_maximum_75"))
      end
    end
  end
end
