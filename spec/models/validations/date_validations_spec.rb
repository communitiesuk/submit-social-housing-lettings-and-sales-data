require "rails_helper"

RSpec.describe Validations::DateValidations do
  subject(:date_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::DateValidations } }
  let(:record) { FactoryBot.create(:lettings_log) }
  let(:scheme) { FactoryBot.create(:scheme, end_date: Time.zone.today - 5.days) }
  let(:scheme_no_end_date) { FactoryBot.create(:scheme, end_date: nil) }

  describe "tenancy start date" do
    context "when in 22/23 collection" do
      context "when in the crossover period" do
        before do
          allow(Time).to receive(:now).and_return(Time.zone.local(2022, 4, 1))
          record.created_at = Time.zone.local(2022, 4, 1)
        end

        it "cannot be before the first collection window start date" do
          record.startdate = Time.zone.local(2021, 1, 1)
          date_validator.validate_startdate(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 21/22 or 22/23 financial years, which is between 1st April 2021 and 31st March 2023")
        end

        it "cannot be after the second collection window end date" do
          record.startdate = Time.zone.local(2023, 7, 1, 6)
          date_validator.validate_startdate(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 21/22 or 22/23 financial years, which is between 1st April 2021 and 31st March 2023")
        end
      end

      context "when after the crossover period" do
        before do
          allow(Time).to receive(:now).and_return(Time.zone.local(2023, 1, 1))
          record.created_at = Time.zone.local(2023, 1, 1)
        end

        it "cannot be before the first collection window start date" do
          record.startdate = Time.zone.local(2022, 1, 1)
          date_validator.validate_startdate(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 22/23 financial year, which is between 1st April 2022 and 31st March 2023")
        end

        it "cannot be after the second collection window end date" do
          record.startdate = Time.zone.local(2023, 7, 1, 6)
          date_validator.validate_startdate(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 22/23 financial year, which is between 1st April 2022 and 31st March 2023")
        end
      end
    end

    context "when in 23/24 collection" do
      context "when in the crossover period" do
        before do
          allow(Time).to receive(:now).and_return(Time.zone.local(2023, 4, 1))
          record.created_at = Time.zone.local(2023, 4, 1)
        end

        it "cannot be before the first collection window start date" do
          record.startdate = Time.zone.local(2022, 1, 1)
          date_validator.validate_startdate(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 22/23 or 23/24 financial years, which is between 1st April 2022 and 31st March 2024")
        end

        it "cannot be after the second collection window end date" do
          record.startdate = Time.zone.local(2024, 7, 1, 6)
          date_validator.validate_startdate(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 22/23 or 23/24 financial years, which is between 1st April 2022 and 31st March 2024")
        end
      end

      context "when after the crossover period" do
        before do
          allow(Time).to receive(:now).and_return(Time.zone.local(2024, 1, 1))
          record.created_at = Time.zone.local(2024, 1, 1)
        end

        it "cannot be before the first collection window start date" do
          record.startdate = Time.zone.local(2023, 1, 1)
          date_validator.validate_startdate(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 23/24 financial year, which is between 1st April 2023 and 31st March 2024")
        end

        it "cannot be after the second collection window end date" do
          record.startdate = Time.zone.local(2024, 7, 1, 6)
          date_validator.validate_startdate(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 23/24 financial year, which is between 1st April 2023 and 31st March 2024")
        end
      end
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

    it "validates that the tenancy start date is before the end date of the chosen scheme if it has an end date" do
      record.startdate = Time.zone.today - 3.days
      record.scheme = scheme
      date_validator.validate_startdate(record)
      expect(record.errors["startdate"])
        .to include(match I18n.t("validations.setup.startdate.before_scheme_end_date"))
    end

    it "validates that the tenancy start date is after the void date if it has a void date" do
      record.startdate = Time.zone.local(2022, 1, 1)
      record.voiddate = Time.zone.local(2022, 2, 1)
      date_validator.validate_startdate(record)
      expect(record.errors["startdate"])
        .to include(match I18n.t("validations.setup.startdate.after_void_date"))
    end

    it "validates that the tenancy start date is after the major repair date if it has a major repair date" do
      record.startdate = Time.zone.local(2022, 1, 1)
      record.mrcdate = Time.zone.local(2022, 2, 1)
      date_validator.validate_startdate(record)
      expect(record.errors["startdate"])
        .to include(match I18n.t("validations.setup.startdate.after_major_repair_date"))
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

    it "validates that the tenancy start date is not later than 14 days from the current date" do
      record.startdate = Time.zone.today + 15.days
      date_validator.validate_startdate(record)
      expect(record.errors["startdate"])
        .to include(match I18n.t("validations.setup.startdate.later_than_14_days_after"))
    end

    it "produces no error when tenancy start date is not later than 14 days from the current date" do
      record.startdate = Time.zone.today + 7.days
      date_validator.validate_startdate(record)
      expect(record.errors["startdate"]).to be_empty
    end

    context "with a deactivated location" do
      let(:scheme) { create(:scheme) }
      let(:location) { create(:location, scheme:) }

      before do
        create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), location:)
        location.reload
      end

      it "produces error when tenancy start date is during deactivated location period" do
        record.startdate = Time.zone.local(2022, 7, 5)
        record.location = location
        date_validator.validate_startdate(record)
        expect(record.errors["startdate"])
        .to include(match I18n.t("validations.setup.startdate.location.deactivated", postcode: location.postcode, date: "4 June 2022"))
      end

      it "produces no error when tenancy start date is during an active location period" do
        record.startdate = Time.zone.local(2022, 6, 1)
        record.location = location
        date_validator.validate_startdate(record)
        expect(record.errors["startdate"]).to be_empty
      end
    end

    context "with a location that is reactivating soon" do
      let(:scheme) { create(:scheme) }
      let(:location) { create(:location, scheme:) }

      before do
        create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), reactivation_date: Time.zone.local(2022, 8, 4), location:)
        location.reload
      end

      it "produces error when tenancy start date is during deactivated location period" do
        record.startdate = Time.zone.local(2022, 7, 5)
        record.location = location
        date_validator.validate_startdate(record)
        expect(record.errors["startdate"])
        .to include(match I18n.t("validations.setup.startdate.location.reactivating_soon", postcode: location.postcode, date: "4 August 2022"))
      end

      it "produces no error when tenancy start date is during an active location period" do
        record.startdate = Time.zone.local(2022, 9, 1)
        record.location = location
        date_validator.validate_startdate(record)
        expect(record.errors["startdate"]).to be_empty
      end
    end

    context "with a location that has many reactivations soon" do
      let(:scheme) { create(:scheme) }
      let(:location) { create(:location, scheme:) }

      before do
        create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), reactivation_date: Time.zone.local(2022, 8, 4), location:)
        create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 2), reactivation_date: Time.zone.local(2022, 8, 3), location:)
        create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 1), reactivation_date: Time.zone.local(2022, 9, 4), location:)
        location.reload
      end

      it "produces error when tenancy start date is during deactivated location period" do
        record.startdate = Time.zone.local(2022, 7, 5)
        record.location = location
        date_validator.validate_startdate(record)
        expect(record.errors["startdate"])
        .to include(match I18n.t("validations.setup.startdate.location.reactivating_soon", postcode: location.postcode, date: "4 September 2022"))
      end

      it "produces no error when tenancy start date is during an active location period" do
        record.startdate = Time.zone.local(2022, 10, 1)
        record.location = location
        date_validator.validate_startdate(record)
        expect(record.errors["startdate"]).to be_empty
      end
    end

    context "with a location with no deactivation periods" do
      let(:scheme) { create(:scheme) }
      let(:location) { create(:location, scheme:, startdate: Time.zone.local(2022, 9, 15)) }

      it "produces no error" do
        record.startdate = Time.zone.local(2022, 10, 15)
        record.location = location
        date_validator.validate_startdate(record)
        expect(record.errors["startdate"]).to be_empty
      end

      it "produces an error when the date is before available_from date" do
        record.startdate = Time.zone.local(2022, 8, 15)
        record.location = location
        date_validator.validate_startdate(record)
        expect(record.errors["startdate"])
        .to include(match I18n.t("validations.setup.startdate.location.activating_soon", postcode: location.postcode, date: "15 September 2022"))
      end
    end

    context "with a scheme that is reactivating soon" do
      let(:scheme) { create(:scheme) }

      before do
        create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), reactivation_date: Time.zone.local(2022, 8, 4), scheme:)
        scheme.reload
      end

      it "produces error when tenancy start date is during deactivated scheme period" do
        record.startdate = Time.zone.local(2022, 7, 5)
        record.scheme = scheme
        date_validator.validate_startdate(record)
        expect(record.errors["startdate"])
        .to include(match I18n.t("validations.setup.startdate.scheme.reactivating_soon", name: scheme.service_name, date: "4 August 2022"))
      end

      it "produces no error when tenancy start date is during an active scheme period" do
        record.startdate = Time.zone.local(2022, 9, 1)
        record.scheme = scheme
        date_validator.validate_startdate(record)
        expect(record.errors["startdate"]).to be_empty
      end
    end

    context "with a scheme that has many reactivations soon" do
      let(:scheme) { create(:scheme) }

      before do
        create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), reactivation_date: Time.zone.local(2022, 8, 4), scheme:)
        create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 2), reactivation_date: Time.zone.local(2022, 8, 3), scheme:)
        create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 1), reactivation_date: Time.zone.local(2022, 9, 4), scheme:)
        scheme.reload
      end

      it "produces error when tenancy start date is during deactivated scheme period" do
        record.startdate = Time.zone.local(2022, 7, 5)
        record.scheme = scheme
        date_validator.validate_startdate(record)
        expect(record.errors["startdate"])
        .to include(match I18n.t("validations.setup.startdate.scheme.reactivating_soon", name: scheme.service_name, date: "4 September 2022"))
      end

      it "produces no error when tenancy start date is during an active scheme period" do
        record.startdate = Time.zone.local(2022, 10, 1)
        record.scheme = scheme
        date_validator.validate_startdate(record)
        expect(record.errors["startdate"]).to be_empty
      end
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

    it "cannot be more than 10 years before the tenancy start date" do
      record.startdate = Time.zone.local(2022, 2, 1)
      record.mrcdate = Time.zone.local(2012, 1, 1)
      date_validator.validate_property_major_repairs(record)
      expect(record.errors["mrcdate"])
        .to include(match I18n.t("validations.property.mrcdate.ten_years_before_tenancy_start"))
    end

    it "must be within 10 years of the tenancy start date" do
      record.startdate = Time.zone.local(2022, 2, 1)
      record.mrcdate = Time.zone.local(2012, 3, 1)
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
