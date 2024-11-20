require "rails_helper"

RSpec.describe Validations::Sales::FinancialValidations do
  subject(:financial_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::Sales::FinancialValidations } }

  describe "income validations for shared ownership" do
    let(:record) { FactoryBot.build(:sales_log, ownershipsch: 1) }

    context "when buying in a non london borough" do
      before do
        record.la = "E08000035"
      end

      it "adds errors if buyer 1 has income over 80,000" do
        record.income1 = 85_000
        financial_validator.validate_income1(record)
        expect(record.errors["income1"]).to include(match I18n.t("validations.sales.financial.income1.outside_non_london_income_range"))
        expect(record.errors["ownershipsch"]).to include(match I18n.t("validations.sales.financial.ownershipsch.outside_non_london_income_range"))
        expect(record.errors["la"]).to include(match I18n.t("validations.sales.financial.la.outside_non_london_income_range"))
        expect(record.errors["postcode_full"]).to include(match I18n.t("validations.sales.financial.postcode_full.outside_non_london_income_range"))
        expect(record.errors["uprn_selection"]).to include(match I18n.t("validations.sales.financial.uprn_selection.outside_non_london_income_range"))
      end

      it "adds errors if buyer 2 has income over 80,000" do
        record.income2 = 85_000
        financial_validator.validate_income2(record)
        expect(record.errors["income2"]).to include(match I18n.t("validations.sales.financial.income2.outside_non_london_income_range"))
        expect(record.errors["ownershipsch"]).to include(match I18n.t("validations.sales.financial.ownershipsch.outside_non_london_income_range"))
        expect(record.errors["la"]).to include(match I18n.t("validations.sales.financial.la.outside_non_london_income_range"))
        expect(record.errors["postcode_full"]).to include(match I18n.t("validations.sales.financial.postcode_full.outside_non_london_income_range"))
        expect(record.errors["uprn_selection"]).to include(match I18n.t("validations.sales.financial.uprn_selection.outside_non_london_income_range"))
      end

      it "does not add errors if buyer 1 has income above 0 and below 80_000" do
        record.income1 = 75_000
        financial_validator.validate_income1(record)
        expect(record.errors).to be_empty
      end

      it "does not add errors if buyer 2 has income above 0 and below 80_000" do
        record.income2 = 75_000
        financial_validator.validate_income2(record)
        expect(record.errors).to be_empty
      end

      it "adds errors if buyer 1 has income below 0" do
        record.income1 = -500
        financial_validator.validate_income1(record)
        expect(record.errors["income1"]).to include(match I18n.t("validations.sales.financial.income1.outside_non_london_income_range"))
        expect(record.errors["ownershipsch"]).to include(match I18n.t("validations.sales.financial.ownershipsch.outside_non_london_income_range"))
        expect(record.errors["la"]).to include(match I18n.t("validations.sales.financial.la.outside_non_london_income_range"))
        expect(record.errors["postcode_full"]).to include(match I18n.t("validations.sales.financial.postcode_full.outside_non_london_income_range"))
        expect(record.errors["uprn_selection"]).to include(match I18n.t("validations.sales.financial.uprn_selection.outside_non_london_income_range"))
      end

      it "adds errors if buyer 2 has income below 0" do
        record.income2 = -5
        financial_validator.validate_income2(record)
        expect(record.errors["income2"]).to include(match I18n.t("validations.sales.financial.income2.outside_non_london_income_range"))
        expect(record.errors["ownershipsch"]).to include(match I18n.t("validations.sales.financial.ownershipsch.outside_non_london_income_range"))
        expect(record.errors["la"]).to include(match I18n.t("validations.sales.financial.la.outside_non_london_income_range"))
        expect(record.errors["postcode_full"]).to include(match I18n.t("validations.sales.financial.postcode_full.outside_non_london_income_range"))
        expect(record.errors["uprn_selection"]).to include(match I18n.t("validations.sales.financial.uprn_selection.outside_non_london_income_range"))
      end

      it "adds errors when combined income is over 80_000" do
        record.income1 = 45_000
        record.income2 = 40_000
        financial_validator.validate_combined_income(record)
        expect(record.errors["income1"]).to include(match I18n.t("validations.sales.financial.income1.combined_over_hard_max_for_outside_london"))
        expect(record.errors["income2"]).to include(match I18n.t("validations.sales.financial.income2.combined_over_hard_max_for_outside_london"))
      end

      it "does not add errors when combined income is under 80_000" do
        record.income1 = 35_000
        record.income2 = 40_000
        financial_validator.validate_combined_income(record)
        expect(record.errors).to be_empty
      end
    end

    context "when buying in a london borough" do
      before do
        record.la = "E09000030"
      end

      it "adds errors if buyer 1 has income over 90,000" do
        record.income1 = 95_000
        financial_validator.validate_income1(record)
        expect(record.errors["income1"]).to include(match I18n.t("validations.sales.financial.income1.outside_london_income_range"))
        expect(record.errors["ownershipsch"]).to include(match I18n.t("validations.sales.financial.ownershipsch.outside_london_income_range"))
        expect(record.errors["la"]).to include(match I18n.t("validations.sales.financial.la.outside_london_income_range"))
        expect(record.errors["postcode_full"]).to include(match I18n.t("validations.sales.financial.postcode_full.outside_london_income_range"))
        expect(record.errors["uprn_selection"]).to include(match I18n.t("validations.sales.financial.uprn_selection.outside_london_income_range"))
      end

      it "adds errors if buyer 2 has income over 90,000" do
        record.income2 = 95_000
        financial_validator.validate_income2(record)
        expect(record.errors["income2"]).to include(match I18n.t("validations.sales.financial.income2.outside_london_income_range"))
        expect(record.errors["ownershipsch"]).to include(match I18n.t("validations.sales.financial.ownershipsch.outside_london_income_range"))
        expect(record.errors["la"]).to include(match I18n.t("validations.sales.financial.la.outside_london_income_range"))
        expect(record.errors["postcode_full"]).to include(match I18n.t("validations.sales.financial.postcode_full.outside_london_income_range"))
        expect(record.errors["uprn_selection"]).to include(match I18n.t("validations.sales.financial.uprn_selection.outside_london_income_range"))
      end

      it "does not add errors if buyer 1 has income above 0 and below 90_000" do
        record.income1 = 75_000
        financial_validator.validate_income1(record)
        expect(record.errors).to be_empty
      end

      it "does not add errors if buyer 2 has income above 0 and below 90_000" do
        record.income2 = 75_000
        financial_validator.validate_income2(record)
        expect(record.errors).to be_empty
      end

      it "adds errors if buyer 1 has income below 0" do
        record.income1 = -500
        financial_validator.validate_income1(record)
        expect(record.errors["income1"]).to include(match I18n.t("validations.sales.financial.income1.outside_london_income_range"))
        expect(record.errors["ownershipsch"]).to include(match I18n.t("validations.sales.financial.ownershipsch.outside_london_income_range"))
        expect(record.errors["la"]).to include(match I18n.t("validations.sales.financial.la.outside_london_income_range"))
        expect(record.errors["postcode_full"]).to include(match I18n.t("validations.sales.financial.postcode_full.outside_london_income_range"))
        expect(record.errors["uprn_selection"]).to include(match I18n.t("validations.sales.financial.uprn_selection.outside_london_income_range"))
      end

      it "adds errors if buyer 2 has income below 0" do
        record.income2 = -2
        financial_validator.validate_income2(record)
        expect(record.errors["income2"]).to include(match I18n.t("validations.sales.financial.income2.outside_london_income_range"))
        expect(record.errors["ownershipsch"]).to include(match I18n.t("validations.sales.financial.ownershipsch.outside_london_income_range"))
        expect(record.errors["la"]).to include(match I18n.t("validations.sales.financial.la.outside_london_income_range"))
        expect(record.errors["postcode_full"]).to include(match I18n.t("validations.sales.financial.postcode_full.outside_london_income_range"))
        expect(record.errors["uprn_selection"]).to include(match I18n.t("validations.sales.financial.uprn_selection.outside_london_income_range"))
      end

      it "adds errors when combined income is over 90_000" do
        record.income1 = 55_000
        record.income2 = 40_000
        financial_validator.validate_combined_income(record)
        expect(record.errors["income1"]).to include(match I18n.t("validations.sales.financial.income1.combined_over_hard_max_for_london"))
        expect(record.errors["income2"]).to include(match I18n.t("validations.sales.financial.income2.combined_over_hard_max_for_london"))
      end

      it "does not add errors when combined income is under 90_000" do
        record.income1 = 35_000
        record.income2 = 40_000
        financial_validator.validate_combined_income(record)
        expect(record.errors).to be_empty
      end
    end
  end

  describe "#validate_mortgage" do
    let(:record) { FactoryBot.build(:sales_log) }

    it "adds an error is the mortgage is zero" do
      record.mortgageused = 1
      record.mortgage = 0
      financial_validator.validate_mortgage(record)
      expect(record.errors[:mortgage]).to include I18n.t("validations.sales.financial.mortgage.mortgage_zero")
    end

    it "does not add an error is the mortgage is positive" do
      record.mortgageused = 1
      record.mortgage = 234
      financial_validator.validate_mortgage(record)
      expect(record.errors).to be_empty
    end
  end

  describe "#validate_percentage_bought_not_greater_than_percentage_owned" do
    let(:record) { FactoryBot.build(:sales_log) }

    it "does not add an error if the percentage bought is less than the percentage owned" do
      record.stairbought = 20
      record.stairowned = 40
      financial_validator.validate_percentage_bought_not_greater_than_percentage_owned(record)
      expect(record.errors).to be_empty
    end

    it "does not add an error if the percentage bought is equal to the percentage owned" do
      record.stairbought = 30
      record.stairowned = 30
      financial_validator.validate_percentage_bought_not_greater_than_percentage_owned(record)
      expect(record.errors).to be_empty
    end

    it "adds an error to stairowned and not stairbought if the percentage bought is more than the percentage owned for joint purchase" do
      record.stairbought = 50
      record.stairowned = 40
      record.jointpur = 1
      financial_validator.validate_percentage_bought_not_greater_than_percentage_owned(record)
      expect(record.errors["stairowned"]).to include(I18n.t("validations.sales.financial.stairowned.percentage_bought_must_be_greater_than_percentage_owned.joint_purchase"))
    end

    it "adds an error to stairowned and not stairbought if the percentage bought is more than the percentage owned for non joint purchase" do
      record.stairbought = 50
      record.stairowned = 40
      record.jointpur = 2
      financial_validator.validate_percentage_bought_not_greater_than_percentage_owned(record)
      expect(record.errors["stairowned"]).to include(I18n.t("validations.sales.financial.stairowned.percentage_bought_must_be_greater_than_percentage_owned.not_joint_purchase"))
    end
  end

  describe "#validate_percentage_bought_not_equal_percentage_owned" do
    let(:record) { FactoryBot.build(:sales_log) }

    context "with 24/25 logs" do
      before do
        record.saledate = Time.zone.local(2024, 4, 3)
      end

      it "does not add an error if the percentage bought is less than the percentage owned" do
        record.stairbought = 20
        record.stairowned = 40
        financial_validator.validate_percentage_bought_not_equal_percentage_owned(record)
        expect(record.errors).to be_empty
      end

      it "adds an error if the percentage bought is equal to the percentage owned" do
        record.stairbought = 30
        record.stairowned = 30
        financial_validator.validate_percentage_bought_not_equal_percentage_owned(record)
        expect(record.errors["stairowned"]).to eq([I18n.t("validations.sales.financial.stairowned.percentage_bought_equal_percentage_owned", stairbought: 30, stairowned: 30)])
        expect(record.errors["stairbought"]).to eq([I18n.t("validations.sales.financial.stairbought.percentage_bought_equal_percentage_owned", stairbought: 30, stairowned: 30)])
      end

      it "does not add an error to stairowned and not stairbought if the percentage bought is more than the percentage owned" do
        record.stairbought = 50
        record.stairowned = 40
        financial_validator.validate_percentage_bought_not_equal_percentage_owned(record)
        expect(record.errors).to be_empty
      end
    end

    context "with 23/24 logs" do
      before do
        record.saledate = Time.zone.local(2023, 4, 3)
      end

      it "does not add an error if the percentage bought is equal to the percentage owned" do
        record.stairbought = 30
        record.stairowned = 30
        financial_validator.validate_percentage_bought_not_equal_percentage_owned(record)
        expect(record.errors).to be_empty
      end
    end
  end

  describe "#validate_monthly_leasehold_charges" do
    let(:record) { FactoryBot.build(:sales_log) }

    it "does not add an error if monthly leasehold charges are positive" do
      record.mscharge = 2345
      financial_validator.validate_monthly_leasehold_charges(record)
      expect(record.errors).to be_empty
    end

    it "adds an error if monthly leasehold charges are zero" do
      record.mscharge = 0
      financial_validator.validate_monthly_leasehold_charges(record)
      expect(record.errors[:mscharge]).to include I18n.t("validations.sales.financial.mscharge.monthly_leasehold_charges.not_zero")
    end
  end

  describe "#validate_percentage_bought_at_least_threshold" do
    let(:record) { FactoryBot.build(:sales_log) }

    it "adds an error to stairbought and type if the percentage bought is less than the threshold (which is 1% by default, but higher for some shared ownership types)" do
      record.stairbought = 9
      [2, 16, 18, 24].each do |type|
        record.type = type
        shared_ownership_type = record.form.get_question("type", record).label_from_value(record.type).downcase
        financial_validator.validate_percentage_bought_at_least_threshold(record)
        expect(record.errors["stairbought"]).to eq([I18n.t("validations.sales.financial.stairbought.percentage_bought_must_be_at_least_threshold", threshold: 10, shared_ownership_type:)])
        expect(record.errors["type"]).to eq([I18n.t("validations.sales.financial.type.percentage_bought_must_be_at_least_threshold", threshold: 10, shared_ownership_type:)])
        record.errors.clear
      end

      record.stairbought = 0
      [28, 30, 31, 32].each do |type|
        record.type = type
        shared_ownership_type = record.form.get_question("type", record).label_from_value(record.type).downcase
        financial_validator.validate_percentage_bought_at_least_threshold(record)
        expect(record.errors["stairbought"]).to eq([I18n.t("validations.sales.financial.stairbought.percentage_bought_must_be_at_least_threshold", threshold: 1, shared_ownership_type:)])
        expect(record.errors["type"]).to eq([I18n.t("validations.sales.financial.type.percentage_bought_must_be_at_least_threshold", threshold: 1, shared_ownership_type:)])
        record.errors.clear
      end
    end

    it "doesn't add an error to stairbought and type if the percentage bought is less than the threshold (which is 1% by default, but higher for some shared ownership types)" do
      record.stairbought = 10
      [2, 16, 18, 24].each do |type|
        record.type = type
        financial_validator.validate_percentage_bought_at_least_threshold(record)
        expect(record.errors).to be_empty
        record.errors.clear
      end

      record.stairbought = 1
      [28, 30, 31, 32].each do |type|
        record.type = type
        financial_validator.validate_percentage_bought_at_least_threshold(record)
        expect(record.errors).to be_empty
        record.errors.clear
      end
    end
  end

  describe "#validate_child_income" do
    let(:record) { FactoryBot.build(:sales_log) }

    context "when buyer 2 is not a child" do
      before do
        record.ecstat2 = rand(0..8)
      end

      it "does not add an error if buyer 2 has an income" do
        record.income2 = 40_000
        financial_validator.validate_child_income(record)
        expect(record.errors).to be_empty
      end
    end

    context "when buyer 2 is a child" do
      let(:record) { build(:sales_log, :saledate_today, ecstat2: 9) }

      it "does not add an error if buyer 2 has no income" do
        record.income2 = 0
        financial_validator.validate_child_income(record)
        expect(record.errors).to be_empty
      end

      it "adds errors if buyer 2 has an income" do
        record.income2 = 40_000
        financial_validator.validate_child_income(record)
        expect(record.errors["ecstat2"]).to include(match I18n.t("validations.sales.financial.ecstat2.child_has_income"))
        expect(record.errors["income2"]).to include(match I18n.t("validations.sales.financial.income2.child_has_income"))
      end
    end
  end

  describe "#validate_equity_in_range_for_year_and_type" do
    let(:record) { FactoryBot.build(:sales_log, saledate:, resale: nil) }

    context "with a log in the 22/23 collection year" do
      let(:saledate) { Time.zone.local(2023, 1, 1) }

      it "adds an error for type 2, equity below min with the correct percentage" do
        record.type = 2
        record.equity = 1
        financial_validator.validate_equity_in_range_for_year_and_type(record)
        expect(record.errors["equity"]).to include(match I18n.t("validations.sales.financial.equity.equity_under_min", min_equity: 25))
        expect(record.errors["type"]).to include(match I18n.t("validations.sales.financial.type.equity_under_min", min_equity: 25))
      end

      it "adds an error for type 30, equity below min with the correct percentage" do
        record.type = 30
        record.equity = 1
        financial_validator.validate_equity_in_range_for_year_and_type(record)
        expect(record.errors["equity"]).to include(match I18n.t("validations.sales.financial.equity.equity_under_min", min_equity: 10))
        expect(record.errors["type"]).to include(match I18n.t("validations.sales.financial.type.equity_under_min", min_equity: 10))
      end

      it "does not add an error for equity in range with the correct percentage" do
        record.type = 2
        record.equity = 50
        financial_validator.validate_equity_in_range_for_year_and_type(record)
        expect(record.errors).to be_empty
      end

      it "adds an error for equity above max with the correct percentage" do
        record.type = 2
        record.equity = 90
        financial_validator.validate_equity_in_range_for_year_and_type(record)
        expect(record.errors["equity"]).to include(match I18n.t("validations.sales.financial.equity.equity_over_max", max_equity: 75))
        expect(record.errors["type"]).to include(match I18n.t("validations.sales.financial.type.equity_over_max", max_equity: 75))
      end

      it "does not add an error if it's a resale" do
        record.type = 2
        record.equity = 90
        record.resale = 1
        financial_validator.validate_equity_in_range_for_year_and_type(record)
        expect(record.errors).to be_empty
      end
    end

    context "with a log in 23/24 collection year" do
      let(:saledate) { Time.zone.local(2024, 1, 1) }

      it "adds an error for type 2, equity below min with the correct percentage" do
        record.type = 2
        record.equity = 1
        financial_validator.validate_equity_in_range_for_year_and_type(record)
        expect(record.errors["equity"]).to include(match I18n.t("validations.sales.financial.equity.equity_under_min", min_equity: 25))
        expect(record.errors["type"]).to include(match I18n.t("validations.sales.financial.type.equity_under_min", min_equity: 25))
      end

      it "adds an error for type 30, equity below min with the correct percentage" do
        record.type = 30
        record.equity = 1
        financial_validator.validate_equity_in_range_for_year_and_type(record)
        expect(record.errors["equity"]).to include(match I18n.t("validations.sales.financial.equity.equity_under_min", min_equity: 10))
        expect(record.errors["type"]).to include(match I18n.t("validations.sales.financial.type.equity_under_min", min_equity: 10))
      end

      it "does not add an error for equity in range with the correct percentage" do
        record.type = 2
        record.equity = 50
        financial_validator.validate_equity_in_range_for_year_and_type(record)
        expect(record.errors).to be_empty
      end

      it "adds an error for equity above max with the correct percentage" do
        record.type = 2
        record.equity = 90
        financial_validator.validate_equity_in_range_for_year_and_type(record)
        expect(record.errors["equity"]).to include(match I18n.t("validations.sales.financial.equity.equity_over_max", max_equity: 75))
        expect(record.errors["type"]).to include(match I18n.t("validations.sales.financial.type.equity_over_max", max_equity: 75))
      end
    end
  end

  describe "#validate_equity_less_than_staircase_difference" do
    let(:record) { FactoryBot.build(:sales_log, saledate:) }

    context "with a log in the 23/24 collection year" do
      let(:saledate) { Time.zone.local(2023, 4, 1) }

      it "does not add an error" do
        record.stairbought = 2
        record.stairowned = 3
        record.equity = 2
        financial_validator.validate_equity_less_than_staircase_difference(record)
        expect(record.errors).to be_empty
      end
    end

    context "with a log in 24/25 collection year" do
      let(:saledate) { Time.zone.local(2024, 4, 1) }

      it "adds errors if equity is more than stairowned - stairbought for joint purchase" do
        record.stairbought = 2.5
        record.stairowned = 3
        record.equity = 2
        record.jointpur = 1
        financial_validator.validate_equity_less_than_staircase_difference(record)
        expect(record.errors["equity"]).to include(I18n.t("validations.sales.financial.equity.equity_over_stairowned_minus_stairbought.joint_purchase", equity: 2, staircase_difference: 0.5))
        expect(record.errors["stairowned"]).to include(I18n.t("validations.sales.financial.stairowned.equity_over_stairowned_minus_stairbought.joint_purchase", equity: 2, staircase_difference: 0.5))
        expect(record.errors["stairbought"]).to include(I18n.t("validations.sales.financial.stairbought.equity_over_stairowned_minus_stairbought.joint_purchase", equity: 2, staircase_difference: 0.5))
      end

      it "adds errors if equity is more than stairowned - stairbought for non joint purchase" do
        record.stairbought = 2
        record.stairowned = 3
        record.equity = 2.5
        record.jointpur = 2
        financial_validator.validate_equity_less_than_staircase_difference(record)
        expect(record.errors["equity"]).to include(I18n.t("validations.sales.financial.equity.equity_over_stairowned_minus_stairbought.not_joint_purchase", equity: 2.5, staircase_difference: 1.0))
        expect(record.errors["stairowned"]).to include(I18n.t("validations.sales.financial.stairowned.equity_over_stairowned_minus_stairbought.not_joint_purchase", equity: 2.5, staircase_difference: 1.0))
        expect(record.errors["stairbought"]).to include(I18n.t("validations.sales.financial.stairbought.equity_over_stairowned_minus_stairbought.not_joint_purchase", equity: 2.5, staircase_difference: 1.0))
      end

      it "does not add errors if equity is less than stairowned - stairbought" do
        record.stairbought = 2
        record.stairowned = 10
        record.equity = 2
        financial_validator.validate_equity_less_than_staircase_difference(record)
        expect(record.errors).to be_empty
      end

      it "does not add errors if equity is equal stairowned - stairbought" do
        record.stairbought = 2
        record.stairowned = 10
        record.equity = 8
        financial_validator.validate_equity_less_than_staircase_difference(record)
        expect(record.errors).to be_empty
      end

      it "does not add errors if stairbought is not given" do
        record.stairbought = nil
        record.stairowned = 10
        record.equity = 2
        financial_validator.validate_equity_less_than_staircase_difference(record)
        expect(record.errors).to be_empty
      end

      it "does not add errors if stairowned is not given" do
        record.stairbought = 2
        record.stairowned = nil
        record.equity = 2
        financial_validator.validate_equity_less_than_staircase_difference(record)
        expect(record.errors).to be_empty
      end

      it "does not add errors if equity is not given" do
        record.stairbought = 2
        record.stairowned = 10
        record.equity = 0
        financial_validator.validate_equity_less_than_staircase_difference(record)
        expect(record.errors).to be_empty
      end
    end
  end
end
