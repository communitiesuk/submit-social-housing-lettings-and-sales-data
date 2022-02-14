require "rails_helper"

RSpec.describe Validations::PropertyValidations do
  subject(:property_validator) { property_validator_class.new }

  let(:property_validator_class) { Class.new { include Validations::PropertyValidations } }
  let(:record) { FactoryBot.create(:case_log) }

  describe "#validate_property_number_of_times_relet" do
    let(:expected_error) { I18n.t("validations.property.offered.relet_number") }

    it "does not add an error if the record offered is missing" do
      record.offered = nil
      property_validator.validate_property_number_of_times_relet(record)
      expect(record.errors).to be_empty
    end

    it "does not add an error if offered is valid (number between 0 and 20)" do
      record.offered = 0
      property_validator.validate_property_number_of_times_relet(record)
      expect(record.errors).to be_empty
      record.offered = 10
      property_validator.validate_property_number_of_times_relet(record)
      expect(record.errors).to be_empty
      record.offered = 20
      property_validator.validate_property_number_of_times_relet(record)
      expect(record.errors).to be_empty
    end

    it "does add an error when offered is invalid" do
      record.offered = "invalid"
      property_validator.validate_property_number_of_times_relet(record)
      expect(record.errors).not_to be_empty
      expect(record.errors["offered"]).to include(match(expected_error))
      record.offered = 21
      property_validator.validate_property_number_of_times_relet(record)
      expect(record.errors).not_to be_empty
      expect(record.errors["offered"]).to include(match(expected_error))
    end
  end

  describe "#validate_shared_housing_rooms" do
    context "when number of bedrooms has not been answered" do
      it "does not add an error" do
        record.beds = nil
        record.unittype_gn = "Bedsit"
        property_validator.validate_shared_housing_rooms(record)
        expect(record.errors).to be_empty
      end
    end

    context "when unit type is shared and number of bedrooms has not been answered" do
      it "does not add an error" do
        record.beds = nil
        record.unittype_gn = "Shared bungalow"
        property_validator.validate_shared_housing_rooms(record)
        expect(record.errors).to be_empty
      end
    end

    context "when unit type has not been answered" do
      it "does not add an error" do
        record.beds = 2
        record.unittype_gn = nil
        property_validator.validate_shared_housing_rooms(record)
        expect(record.errors).to be_empty
      end
    end

    context "when a bedsit has more than 1 bedroom" do
      let(:expected_error) { I18n.t("validations.property.unittype_gn.one_bedroom_bedsit") }

      it "adds an error" do
        record.beds = 2
        record.unittype_gn = "Bedsit"
        property_validator.validate_shared_housing_rooms(record)
        expect(record.errors["unittype_gn"]).to include(match(expected_error))
      end
    end

    context "when a bedsit has less than 1 bedroom" do
      let(:expected_error) { I18n.t("validations.property.unittype_gn.one_bedroom_bedsit") }

      it "adds an error" do
        record.beds = 0
        record.unittype_gn = "Bedsit"
        property_validator.validate_shared_housing_rooms(record)
        expect(record.errors["unittype_gn"]).to include(match(expected_error))
      end
    end

    context "when shared housing has more than 7 bedrooms" do
      let(:expected_error) { I18n.t("validations.property.unittype_gn.one_seven_bedroom_shared") }

      it "adds an error if the number of bedrooms is not between 1 and 7" do
        record.beds = 8
        record.unittype_gn = "Shared house"
        record.other_hhmemb = 2
        property_validator.validate_shared_housing_rooms(record)
        expect(record.errors["unittype_gn"]).to include(match(expected_error))
      end
    end

    context "when shared housing has less than 1 bedrooms" do
      let(:expected_error) { I18n.t("validations.property.unittype_gn.one_seven_bedroom_shared") }

      it "adds an error if the number of bedrooms is not between 1 and 7" do
        record.beds = 0
        record.unittype_gn = "Shared house"
        record.other_hhmemb = 2
        property_validator.validate_shared_housing_rooms(record)
        expect(record.errors["unittype_gn"]).to include(match(expected_error))
      end
    end

    context "when there are too many bedrooms for the number of household members and unit type" do
      let(:expected_error) { I18n.t("validations.property.unittype_gn.one_three_bedroom_single_tenant_shared") }

      it "adds an error" do
        record.beds = 4
        record.unittype_gn = "Shared house"
        record.other_hhmemb = 0
        property_validator.validate_shared_housing_rooms(record)
        expect(record.errors["unittype_gn"]).to include(match(expected_error))
      end
    end
  end

  describe "#validate_la" do
    context "when the rent type is London affordable" do
      let(:expected_error) { I18n.t("validations.property.la.london_rent") }

      it "validates that the local authority is in London" do
        record.la = "Ashford"
        record.rent_type = "London Affordable rent"
        property_validator.validate_la(record)
        expect(record.errors["la"]).to include(match(expected_error))
      end

      it "expects that the local authority is in London" do
        record.la = "Westminster"
        record.rent_type = "London Affordable rent"
        property_validator.validate_la(record)
        expect(record.errors["la"]).to be_empty
      end
    end
  end
end
