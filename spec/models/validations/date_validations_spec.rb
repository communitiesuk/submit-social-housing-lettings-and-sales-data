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
        record.rsnvac = 11
        record.mrcdate = Time.zone.local(2022, 1, 1)
        date_validator.validate_property_major_repairs(record)
        expect(record.errors["mrcdate"])
          .to include(match I18n.t("validations.property.mrcdate.not_first_let"))
      end

      it "validates that no major repair date is provided for a conversion" do
        record.rsnvac = 12
        record.mrcdate = Time.zone.local(2022, 1, 1)
        date_validator.validate_property_major_repairs(record)
        expect(record.errors["mrcdate"])
          .to include(match I18n.t("validations.property.mrcdate.not_first_let"))
      end

      it "validates that no major repair date is provided for a leased property" do
        record.rsnvac = 13
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

  describe "property void date" do
    it "cannot be after the tenancy start date" do
      record.startdate = Time.zone.local(2022, 1, 1)
      record.property_void_date = Time.zone.local(2022, 2, 1)
      date_validator.validate_property_void_date(record)
      expect(record.errors["property_void_date"])
        .to include(match I18n.t("validations.property.void_date.before_tenancy_start"))
    end

    it "must be before the tenancy start date" do
      record.startdate = Time.zone.local(2022, 2, 1)
      record.property_void_date = Time.zone.local(2022, 1, 1)
      date_validator.validate_property_void_date(record)
      expect(record.errors["property_void_date"]).to be_empty
    end

    it "cannot be more than 10 years before the tenancy start date" do
      record.startdate = Time.zone.local(2022, 2, 1)
      record.property_void_date = Time.zone.local(2012, 1, 1)
      date_validator.validate_property_void_date(record)
      expect(record.errors["property_void_date"])
        .to include(match I18n.t("validations.property.void_date.ten_years_before_tenancy_start"))
    end

    it "must be within 10 years of the tenancy start date" do
      record.startdate = Time.zone.local(2022, 2, 1)
      record.property_void_date = Time.zone.local(2012, 3, 1)
      date_validator.validate_property_void_date(record)
      expect(record.errors["property_void_date"]).to be_empty
    end

    context "when major repairs have been carried out" do
      it "cannot be after major repairs date" do
        record.mrcdate = Time.zone.local(2022, 1, 1)
        record.property_void_date = Time.zone.local(2022, 2, 1)
        date_validator.validate_property_void_date(record)
        expect(record.errors["property_void_date"])
          .to include(match I18n.t("validations.property.void_date.after_mrcdate"))
      end

      it "must be before major repairs date" do
        record.mrcdate = Time.zone.local(2022, 2, 1)
        record.property_void_date = Time.zone.local(2022, 1, 1)
        date_validator.validate_property_void_date(record)
        expect(record.errors["property_void_date"]).to be_empty
      end
    end
  end
end
