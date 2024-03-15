require "rails_helper"

RSpec.describe Validations::Sales::SaleInformationValidations do
  subject(:sale_information_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::Sales::SaleInformationValidations } }

  describe "#validate_practical_completion_date" do
    context "when hodate blank" do
      let(:record) { build(:sales_log, hodate: nil) }

      it "does not add an error" do
        sale_information_validator.validate_practical_completion_date(record)

        expect(record.errors).not_to be_present
      end
    end

    context "when saledate blank" do
      let(:record) { build(:sales_log, saledate: nil) }

      it "does not add an error" do
        sale_information_validator.validate_practical_completion_date(record)

        expect(record.errors).not_to be_present
      end
    end

    context "when saledate and hodate blank" do
      let(:record) { build(:sales_log, hodate: nil, saledate: nil) }

      it "does not add an error" do
        sale_information_validator.validate_practical_completion_date(record)

        expect(record.errors).not_to be_present
      end
    end

    context "when hodate invalid" do
      let(:record) { build(:sales_log, hodate: Date.new(0, 1, 1)) }

      it "adds an error" do
        sale_information_validator.validate_practical_completion_date(record)

        expect(record.errors[:hodate]).to be_present
      end
    end

    context "when hodate less than 3 years before saledate" do
      let(:record) { build(:sales_log, hodate: Date.new(2021, 12, 2), saledate: Date.new(2024, 12, 1)) }

      it "does not add an error" do
        sale_information_validator.validate_practical_completion_date(record)

        expect(record.errors).not_to be_present
      end
    end

    context "when hodate 3 or more years before saledate" do
      context "and form year is 2023 or earlier" do
        let(:record) { build(:sales_log, hodate: Date.new(2020, 12, 1), saledate: Date.new(2023, 12, 1)) }

        it "does not add an error" do
          sale_information_validator.validate_practical_completion_date(record)

          expect(record.errors).not_to be_present
        end
      end

      context "and form year is 2024 or later" do
        let(:record) { build(:sales_log, hodate: Date.new(2021, 12, 1), saledate: Date.new(2024, 12, 1)) }

        it "adds an error" do
          sale_information_validator.validate_practical_completion_date(record)

          expect(record.errors[:hodate]).to be_present
        end
      end
    end

    context "when hodate after saledate" do
      let(:record) { build(:sales_log, hodate: 1.month.ago, saledate: 2.months.ago) }

      it "adds an error" do
        sale_information_validator.validate_practical_completion_date(record)

        expect(record.errors[:hodate]).to be_present
      end
    end

    context "when hodate == saledate" do
      let(:record) { build(:sales_log, hodate: Time.zone.parse("2023-07-01"), saledate: Time.zone.parse("2023-07-01")) }

      it "does not add an error" do
        sale_information_validator.validate_practical_completion_date(record)

        expect(record.errors[:hodate]).not_to be_present
      end
    end
  end

  describe "#validate_exchange_date" do
    context "when exdate blank" do
      let(:record) { build(:sales_log, exdate: nil) }

      it "does not add an error" do
        sale_information_validator.validate_exchange_date(record)

        expect(record.errors[:exdate]).not_to be_present
      end
    end

    context "when saledate blank" do
      let(:record) { build(:sales_log, saledate: nil) }

      it "does not add an error" do
        sale_information_validator.validate_exchange_date(record)

        expect(record.errors[:exdate]).not_to be_present
      end
    end

    context "when saledate and exdate blank" do
      let(:record) { build(:sales_log, exdate: nil, saledate: nil) }

      it "does not add an error" do
        sale_information_validator.validate_exchange_date(record)

        expect(record.errors[:exdate]).not_to be_present
      end
    end

    context "when exdate before saledate" do
      let(:record) { build(:sales_log, exdate: 2.months.ago, saledate: 1.month.ago) }

      it "does not add the error" do
        sale_information_validator.validate_exchange_date(record)

        expect(record.errors[:exdate]).not_to be_present
      end
    end

    context "when exdate more than 1 year before saledate" do
      let(:record) { build(:sales_log, exdate: 2.years.ago, saledate: 1.month.ago) }

      it "adds error" do
        sale_information_validator.validate_exchange_date(record)

        expect(record.errors[:exdate]).to eq(
          ["Contract exchange date must be less than 1 year before sale completion date"],
        )
        expect(record.errors[:saledate]).to eq(
          ["Sale completion date must be less than 1 year after contract exchange date"],
        )
      end
    end

    context "when exdate after saledate" do
      let(:record) { build(:sales_log, exdate: 1.month.ago, saledate: 2.months.ago) }

      it "adds error" do
        sale_information_validator.validate_exchange_date(record)

        expect(record.errors[:exdate]).to eq(
          ["Contract exchange date must be before sale completion date"],
        )
        expect(record.errors[:saledate]).to eq(
          ["Sale completion date must be after contract exchange date"],
        )
      end
    end

    context "when exdate == saledate" do
      let(:record) { build(:sales_log, exdate: Time.zone.parse("2023-07-01"), saledate: Time.zone.parse("2023-07-01")) }

      it "does not add an error" do
        sale_information_validator.validate_exchange_date(record)

        expect(record.errors[:exdate]).not_to be_present
      end
    end
  end

  describe "#validate_previous_property_unit_type" do
    context "when number of bedrooms is <= 1" do
      let(:record) { FactoryBot.build(:sales_log, frombeds: 1, fromprop: 2) }

      it "does not add an error if it's a bedsit" do
        sale_information_validator.validate_previous_property_unit_type(record)

        expect(record.errors).to be_empty
      end
    end

    context "when number of bedrooms is > 1" do
      let(:record) { FactoryBot.build(:sales_log, frombeds: 2, fromprop: 2) }

      it "does add an error if it's a bedsit" do
        sale_information_validator.validate_previous_property_unit_type(record)
        expect(record.errors["fromprop"]).to include(I18n.t("validations.sale_information.previous_property_type.property_type_bedsit"))
        expect(record.errors["frombeds"]).to include(I18n.t("validations.sale_information.previous_property_type.property_type_bedsit"))
      end
    end
  end

  describe "#validate_discounted_ownership_value" do
    let(:record) { FactoryBot.build(:sales_log, mortgage: 10_000, deposit: 5_000, value: 30_000, ownershipsch: 2, type: 8, saledate: now) }

    around do |example|
      Timecop.freeze(now) do
        example.run
      end
      Timecop.return
    end

    context "with a log in the 24/25 collection year" do
      let(:now) { Time.zone.local(2024, 4, 1) }

      context "when grant is routed to" do
        context "and not provided" do
          before do
            record.grant = nil
          end

          it "returns false" do
            sale_information_validator.validate_discounted_ownership_value(record)
            expect(record.errors["mortgageused"]).to be_empty
            expect(record.errors["mortgage"]).to be_empty
            expect(record.errors["value"]).to be_empty
            expect(record.errors["deposit"]).to be_empty
            expect(record.errors["ownershipsch"]).to be_empty
            expect(record.errors["discount"]).to be_empty
            expect(record.errors["grant"]).to be_empty
          end
        end

        context "and is provided" do
          it "returns true if mortgage, deposit and grant total does not equal market value" do
            record.grant = 3_000
            sale_information_validator.validate_discounted_ownership_value(record)
            expect(record.errors["mortgageused"]).to include("The mortgage, deposit, and grant when added together is £18,000.00, and the purchase purchase price times by the discount is £30,000.00. These figures should be the same")
            expect(record.errors["mortgage"]).to include("The mortgage, deposit, and grant when added together is £18,000.00, and the purchase purchase price times by the discount is £30,000.00. These figures should be the same")
            expect(record.errors["value"]).to include("The mortgage, deposit, and grant when added together is £18,000.00, and the purchase purchase price times by the discount is £30,000.00. These figures should be the same")
            expect(record.errors["deposit"]).to include("The mortgage, deposit, and grant when added together is £18,000.00, and the purchase purchase price times by the discount is £30,000.00. These figures should be the same")
            expect(record.errors["ownershipsch"]).to include("The mortgage, deposit, and grant when added together is £18,000.00, and the purchase purchase price times by the discount is £30,000.00. These figures should be the same")
            expect(record.errors["discount"]).to include("The mortgage, deposit, and grant when added together is £18,000.00, and the purchase purchase price times by the discount is £30,000.00. These figures should be the same")
            expect(record.errors["grant"]).to include("The mortgage, deposit, and grant when added together is £18,000.00, and the purchase purchase price times by the discount is £30,000.00. These figures should be the same")
          end

          it "returns false if mortgage, deposit and grant total equals market value" do
            record.grant = 15_000
            sale_information_validator.validate_discounted_ownership_value(record)
            expect(record.errors["mortgageused"]).to be_empty
            expect(record.errors["mortgage"]).to be_empty
            expect(record.errors["value"]).to be_empty
            expect(record.errors["deposit"]).to be_empty
            expect(record.errors["ownershipsch"]).to be_empty
            expect(record.errors["discount"]).to be_empty
            expect(record.errors["grant"]).to be_empty
          end
        end
      end

      context "when discount is routed to" do
        let(:record) { FactoryBot.build(:sales_log, mortgage: 10_000, deposit: 5_000, value: 30_000, ownershipsch: 2, type: 9, saledate: now) }

        context "and not provided" do
          before do
            record.discount = nil
          end

          it "returns false" do
            sale_information_validator.validate_discounted_ownership_value(record)
            expect(record.errors["mortgageused"]).to be_empty
            expect(record.errors["mortgage"]).to be_empty
            expect(record.errors["value"]).to be_empty
            expect(record.errors["deposit"]).to be_empty
            expect(record.errors["ownershipsch"]).to be_empty
            expect(record.errors["discount"]).to be_empty
            expect(record.errors["grant"]).to be_empty
          end
        end

        context "and is provided" do
          it "returns true if mortgage and deposit total does not equal market value - discount" do
            record.discount = 10
            sale_information_validator.validate_discounted_ownership_value(record)
            expect(record.errors["mortgageused"]).to include("The mortgage, deposit, and grant when added together is £15,000.00, and the purchase purchase price times by the discount is £27,000.00. These figures should be the same")
            expect(record.errors["mortgage"]).to include("The mortgage, deposit, and grant when added together is £15,000.00, and the purchase purchase price times by the discount is £27,000.00. These figures should be the same")
            expect(record.errors["value"]).to include("The mortgage, deposit, and grant when added together is £15,000.00, and the purchase purchase price times by the discount is £27,000.00. These figures should be the same")
            expect(record.errors["deposit"]).to include("The mortgage, deposit, and grant when added together is £15,000.00, and the purchase purchase price times by the discount is £27,000.00. These figures should be the same")
            expect(record.errors["ownershipsch"]).to include("The mortgage, deposit, and grant when added together is £15,000.00, and the purchase purchase price times by the discount is £27,000.00. These figures should be the same")
            expect(record.errors["discount"]).to include("The mortgage, deposit, and grant when added together is £15,000.00, and the purchase purchase price times by the discount is £27,000.00. These figures should be the same")
            expect(record.errors["grant"]).to include("The mortgage, deposit, and grant when added together is £15,000.00, and the purchase purchase price times by the discount is £27,000.00. These figures should be the same")
          end

          it "returns false if mortgage and deposit total equals market value - discount" do
            record.discount = 50
            sale_information_validator.validate_discounted_ownership_value(record)
            expect(record.errors["mortgageused"]).to be_empty
            expect(record.errors["mortgage"]).to be_empty
            expect(record.errors["value"]).to be_empty
            expect(record.errors["deposit"]).to be_empty
            expect(record.errors["ownershipsch"]).to be_empty
            expect(record.errors["discount"]).to be_empty
            expect(record.errors["grant"]).to be_empty
          end
        end
      end

      context "when neither discount nor grant is routed to" do
        let(:record) { FactoryBot.build(:sales_log, mortgage: 10_000, value: 30_000, ownershipsch: 2, type: 29, saledate: now) }

        it "returns true if mortgage and deposit total does not equal market value" do
          record.deposit = 2_000
          sale_information_validator.validate_discounted_ownership_value(record)
          expect(record.errors["mortgageused"]).to include("The mortgage, deposit, and grant when added together is £12,000.00, and the purchase purchase price times by the discount is £30,000.00. These figures should be the same")
          expect(record.errors["mortgage"]).to include("The mortgage, deposit, and grant when added together is £12,000.00, and the purchase purchase price times by the discount is £30,000.00. These figures should be the same")
          expect(record.errors["value"]).to include("The mortgage, deposit, and grant when added together is £12,000.00, and the purchase purchase price times by the discount is £30,000.00. These figures should be the same")
          expect(record.errors["deposit"]).to include("The mortgage, deposit, and grant when added together is £12,000.00, and the purchase purchase price times by the discount is £30,000.00. These figures should be the same")
          expect(record.errors["ownershipsch"]).to include("The mortgage, deposit, and grant when added together is £12,000.00, and the purchase purchase price times by the discount is £30,000.00. These figures should be the same")
          expect(record.errors["discount"]).to include("The mortgage, deposit, and grant when added together is £12,000.00, and the purchase purchase price times by the discount is £30,000.00. These figures should be the same")
          expect(record.errors["grant"]).to include("The mortgage, deposit, and grant when added together is £12,000.00, and the purchase purchase price times by the discount is £30,000.00. These figures should be the same")
        end

        it "returns false if mortgage and deposit total equals market value" do
          record.deposit = 20_000
          sale_information_validator.validate_discounted_ownership_value(record)
          expect(record.errors["mortgageused"]).to be_empty
          expect(record.errors["mortgage"]).to be_empty
          expect(record.errors["value"]).to be_empty
          expect(record.errors["deposit"]).to be_empty
          expect(record.errors["ownershipsch"]).to be_empty
          expect(record.errors["discount"]).to be_empty
          expect(record.errors["grant"]).to be_empty
        end
      end

      context "when mortgage is routed to" do
        let(:record) { FactoryBot.build(:sales_log, mortgageused: 1, deposit: 5_000, grant: 3_000, value: 20_000, discount: 10, ownershipsch: 2, saledate: now) }

        context "and not provided" do
          before do
            record.mortgage = nil
          end

          it "returns false" do
            sale_information_validator.validate_discounted_ownership_value(record)
            expect(record.errors["mortgageused"]).to be_empty
            expect(record.errors["mortgage"]).to be_empty
            expect(record.errors["value"]).to be_empty
            expect(record.errors["deposit"]).to be_empty
            expect(record.errors["ownershipsch"]).to be_empty
            expect(record.errors["discount"]).to be_empty
            expect(record.errors["grant"]).to be_empty
          end
        end

        context "and is provided" do
          it "returns true if mortgage, grant and deposit total does not equal market value - discount" do
            record.mortgage = 10
            sale_information_validator.validate_discounted_ownership_value(record)
            expect(record.errors["mortgageused"]).to include("The mortgage, deposit, and grant when added together is £8,010.00, and the purchase purchase price times by the discount is £18,000.00. These figures should be the same")
            expect(record.errors["mortgage"]).to include("The mortgage, deposit, and grant when added together is £8,010.00, and the purchase purchase price times by the discount is £18,000.00. These figures should be the same")
            expect(record.errors["value"]).to include("The mortgage, deposit, and grant when added together is £8,010.00, and the purchase purchase price times by the discount is £18,000.00. These figures should be the same")
            expect(record.errors["deposit"]).to include("The mortgage, deposit, and grant when added together is £8,010.00, and the purchase purchase price times by the discount is £18,000.00. These figures should be the same")
            expect(record.errors["ownershipsch"]).to include("The mortgage, deposit, and grant when added together is £8,010.00, and the purchase purchase price times by the discount is £18,000.00. These figures should be the same")
            expect(record.errors["discount"]).to include("The mortgage, deposit, and grant when added together is £8,010.00, and the purchase purchase price times by the discount is £18,000.00. These figures should be the same")
            expect(record.errors["grant"]).to include("The mortgage, deposit, and grant when added together is £8,010.00, and the purchase purchase price times by the discount is £18,000.00. These figures should be the same")
          end

          it "returns false if mortgage, grant and deposit total equals market value - discount" do
            record.mortgage = 10_000
            sale_information_validator.validate_discounted_ownership_value(record)
            expect(record.errors["mortgageused"]).to be_empty
            expect(record.errors["mortgage"]).to be_empty
            expect(record.errors["value"]).to be_empty
            expect(record.errors["deposit"]).to be_empty
            expect(record.errors["ownershipsch"]).to be_empty
            expect(record.errors["discount"]).to be_empty
            expect(record.errors["grant"]).to be_empty
          end
        end
      end

      context "when mortgage is not routed to" do
        let(:record) { FactoryBot.build(:sales_log, mortgageused: 2, deposit: 5_000, grant: 3_000, value: 20_000, discount: 10, ownershipsch: 2, saledate: now) }

        it "returns true if grant and deposit total does not equal market value - discount" do
          sale_information_validator.validate_discounted_ownership_value(record)
          expect(record.errors["mortgageused"]).to include("The mortgage, deposit, and grant when added together is £8,000.00, and the purchase purchase price times by the discount is £18,000.00. These figures should be the same")
          expect(record.errors["mortgage"]).to include("The mortgage, deposit, and grant when added together is £8,000.00, and the purchase purchase price times by the discount is £18,000.00. These figures should be the same")
          expect(record.errors["value"]).to include("The mortgage, deposit, and grant when added together is £8,000.00, and the purchase purchase price times by the discount is £18,000.00. These figures should be the same")
          expect(record.errors["deposit"]).to include("The mortgage, deposit, and grant when added together is £8,000.00, and the purchase purchase price times by the discount is £18,000.00. These figures should be the same")
          expect(record.errors["ownershipsch"]).to include("The mortgage, deposit, and grant when added together is £8,000.00, and the purchase purchase price times by the discount is £18,000.00. These figures should be the same")
          expect(record.errors["discount"]).to include("The mortgage, deposit, and grant when added together is £8,000.00, and the purchase purchase price times by the discount is £18,000.00. These figures should be the same")
          expect(record.errors["grant"]).to include("The mortgage, deposit, and grant when added together is £8,000.00, and the purchase purchase price times by the discount is £18,000.00. These figures should be the same")
        end

        it "returns false if mortgage, grant and deposit total equals market value - discount" do
          record.grant = 13_000
          sale_information_validator.validate_discounted_ownership_value(record)
          expect(record.errors["mortgageused"]).to be_empty
          expect(record.errors["mortgage"]).to be_empty
          expect(record.errors["value"]).to be_empty
          expect(record.errors["deposit"]).to be_empty
          expect(record.errors["ownershipsch"]).to be_empty
          expect(record.errors["discount"]).to be_empty
          expect(record.errors["grant"]).to be_empty
        end
      end

      context "when ownership is not discounted" do
        let(:record) { FactoryBot.build(:sales_log, mortgage: 10_000, deposit: 5_000, grant: 3_000, value: 20_000, discount: 10, ownershipsch: 1, saledate: now) }

        it "returns false" do
          sale_information_validator.validate_discounted_ownership_value(record)
          expect(record.errors["mortgageused"]).to be_empty
          expect(record.errors["mortgage"]).to be_empty
          expect(record.errors["value"]).to be_empty
          expect(record.errors["deposit"]).to be_empty
          expect(record.errors["ownershipsch"]).to be_empty
          expect(record.errors["discount"]).to be_empty
          expect(record.errors["grant"]).to be_empty
        end
      end

      context "when it is a 2023 log" do
        let(:record) { FactoryBot.build(:sales_log, mortgageused: 1, deposit: 5_000, grant: 3_000, value: 20_000, discount: 10, ownershipsch: 2, saledate: Time.zone.local(2023, 4, 1)) }

        it "returns false" do
          record.mortgage = 10
          sale_information_validator.validate_discounted_ownership_value(record)
          expect(record.errors["mortgageused"]).to be_empty
          expect(record.errors["mortgage"]).to be_empty
          expect(record.errors["value"]).to be_empty
          expect(record.errors["deposit"]).to be_empty
          expect(record.errors["ownershipsch"]).to be_empty
          expect(record.errors["discount"]).to be_empty
          expect(record.errors["grant"]).to be_empty
        end
      end
    end
  end

  describe "#validate_basic_monthly_rent" do
    context "when within permitted bounds" do
      let(:record) { build(:sales_log, mrent: 9998, ownershipsch: 1, type: 2) }

      it "does not add an error" do
        sale_information_validator.validate_basic_monthly_rent(record)

        expect(record.errors[:mrent]).not_to be_present
        expect(record.errors[:type]).not_to be_present
      end
    end

    context "when the rent is blank" do
      let(:record) { build(:sales_log, mrent: nil, ownershipsch: 1, type: 2) }

      it "does not add an error" do
        sale_information_validator.validate_basic_monthly_rent(record)

        expect(record.errors[:mrent]).not_to be_present
        expect(record.errors[:type]).not_to be_present
      end
    end

    context "when the type is old persons shared ownership" do
      let(:record) { build(:sales_log, mrent: 100_000, ownershipsch: 1, type: 24) }

      it "does not add an error" do
        sale_information_validator.validate_basic_monthly_rent(record)

        expect(record.errors[:mrent]).not_to be_present
        expect(record.errors[:type]).not_to be_present
      end
    end

    context "when the type is blank" do
      let(:record) { build(:sales_log, mrent: 100_000, ownershipsch: 1, type: nil) }

      it "does not add an error" do
        sale_information_validator.validate_basic_monthly_rent(record)

        expect(record.errors[:mrent]).not_to be_present
        expect(record.errors[:type]).not_to be_present
      end
    end

    context "when higher than upper bound" do
      let(:record) { build(:sales_log, mrent: 100_000, ownershipsch: 1, type: 2) }

      it "adds an error" do
        sale_information_validator.validate_basic_monthly_rent(record)

        expect(record.errors[:mrent]).to include(I18n.t("validations.sale_information.monthly_rent.higher_than_expected"))
        expect(record.errors[:type]).to include(I18n.t("validations.sale_information.monthly_rent.higher_than_expected"))
      end
    end
  end

  describe "#validate_grant_amount" do
    context "when within permitted bounds" do
      let(:record) { build(:sales_log, grant: 10_000, saledate: Time.zone.local(2024, 4, 5)) }

      it "does not add an error" do
        sale_information_validator.validate_grant_amount(record)

        expect(record.errors).not_to be_present
      end
    end

    context "when over the max" do
      let(:record) { build(:sales_log, type: 8, grant: 17_000, saledate: Time.zone.local(2024, 4, 5)) }

      it "adds an error" do
        sale_information_validator.validate_grant_amount(record)

        expect(record.errors[:grant]).to include("Loan, grants or subsidies must be between £9,000 and £16,000")
      end
    end

    context "when under the min" do
      let(:record) { build(:sales_log, type: 21, grant: 3, saledate: Time.zone.local(2024, 4, 5)) }

      it "adds an error" do
        sale_information_validator.validate_grant_amount(record)

        expect(record.errors[:grant]).to include("Loan, grants or subsidies must be between £9,000 and £16,000")
      end
    end

    context "when grant is blank" do
      let(:record) { build(:sales_log, type: 21, grant: nil, saledate: Time.zone.local(2024, 4, 5)) }

      it "does not add an error" do
        sale_information_validator.validate_grant_amount(record)

        expect(record.errors).not_to be_present
      end
    end

    context "when over the max and type is not RTA of social homebuy" do
      let(:record) { build(:sales_log, type: 9, grant: 17_000, saledate: Time.zone.local(2024, 4, 5)) }

      it "does not add an error" do
        sale_information_validator.validate_grant_amount(record)

        expect(record.errors).not_to be_present
      end
    end

    context "when under the min and type is not RTA of social homebuy" do
      let(:record) { build(:sales_log, type: 9, grant: 17_000, saledate: Time.zone.local(2024, 4, 5)) }

      it "does not add error" do
        sale_information_validator.validate_grant_amount(record)

        expect(record.errors).not_to be_present
      end
    end

    context "with log before 2024/25 collection" do
      let(:record) { build(:sales_log, type: 8, grant: 3, saledate: Time.zone.local(2023, 4, 5)) }

      it "does not add an error" do
        sale_information_validator.validate_grant_amount(record)

        expect(record.errors).not_to be_present
      end
    end
  end

  describe "#validate_stairbought" do
    let(:now) { Time.zone.local(2024, 4, 4) }

    before do
      Timecop.freeze(now)
      Singleton.__init__(FormHandler)
    end

    after do
      Timecop.return
      Singleton.__init__(FormHandler)
    end

    [
      ["Shared Ownership (new model lease)", 30, 90],
      ["Home Ownership for people with Long-Term Disabilities (HOLD)", 16, 90],
      ["Rent to Buy — Shared Ownership", 28, 90],
      ["Right to Shared Ownership (RtSO)", 31, 90],
      ["London Living Rent — Shared Ownership", 32, 90],
      ["Shared Ownership (old model lease)", 2, 75],
      ["Social HomeBuy — shared ownership purchase", 18, 75],
      ["Older Persons Shared Ownership", 24, 50],
    ].each do |label, type, max|
      context "when ownership type is #{label}" do
        let(:record) { build(:sales_log, ownershipsch: 1, type:, saledate: now) }

        it "does not add an error if stairbought is under #{max}%" do
          record.stairbought = max - 1
          sale_information_validator.validate_stairbought(record)

          expect(record.errors).to be_empty
        end

        it "does not add an error if stairbought is #{max}%" do
          record.stairbought = max
          sale_information_validator.validate_stairbought(record)

          expect(record.errors).to be_empty
        end

        it "does not add an error if stairbought is not given" do
          record.stairbought = nil
          sale_information_validator.validate_stairbought(record)

          expect(record.errors).to be_empty
        end

        it "adds an error if stairbought is over #{max}%" do
          record.stairbought = max + 2
          sale_information_validator.validate_stairbought(record)

          expect(record.errors[:stairbought]).to include("The percentage bought in this staircasing transaction cannot be higher than #{max}% for #{label} sales.")
          expect(record.errors[:type]).to include("The percentage bought in this staircasing transaction cannot be higher than #{max}% for #{label} sales.")
        end
      end
    end
    context "when the collection year is before 2024" do
      let(:record) { build(:sales_log, ownershipsch: 1, type: 24, saledate: now, stairbought: 90) }
      let(:now) { Time.zone.local(2023, 4, 4) }

      it "does not add an error" do
        sale_information_validator.validate_stairbought(record)

        expect(record.errors).to be_empty
      end
    end
  end

  describe "#validate_discount_and_value" do
    let(:record) { FactoryBot.build(:sales_log, value: 200_000, discount: 50, ownershipsch: 2, type: 9, saledate: now) }
    let(:now) { Time.zone.local(2024, 4, 1) }

    around do |example|
      Timecop.freeze(now) do
        example.run
      end
      Timecop.return
    end

    context "with a log in the 24/25 collection year" do
      context "when in London" do
        before do
          record.la = "E09000001"
        end

        it "adds an error if value * discount is more than 136,400" do
          record.discount = 80
          sale_information_validator.validate_discount_and_value(record)
          expect(record.errors["value"]).to include("The percentage discount multiplied by the purchase price is £160,000.00. This figure should not be more than £136,400 for properties in London.")
          expect(record.errors["discount"]).to include("The percentage discount multiplied by the purchase price is £160,000.00. This figure should not be more than £136,400 for properties in London.")
          expect(record.errors["la"]).to include("The percentage discount multiplied by the purchase price is £160,000.00. This figure should not be more than £136,400 for properties in London.")
          expect(record.errors["postcode_full"]).to include("The percentage discount multiplied by the purchase price is £160,000.00. This figure should not be more than £136,400 for properties in London.")
          expect(record.errors["uprn"]).to include("The percentage discount multiplied by the purchase price is £160,000.00. This figure should not be more than £136,400 for properties in London.")
        end

        it "does not add an error value * discount is less than 136,400" do
          sale_information_validator.validate_discount_and_value(record)
          expect(record.errors["value"]).to be_empty
          expect(record.errors["discount"]).to be_empty
          expect(record.errors["la"]).to be_empty
          expect(record.errors["postcode_full"]).to be_empty
          expect(record.errors["uprn"]).to be_empty
        end
      end

      context "when in outside of London" do
        before do
          record.la = "E06000015"
        end

        it "adds an error if value * discount is more than 136,400" do
          record.discount = 52
          sale_information_validator.validate_discount_and_value(record)
          expect(record.errors["value"]).to include("The percentage discount multiplied by the purchase price is £104,000.00. This figure should not be more than £102,400 for properties outside of London.")
          expect(record.errors["discount"]).to include("The percentage discount multiplied by the purchase price is £104,000.00. This figure should not be more than £102,400 for properties outside of London.")
          expect(record.errors["la"]).to include("The percentage discount multiplied by the purchase price is £104,000.00. This figure should not be more than £102,400 for properties outside of London.")
          expect(record.errors["postcode_full"]).to include("The percentage discount multiplied by the purchase price is £104,000.00. This figure should not be more than £102,400 for properties outside of London.")
          expect(record.errors["uprn"]).to include("The percentage discount multiplied by the purchase price is £104,000.00. This figure should not be more than £102,400 for properties outside of London.")
        end

        it "does not add an error value * discount is less than 136,400" do
          sale_information_validator.validate_discount_and_value(record)
          expect(record.errors["value"]).to be_empty
          expect(record.errors["discount"]).to be_empty
          expect(record.errors["la"]).to be_empty
          expect(record.errors["postcode_full"]).to be_empty
          expect(record.errors["uprn"]).to be_empty
        end
      end
    end

    context "when it is a 2023 log" do
      let(:record) { FactoryBot.build(:sales_log, value: 200_000, discount: 80, ownershipsch: 2, type: 9, saledate: Time.zone.local(2023, 4, 1), la: "E06000015") }

      it "does not add an error" do
        sale_information_validator.validate_discount_and_value(record)
        expect(record.errors["value"]).to be_empty
        expect(record.errors["discount"]).to be_empty
        expect(record.errors["la"]).to be_empty
        expect(record.errors["postcode_full"]).to be_empty
        expect(record.errors["uprn"]).to be_empty
      end
    end
  end

  describe "#validate_non_staircasing_mortgage" do
    let(:record) { FactoryBot.build(:sales_log, mortgageused: 1, mortgage: 10_000, deposit: 5_000, value: 30_000, equity: 28, ownershipsch: 1, type: 30, saledate: now) }

    around do |example|
      Timecop.freeze(now) do
        Singleton.__init__(FormHandler)
        example.run
      end
      Timecop.return
      Singleton.__init__(FormHandler)
    end

    context "with a log in the 24/25 collection year" do
      let(:now) { Time.zone.local(2024, 4, 4) }

      context "when MORTGAGE + DEPOSIT does not equal VALUE * EQUITY/100 " do
        context "and it is not a staircase transaction" do
          before do
            record.staircase = 2
          end

          it "adds an error" do
            sale_information_validator.validate_non_staircasing_mortgage(record)
            expect(record.errors["mortgage"]).to include("The mortgage and deposit added together is £15,000.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
            expect(record.errors["value"]).to include("The mortgage and deposit added together is £15,000.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
            expect(record.errors["deposit"]).to include("The mortgage and deposit added together is £15,000.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
            expect(record.errors["equity"]).to include("The mortgage and deposit added together is £15,000.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
            expect(record.errors["type"]).to include("The mortgage and deposit added together is £15,000.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
            expect(record.errors["cashdis"]).not_to include("The mortgage and deposit added together is £15,000.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
          end

          context "and it is a social homebuy" do
            before do
              record.type = 18
              record.cashdis = "200"
            end

            it "adds an error" do
              sale_information_validator.validate_non_staircasing_mortgage(record)
              expect(record.errors["mortgage"]).to include("The mortgage, deposit, and cash discount added together is £15,200.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
              expect(record.errors["value"]).to include("The mortgage, deposit, and cash discount added together is £15,200.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
              expect(record.errors["deposit"]).to include("The mortgage, deposit, and cash discount added together is £15,200.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
              expect(record.errors["equity"]).to include("The mortgage, deposit, and cash discount added together is £15,200.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
              expect(record.errors["cashdis"]).to include("The mortgage, deposit, and cash discount added together is £15,200.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
              expect(record.errors["type"]).to include("The mortgage, deposit, and cash discount added together is £15,200.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
            end
          end

          context "and it is not a shared ownership transaction" do
            before do
              record.ownershipsch = 2
            end

            it "does not add an error" do
              sale_information_validator.validate_non_staircasing_mortgage(record)
              expect(record.errors["mortgage"]).to be_empty
              expect(record.errors["value"]).to be_empty
              expect(record.errors["deposit"]).to be_empty
              expect(record.errors["equity"]).to be_empty
              expect(record.errors["cashdis"]).to be_empty
              expect(record.errors["type"]).to be_empty
            end
          end
        end

        context "and it is a staircase transaction" do
          before do
            record.staircase = 1
          end

          it "does not add an error" do
            sale_information_validator.validate_non_staircasing_mortgage(record)
            expect(record.errors["mortgage"]).to be_empty
            expect(record.errors["value"]).to be_empty
            expect(record.errors["deposit"]).to be_empty
            expect(record.errors["equity"]).to be_empty
            expect(record.errors["cashdis"]).to be_empty
            expect(record.errors["type"]).to be_empty
          end
        end
      end

      context "when MORTGAGE + DEPOSIT equals VALUE * EQUITY/100" do
        let(:record) { FactoryBot.build(:sales_log, mortgageused: 1, mortgage: 10_000, staircase: 2, deposit: 5_000, value: 30_000, equity: 50, ownershipsch: 1, type: 30, saledate: now) }

        it "does not add an error" do
          sale_information_validator.validate_non_staircasing_mortgage(record)
          expect(record.errors["mortgage"]).to be_empty
          expect(record.errors["value"]).to be_empty
          expect(record.errors["deposit"]).to be_empty
          expect(record.errors["equity"]).to be_empty
          expect(record.errors["cashdis"]).to be_empty
          expect(record.errors["type"]).to be_empty
        end
      end

      context "when MORTGAGE + DEPOSIT is within 1£ tolerance of VALUE * EQUITY/100" do
        let(:record) { FactoryBot.build(:sales_log, mortgageused: 1, mortgage: 10_000, staircase: 2, deposit: 50_000, value: 120_001, equity: 50, ownershipsch: 1, type: 30, saledate: now) }

        it "does not add an error" do
          sale_information_validator.validate_non_staircasing_mortgage(record)
          expect(record.errors["mortgage"]).to be_empty
          expect(record.errors["value"]).to be_empty
          expect(record.errors["deposit"]).to be_empty
          expect(record.errors["equity"]).to be_empty
          expect(record.errors["cashdis"]).to be_empty
          expect(record.errors["type"]).to be_empty
        end
      end

      context "when mortgage is not used" do
        before do
          record.mortgageused = 2
        end

        context "when DEPOSIT does not equal VALUE * EQUITY/100 " do
          context "and it is not a staircase transaction" do
            before do
              record.staircase = 2
            end

            it "adds an error" do
              sale_information_validator.validate_non_staircasing_mortgage(record)
              expect(record.errors["mortgageused"]).to include("The deposit is £5,000.00 and the value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
              expect(record.errors["value"]).to include("The deposit is £5,000.00 and the value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
              expect(record.errors["deposit"]).to include("The deposit is £5,000.00 and the value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
              expect(record.errors["equity"]).to include("The deposit is £5,000.00 and the value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
              expect(record.errors["type"]).to include("The deposit is £5,000.00 and the value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
              expect(record.errors["cashdis"]).not_to include("The deposit is £5,000.00 and the value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
            end

            context "and it is a social homebuy" do
              before do
                record.type = 18
                record.cashdis = "200"
              end

              it "adds an error" do
                sale_information_validator.validate_non_staircasing_mortgage(record)
                expect(record.errors["mortgageused"]).to include("The deposit and cash discount added together is £5,200.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
                expect(record.errors["value"]).to include("The deposit and cash discount added together is £5,200.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
                expect(record.errors["deposit"]).to include("The deposit and cash discount added together is £5,200.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
                expect(record.errors["equity"]).to include("The deposit and cash discount added together is £5,200.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
                expect(record.errors["cashdis"]).to include("The deposit and cash discount added together is £5,200.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
                expect(record.errors["type"]).to include("The deposit and cash discount added together is £5,200.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
              end
            end

            context "and it is not a shared ownership transaction" do
              before do
                record.ownershipsch = 2
              end

              it "does not add an error" do
                sale_information_validator.validate_non_staircasing_mortgage(record)
                expect(record.errors["mortgageused"]).to be_empty
                expect(record.errors["value"]).to be_empty
                expect(record.errors["deposit"]).to be_empty
                expect(record.errors["equity"]).to be_empty
                expect(record.errors["cashdis"]).to be_empty
                expect(record.errors["type"]).to be_empty
              end
            end
          end

          context "and it is a staircase transaction" do
            before do
              record.staircase = 1
            end

            it "does not add an error" do
              sale_information_validator.validate_non_staircasing_mortgage(record)
              expect(record.errors["mortgageused"]).to be_empty
              expect(record.errors["value"]).to be_empty
              expect(record.errors["deposit"]).to be_empty
              expect(record.errors["equity"]).to be_empty
              expect(record.errors["cashdis"]).to be_empty
              expect(record.errors["type"]).to be_empty
            end
          end
        end

        context "when DEPOSIT equals VALUE * EQUITY/100" do
          let(:record) { FactoryBot.build(:sales_log, mortgageused: 2, staircase: 2, deposit: 15_000, value: 30_000, equity: 50, ownershipsch: 1, type: 30, saledate: now) }

          it "does not add an error" do
            sale_information_validator.validate_non_staircasing_mortgage(record)
            expect(record.errors["mortgageused"]).to be_empty
            expect(record.errors["value"]).to be_empty
            expect(record.errors["deposit"]).to be_empty
            expect(record.errors["equity"]).to be_empty
            expect(record.errors["cashdis"]).to be_empty
            expect(record.errors["type"]).to be_empty
          end
        end

        context "when DEPOSIT is within 1£ tolerance of VALUE * EQUITY/100" do
          let(:record) { FactoryBot.build(:sales_log, mortgageused: 2, staircase: 2, deposit: 15_000, value: 30_001, equity: 50, ownershipsch: 1, type: 30, saledate: now) }

          it "does not add an error" do
            sale_information_validator.validate_non_staircasing_mortgage(record)
            expect(record.errors["mortgageused"]).to be_empty
            expect(record.errors["value"]).to be_empty
            expect(record.errors["deposit"]).to be_empty
            expect(record.errors["equity"]).to be_empty
            expect(record.errors["cashdis"]).to be_empty
            expect(record.errors["type"]).to be_empty
          end
        end
      end
    end

    context "when it is a 2023 log" do
      let(:now) { Time.zone.local(2023, 4, 1) }
      let(:record) { FactoryBot.build(:sales_log, mortgage: 10_000, staircase: 2, deposit: 5_000, value: 30_000, equity: 28, ownershipsch: 1, type: 30, saledate: now) }

      it "does not add an error" do
        sale_information_validator.validate_non_staircasing_mortgage(record)
        expect(record.errors["mortgage"]).to be_empty
        expect(record.errors["value"]).to be_empty
        expect(record.errors["deposit"]).to be_empty
        expect(record.errors["equity"]).to be_empty
        expect(record.errors["cashdis"]).to be_empty
        expect(record.errors["type"]).to be_empty
      end
    end
  end

  describe "#validate_staircasing_mortgage" do
    let(:record) { FactoryBot.build(:sales_log, mortgageused: 1, mortgage: 10_000, deposit: 5_000, value: 30_000, stairbought: 28, ownershipsch: 1, type: 30, saledate: now) }

    around do |example|
      Timecop.freeze(now) do
        Singleton.__init__(FormHandler)
        example.run
      end
      Timecop.return
      Singleton.__init__(FormHandler)
    end

    context "with a log in the 24/25 collection year" do
      let(:now) { Time.zone.local(2024, 4, 4) }

      context "when MORTGAGE + DEPOSIT does not equal STAIRBOUGHT/100 * VALUE" do
        context "and it is a staircase transaction" do
          before do
            record.staircase = 1
          end

          it "adds an error" do
            sale_information_validator.validate_staircasing_mortgage(record)
            expect(record.errors["mortgage"]).to include("The mortgage and deposit added together is £15,000.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
            expect(record.errors["value"]).to include("The mortgage and deposit added together is £15,000.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
            expect(record.errors["deposit"]).to include("The mortgage and deposit added together is £15,000.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
            expect(record.errors["stairbought"]).to include("The mortgage and deposit added together is £15,000.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
            expect(record.errors["type"]).to include("The mortgage and deposit added together is £15,000.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
            expect(record.errors["cashdis"]).not_to include("The mortgage and deposit added together is £15,000.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
          end

          context "and it is a social homebuy" do
            before do
              record.type = 18
              record.cashdis = "200"
            end

            it "adds an error" do
              sale_information_validator.validate_staircasing_mortgage(record)
              expect(record.errors["mortgage"]).to include("The mortgage, deposit, and cash discount added together is £15,200.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
              expect(record.errors["value"]).to include("The mortgage, deposit, and cash discount added together is £15,200.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
              expect(record.errors["deposit"]).to include("The mortgage, deposit, and cash discount added together is £15,200.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
              expect(record.errors["stairbought"]).to include("The mortgage, deposit, and cash discount added together is £15,200.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
              expect(record.errors["cashdis"]).to include("The mortgage, deposit, and cash discount added together is £15,200.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
              expect(record.errors["type"]).to include("The mortgage, deposit, and cash discount added together is £15,200.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
            end
          end

          context "and it is not a shared ownership transaction" do
            before do
              record.ownershipsch = 2
            end

            it "does not add an error" do
              sale_information_validator.validate_non_staircasing_mortgage(record)
              expect(record.errors["mortgage"]).to be_empty
              expect(record.errors["value"]).to be_empty
              expect(record.errors["deposit"]).to be_empty
              expect(record.errors["stairbought"]).to be_empty
              expect(record.errors["cashdis"]).to be_empty
              expect(record.errors["type"]).to be_empty
            end
          end
        end

        context "and it is not a staircase transaction" do
          before do
            record.staircase = 2
          end

          it "does not add an error" do
            sale_information_validator.validate_staircasing_mortgage(record)
            expect(record.errors["mortgage"]).to be_empty
            expect(record.errors["value"]).to be_empty
            expect(record.errors["deposit"]).to be_empty
            expect(record.errors["stairbought"]).to be_empty
            expect(record.errors["cashdis"]).to be_empty
            expect(record.errors["type"]).to be_empty
          end
        end
      end

      context "when MORTGAGE + DEPOSIT equals STAIRBOUGHT/100 * VALUE" do
        let(:record) { FactoryBot.build(:sales_log, mortgageused: 1, mortgage: 10_000, staircase: 1, deposit: 5_000, value: 30_000, stairbought: 50, ownershipsch: 1, type: 30, saledate: now) }

        it "does not add an error" do
          sale_information_validator.validate_staircasing_mortgage(record)
          expect(record.errors["mortgage"]).to be_empty
          expect(record.errors["value"]).to be_empty
          expect(record.errors["deposit"]).to be_empty
          expect(record.errors["stairbought"]).to be_empty
          expect(record.errors["cashdis"]).to be_empty
          expect(record.errors["type"]).to be_empty
        end
      end

      context "when MORTGAGE + DEPOSIT is within 1£ tolerance of STAIRBOUGHT/100 * VALUE" do
        let(:record) { FactoryBot.build(:sales_log, mortgageused: 1, mortgage: 10_000, staircase: 1, deposit: 5_000, value: 30_001, stairbought: 50, ownershipsch: 1, type: 30, saledate: now) }

        it "does not add an error" do
          sale_information_validator.validate_staircasing_mortgage(record)
          expect(record.errors["mortgage"]).to be_empty
          expect(record.errors["value"]).to be_empty
          expect(record.errors["deposit"]).to be_empty
          expect(record.errors["stairbought"]).to be_empty
          expect(record.errors["cashdis"]).to be_empty
          expect(record.errors["type"]).to be_empty
        end
      end
    end

    context "when it is a 2023 log" do
      let(:now) { Time.zone.local(2023, 4, 1) }
      let(:record) { FactoryBot.build(:sales_log, mortgage: 10_000, staircase: 1, deposit: 5_000, value: 30_000, stairbought: 28, ownershipsch: 1, type: 30, saledate: now) }

      it "does not add an error" do
        sale_information_validator.validate_staircasing_mortgage(record)
        expect(record.errors["mortgage"]).to be_empty
        expect(record.errors["value"]).to be_empty
        expect(record.errors["deposit"]).to be_empty
        expect(record.errors["stairbought"]).to be_empty
        expect(record.errors["cashdis"]).to be_empty
        expect(record.errors["type"]).to be_empty
      end
    end

    context "when mortgage is not used" do
      context "with a log in the 24/25 collection year" do
        let(:now) { Time.zone.local(2024, 4, 4) }

        before do
          record.mortgageused = 2
        end

        context "when DEPOSIT does not equal STAIRBOUGHT/100 * VALUE" do
          context "and it is a staircase transaction" do
            before do
              record.staircase = 1
            end

            it "adds an error" do
              sale_information_validator.validate_staircasing_mortgage(record)
              expect(record.errors["mortgageused"]).to include("The deposit is £5,000.00 and the value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
              expect(record.errors["value"]).to include("The deposit is £5,000.00 and the value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
              expect(record.errors["deposit"]).to include("The deposit is £5,000.00 and the value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
              expect(record.errors["stairbought"]).to include("The deposit is £5,000.00 and the value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
              expect(record.errors["type"]).to include("The deposit is £5,000.00 and the value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
              expect(record.errors["cashdis"]).not_to include("The deposit is £5,000.00 and the value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
            end

            context "and it is a social homebuy" do
              before do
                record.type = 18
                record.cashdis = "200"
              end

              it "adds an error" do
                sale_information_validator.validate_staircasing_mortgage(record)
                expect(record.errors["mortgageused"]).to include("The deposit and cash discount added together is £5,200.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
                expect(record.errors["value"]).to include("The deposit and cash discount added together is £5,200.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
                expect(record.errors["deposit"]).to include("The deposit and cash discount added together is £5,200.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
                expect(record.errors["stairbought"]).to include("The deposit and cash discount added together is £5,200.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
                expect(record.errors["cashdis"]).to include("The deposit and cash discount added together is £5,200.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
                expect(record.errors["type"]).to include("The deposit and cash discount added together is £5,200.00. The value multiplied by the percentage bought is £8,400.00. These figures should be the same.")
              end
            end

            context "and it is not a shared ownership transaction" do
              before do
                record.ownershipsch = 2
              end

              it "does not add an error" do
                sale_information_validator.validate_non_staircasing_mortgage(record)
                expect(record.errors["mortgageused"]).to be_empty
                expect(record.errors["value"]).to be_empty
                expect(record.errors["deposit"]).to be_empty
                expect(record.errors["stairbought"]).to be_empty
                expect(record.errors["cashdis"]).to be_empty
                expect(record.errors["type"]).to be_empty
              end
            end
          end

          context "and it is not a staircase transaction" do
            before do
              record.staircase = 2
            end

            it "does not add an error" do
              sale_information_validator.validate_staircasing_mortgage(record)
              expect(record.errors["mortgageused"]).to be_empty
              expect(record.errors["value"]).to be_empty
              expect(record.errors["deposit"]).to be_empty
              expect(record.errors["stairbought"]).to be_empty
              expect(record.errors["cashdis"]).to be_empty
              expect(record.errors["type"]).to be_empty
            end
          end
        end

        context "when DEPOSIT equals STAIRBOUGHT/100 * VALUE" do
          let(:record) { FactoryBot.build(:sales_log, mortgageused: 2, staircase: 1, deposit: 15_000, value: 30_000, stairbought: 50, ownershipsch: 1, type: 30, saledate: now) }

          it "does not add an error" do
            sale_information_validator.validate_staircasing_mortgage(record)
            expect(record.errors["mortgageused"]).to be_empty
            expect(record.errors["value"]).to be_empty
            expect(record.errors["deposit"]).to be_empty
            expect(record.errors["stairbought"]).to be_empty
            expect(record.errors["cashdis"]).to be_empty
            expect(record.errors["type"]).to be_empty
          end
        end

        context "when DEPOSIT is within 1£ tolerance of STAIRBOUGHT/100 * VALUE" do
          let(:record) { FactoryBot.build(:sales_log, mortgageused: 2, staircase: 1, deposit: 15_000, value: 30_001, stairbought: 50, ownershipsch: 1, type: 30, saledate: now) }

          it "does not add an error" do
            sale_information_validator.validate_staircasing_mortgage(record)
            expect(record.errors["mortgageused"]).to be_empty
            expect(record.errors["value"]).to be_empty
            expect(record.errors["deposit"]).to be_empty
            expect(record.errors["stairbought"]).to be_empty
            expect(record.errors["cashdis"]).to be_empty
            expect(record.errors["type"]).to be_empty
          end
        end
      end

      context "when it is a 2023 log" do
        let(:now) { Time.zone.local(2023, 4, 1) }
        let(:record) { FactoryBot.build(:sales_log, mortgageused: 2, staircase: 1, deposit: 5_000, value: 30_000, stairbought: 28, ownershipsch: 1, type: 30, saledate: now) }

        it "does not add an error" do
          sale_information_validator.validate_staircasing_mortgage(record)
          expect(record.errors["mortgageused"]).to be_empty
          expect(record.errors["value"]).to be_empty
          expect(record.errors["deposit"]).to be_empty
          expect(record.errors["stairbought"]).to be_empty
          expect(record.errors["cashdis"]).to be_empty
          expect(record.errors["type"]).to be_empty
        end
      end
    end
  end

  describe "#validate_mortgage_used_and_stairbought" do
    let(:now) { Time.zone.local(2024, 4, 4) }

    before do
      Timecop.freeze(now)
      Singleton.__init__(FormHandler)
    end

    after do
      Timecop.return
      Singleton.__init__(FormHandler)
    end

    context "when mortgageused don't know" do
      let(:record) { build(:sales_log, ownershipsch: 1, type: 9, saledate: now, mortgageused: 3) }

      it "does not add an error if stairowned 100" do
        record.stairowned = 100
        sale_information_validator.validate_mortgage_used_and_stairbought(record)

        expect(record.errors).to be_empty
      end

      it "adds an error if stairowned is not 100" do
        record.stairowned = 90
        sale_information_validator.validate_mortgage_used_and_stairbought(record)

        expect(record.errors[:stairowned]).to include("The percentage owned has to be 100% if the mortgage used is 'Don’t know'")
        expect(record.errors[:mortgageused]).to include("The percentage owned has to be 100% if the mortgage used is 'Don’t know'")
      end
    end

    context "when the collection year is before 2024" do
      let(:record) { build(:sales_log, ownershipsch: 1, type: 9, saledate: now, mortgageused: 3, stairowned: 90) }
      let(:now) { Time.zone.local(2023, 4, 4) }

      it "adds an error" do
        sale_information_validator.validate_mortgage_used_and_stairbought(record)

        expect(record.errors[:stairowned]).to include("The percentage owned has to be 100% if the mortgage used is 'Don’t know'")
        expect(record.errors[:mortgageused]).to include("The percentage owned has to be 100% if the mortgage used is 'Don’t know'")
      end
    end
  end
end
