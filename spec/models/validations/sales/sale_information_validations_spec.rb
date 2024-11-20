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
          ["Contract exchange date must be less than 1 year before sale completion date."],
        )
        expect(record.errors[:saledate]).to eq(
          ["Sale completion date must be less than 1 year after contract exchange date."],
        )
      end
    end

    context "when exdate after saledate" do
      let(:record) { build(:sales_log, exdate: 1.month.ago, saledate: 2.months.ago) }

      it "adds error" do
        sale_information_validator.validate_exchange_date(record)

        expect(record.errors[:exdate]).to eq(
          ["Contract exchange date must be before sale completion date."],
        )
        expect(record.errors[:saledate]).to eq(
          ["Sale completion date must be after contract exchange date."],
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
        expect(record.errors["fromprop"]).to include(I18n.t("validations.sales.sale_information.fromprop.previous_property_type_bedsit"))
        expect(record.errors["frombeds"]).to include(I18n.t("validations.sales.sale_information.frombeds.previous_property_type_bedsit"))
      end
    end
  end

  describe "#validate_discounted_ownership_value" do
    let(:record) { FactoryBot.build(:sales_log, :saledate_today, mortgage: 10_000, deposit: 5_000, value: 30_000, ownershipsch: 2, type: 8) }

    context "when grant is routed to" do
      let(:record) { FactoryBot.build(:sales_log, :saledate_today, deposit: nil, ownershipsch: 2, type: 8) }

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
        it "adds an error if mortgage, deposit and grant at least 1 greater than discounted value" do
          record.mortgage = 30_000
          record.deposit = 5_000
          record.grant = 15_000
          record.value = 49_999

          sale_information_validator.validate_discounted_ownership_value(record)

          expect(record.errors["mortgageused"]).to include("The mortgage (£30,000.00), cash deposit (£5,000.00), and grant (£15,000.00) added together is £50,000.00.</br></br>The full purchase price is £49,999.00.</br></br>These two amounts should be the same.")
          expect(record.errors["mortgage"]).to include("The mortgage (£30,000.00), cash deposit (£5,000.00), and grant (£15,000.00) added together is £50,000.00.</br></br>The full purchase price is £49,999.00.</br></br>These two amounts should be the same.")
          expect(record.errors["value"]).to include("The mortgage (£30,000.00), cash deposit (£5,000.00), and grant (£15,000.00) added together is £50,000.00.</br></br>The full purchase price is £49,999.00.</br></br>These two amounts should be the same.")
          expect(record.errors["deposit"]).to include("The mortgage (£30,000.00), cash deposit (£5,000.00), and grant (£15,000.00) added together is £50,000.00.</br></br>The full purchase price is £49,999.00.</br></br>These two amounts should be the same.")
          expect(record.errors["ownershipsch"]).to include("The mortgage (£30,000.00), cash deposit (£5,000.00), and grant (£15,000.00) added together is £50,000.00.</br></br>The full purchase price is £49,999.00.</br></br>These two amounts should be the same.")
          expect(record.errors["discount"]).to include("The mortgage (£30,000.00), cash deposit (£5,000.00), and grant (£15,000.00) added together is £50,000.00.</br></br>The full purchase price is £49,999.00.</br></br>These two amounts should be the same.")
          expect(record.errors["grant"]).to include("The mortgage (£30,000.00), cash deposit (£5,000.00), and grant (£15,000.00) added together is £50,000.00.</br></br>The full purchase price is £49,999.00.</br></br>These two amounts should be the same.")
        end

        it "adds an error if mortgage, deposit and grant at least 1 less than discounted value" do
          record.mortgage = 30_000
          record.deposit = 5_000
          record.grant = 15_000
          record.value = 50_001

          sale_information_validator.validate_discounted_ownership_value(record)

          expect(record.errors["mortgageused"]).to include("The mortgage (£30,000.00), cash deposit (£5,000.00), and grant (£15,000.00) added together is £50,000.00.</br></br>The full purchase price is £50,001.00.</br></br>These two amounts should be the same.")
          expect(record.errors["mortgage"]).to include("The mortgage (£30,000.00), cash deposit (£5,000.00), and grant (£15,000.00) added together is £50,000.00.</br></br>The full purchase price is £50,001.00.</br></br>These two amounts should be the same.")
          expect(record.errors["value"]).to include("The mortgage (£30,000.00), cash deposit (£5,000.00), and grant (£15,000.00) added together is £50,000.00.</br></br>The full purchase price is £50,001.00.</br></br>These two amounts should be the same.")
          expect(record.errors["deposit"]).to include("The mortgage (£30,000.00), cash deposit (£5,000.00), and grant (£15,000.00) added together is £50,000.00.</br></br>The full purchase price is £50,001.00.</br></br>These two amounts should be the same.")
          expect(record.errors["ownershipsch"]).to include("The mortgage (£30,000.00), cash deposit (£5,000.00), and grant (£15,000.00) added together is £50,000.00.</br></br>The full purchase price is £50,001.00.</br></br>These two amounts should be the same.")
          expect(record.errors["discount"]).to include("The mortgage (£30,000.00), cash deposit (£5,000.00), and grant (£15,000.00) added together is £50,000.00.</br></br>The full purchase price is £50,001.00.</br></br>These two amounts should be the same.")
          expect(record.errors["grant"]).to include("The mortgage (£30,000.00), cash deposit (£5,000.00), and grant (£15,000.00) added together is £50,000.00.</br></br>The full purchase price is £50,001.00.</br></br>These two amounts should be the same.")
        end

        it "does not add an error if mortgage, deposit and grant total equals discounted value" do
          record.mortgage = 30_000
          record.deposit = 5_000
          record.grant = 15_000
          record.value = 50_000

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
      let(:record) { FactoryBot.build(:sales_log, :saledate_today, grant: nil, ownershipsch: 2, type: 9) }

      context "and not provided" do
        it "returns false" do
          record.value = 30_000
          record.mortgage = 10_000
          record.deposit = 5_000
          record.discount = nil

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
        it "does not add errors if mortgage and deposit total equals market value - discount" do
          record.value = 30_000
          record.mortgage = 10_000
          record.deposit = 5_000
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

        it "does not add errors if mortgage and deposit total is within a 0.05% x market value tolerance of market value - discount" do
          record.value = 123_000
          record.mortgage = 66_112
          record.deposit = 0
          record.discount = 46.3

          sale_information_validator.validate_discounted_ownership_value(record)

          expect(record.errors["mortgageused"]).to be_empty
          expect(record.errors["mortgage"]).to be_empty
          expect(record.errors["value"]).to be_empty
          expect(record.errors["deposit"]).to be_empty
          expect(record.errors["ownershipsch"]).to be_empty
          expect(record.errors["discount"]).to be_empty
          expect(record.errors["grant"]).to be_empty
        end

        it "adds errors if mortgage and deposit total is not within a 0.05% x market value tolerance of market value - discount" do
          record.value = 123_000
          record.mortgage = 66_113
          record.deposit = 0
          record.discount = 46.3

          sale_information_validator.validate_discounted_ownership_value(record)

          expect(record.errors["mortgageused"]).to include("The mortgage (£66,113.00) and cash deposit (£0.00) added together is £66,113.00.</br></br>The full purchase price (£123,000.00) subtracted by the sum of the full purchase price (£123,000.00) multiplied by the percentage discount (46.3%) is £66,051.00.</br></br>These two amounts should be the same.")
          expect(record.errors["mortgage"]).to include("The mortgage (£66,113.00) and cash deposit (£0.00) added together is £66,113.00.</br></br>The full purchase price (£123,000.00) subtracted by the sum of the full purchase price (£123,000.00) multiplied by the percentage discount (46.3%) is £66,051.00.</br></br>These two amounts should be the same.")
          expect(record.errors["value"]).to include("The mortgage (£66,113.00) and cash deposit (£0.00) added together is £66,113.00.</br></br>The full purchase price (£123,000.00) subtracted by the sum of the full purchase price (£123,000.00) multiplied by the percentage discount (46.3%) is £66,051.00.</br></br>These two amounts should be the same.")
          expect(record.errors["deposit"]).to include("The mortgage (£66,113.00) and cash deposit (£0.00) added together is £66,113.00.</br></br>The full purchase price (£123,000.00) subtracted by the sum of the full purchase price (£123,000.00) multiplied by the percentage discount (46.3%) is £66,051.00.</br></br>These two amounts should be the same.")
          expect(record.errors["ownershipsch"]).to include("The mortgage (£66,113.00) and cash deposit (£0.00) added together is £66,113.00.</br></br>The full purchase price (£123,000.00) subtracted by the sum of the full purchase price (£123,000.00) multiplied by the percentage discount (46.3%) is £66,051.00.</br></br>These two amounts should be the same.")
          expect(record.errors["discount"]).to include("The mortgage (£66,113.00) and cash deposit (£0.00) added together is £66,113.00.</br></br>The full purchase price (£123,000.00) subtracted by the sum of the full purchase price (£123,000.00) multiplied by the percentage discount (46.3%) is £66,051.00.</br></br>These two amounts should be the same.")
          expect(record.errors["grant"]).to include("The mortgage (£66,113.00) and cash deposit (£0.00) added together is £66,113.00.</br></br>The full purchase price (£123,000.00) subtracted by the sum of the full purchase price (£123,000.00) multiplied by the percentage discount (46.3%) is £66,051.00.</br></br>These two amounts should be the same.")
        end

        it "does not add errors if mortgage and deposit total is exactly 0.05% x market value away from market value - discount" do
          record.value = 120_000
          record.mortgage = 64_500
          record.deposit = 0
          record.discount = 46.3

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
      let(:record) { FactoryBot.build(:sales_log, :saledate_today, mortgage: 10_000, value: 30_000, ownershipsch: 2, type: 29) }

      it "returns true if mortgage and deposit total does not equal market value" do
        record.deposit = 2_000
        sale_information_validator.validate_discounted_ownership_value(record)

        expect(record.errors["mortgageused"]).to include("The mortgage (£10,000.00) and cash deposit (£2,000.00) added together is £12,000.00.</br></br>The full purchase price is £30,000.00.</br></br>These two amounts should be the same.")
        expect(record.errors["mortgage"]).to include("The mortgage (£10,000.00) and cash deposit (£2,000.00) added together is £12,000.00.</br></br>The full purchase price is £30,000.00.</br></br>These two amounts should be the same.")
        expect(record.errors["value"]).to include("The mortgage (£10,000.00) and cash deposit (£2,000.00) added together is £12,000.00.</br></br>The full purchase price is £30,000.00.</br></br>These two amounts should be the same.")
        expect(record.errors["deposit"]).to include("The mortgage (£10,000.00) and cash deposit (£2,000.00) added together is £12,000.00.</br></br>The full purchase price is £30,000.00.</br></br>These two amounts should be the same.")
        expect(record.errors["ownershipsch"]).to include("The mortgage (£10,000.00) and cash deposit (£2,000.00) added together is £12,000.00.</br></br>The full purchase price is £30,000.00.</br></br>These two amounts should be the same.")
        expect(record.errors["discount"]).to include("The mortgage (£10,000.00) and cash deposit (£2,000.00) added together is £12,000.00.</br></br>The full purchase price is £30,000.00.</br></br>These two amounts should be the same.")
        expect(record.errors["grant"]).to include("The mortgage (£10,000.00) and cash deposit (£2,000.00) added together is £12,000.00.</br></br>The full purchase price is £30,000.00.</br></br>These two amounts should be the same.")
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
      let(:record) { FactoryBot.build(:sales_log, :saledate_today, mortgageused: 1, deposit: 5_000, grant: 3_000, value: 20_000, discount: 10, ownershipsch: 2) }

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
          expect(record.errors["mortgageused"]).to include("The mortgage (£10.00), cash deposit (£5,000.00), and grant (£3,000.00) added together is £8,010.00.</br></br>The full purchase price (£20,000.00) subtracted by the sum of the full purchase price (£20,000.00) multiplied by the percentage discount (10.0%) is £18,000.00.</br></br>These two amounts should be the same.")
          expect(record.errors["mortgage"]).to include("The mortgage (£10.00), cash deposit (£5,000.00), and grant (£3,000.00) added together is £8,010.00.</br></br>The full purchase price (£20,000.00) subtracted by the sum of the full purchase price (£20,000.00) multiplied by the percentage discount (10.0%) is £18,000.00.</br></br>These two amounts should be the same.")
          expect(record.errors["value"]).to include("The mortgage (£10.00), cash deposit (£5,000.00), and grant (£3,000.00) added together is £8,010.00.</br></br>The full purchase price (£20,000.00) subtracted by the sum of the full purchase price (£20,000.00) multiplied by the percentage discount (10.0%) is £18,000.00.</br></br>These two amounts should be the same.")
          expect(record.errors["deposit"]).to include("The mortgage (£10.00), cash deposit (£5,000.00), and grant (£3,000.00) added together is £8,010.00.</br></br>The full purchase price (£20,000.00) subtracted by the sum of the full purchase price (£20,000.00) multiplied by the percentage discount (10.0%) is £18,000.00.</br></br>These two amounts should be the same.")
          expect(record.errors["ownershipsch"]).to include("The mortgage (£10.00), cash deposit (£5,000.00), and grant (£3,000.00) added together is £8,010.00.</br></br>The full purchase price (£20,000.00) subtracted by the sum of the full purchase price (£20,000.00) multiplied by the percentage discount (10.0%) is £18,000.00.</br></br>These two amounts should be the same.")
          expect(record.errors["discount"]).to include("The mortgage (£10.00), cash deposit (£5,000.00), and grant (£3,000.00) added together is £8,010.00.</br></br>The full purchase price (£20,000.00) subtracted by the sum of the full purchase price (£20,000.00) multiplied by the percentage discount (10.0%) is £18,000.00.</br></br>These two amounts should be the same.")
          expect(record.errors["grant"]).to include("The mortgage (£10.00), cash deposit (£5,000.00), and grant (£3,000.00) added together is £8,010.00.</br></br>The full purchase price (£20,000.00) subtracted by the sum of the full purchase price (£20,000.00) multiplied by the percentage discount (10.0%) is £18,000.00.</br></br>These two amounts should be the same.")
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
      let(:record) { FactoryBot.build(:sales_log, :saledate_today, mortgageused: 2, deposit: 5_000, grant: 3_000, value: 20_000, discount: 10, ownershipsch: 2) }

      it "returns true if grant and deposit total does not equal market value - discount" do
        sale_information_validator.validate_discounted_ownership_value(record)

        expect(record.errors["mortgageused"]).to include("The mortgage, cash deposit (£5,000.00), and grant (£3,000.00) added together is £8,000.00.</br></br>The full purchase price (£20,000.00) subtracted by the sum of the full purchase price (£20,000.00) multiplied by the percentage discount (10.0%) is £18,000.00.</br></br>These two amounts should be the same.")
        expect(record.errors["mortgage"]).to include("The mortgage, cash deposit (£5,000.00), and grant (£3,000.00) added together is £8,000.00.</br></br>The full purchase price (£20,000.00) subtracted by the sum of the full purchase price (£20,000.00) multiplied by the percentage discount (10.0%) is £18,000.00.</br></br>These two amounts should be the same.")
        expect(record.errors["value"]).to include("The mortgage, cash deposit (£5,000.00), and grant (£3,000.00) added together is £8,000.00.</br></br>The full purchase price (£20,000.00) subtracted by the sum of the full purchase price (£20,000.00) multiplied by the percentage discount (10.0%) is £18,000.00.</br></br>These two amounts should be the same.")
        expect(record.errors["deposit"]).to include("The mortgage, cash deposit (£5,000.00), and grant (£3,000.00) added together is £8,000.00.</br></br>The full purchase price (£20,000.00) subtracted by the sum of the full purchase price (£20,000.00) multiplied by the percentage discount (10.0%) is £18,000.00.</br></br>These two amounts should be the same.")
        expect(record.errors["ownershipsch"]).to include("The mortgage, cash deposit (£5,000.00), and grant (£3,000.00) added together is £8,000.00.</br></br>The full purchase price (£20,000.00) subtracted by the sum of the full purchase price (£20,000.00) multiplied by the percentage discount (10.0%) is £18,000.00.</br></br>These two amounts should be the same.")
        expect(record.errors["discount"]).to include("The mortgage, cash deposit (£5,000.00), and grant (£3,000.00) added together is £8,000.00.</br></br>The full purchase price (£20,000.00) subtracted by the sum of the full purchase price (£20,000.00) multiplied by the percentage discount (10.0%) is £18,000.00.</br></br>These two amounts should be the same.")
        expect(record.errors["grant"]).to include("The mortgage, cash deposit (£5,000.00), and grant (£3,000.00) added together is £8,000.00.</br></br>The full purchase price (£20,000.00) subtracted by the sum of the full purchase price (£20,000.00) multiplied by the percentage discount (10.0%) is £18,000.00.</br></br>These two amounts should be the same.")
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
      let(:record) { FactoryBot.build(:sales_log, :saledate_today, mortgage: 10_000, deposit: 5_000, grant: 3_000, value: 20_000, discount: 10, ownershipsch: 1) }

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

  describe "#validate_outright_sale_value_matches_mortgage_plus_deposit" do
    context "with a 2024 outright sale log" do
      let(:record) { FactoryBot.build(:sales_log, value: 300_000, ownershipsch: 3, saledate: Time.zone.local(2024, 5, 1)) }

      context "when a mortgage is used" do
        before do
          record.mortgageused = 1
        end

        context "and the mortgage plus deposit match the value" do
          before do
            record.mortgage = 200_000
            record.deposit = 100_000
          end

          it "does not add errors" do
            sale_information_validator.validate_outright_sale_value_matches_mortgage_plus_deposit(record)
            expect(record.errors).to be_empty
          end
        end

        context "and the mortgage plus deposit don't match the value" do
          before do
            record.mortgage = 100_000
            record.deposit = 100_000
          end

          it "adds errors" do
            sale_information_validator.validate_outright_sale_value_matches_mortgage_plus_deposit(record)
            expect(record.errors["mortgageused"]).to include("The mortgage (£100,000.00) and cash deposit (£100,000.00) when added together is £200,000.00.</br></br>The full purchase price is £300,000.00.</br></br>These two amounts should be the same.")
            expect(record.errors["mortgage"]).to include("The mortgage (£100,000.00) and cash deposit (£100,000.00) when added together is £200,000.00.</br></br>The full purchase price is £300,000.00.</br></br>These two amounts should be the same.")
            expect(record.errors["deposit"]).to include("The mortgage (£100,000.00) and cash deposit (£100,000.00) when added together is £200,000.00.</br></br>The full purchase price is £300,000.00.</br></br>These two amounts should be the same.")
            expect(record.errors["value"]).to include("The mortgage (£100,000.00) and cash deposit (£100,000.00) when added together is £200,000.00.</br></br>The full purchase price is £300,000.00.</br></br>These two amounts should be the same.")
            expect(record.errors["ownershipsch"]).to include("The mortgage (£100,000.00) and cash deposit (£100,000.00) when added together is £200,000.00.</br></br>The full purchase price is £300,000.00.</br></br>These two amounts should be the same.")
          end
        end

        context "and deposit is not provided" do
          before do
            record.mortgage = 100_000
            record.deposit = nil
          end

          it "does not add errors" do
            sale_information_validator.validate_outright_sale_value_matches_mortgage_plus_deposit(record)
            expect(record.errors).to be_empty
          end
        end

        context "and mortgage is not provided" do
          before do
            record.mortgage = nil
            record.deposit = 100_000
          end

          it "does not add errors" do
            sale_information_validator.validate_outright_sale_value_matches_mortgage_plus_deposit(record)
            expect(record.errors).to be_empty
          end
        end
      end
    end

    context "with a 2024 log that is not an outright sale" do
      let(:record) { FactoryBot.build(:sales_log, value: 300_000, ownershipsch: 2, saledate: Time.zone.local(2024, 5, 1)) }

      it "does not add errors" do
        record.mortgageused = 1
        record.mortgage = 100_000
        record.deposit = 100_000
        sale_information_validator.validate_outright_sale_value_matches_mortgage_plus_deposit(record)
        expect(record.errors).to be_empty
      end
    end

    context "with a 2023 outright sale log" do
      let(:record) { FactoryBot.build(:sales_log, value: 300_000, ownershipsch: 3, saledate: Time.zone.local(2023, 5, 1)) }

      it "does not add errors" do
        record.mortgageused = 1
        record.mortgage = 100_000
        record.deposit = 100_000
        sale_information_validator.validate_outright_sale_value_matches_mortgage_plus_deposit(record)
        expect(record.errors).to be_empty
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

        expect(record.errors[:mrent]).to include(I18n.t("validations.sales.sale_information.mrent.monthly_rent_higher_than_expected"))
        expect(record.errors[:type]).to include(I18n.t("validations.sales.sale_information.type.monthly_rent_higher_than_expected"))
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

        expect(record.errors[:grant]).to include("Loan, grants or subsidies must be between £9,000 and £16,000.")
      end
    end

    context "when under the min" do
      let(:record) { build(:sales_log, type: 21, grant: 3, saledate: Time.zone.local(2024, 4, 5)) }

      it "adds an error" do
        sale_information_validator.validate_grant_amount(record)

        expect(record.errors[:grant]).to include("Loan, grants or subsidies must be between £9,000 and £16,000.")
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
    let(:saledate) { Time.zone.local(2024, 4, 4) }

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
        let(:record) { build(:sales_log, ownershipsch: 1, type:, saledate:) }

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
      let(:record) { build(:sales_log, ownershipsch: 1, type: 24, saledate:, stairbought: 90) }
      let(:saledate) { Time.zone.local(2023, 4, 4) }

      it "does not add an error" do
        sale_information_validator.validate_stairbought(record)

        expect(record.errors).to be_empty
      end
    end
  end

  describe "#validate_discount_and_value" do
    let(:record) { FactoryBot.build(:sales_log, value: 200_000, discount: 50, ownershipsch: 2, type: 9, saledate:) }
    let(:saledate) { Time.zone.local(2024, 4, 1) }

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
    let(:record) { FactoryBot.build(:sales_log, mortgageused: 1, mortgage: 10_000, deposit: 5_000, value: 30_000, equity: 28, ownershipsch: 1, type: 30, saledate:) }

    context "with a log in the 24/25 collection year" do
      let(:saledate) { Time.zone.local(2024, 4, 4) }

      context "when MORTGAGE + DEPOSIT does not equal VALUE * EQUITY/100 " do
        context "and it is not a staircase transaction" do
          before do
            record.staircase = 2
          end

          it "adds an error" do
            sale_information_validator.validate_non_staircasing_mortgage(record)
            expect(record.errors["mortgage"]).to include("The mortgage (£10,000.00) and cash deposit (£5,000.00) added together is £15,000.00.</br></br>The full purchase price (£30,000.00) multiplied by the percentage equity stake purchased (28.0%) is £8,400.00.</br></br>These two amounts should be the same.")
            expect(record.errors["value"]).to include("The mortgage (£10,000.00) and cash deposit (£5,000.00) added together is £15,000.00.</br></br>The full purchase price (£30,000.00) multiplied by the percentage equity stake purchased (28.0%) is £8,400.00.</br></br>These two amounts should be the same.")
            expect(record.errors["deposit"]).to include("The mortgage (£10,000.00) and cash deposit (£5,000.00) added together is £15,000.00.</br></br>The full purchase price (£30,000.00) multiplied by the percentage equity stake purchased (28.0%) is £8,400.00.</br></br>These two amounts should be the same.")
            expect(record.errors["equity"]).to include("The mortgage (£10,000.00) and cash deposit (£5,000.00) added together is £15,000.00.</br></br>The full purchase price (£30,000.00) multiplied by the percentage equity stake purchased (28.0%) is £8,400.00.</br></br>These two amounts should be the same.")
            expect(record.errors["type"]).to include("The mortgage (£10,000.00) and cash deposit (£5,000.00) added together is £15,000.00.</br></br>The full purchase price (£30,000.00) multiplied by the percentage equity stake purchased (28.0%) is £8,400.00.</br></br>These two amounts should be the same.")
            expect(record.errors["cashdis"]).not_to include("The mortgage (£10,000.00) and cash deposit (£5,000.00) added together is £15,000.00.</br></br>The full purchase price (£30,000.00) multiplied by the percentage equity stake purchased (28.0%) is £8,400.00.</br></br>These two amounts should be the same.")
          end

          context "and it is a social homebuy" do
            before do
              record.type = 18
              record.cashdis = "200"
            end

            it "adds an error" do
              sale_information_validator.validate_non_staircasing_mortgage(record)
              expect(record.errors["mortgage"]).to include("The mortgage amount (£10,000.00), cash deposit (£5,000.00), and cash discount (£200.00) added together is £15,200.00.</br></br>The full purchase price (£30,000.00) multiplied by the percentage equity stake purchased (28.0%) is £8,400.00.</br></br>These two amounts should be the same.")
              expect(record.errors["value"]).to include("The mortgage amount (£10,000.00), cash deposit (£5,000.00), and cash discount (£200.00) added together is £15,200.00.</br></br>The full purchase price (£30,000.00) multiplied by the percentage equity stake purchased (28.0%) is £8,400.00.</br></br>These two amounts should be the same.")
              expect(record.errors["deposit"]).to include("The mortgage amount (£10,000.00), cash deposit (£5,000.00), and cash discount (£200.00) added together is £15,200.00.</br></br>The full purchase price (£30,000.00) multiplied by the percentage equity stake purchased (28.0%) is £8,400.00.</br></br>These two amounts should be the same.")
              expect(record.errors["equity"]).to include("The mortgage amount (£10,000.00), cash deposit (£5,000.00), and cash discount (£200.00) added together is £15,200.00.</br></br>The full purchase price (£30,000.00) multiplied by the percentage equity stake purchased (28.0%) is £8,400.00.</br></br>These two amounts should be the same.")
              expect(record.errors["cashdis"]).to include("The mortgage amount (£10,000.00), cash deposit (£5,000.00), and cash discount (£200.00) added together is £15,200.00.</br></br>The full purchase price (£30,000.00) multiplied by the percentage equity stake purchased (28.0%) is £8,400.00.</br></br>These two amounts should be the same.")
              expect(record.errors["type"]).to include("The mortgage amount (£10,000.00), cash deposit (£5,000.00), and cash discount (£200.00) added together is £15,200.00.</br></br>The full purchase price (£30,000.00) multiplied by the percentage equity stake purchased (28.0%) is £8,400.00.</br></br>These two amounts should be the same.")
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
        let(:record) { FactoryBot.build(:sales_log, mortgageused: 1, mortgage: 10_000, staircase: 2, deposit: 5_000, value: 30_000, equity: 50, ownershipsch: 1, type: 30, saledate:) }

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
        let(:record) { FactoryBot.build(:sales_log, mortgageused: 1, mortgage: 10_000, staircase: 2, deposit: 50_000, value: 120_001, equity: 50, ownershipsch: 1, type: 30, saledate:) }

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
              expect(record.errors["mortgageused"]).to include("The cash deposit is £5,000.00.</br></br>The full purchase price (£30,000.00) multiplied by the percentage bought is £8,400.00.</br></br>These two amounts should be the same.")
              expect(record.errors["value"]).to include("The cash deposit is £5,000.00.</br></br>The full purchase price (£30,000.00) multiplied by the percentage bought is £8,400.00.</br></br>These two amounts should be the same.")
              expect(record.errors["deposit"]).to include("The cash deposit is £5,000.00.</br></br>The full purchase price (£30,000.00) multiplied by the percentage bought is £8,400.00.</br></br>These two amounts should be the same.")
              expect(record.errors["equity"]).to include("The cash deposit is £5,000.00.</br></br>The full purchase price (£30,000.00) multiplied by the percentage bought is £8,400.00.</br></br>These two amounts should be the same.")
              expect(record.errors["type"]).to include("The cash deposit is £5,000.00.</br></br>The full purchase price (£30,000.00) multiplied by the percentage bought is £8,400.00.</br></br>These two amounts should be the same.")
              expect(record.errors["cashdis"]).not_to include("The cash deposit is £5,000.00.</br></br>The full purchase price (£30,000.00) multiplied by the percentage bought is £8,400.00.</br></br>These two amounts should be the same.")
            end

            context "and it is a social homebuy" do
              before do
                record.type = 18
                record.cashdis = "200"
              end

              it "adds an error" do
                sale_information_validator.validate_non_staircasing_mortgage(record)
                expect(record.errors["mortgageused"]).to include("The cash deposit (£5,000.00) and cash discount (£200.00) added together is £5,200.00.</br></br>The full purchase price (£30,000.00) multiplied by the percentage bought (28.0%) is £8,400.00.</br></br>These two amounts should be the same.")
                expect(record.errors["value"]).to include("The cash deposit (£5,000.00) and cash discount (£200.00) added together is £5,200.00.</br></br>The full purchase price (£30,000.00) multiplied by the percentage bought (28.0%) is £8,400.00.</br></br>These two amounts should be the same.")
                expect(record.errors["deposit"]).to include("The cash deposit (£5,000.00) and cash discount (£200.00) added together is £5,200.00.</br></br>The full purchase price (£30,000.00) multiplied by the percentage bought (28.0%) is £8,400.00.</br></br>These two amounts should be the same.")
                expect(record.errors["equity"]).to include("The cash deposit (£5,000.00) and cash discount (£200.00) added together is £5,200.00.</br></br>The full purchase price (£30,000.00) multiplied by the percentage bought (28.0%) is £8,400.00.</br></br>These two amounts should be the same.")
                expect(record.errors["cashdis"]).to include("The cash deposit (£5,000.00) and cash discount (£200.00) added together is £5,200.00.</br></br>The full purchase price (£30,000.00) multiplied by the percentage bought (28.0%) is £8,400.00.</br></br>These two amounts should be the same.")
                expect(record.errors["type"]).to include("The cash deposit (£5,000.00) and cash discount (£200.00) added together is £5,200.00.</br></br>The full purchase price (£30,000.00) multiplied by the percentage bought (28.0%) is £8,400.00.</br></br>These two amounts should be the same.")
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
          let(:record) { FactoryBot.build(:sales_log, mortgageused: 2, staircase: 2, deposit: 15_000, value: 30_000, equity: 50, ownershipsch: 1, type: 30, saledate:) }

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
          let(:record) { FactoryBot.build(:sales_log, mortgageused: 2, staircase: 2, deposit: 15_000, value: 30_001, equity: 50, ownershipsch: 1, type: 30, saledate:) }

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
      let(:saledate) { Time.zone.local(2023, 4, 1) }
      let(:record) { FactoryBot.build(:sales_log, mortgage: 10_000, staircase: 2, deposit: 5_000, value: 30_000, equity: 28, ownershipsch: 1, type: 30, saledate:) }

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
    let(:record) { FactoryBot.build(:sales_log, mortgageused: 1, mortgage: 10_000, deposit: 5_000, value: 30_000, stairbought: 28, ownershipsch: 1, type: 30, saledate:) }

    context "with a log in the 24/25 collection year" do
      let(:saledate) { Time.zone.local(2024, 4, 4) }

      context "when MORTGAGE + DEPOSIT does not equal STAIRBOUGHT/100 * VALUE" do
        context "and it is a staircase transaction" do
          before do
            record.staircase = 1
          end

          it "adds an error" do
            sale_information_validator.validate_staircasing_mortgage(record)
            expect(record.errors["mortgage"]).to include(I18n.t("validations.sales.sale_information.mortgage.staircasing_mortgage.mortgage_used", mortgage: "£10,000.00", deposit: "£5,000.00", mortgage_and_deposit_total: "£15,000.00", value: "£30,000.00", stairbought_part_of_value: "£8,400.00"))
            expect(record.errors["value"]).to include(I18n.t("validations.sales.sale_information.value.staircasing_mortgage.mortgage_used", mortgage: "£10,000.00", deposit: "£5,000.00", mortgage_and_deposit_total: "£15,000.00", value: "£30,000.00", stairbought_part_of_value: "£8,400.00"))
            expect(record.errors["deposit"]).to include(I18n.t("validations.sales.sale_information.deposit.staircasing_mortgage.mortgage_used", mortgage: "£10,000.00", deposit: "£5,000.00", mortgage_and_deposit_total: "£15,000.00", value: "£30,000.00", stairbought_part_of_value: "£8,400.00"))
            expect(record.errors["stairbought"]).to include(I18n.t("validations.sales.sale_information.stairbought.staircasing_mortgage.mortgage_used", mortgage: "£10,000.00", deposit: "£5,000.00", mortgage_and_deposit_total: "£15,000.00", value: "£30,000.00", stairbought_part_of_value: "£8,400.00"))
            expect(record.errors["type"]).to include(I18n.t("validations.sales.sale_information.type.staircasing_mortgage.mortgage_used", mortgage: "£10,000.00", deposit: "£5,000.00", mortgage_and_deposit_total: "£15,000.00", value: "£30,000.00", stairbought_part_of_value: "£8,400.00"))
          end

          context "and it is a social homebuy" do
            before do
              record.type = 18
              record.cashdis = "200"
            end

            it "adds an error" do
              sale_information_validator.validate_staircasing_mortgage(record)
              expect(record.errors["mortgage"]).to include(I18n.t("validations.sales.sale_information.mortgage.staircasing_mortgage.mortgage_used_socialhomebuy", mortgage: "£10,000.00", deposit: "£5,000.00", cashdis: "£200.00", mortgage_deposit_and_discount_total: "£15,200.00", value: "£30,000.00", stairbought_part_of_value: "£8,400.00", stairbought: "28.0%"))
              expect(record.errors["value"]).to include(I18n.t("validations.sales.sale_information.value.staircasing_mortgage.mortgage_used_socialhomebuy", mortgage: "£10,000.00", deposit: "£5,000.00", cashdis: "£200.00", mortgage_deposit_and_discount_total: "£15,200.00", value: "£30,000.00", stairbought_part_of_value: "£8,400.00", stairbought: "28.0%"))
              expect(record.errors["deposit"]).to include(I18n.t("validations.sales.sale_information.deposit.staircasing_mortgage.mortgage_used_socialhomebuy", mortgage: "£10,000.00", deposit: "£5,000.00", cashdis: "£200.00", mortgage_deposit_and_discount_total: "£15,200.00", value: "£30,000.00", stairbought_part_of_value: "£8,400.00", stairbought: "28.0%"))
              expect(record.errors["stairbought"]).to include(I18n.t("validations.sales.sale_information.stairbought.staircasing_mortgage.mortgage_used_socialhomebuy", mortgage: "£10,000.00", deposit: "£5,000.00", cashdis: "£200.00", mortgage_deposit_and_discount_total: "£15,200.00", value: "£30,000.00", stairbought_part_of_value: "£8,400.00", stairbought: "28.0%"))
              expect(record.errors["cashdis"]).to include(I18n.t("validations.sales.sale_information.cashdis.staircasing_mortgage.mortgage_used_socialhomebuy", mortgage: "£10,000.00", deposit: "£5,000.00", cashdis: "£200.00", mortgage_deposit_and_discount_total: "£15,200.00", value: "£30,000.00", stairbought_part_of_value: "£8,400.00", stairbought: "28.0%"))
              expect(record.errors["type"]).to include(I18n.t("validations.sales.sale_information.type.staircasing_mortgage.mortgage_used_socialhomebuy", mortgage: "£10,000.00", deposit: "£5,000.00", cashdis: "£200.00", mortgage_deposit_and_discount_total: "£15,200.00", value: "£30,000.00", stairbought_part_of_value: "£8,400.00", stairbought: "28.0%"))
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
        let(:record) { FactoryBot.build(:sales_log, mortgageused: 1, mortgage: 10_000, staircase: 1, deposit: 5_000, value: 30_000, stairbought: 50, ownershipsch: 1, type: 30, saledate:) }

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
        let(:record) { FactoryBot.build(:sales_log, mortgageused: 1, mortgage: 10_000, staircase: 1, deposit: 5_000, value: 30_001, stairbought: 50, ownershipsch: 1, type: 30, saledate:) }

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
      let(:saledate) { Time.zone.local(2023, 4, 1) }
      let(:record) { FactoryBot.build(:sales_log, mortgage: 10_000, staircase: 1, deposit: 5_000, value: 30_000, stairbought: 28, ownershipsch: 1, type: 30, saledate:) }

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
        let(:saledate) { Time.zone.local(2024, 4, 4) }

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
              expect(record.errors["mortgageused"]).to include(I18n.t("validations.sales.sale_information.mortgageused.staircasing_mortgage.mortgage_not_used", deposit: "£5,000.00", value: "£30,000.00", stairbought_part_of_value: "£8,400.00"))
              expect(record.errors["value"]).to include(I18n.t("validations.sales.sale_information.value.staircasing_mortgage.mortgage_not_used", deposit: "£5,000.00", value: "£30,000.00", stairbought_part_of_value: "£8,400.00"))
              expect(record.errors["deposit"]).to include(I18n.t("validations.sales.sale_information.deposit.staircasing_mortgage.mortgage_not_used", deposit: "£5,000.00", value: "£30,000.00", stairbought_part_of_value: "£8,400.00"))
              expect(record.errors["stairbought"]).to include(I18n.t("validations.sales.sale_information.stairbought.staircasing_mortgage.mortgage_not_used", deposit: "£5,000.00", value: "£30,000.00", stairbought_part_of_value: "£8,400.00"))
              expect(record.errors["type"]).to include(I18n.t("validations.sales.sale_information.type.staircasing_mortgage.mortgage_not_used", deposit: "£5,000.00", value: "£30,000.00", stairbought_part_of_value: "£8,400.00"))
            end

            context "and it is a social homebuy" do
              before do
                record.type = 18
                record.cashdis = "200"
              end

              it "adds an error" do
                sale_information_validator.validate_staircasing_mortgage(record)
                expect(record.errors["mortgageused"]).to include(I18n.t("validations.sales.sale_information.mortgageused.staircasing_mortgage.mortgage_not_used_socialhomebuy", deposit: "£5,000.00", cashdis: "£200.00", deposit_and_discount_total: "£5,200.00", value: "£30,000.00", stairbought: "28.0%", stairbought_part_of_value: "£8,400.00"))
                expect(record.errors["value"]).to include(I18n.t("validations.sales.sale_information.value.staircasing_mortgage.mortgage_not_used_socialhomebuy", deposit: "£5,000.00", cashdis: "£200.00", deposit_and_discount_total: "£5,200.00", value: "£30,000.00", stairbought: "28.0%", stairbought_part_of_value: "£8,400.00"))
                expect(record.errors["deposit"]).to include(I18n.t("validations.sales.sale_information.deposit.staircasing_mortgage.mortgage_not_used_socialhomebuy", deposit: "£5,000.00", cashdis: "£200.00", deposit_and_discount_total: "£5,200.00", value: "£30,000.00", stairbought: "28.0%", stairbought_part_of_value: "£8,400.00"))
                expect(record.errors["stairbought"]).to include(I18n.t("validations.sales.sale_information.stairbought.staircasing_mortgage.mortgage_not_used_socialhomebuy", deposit: "£5,000.00", cashdis: "£200.00", deposit_and_discount_total: "£5,200.00", value: "£30,000.00", stairbought: "28.0%", stairbought_part_of_value: "£8,400.00"))
                expect(record.errors["cashdis"]).to include(I18n.t("validations.sales.sale_information.cashdis.staircasing_mortgage.mortgage_not_used_socialhomebuy", deposit: "£5,000.00", cashdis: "£200.00", deposit_and_discount_total: "£5,200.00", value: "£30,000.00", stairbought: "28.0%", stairbought_part_of_value: "£8,400.00"))
                expect(record.errors["type"]).to include(I18n.t("validations.sales.sale_information.type.staircasing_mortgage.mortgage_not_used_socialhomebuy", deposit: "£5,000.00", cashdis: "£200.00", deposit_and_discount_total: "£5,200.00", value: "£30,000.00", stairbought: "28.0%", stairbought_part_of_value: "£8,400.00"))
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
          let(:record) { FactoryBot.build(:sales_log, mortgageused: 2, staircase: 1, deposit: 15_000, value: 30_000, stairbought: 50, ownershipsch: 1, type: 30, saledate:) }

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
          let(:record) { FactoryBot.build(:sales_log, mortgageused: 2, staircase: 1, deposit: 15_000, value: 30_001, stairbought: 50, ownershipsch: 1, type: 30, saledate:) }

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
        let(:saledate) { Time.zone.local(2023, 4, 1) }
        let(:record) { FactoryBot.build(:sales_log, mortgageused: 2, staircase: 1, deposit: 5_000, value: 30_000, stairbought: 28, ownershipsch: 1, type: 30, saledate:) }

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

  describe "#validate_mortgage_used_dont_know" do
    let(:staircase) { nil }
    let(:stairowned) { nil }
    let(:saledate) { nil }
    let(:sales_log) { build(:sales_log, ownershipsch:, mortgageused:, staircase:, stairowned:, saledate:) }

    before do
      sale_information_validator.validate_mortgage_used_dont_know(sales_log)
    end

    context "when mortgageused is don't know" do
      let(:mortgageused) { 3 }

      context "and it is a discounted ownership sale" do
        let(:ownershipsch) { 2 }

        it "adds an error" do
          expect(sales_log.errors[:mortgageused]).to include "Enter a valid value for was a mortgage used for the purchase of this property?"
        end
      end

      context "and it is an outright sale" do
        let(:ownershipsch) { 3 }

        context "with a saledate before 24/25" do
          let(:saledate) { Time.zone.local(2023, 9, 9) }

          it "adds errors" do
            expect(sales_log.errors[:mortgageused]).to include "Enter a valid value for was a mortgage used for the purchase of this property?"
            expect(sales_log.errors[:saledate]).to include "You must answer either ‘yes’ or ‘no’ to the question ‘was a mortgage used’ for the selected year."
          end
        end

        context "with a saledate from 24/25 or after" do
          let(:saledate) { Time.zone.today }

          it "does not add any errors" do
            expect(sales_log.errors).to be_empty
          end
        end
      end

      context "and it is a shared ownership scheme sale" do
        let(:ownershipsch) { 1 }

        context "and a staircasing transaction" do
          let(:staircase) { 1 }

          context "and stairowned is nil" do
            let(:stairowned) { nil }

            it "does not add an error" do
              expect(sales_log.errors).to be_empty
            end
          end

          context "and stairowned is less than 100" do
            let(:stairowned) { 50 }

            it "adds errors" do
              expect(sales_log.errors[:mortgageused]).to include "The percentage owned has to be 100% if the mortgage used is 'Don’t know'"
              expect(sales_log.errors[:stairowned]).to include "The percentage owned has to be 100% if the mortgage used is 'Don’t know'"
            end
          end

          context "and stairowned is 100" do
            let(:stairowned) { 100 }

            it "does not add an error" do
              expect(sales_log.errors).to be_empty
            end
          end
        end

        context "and not a staircasing transaction" do
          let(:staircase) { 2 }

          it "adds errors" do
            expect(sales_log.errors[:mortgageused]).to include "Enter a valid value for was a mortgage used for the purchase of this property?"
            expect(sales_log.errors[:staircase]).to include "You must answer either ‘yes’ or ‘no’ to the question ‘was a mortgage used’ for staircasing transactions."
          end
        end
      end
    end

    context "when mortgageused is not don't know" do
      let(:mortgageused) { 1 }

      context "and it is a discounted ownership sale" do
        let(:ownershipsch) { 2 }

        it "does not add an error" do
          expect(sales_log.errors).to be_empty
        end
      end
    end
  end

  describe "#validate_number_of_staircase_transactions" do
    let(:record) { build(:sales_log, numstair:, firststair:) }

    before do
      sale_information_validator.validate_number_of_staircase_transactions(record)
    end

    context "when it is not the first staircasing transaction" do
      context "and the number of staircasing transactions is between 2 and 10" do
        let(:numstair) { 6 }
        let(:firststair) { 2 }

        it "does not add an error" do
          expect(record.errors).to be_empty
        end
      end

      context "and the number of staircasing transactions is less than 2" do
        let(:numstair) { 1 }
        let(:firststair) { 2 }

        it "adds an error" do
          expect(record.errors[:numstair]).to include(I18n.t("validations.sales.sale_information.numstair.must_be_greater_than_one"))
          expect(record.errors[:firststair]).to include(I18n.t("validations.sales.sale_information.firststair.cannot_be_no"))
        end
      end
    end

    context "when it is the first staircasing transaction" do
      context "and numstair is also 1" do
        let(:numstair) { 1 }
        let(:firststair) { 1 }

        it "does not add an error" do
          expect(record.errors).to be_empty
        end
      end
    end
  end
end
