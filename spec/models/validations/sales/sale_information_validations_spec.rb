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
end
