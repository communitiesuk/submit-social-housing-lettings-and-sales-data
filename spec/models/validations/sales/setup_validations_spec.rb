require "rails_helper"

RSpec.describe Validations::Sales::SetupValidations do
  subject(:setup_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::Sales::SetupValidations } }

  describe "#validate_saledate" do
    context "when saledate is blank" do
      let(:record) { FactoryBot.build(:sales_log, saledate: nil) }

      it "does not add an error" do
        setup_validator.validate_saledate(record)

        expect(record.errors).to be_empty
      end
    end

    context "when saledate is in the 22/23 financial year" do
      let(:record) { FactoryBot.build(:sales_log, saledate: Time.zone.local(2023, 1, 1)) }

      it "does not add an error" do
        setup_validator.validate_saledate(record)

        expect(record.errors).to be_empty
      end
    end

    context "when saledate is before the 22/23 financial year" do
      let(:record) { FactoryBot.build(:sales_log, saledate: Time.zone.local(2022, 1, 1)) }

      it "adds error" do
        setup_validator.validate_saledate(record)

        expect(record.errors[:saledate]).to include(I18n.t("validations.setup.saledate.financial_year"))
      end
    end

    context "when saledate is after the 22/23 financial year" do
      let(:record) { FactoryBot.build(:sales_log, saledate: Time.zone.local(2023, 4, 1)) }

      it "adds error" do
        setup_validator.validate_saledate(record)

        expect(record.errors[:saledate]).to include(I18n.t("validations.setup.saledate.financial_year"))
      end
    end
  end
end
