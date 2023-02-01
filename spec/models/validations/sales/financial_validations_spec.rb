require "rails_helper"

RSpec.describe Validations::Sales::FinancialValidations do
  subject(:financial_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::Sales::FinancialValidations } }

  describe "income validations for shared ownership" do
    let(:record) { FactoryBot.create(:sales_log, ownershipsch: 1) }

    context "in a non london borough" do
      before do
        record.update!(la: "E08000035")
        record.reload
      end

      it "adds errors if buyer 1's economic status is not child and has income over 80,000" do
        record.income1 = 85_000
        record.ecstat1 = rand(0..8)
        financial_validator.validate_income1(record)
        expect(record.errors["income1"]).to include(match I18n.t("validations.financial.income.over_hard_max", hard_max: 80_000))
        expect(record.errors["ecstat1"]).to include(match I18n.t("validations.financial.income.over_hard_max", hard_max: 80_000))
        expect(record.errors["ownershipsch"]).to include(match I18n.t("validations.financial.income.over_hard_max", hard_max: 80_000))
        expect(record.errors["la"]).to include(match I18n.t("validations.financial.income.over_hard_max", hard_max: 80_000))
        expect(record.errors["postcode_full"]).to include(match I18n.t("validations.financial.income.over_hard_max", hard_max: 80_000))
      end

      it "adds errors if buyer 2's economic status is not child and has income over 80,000" do
        record.income2 = 85_000
        record.ecstat2 = rand(0..8)
        financial_validator.validate_income2(record)
        expect(record.errors["income2"]).to include(match I18n.t("validations.financial.income.over_hard_max", hard_max: 80_000))
        expect(record.errors["ecstat2"]).to include(match I18n.t("validations.financial.income.over_hard_max", hard_max: 80_000))
        expect(record.errors["ownershipsch"]).to include(match I18n.t("validations.financial.income.over_hard_max", hard_max: 80_000))
        expect(record.errors["la"]).to include(match I18n.t("validations.financial.income.over_hard_max", hard_max: 80_000))
        expect(record.errors["postcode_full"]).to include(match I18n.t("validations.financial.income.over_hard_max", hard_max: 80_000))
      end

      it "does not add errors if buyer 1 has not set economic status" do
        record.income1 = 85_000
        financial_validator.validate_income1(record)
        expect(record.errors).to be_empty
      end

      it "does not add errors if buyer 1 has income below 80_000" do
        record.income1 = 75_000
        record.ecstat1 = rand(0..8)
        financial_validator.validate_income1(record)
        expect(record.errors).to be_empty
      end

      it "does not add errors if buyer 2 has not set economic status" do
        record.income2 = 85_000
        financial_validator.validate_income2(record)
        expect(record.errors).to be_empty
      end

      it "does not add errors if buyer 2 has income below 80_000" do
        record.income2 = 75_000
        record.ecstat2 = rand(0..8)
        financial_validator.validate_income2(record)
        expect(record.errors).to be_empty
      end

      it "adds errors when combined income is over 80_000" do
        record.income1 = 45_000
        record.income2 = 40_000
        financial_validator.validate_combined_income(record)
        expect(record.errors["income1"]).to include(match I18n.t("validations.financial.income.combined_over_hard_max", hard_max: 80_000))
        expect(record.errors["income2"]).to include(match I18n.t("validations.financial.income.combined_over_hard_max", hard_max: 80_000))
      end

      it "does not add errors when combined income is under 80_000" do
        record.income1 = 35_000
        record.income2 = 40_000
        financial_validator.validate_combined_income(record)
        expect(record.errors).to be_empty
      end
    end

    context "in a london borough" do
      before do
        record.update!(la: "E09000030")
        record.reload
      end

      it "adds errors if buyer 1's economic status is not child and has income over 90,000" do
        record.income1 = 95_000
        record.ecstat1 = rand(0..8)
        financial_validator.validate_income1(record)
        expect(record.errors["income1"]).to include(match I18n.t("validations.financial.income.over_hard_max", hard_max: 90_000))
        expect(record.errors["ecstat1"]).to include(match I18n.t("validations.financial.income.over_hard_max", hard_max: 90_000))
        expect(record.errors["ownershipsch"]).to include(match I18n.t("validations.financial.income.over_hard_max", hard_max: 90_000))
        expect(record.errors["la"]).to include(match I18n.t("validations.financial.income.over_hard_max", hard_max: 90_000))
        expect(record.errors["postcode_full"]).to include(match I18n.t("validations.financial.income.over_hard_max", hard_max: 90_000))
      end

      it "adds errors if buyer 2's economic status is not child and has income over 90,000" do
        record.income2 = 95_000
        record.ecstat2 = rand(0..8)
        financial_validator.validate_income2(record)
        expect(record.errors["income2"]).to include(match I18n.t("validations.financial.income.over_hard_max", hard_max: 90_000))
        expect(record.errors["ecstat2"]).to include(match I18n.t("validations.financial.income.over_hard_max", hard_max: 90_000))
        expect(record.errors["ownershipsch"]).to include(match I18n.t("validations.financial.income.over_hard_max", hard_max: 90_000))
        expect(record.errors["la"]).to include(match I18n.t("validations.financial.income.over_hard_max", hard_max: 90_000))
        expect(record.errors["postcode_full"]).to include(match I18n.t("validations.financial.income.over_hard_max", hard_max: 90_000))
      end

      it "does not add errors if buyer 1 has not set economic status" do
        record.income1 = 95_000
        financial_validator.validate_income1(record)
        expect(record.errors).to be_empty
      end

      it "does not add errors if buyer 1 has income below 90_000" do
        record.income1 = 75_000
        record.ecstat1 = rand(0..8)
        financial_validator.validate_income1(record)
        expect(record.errors).to be_empty
      end

      it "does not add errors if buyer 2 has not set economic status" do
        record.income2 = 95_000
        financial_validator.validate_income2(record)
        expect(record.errors).to be_empty
      end

      it "does not add errors if buyer 2 has income below 90_000" do
        record.income2 = 75_000
        record.ecstat2 = rand(0..8)
        financial_validator.validate_income2(record)
        expect(record.errors).to be_empty
      end

      it "adds errors when combined income is over 90_000" do
        record.income1 = 55_000
        record.income2 = 40_000
        financial_validator.validate_combined_income(record)
        expect(record.errors["income1"]).to include(match I18n.t("validations.financial.income.combined_over_hard_max", hard_max: 90_000))
        expect(record.errors["income2"]).to include(match I18n.t("validations.financial.income.combined_over_hard_max", hard_max: 90_000))
      end

      it "does not add errors when combined income is under 90_000" do
        record.income1 = 35_000
        record.income2 = 40_000
        financial_validator.validate_combined_income(record)
        expect(record.errors).to be_empty
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
