require "rails_helper"

RSpec.describe Validations::SetupValidations do
  subject(:setup_validator) { setup_validator_class.new }

  let(:setup_validator_class) { Class.new { include Validations::SetupValidations } }
  let(:record) { FactoryBot.create(:lettings_log) }

  describe "#validate_irproduct" do
    it "adds an error when the intermediate rent product name is not provided but the rent type was given as other intermediate rent product" do
      record.rent_type = 5
      record.irproduct_other = nil
      setup_validator.validate_irproduct_other(record)
      expect(record.errors["irproduct_other"])
      .to include(match I18n.t("validations.setup.intermediate_rent_product_name.blank"))
    end

    it "adds an error when the intermediate rent product name is blank but the rent type was given as other intermediate rent product" do
      record.rent_type = 5
      record.irproduct_other = ""
      setup_validator.validate_irproduct_other(record)
      expect(record.errors["irproduct_other"])
      .to include(match I18n.t("validations.setup.intermediate_rent_product_name.blank"))
    end

    it "Does not add an error when the intermediate rent product name is provided and the rent type was given as other intermediate rent product" do
      record.rent_type = 5
      record.irproduct_other = "Example"
      setup_validator.validate_irproduct_other(record)
      expect(record.errors["irproduct_other"]).to be_empty
    end
  end

  describe "#validate_scheme" do
    context "with a deactivated location" do
      let(:scheme) { create(:scheme) }
      let(:location) { create(:location, scheme:, startdate: nil) }

      before do
        create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), location:)
        location.reload
      end

      it "produces error when tenancy start date is during deactivated location period" do
        record.startdate = Time.zone.local(2022, 7, 5)
        record.location = location
        setup_validator.validate_scheme(record)
        expect(record.errors["scheme_id"])
        .to include(match I18n.t("validations.setup.startdate.during_deactivated_location", postcode: location.postcode, date: "4 June 2022"))
      end

      it "produces no error when tenancy start date is during an active location period" do
        record.startdate = Time.zone.local(2022, 6, 1)
        record.location = location
        setup_validator.validate_scheme(record)
        expect(record.errors["scheme_id"]).to be_empty
      end
    end

    context "with a location that is reactivating soon" do
      let(:scheme) { create(:scheme) }
      let(:location) { create(:location, scheme:, startdate: nil) }

      before do
        create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), reactivation_date: Time.zone.local(2022, 8, 4), location:)
        location.reload
      end

      it "produces error when tenancy start date is during deactivated location period" do
        record.startdate = Time.zone.local(2022, 7, 5)
        record.location = location
        setup_validator.validate_scheme(record)
        expect(record.errors["scheme_id"])
        .to include(match I18n.t("validations.setup.startdate.location_reactivating_soon", postcode: location.postcode, date: "4 August 2022"))
      end

      it "produces no error when tenancy start date is during an active location period" do
        record.startdate = Time.zone.local(2022, 9, 1)
        record.location = location
        setup_validator.validate_scheme(record)
        expect(record.errors["scheme_id"]).to be_empty
      end
    end

    context "with a location with no deactivation periods" do
      let(:scheme) { create(:scheme) }
      let(:location) { create(:location, scheme:, startdate: Time.zone.local(2022, 9, 15)) }

      it "produces no error" do
        record.startdate = Time.zone.local(2022, 10, 15)
        record.location = location
        setup_validator.validate_scheme(record)
        expect(record.errors["scheme_id"]).to be_empty
      end

      it "produces an error when the date is before available_from date" do
        record.startdate = Time.zone.local(2022, 8, 15)
        record.location = location
        setup_validator.validate_scheme(record)
        expect(record.errors["scheme_id"])
        .to include(match I18n.t("validations.setup.startdate.location_reactivating_soon", postcode: location.postcode, date: "15 September 2022"))
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
        setup_validator.validate_scheme(record)
        expect(record.errors["scheme_id"])
        .to include(match I18n.t("validations.setup.startdate.scheme_reactivating_soon", name: scheme.service_name, date: "4 August 2022"))
      end

      it "produces no error when tenancy start date is during an active scheme period" do
        record.startdate = Time.zone.local(2022, 9, 1)
        record.scheme = scheme
        setup_validator.validate_scheme(record)
        expect(record.errors["scheme_id"]).to be_empty
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
        setup_validator.validate_scheme(record)
        expect(record.errors["scheme_id"])
        .to include(match I18n.t("validations.setup.startdate.scheme_reactivating_soon", name: scheme.service_name, date: "4 September 2022"))
      end

      it "produces no error when tenancy start date is during an active scheme period" do
        record.startdate = Time.zone.local(2022, 10, 1)
        record.scheme = scheme
        setup_validator.validate_scheme(record)
        expect(record.errors["scheme_id"]).to be_empty
      end
    end
  end

  describe "#validate_location" do
    context "with a deactivated location" do
      let(:scheme) { create(:scheme) }
      let(:location) { create(:location, scheme:, startdate: nil) }

      before do
        create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), location:)
        location.reload
      end

      it "produces error when tenancy start date is during deactivated location period" do
        record.startdate = Time.zone.local(2022, 7, 5)
        record.location = location
        setup_validator.validate_location(record)
        expect(record.errors["location_id"])
        .to include(match I18n.t("validations.setup.startdate.during_deactivated_location", postcode: location.postcode, date: "4 June 2022"))
      end

      it "produces no error when tenancy start date is during an active location period" do
        record.startdate = Time.zone.local(2022, 6, 1)
        record.location = location
        setup_validator.validate_location(record)
        expect(record.errors["location_id"]).to be_empty
      end
    end

    context "with a location that is reactivating soon" do
      let(:scheme) { create(:scheme) }
      let(:location) { create(:location, scheme:, startdate: nil) }

      before do
        create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), reactivation_date: Time.zone.local(2022, 8, 4), location:)
        location.reload
      end

      it "produces error when tenancy start date is during deactivated location period" do
        record.startdate = Time.zone.local(2022, 7, 5)
        record.location = location
        setup_validator.validate_location(record)
        expect(record.errors["location_id"])
        .to include(match I18n.t("validations.setup.startdate.location_reactivating_soon", postcode: location.postcode, date: "4 August 2022"))
      end

      it "produces no error when tenancy start date is during an active location period" do
        record.startdate = Time.zone.local(2022, 9, 1)
        record.location = location
        setup_validator.validate_location(record)
        expect(record.errors["location_id"]).to be_empty
      end
    end

    context "with a location with no deactivation periods" do
      let(:scheme) { create(:scheme) }
      let(:location) { create(:location, scheme:, startdate: Time.zone.local(2022, 9, 15)) }

      it "produces no error" do
        record.startdate = Time.zone.local(2022, 10, 15)
        record.location = location
        setup_validator.validate_location(record)
        expect(record.errors["location_id"]).to be_empty
      end

      it "produces an error when the date is before available_from date" do
        record.startdate = Time.zone.local(2022, 8, 15)
        record.location = location
        setup_validator.validate_location(record)
        expect(record.errors["location_id"])
        .to include(match I18n.t("validations.setup.startdate.location_reactivating_soon", postcode: location.postcode, date: "15 September 2022"))
      end
    end
  end
end
