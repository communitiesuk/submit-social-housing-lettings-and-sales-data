require "rails_helper"

RSpec.describe Validations::DateValidations do
  subject(:date_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::DateValidations } }
  let(:record) { FactoryBot.create(:case_log) }
  let(:scheme) { FactoryBot.create(:scheme, end_date: Time.zone.today - 5.days) }
  let(:scheme_no_end_date) { FactoryBot.create(:scheme, end_date: nil) }

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

    it "validates that the tenancy start date is later than or 14 days before the current date" do
      record.startdate = Time.zone.today - 15.days
      setup_validator.validate_startdate(record)
      expect(record.errors["startdate"])
        .to include(match I18n.t("validations.setup.startdate.later_than_or_14_days_before"))
    end

    it "produces no error when the tenancy start date is later than or 14 days before the current date" do
      record.startdate = Time.zone.today - 7.days
      setup_validator.validate_startdate(record)
      expect(record.errors["startdate"]).to be_empty
    end

    it "validates that the tenancy start date is before the end date of the chosen scheme if it has an end date" do
      record.startdate = Time.zone.today - 3.days
      record.scheme = scheme
      setup_validator.validate_startdate(record)
      expect(record.errors["startdate"])
        .to include(match I18n.t("validations.setup.startdate.before_scheme_end_date"))
    end

    it "produces no error when the tenancy start date is before the end date of the chosen scheme if it has an end date" do
      record.startdate = Time.zone.today - 30.days
      record.scheme = scheme
      setup_validator.validate_startdate(record)
      expect(record.errors["startdate"]).to be_empty
    end

    it "produces no startdate error for scheme end dates when the chosen scheme does not have an end date" do
      record.startdate = Time.zone.today
      record.scheme = scheme_no_end_date
      setup_validator.validate_startdate(record)
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
        record.rsnvac = 15
        record.mrcdate = Time.zone.local(2022, 1, 1)
        date_validator.validate_property_major_repairs(record)
        expect(record.errors["mrcdate"])
          .to include(match I18n.t("validations.property.mrcdate.not_first_let"))
      end

      it "validates that no major repair date is provided for a conversion" do
        record.rsnvac = 16
        record.mrcdate = Time.zone.local(2022, 1, 1)
        date_validator.validate_property_major_repairs(record)
        expect(record.errors["mrcdate"])
          .to include(match I18n.t("validations.property.mrcdate.not_first_let"))
      end

      it "validates that no major repair date is provided for a leased property" do
        record.rsnvac = 17
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
      record.voiddate = Time.zone.local(2022, 2, 1)
      date_validator.validate_property_void_date(record)
      expect(record.errors["voiddate"])
        .to include(match I18n.t("validations.property.void_date.before_tenancy_start"))
    end

    it "must be before the tenancy start date" do
      record.startdate = Time.zone.local(2022, 2, 1)
      record.voiddate = Time.zone.local(2022, 1, 1)
      date_validator.validate_property_void_date(record)
      expect(record.errors["voiddate"]).to be_empty
    end

    it "cannot be more than 10 years before the tenancy start date" do
      record.startdate = Time.zone.local(2022, 2, 1)
      record.voiddate = Time.zone.local(2012, 1, 1)
      date_validator.validate_property_void_date(record)
      expect(record.errors["voiddate"])
        .to include(match I18n.t("validations.property.void_date.ten_years_before_tenancy_start"))
    end

    it "must be within 10 years of the tenancy start date" do
      record.startdate = Time.zone.local(2022, 2, 1)
      record.voiddate = Time.zone.local(2012, 3, 1)
      date_validator.validate_property_void_date(record)
      expect(record.errors["voiddate"]).to be_empty
    end

    context "when major repairs have been carried out" do
      it "cannot be after major repairs date" do
        record.mrcdate = Time.zone.local(2022, 1, 1)
        record.voiddate = Time.zone.local(2022, 2, 1)
        date_validator.validate_property_void_date(record)
        expect(record.errors["voiddate"])
          .to include(match I18n.t("validations.property.void_date.after_mrcdate"))
      end

      it "must be before major repairs date" do
        record.mrcdate = Time.zone.local(2022, 2, 1)
        record.voiddate = Time.zone.local(2022, 1, 1)
        date_validator.validate_property_void_date(record)
        expect(record.errors["voiddate"]).to be_empty
      end
    end
  end
end
