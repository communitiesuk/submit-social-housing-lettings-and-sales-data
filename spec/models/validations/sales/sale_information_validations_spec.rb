require "rails_helper"

RSpec.describe Validations::Sales::SaleInformationValidations do
  subject(:sale_information_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::Sales::SaleInformationValidations } }

  describe "#validate_deposit_range" do
    context "when within permitted bounds" do
      let(:record) { build(:sales_log, deposit: 0) }

      it "does not add an error" do
        sale_information_validator.validate_deposit_range(record)

        expect(record.errors[:deposit]).not_to be_present
      end
    end

    context "when blank" do
      let(:record) { build(:sales_log, deposit: nil) }

      it "does not add an error" do
        sale_information_validator.validate_deposit_range(record)

        expect(record.errors[:deposit]).not_to be_present
      end
    end

    context "when below lower bound" do
      let(:record) { build(:sales_log, deposit: -1) }

      it "adds an error" do
        sale_information_validator.validate_deposit_range(record)

        expect(record.errors[:deposit]).to be_present
      end
    end

    context "when higher than upper bound" do
      let(:record) { build(:sales_log, deposit: 1_000_000) }

      it "adds an error" do
        sale_information_validator.validate_deposit_range(record)

        expect(record.errors[:deposit]).to be_present
      end
    end
  end

  describe "#validate_practical_completion_date_before_saledate" do
    context "when hodate blank" do
      let(:record) { build(:sales_log, hodate: nil) }

      it "does not add an error" do
        sale_information_validator.validate_practical_completion_date_before_saledate(record)

        expect(record.errors).not_to be_present
      end
    end

    context "when saledate blank" do
      let(:record) { build(:sales_log, saledate: nil) }

      it "does not add an error" do
        sale_information_validator.validate_practical_completion_date_before_saledate(record)

        expect(record.errors).not_to be_present
      end
    end

    context "when saledate and hodate blank" do
      let(:record) { build(:sales_log, hodate: nil, saledate: nil) }

      it "does not add an error" do
        sale_information_validator.validate_practical_completion_date_before_saledate(record)

        expect(record.errors).not_to be_present
      end
    end

    context "when hodate before saledate" do
      let(:record) { build(:sales_log, hodate: 2.months.ago, saledate: 1.month.ago) }

      it "does not add the error" do
        sale_information_validator.validate_practical_completion_date_before_saledate(record)

        expect(record.errors).not_to be_present
      end
    end

    context "when hodate after saledate" do
      let(:record) { build(:sales_log, hodate: 1.month.ago, saledate: 2.months.ago) }

      it "adds error" do
        sale_information_validator.validate_practical_completion_date_before_saledate(record)

        expect(record.errors[:hodate]).to be_present
      end
    end

    context "when hodate == saledate" do
      let(:record) { build(:sales_log, hodate: Time.zone.parse("2023-07-01"), saledate: Time.zone.parse("2023-07-01")) }

      it "does not add an error" do
        sale_information_validator.validate_practical_completion_date_before_saledate(record)

        expect(record.errors[:hodate]).to be_present
      end
    end
  end

  describe "#validate_years_living_in_property_before_purchase" do
    context "when proplen blank" do
      let(:record) { build(:sales_log, proplen: nil) }

      it "does not add an error" do
        sale_information_validator.validate_years_living_in_property_before_purchase(record)

        expect(record.errors).not_to be_present
      end
    end

    context "when type blank" do
      let(:record) { build(:sales_log, type: nil) }

      it "does not add an error" do
        sale_information_validator.validate_years_living_in_property_before_purchase(record)

        expect(record.errors).not_to be_present
      end
    end

    context "when proplen 0" do
      let(:record) { build(:sales_log, proplen: 0) }

      it "does not add an error" do
        sale_information_validator.validate_years_living_in_property_before_purchase(record)

        expect(record.errors).not_to be_present
      end
    end

    context "when type Rent to Buy and proplen > 0" do
      let(:record) { build(:sales_log, proplen: 1, type: 28) }

      it "adds an error" do
        sale_information_validator.validate_years_living_in_property_before_purchase(record)

        expect(record.errors).to be_present
      end
    end

    context "when type Social HomeBuy and proplen > 0" do
      let(:record) { build(:sales_log, proplen: 1, type: 18) }

      it "adds an error" do
        sale_information_validator.validate_years_living_in_property_before_purchase(record)

        expect(record.errors).to be_present
      end
    end

  end
end
