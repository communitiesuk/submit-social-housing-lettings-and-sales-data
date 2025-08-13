require "rails_helper"

RSpec.describe Validations::DateValidations do
  subject(:date_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::DateValidations } }
  let(:record) { build(:lettings_log) }
  let(:scheme) { create(:scheme, end_date: Time.zone.today - 5.days) }
  let(:scheme_no_end_date) { create(:scheme, end_date: nil) }

  describe "tenancy start date" do
    it "must be a valid date" do
      record.startdate = Time.zone.local(0, 7, 1)
      date_validator.validate_startdate(record)
      expect(record.errors["startdate"]).to include(match I18n.t("validations.shared.date.invalid_date"))
    end

    it "does not raise an error when valid" do
      record.startdate = Time.zone.local(2022, 1, 1)
      date_validator.validate_startdate(record)
      expect(record.errors["startdate"]).to be_empty
    end

    it "produces no error when the tenancy start date is before the end date of the chosen scheme if it has an end date" do
      record.startdate = Time.zone.today - 30.days
      record.scheme = scheme
      date_validator.validate_startdate(record)
      expect(record.errors["startdate"]).to be_empty
    end

    it "produces no startdate error for scheme end dates when the chosen scheme does not have an end date" do
      record.startdate = Time.zone.today
      record.scheme = scheme_no_end_date
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
        .to include(match I18n.t("validations.lettings.date.mrcdate.before_tenancy_start"))
      expect(record.errors["startdate"])
      .to include(match I18n.t("validations.lettings.date.startdate.after_major_repair_date"))
    end

    it "must be before the tenancy start date" do
      record.startdate = Time.zone.local(2022, 2, 1)
      record.mrcdate = Time.zone.local(2022, 1, 1)
      date_validator.validate_property_major_repairs(record)
      expect(record.errors["mrcdate"]).to be_empty
    end

    context "with 2024 logs or earlier" do
      it "cannot be more than 10 years before the tenancy start date" do
        record.startdate = Time.zone.local(2024, 4, 1)
        record.mrcdate = Time.zone.local(2014, 1, 31)
        date_validator.validate_property_major_repairs(record)
        expect(record.errors["mrcdate"])
          .to include(match I18n.t("validations.lettings.date.mrcdate.ten_years_before_tenancy_start"))
        expect(record.errors["startdate"])
          .to include(match I18n.t("validations.lettings.date.startdate.ten_years_after_mrc_date"))
      end

      it "must be within 10 years of the tenancy start date" do
        record.startdate = Time.zone.local(2024, 2, 1)
        record.mrcdate = Time.zone.local(2014, 2, 1)
        date_validator.validate_property_major_repairs(record)
        expect(record.errors["mrcdate"]).to be_empty
        expect(record.errors["startdate"]).to be_empty
      end
    end

    context "with 2025 logs or later" do
      it "cannot be more than 20 years before the tenancy start date" do
        record.startdate = Time.zone.local(2026, 2, 1)
        record.mrcdate = Time.zone.local(2006, 1, 31)
        date_validator.validate_property_major_repairs(record)
        expect(record.errors["mrcdate"])
          .to include(match I18n.t("validations.lettings.date.mrcdate.twenty_years_before_tenancy_start"))
        expect(record.errors["startdate"])
          .to include(match I18n.t("validations.lettings.date.startdate.twenty_years_after_mrc_date"))
      end

      it "must be within 20 years of the tenancy start date" do
        record.startdate = Time.zone.local(2026, 2, 1)
        record.mrcdate = Time.zone.local(2006, 2, 1)
        date_validator.validate_property_major_repairs(record)
        expect(record.errors["mrcdate"]).to be_empty
        expect(record.errors["startdate"]).to be_empty
      end
    end

    context "when reason for vacancy is first let of property" do
      it "validates that no major repair date is provided for a new build" do
        record.rsnvac = 15
        record.mrcdate = Time.zone.local(2022, 1, 1)
        date_validator.validate_property_major_repairs(record)
        expect(record.errors["mrcdate"])
          .to include(match I18n.t("validations.lettings.date.mrcdate.not_first_let"))
      end

      it "validates that no major repair date is provided for a conversion" do
        record.rsnvac = 16
        record.mrcdate = Time.zone.local(2022, 1, 1)
        date_validator.validate_property_major_repairs(record)
        expect(record.errors["mrcdate"])
          .to include(match I18n.t("validations.lettings.date.mrcdate.not_first_let"))
      end

      it "validates that no major repair date is provided for a leased property" do
        record.rsnvac = 17
        record.mrcdate = Time.zone.local(2022, 1, 1)
        date_validator.validate_property_major_repairs(record)
        expect(record.errors["mrcdate"])
          .to include(match I18n.t("validations.lettings.date.mrcdate.not_first_let"))
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
        .to include(match I18n.t("validations.lettings.date.void_date.before_tenancy_start"))
      expect(record.errors["startdate"])
      .to include(match I18n.t("validations.lettings.date.startdate.after_void_date"))
    end

    it "must be before the tenancy start date" do
      record.startdate = Time.zone.local(2022, 2, 1)
      record.voiddate = Time.zone.local(2022, 1, 1)
      date_validator.validate_property_void_date(record)
      expect(record.errors["voiddate"]).to be_empty
    end

    context "with 2024 logs or earlier" do
      it "cannot be more than 10 years before the tenancy start date" do
        record.startdate = Time.zone.local(2024, 4, 1)
        record.voiddate = Time.zone.local(2014, 1, 31)
        date_validator.validate_property_void_date(record)
        expect(record.errors["voiddate"])
          .to include(match I18n.t("validations.lettings.date.void_date.ten_years_before_tenancy_start"))
        expect(record.errors["startdate"])
          .to include(match I18n.t("validations.lettings.date.startdate.ten_years_after_void_date"))
      end

      it "must be within 10 years of the tenancy start date" do
        record.startdate = Time.zone.local(2024, 2, 1)
        record.voiddate = Time.zone.local(2014, 2, 1)
        date_validator.validate_property_void_date(record)
        expect(record.errors["voiddate"]).to be_empty
        expect(record.errors["startdate"]).to be_empty
      end
    end

    context "with 2025 logs or later" do
      it "cannot be more than 20 years before the tenancy start date" do
        record.startdate = Time.zone.local(2026, 2, 1)
        record.voiddate = Time.zone.local(2006, 1, 31)
        date_validator.validate_property_void_date(record)
        date_validator.validate_startdate(record)
        expect(record.errors["voiddate"])
          .to include(match I18n.t("validations.lettings.date.void_date.twenty_years_before_tenancy_start"))
        expect(record.errors["startdate"])
          .to include(match I18n.t("validations.lettings.date.startdate.twenty_years_after_void_date"))
      end

      it "must be within 20 years of the tenancy start date" do
        record.startdate = Time.zone.local(2026, 2, 1)
        record.voiddate = Time.zone.local(2006, 2, 1)
        date_validator.validate_property_void_date(record)
        expect(record.errors["voiddate"]).to be_empty
        expect(record.errors["startdate"]).to be_empty
      end
    end

    context "when major repairs have been carried out" do
      it "void_date cannot be after major repairs date" do
        record.mrcdate = Time.zone.local(2022, 1, 1)
        record.voiddate = Time.zone.local(2022, 2, 1)
        date_validator.validate_property_void_date(record)
        expect(record.errors["voiddate"])
          .to include(match I18n.t("validations.lettings.date.void_date.after_mrcdate"))
        expect(record.errors["mrcdate"])
          .to include(match I18n.t("validations.lettings.date.mrcdate.before_void_date"))
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
