require "rails_helper"

RSpec.describe Validations::DateValidations do
  subject(:date_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::DateValidations } }
  let(:record) { FactoryBot.create(:case_log) }

  describe "tenancy start date" do
    it "cannot be before the first collection window start date" do
      record.startdate = Time.zone.local(2020, 1, 1)
      date_validator.validate_startdate(record)
      expect(record.errors["startdate"]).to include(match I18n.t("validations.date.outside_collection_window"))
    end

    it "cannot be after the second collection window end date" do
      record.startdate = Time.zone.local(2023, 7, 1, 6)
      date_validator.validate_startdate(record)
      expect(record.errors["startdate"]).to include(match I18n.t("validations.date.outside_collection_window"))
    end

    it "must be a valid date" do
      record.startdate = Time.zone.local(0, 7, 1)
      date_validator.validate_startdate(record)
      expect(record.errors["startdate"]).to include(match I18n.t("validations.date.invalid_date"))
    end

    it "does not raise an error when valid" do
      record.startdate = Time.zone.local(2022, 1, 1)
      date_validator.validate_startdate(record)
      expect(record.errors["startdate"]).to be_empty
    end
  end

  describe "major repairs date" do
    it "cannot be after the tenancy start date" do
      record.startdate = Time.zone.local(2022, 1, 1)
      record.mrcdate = Time.zone.local(2022, 2, 1)
      date_validator.validate_property_major_repairs(record)
      expect(record.errors["mrcdate"])
        .to include(match I18n.t("validations.property.mrcdate.before_tenancy_start"))
    end

    it "must be before the tenancy start date" do
      record.startdate = Time.zone.local(2022, 2, 1)
      record.mrcdate = Time.zone.local(2022, 1, 1)
      date_validator.validate_property_major_repairs(record)
      expect(record.errors["mrcdate"]).to be_empty
    end

    it "cannot be more than 2 years before the tenancy start date" do
      record.startdate = Time.zone.local(2022, 2, 1)
      record.mrcdate = Time.zone.local(2020, 1, 1)
      date_validator.validate_property_major_repairs(record)
      expect(record.errors["mrcdate"])
        .to include(match I18n.t("validations.property.mrcdate.730_days_before_tenancy_start"))
    end

    it "must be within 2 years of the tenancy start date" do
      record.startdate = Time.zone.local(2022, 2, 1)
      record.mrcdate = Time.zone.local(2020, 3, 1)
      date_validator.validate_property_major_repairs(record)
      expect(record.errors["mrcdate"]).to be_empty
    end

    context "when reason for vacancy is first let of property" do
      it "validates that no major repair date is provided for a new build" do
        record.rsnvac = "First let of new-build property"
        record.mrcdate = Time.zone.local(2022, 1, 1)
        date_validator.validate_property_major_repairs(record)
        expect(record.errors["mrcdate"])
          .to include(match I18n.t("validations.property.mrcdate.not_first_let"))
      end

      it "validates that no major repair date is provided for a conversion" do
        record.rsnvac = "First let of conversion, rehabilitation or acquired property"
        record.mrcdate = Time.zone.local(2022, 1, 1)
        date_validator.validate_property_major_repairs(record)
        expect(record.errors["mrcdate"])
          .to include(match I18n.t("validations.property.mrcdate.not_first_let"))
      end

      it "validates that no major repair date is provided for a leased property" do
        record.rsnvac = "First let of leased property"
        record.mrcdate = Time.zone.local(2022, 1, 1)
        date_validator.validate_property_major_repairs(record)
        expect(record.errors["mrcdate"])
          .to include(match I18n.t("validations.property.mrcdate.not_first_let"))
      end
    end

    context "when the reason for vacancy is not the first let of property" do
      it "expects that major repairs can have been done" do
        record.rsnvac = "Tenant moved to care home"
        record.mrcdate = Time.zone.local(2022, 1, 1)
        date_validator.validate_property_major_repairs(record)
        expect(record.errors["mrcdate"]).to be_empty
      end
    end
  end
end
