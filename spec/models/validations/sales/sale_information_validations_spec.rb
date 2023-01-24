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

  describe "#validate_pratical_completion_date_before_exdate" do
    context "when hodate blank" do
      let(:record) { build(:sales_log, hodate: nil) }

      it "does not add an error" do
        sale_information_validator.validate_pratical_completion_date_before_exdate(record)

        expect(record.errors).not_to be_present
      end
    end

    context "when exdate blank" do
      let(:record) { build(:sales_log, exdate: nil) }

      it "does not add an error" do
        sale_information_validator.validate_pratical_completion_date_before_exdate(record)

        expect(record.errors).not_to be_present
      end
    end

    context "when exdate and hodate blank" do
      let(:record) { build(:sales_log, hodate: nil, exdate: nil) }

      it "does not add an error" do
        sale_information_validator.validate_pratical_completion_date_before_exdate(record)

        expect(record.errors).not_to be_present
      end
    end

    context "when hodate before exdate" do
      let(:record) { build(:sales_log, hodate: 2.months.ago, exdate: 1.month.ago) }

      it "does not add the error" do
        sale_information_validator.validate_pratical_completion_date_before_exdate(record)

        expect(record.errors).not_to be_present
      end
    end

    context "when hodate after exdate" do
      let(:record) { build(:sales_log, hodate: 1.month.ago, exdate: 2.months.ago) }

      it "adds error" do
        sale_information_validator.validate_pratical_completion_date_before_exdate(record)

        expect(record.errors[:hodate]).to be_present
      end
    end

    context "when hodate == exdate" do
      let(:record) { build(:sales_log, hodate: Time.zone.parse("2023-07-01"), exdate: Time.zone.parse("2023-07-01")) }

      it "does not add an error" do
        sale_information_validator.validate_pratical_completion_date_before_exdate(record)

        expect(record.errors[:hodate]).to be_present
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
        expect(record.errors["frombeds"]).to include(I18n.t("validations.sale_information.previous_property_beds.property_type_bedsit"))
      end
    end
  end
end
