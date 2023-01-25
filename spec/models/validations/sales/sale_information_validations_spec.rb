require "rails_helper"

RSpec.describe Validations::Sales::SaleInformationValidations do
  subject(:sale_information_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::Sales::SaleInformationValidations } }

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

      it "does not add the error" do
        sale_information_validator.validate_exchange_date(record)

        expect(record.errors[:exdate]).to eq(
          ["Contract exchange date must be less than 1 year before completion date"],
        )
      end
    end

    context "when exdate after saledate" do
      let(:record) { build(:sales_log, exdate: 1.month.ago, saledate: 2.months.ago) }

      it "adds error" do
        sale_information_validator.validate_exchange_date(record)

        expect(record.errors[:exdate]).to eq(
          ["Contract exchange date must be less than 1 year before completion date"],
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
        expect(record.errors["frombeds"]).to include(I18n.t("validations.sale_information.previous_property_beds.property_type_bedsit"))
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

        expect(record.errors[:type]).to include(I18n.t("validations.sale_information.proplen.rent_to_buy"))
        expect(record.errors[:proplen]).to include(I18n.t("validations.sale_information.proplen.rent_to_buy"))
      end
    end

    context "when type Social HomeBuy and proplen > 0" do
      let(:record) { build(:sales_log, proplen: 1, type: 18) }

      it "adds an error" do
        sale_information_validator.validate_years_living_in_property_before_purchase(record)

        expect(record.errors[:type]).to include(I18n.t("validations.sale_information.proplen.social_homebuy"))
        expect(record.errors[:proplen]).to include(I18n.t("validations.sale_information.proplen.social_homebuy"))
      end
    end
  end

  describe "#validate_discounted_ownership_value" do
    context "when mortgage, deposit and grant total does not equal market value - discount" do
      let(:record) { FactoryBot.build(:sales_log, mortgage: 10_000, deposit: 5_000, grant: 3_000, value: 30_000, discount: 10, ownershipsch: 2) }

      it "does not add an error" do
        sale_information_validator.validate_discounted_ownership_value(record)

        expect(record.errors[:mortgage]).to include(I18n.t("validations.sale_information.discounted_ownership_value", value_with_discount: "27000.00"))
        expect(record.errors[:deposit]).to include(I18n.t("validations.sale_information.discounted_ownership_value", value_with_discount: "27000.00"))
        expect(record.errors[:grant]).to include(I18n.t("validations.sale_information.discounted_ownership_value", value_with_discount: "27000.00"))
        expect(record.errors[:value]).to include(I18n.t("validations.sale_information.discounted_ownership_value", value_with_discount: "27000.00"))
        expect(record.errors[:discount]).to include(I18n.t("validations.sale_information.discounted_ownership_value", value_with_discount: "27000.00"))
      end
    end

    context "when mortgage, deposit and grant total equals market value - discount" do
      let(:record) { FactoryBot.build(:sales_log, mortgage: 10_000, deposit: 5_000, grant: 3_000, value: 20_000, discount: 10, ownershipsch: 2) }

      it "does not add an error" do
        sale_information_validator.validate_discounted_ownership_value(record)

        expect(record.errors).to be_empty
      end
    end

    context "when mortgage value is not provided" do
      let(:record) { FactoryBot.build(:sales_log, mortgage: nil, deposit: 5_000, grant: 3_000, value: 20_000, discount: 10, ownershipsch: 2) }

      it "does not add an error" do
        sale_information_validator.validate_discounted_ownership_value(record)

        expect(record.errors).to be_empty
      end
    end

    context "when deposit value is not provided" do
      let(:record) { FactoryBot.build(:sales_log, mortgage: 10_000, deposit: nil, grant: 3_000, value: 20_000, discount: 10, ownershipsch: 2) }

      it "does not add an error" do
        sale_information_validator.validate_discounted_ownership_value(record)

        expect(record.errors).to be_empty
      end
    end

    context "when grant value is not provided and discount is provided" do
      let(:record) { FactoryBot.build(:sales_log, mortgage: 10_000, deposit: 5_000, grant: nil, value: 20_000, discount: 10, ownershipsch: 2) }

      it "adds an error for invalid values" do
        sale_information_validator.validate_discounted_ownership_value(record)

        expect(record.errors[:mortgage]).to include(I18n.t("validations.sale_information.discounted_ownership_value", value_with_discount: "18000.00"))
        expect(record.errors[:deposit]).to include(I18n.t("validations.sale_information.discounted_ownership_value", value_with_discount: "18000.00"))
        expect(record.errors[:grant]).to include(I18n.t("validations.sale_information.discounted_ownership_value", value_with_discount: "18000.00"))
        expect(record.errors[:value]).to include(I18n.t("validations.sale_information.discounted_ownership_value", value_with_discount: "18000.00"))
        expect(record.errors[:discount]).to include(I18n.t("validations.sale_information.discounted_ownership_value", value_with_discount: "18000.00"))
      end
    end

    context "when discount is not provided and grant is provided" do
      let(:record) { FactoryBot.build(:sales_log, mortgage: 10_000, deposit: 5_000, grant: 1002, value: 20_000, discount: nil, ownershipsch: 2) }

      it "adds an error for invalid values" do
        sale_information_validator.validate_discounted_ownership_value(record)

        expect(record.errors[:mortgage]).to include(I18n.t("validations.sale_information.discounted_ownership_value", value_with_discount: "20000.00"))
        expect(record.errors[:deposit]).to include(I18n.t("validations.sale_information.discounted_ownership_value", value_with_discount: "20000.00"))
        expect(record.errors[:grant]).to include(I18n.t("validations.sale_information.discounted_ownership_value", value_with_discount: "20000.00"))
        expect(record.errors[:value]).to include(I18n.t("validations.sale_information.discounted_ownership_value", value_with_discount: "20000.00"))
        expect(record.errors[:discount]).to include(I18n.t("validations.sale_information.discounted_ownership_value", value_with_discount: "20000.00"))
      end
    end

    context "when value is not provided" do
      let(:record) { FactoryBot.build(:sales_log, mortgage: 10_000, deposit: 5_000, grant: 3_000, value: nil, discount: 10, ownershipsch: 2) }

      it "does not add an error" do
        sale_information_validator.validate_discounted_ownership_value(record)

        expect(record.errors).to be_empty
      end
    end

    context "when discount and grant is not provided" do
      let(:record) { FactoryBot.build(:sales_log, mortgage: 10_000, deposit: 5_000, grant: nil, value: 20_000, discount: nil, ownershipsch: 2) }

      it "does not add an error" do
        sale_information_validator.validate_discounted_ownership_value(record)

        expect(record.errors).to be_empty
      end
    end

    context "when owhership is not discounted" do
      let(:record) { FactoryBot.build(:sales_log, mortgage: 10_000, deposit: 5_000, grant: 3_000, value: 20_000, discount: 10, ownershipsch: 1) }

      it "does not add an error" do
        sale_information_validator.validate_discounted_ownership_value(record)

        expect(record.errors).to be_empty
      end
    end
  end
end
