require "rails_helper"

RSpec.describe Validations::SetupValidations do
  subject(:setup_validator) { setup_validator_class.new }

  let(:setup_validator_class) { Class.new { include Validations::SetupValidations } }
  let(:record) { FactoryBot.create(:lettings_log) }

  describe "tenancy start date" do
    context "when in 22/23 collection" do
      context "when in the crossover period" do
        before do
          allow(Time).to receive(:now).and_return(Time.zone.local(2022, 4, 1))
          record.created_at = Time.zone.local(2022, 4, 1)
        end

        it "cannot be before the first collection window start date" do
          record.startdate = Time.zone.local(2021, 1, 1)
          setup_validator.validate_startdate_setup(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 21/22 or 22/23 collection years, which is between 1st April 2021 and 31st March 2023")
        end

        it "cannot be after the second collection window end date" do
          record.startdate = Time.zone.local(2023, 7, 1, 6)
          setup_validator.validate_startdate_setup(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 21/22 or 22/23 collection years, which is between 1st April 2021 and 31st March 2023")
        end
      end

      context "when after the crossover period" do
        before do
          allow(Time).to receive(:now).and_return(Time.zone.local(2023, 1, 1))
          record.created_at = Time.zone.local(2023, 1, 1)
        end

        it "cannot be before the first collection window start date" do
          record.startdate = Time.zone.local(2022, 1, 1)
          setup_validator.validate_startdate_setup(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 22/23 collection year, which is between 1st April 2022 and 31st March 2023")
        end

        it "cannot be after the second collection window end date" do
          record.startdate = Time.zone.local(2023, 7, 1, 6)
          setup_validator.validate_startdate_setup(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 22/23 collection year, which is between 1st April 2022 and 31st March 2023")
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
          setup_validator.validate_startdate_setup(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 22/23 or 23/24 collection years, which is between 1st April 2022 and 31st March 2024")
        end

        it "cannot be after the second collection window end date" do
          record.startdate = Time.zone.local(2024, 7, 1, 6)
          setup_validator.validate_startdate_setup(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 22/23 or 23/24 collection years, which is between 1st April 2022 and 31st March 2024")
        end
      end

      context "when after the crossover period" do
        before do
          allow(Time).to receive(:now).and_return(Time.zone.local(2024, 1, 1))
          record.created_at = Time.zone.local(2024, 1, 1)
        end

        it "cannot be before the first collection window start date" do
          record.startdate = Time.zone.local(2023, 1, 1)
          setup_validator.validate_startdate_setup(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 23/24 collection year, which is between 1st April 2023 and 31st March 2024")
        end

        it "cannot be after the second collection window end date" do
          record.startdate = Time.zone.local(2024, 7, 1, 6)
          setup_validator.validate_startdate_setup(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 23/24 collection year, which is between 1st April 2023 and 31st March 2024")
        end
      end
    end
  end

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
      let(:location) { create(:location, scheme:) }

      before do
        create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), location:)
        location.reload
      end

      it "produces error when tenancy start date is during deactivated location period" do
        record.startdate = Time.zone.local(2022, 7, 5)
        record.location = location
        setup_validator.validate_scheme(record)
        expect(record.errors["scheme_id"])
          .to include(match I18n.t("validations.setup.startdate.location.deactivated", postcode: location.postcode, date: "4 June 2022"))
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
      let(:location) { create(:location, scheme:) }

      before do
        create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), reactivation_date: Time.zone.local(2022, 8, 4), location:)
        location.reload
      end

      it "produces error when tenancy start date is during deactivated location period" do
        record.startdate = Time.zone.local(2022, 7, 5)
        record.location = location
        setup_validator.validate_scheme(record)
        expect(record.errors["scheme_id"])
          .to include(match I18n.t("validations.setup.startdate.location.reactivating_soon", postcode: location.postcode, date: "4 August 2022"))
      end

      it "produces no error when tenancy start date is during an active location period" do
        record.startdate = Time.zone.local(2022, 9, 1)
        record.location = location
        setup_validator.validate_scheme(record)
        expect(record.errors["scheme_id"]).to be_empty
      end
    end

    context "with a location with no deactivation periods" do
      let(:scheme) { create(:scheme, created_at: Time.zone.local(2022, 10, 3)) }
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
          .to include(match I18n.t("validations.setup.startdate.location.activating_soon", postcode: location.postcode, date: "15 September 2022"))
      end
    end

    context "with a scheme that is reactivating soon" do
      let(:scheme) { create(:scheme, created_at: Time.zone.local(2022, 4, 1)) }
      before do
        FactoryBot.create(:location, scheme:)
        create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), reactivation_date: Time.zone.local(2022, 8, 4), scheme:)
        scheme.reload
      end

      it "produces error when tenancy start date is during deactivated scheme period" do
        record.startdate = Time.zone.local(2022, 7, 5)
        record.scheme = scheme
        setup_validator.validate_scheme(record)
        expect(record.errors["scheme_id"])
          .to include(match I18n.t("validations.setup.startdate.scheme.reactivating_soon", name: scheme.service_name, date: "4 August 2022"))
      end

      it "produces no error when tenancy start date is during an active scheme period" do
        record.startdate = Time.zone.local(2022, 9, 1)
        record.scheme = scheme
        setup_validator.validate_scheme(record)
        expect(record.errors["scheme_id"]).to be_empty
      end
    end

    context "with a scheme that has many reactivations soon" do
      let(:scheme) { create(:scheme, created_at: Time.zone.local(2022, 4, 1)) }

      before do
        FactoryBot.create(:location, scheme:)
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
          .to include(match I18n.t("validations.setup.startdate.scheme.reactivating_soon", name: scheme.service_name, date: "4 September 2022"))
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
      let(:location) { create(:location, scheme:) }

      before do
        create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), location:)
        location.reload
      end

      it "produces error when tenancy start date is during deactivated location period" do
        record.startdate = Time.zone.local(2022, 7, 5)
        record.location = location
        setup_validator.validate_location(record)
        expect(record.errors["location_id"])
          .to include(match I18n.t("validations.setup.startdate.location.deactivated", postcode: location.postcode, date: "4 June 2022"))
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
      let(:location) { create(:location, scheme:) }

      before do
        create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), reactivation_date: Time.zone.local(2022, 8, 4), location:)
        location.reload
      end

      it "produces error when tenancy start date is during deactivated location period" do
        record.startdate = Time.zone.local(2022, 7, 5)
        record.location = location
        setup_validator.validate_location(record)
        expect(record.errors["location_id"])
          .to include(match I18n.t("validations.setup.startdate.location.reactivating_soon", postcode: location.postcode, date: "4 August 2022"))
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
          .to include(match I18n.t("validations.setup.startdate.location.activating_soon", postcode: location.postcode, date: "15 September 2022"))
      end
    end
  end

  describe "#validate_organisation" do
    let(:user) { FactoryBot.create(:user) }
    let(:other_organisation) { FactoryBot.create(:organisation) }

    it "validates if neither managing nor owning organisation is the same as created_by user organisation" do
      record.created_by = user
      record.owning_organisation = other_organisation
      record.managing_organisation = other_organisation

      setup_validator.validate_organisation(record)
      expect(record.errors["created_by"]).to include(I18n.t("validations.setup.created_by.invalid"))
      expect(record.errors["owning_organisation_id"]).to include(I18n.t("validations.setup.owning_organisation.invalid"))
      expect(record.errors["managing_organisation_id"]).to include(I18n.t("validations.setup.managing_organisation.invalid"))
    end

    it "doesn not validate if either managing or owning organisation is the same as current user organisation" do
      record.created_by = user
      record.owning_organisation = user.organisation
      record.managing_organisation = other_organisation

      setup_validator.validate_organisation(record)
      expect(record.errors["created_by"]).to be_empty
      expect(record.errors["owning_organisation_id"]).to be_empty
      expect(record.errors["managing_organisation_id"]).to be_empty
    end

    it "does not validate if current user is missing" do
      record.created_by = nil
      record.owning_organisation = other_organisation
      record.managing_organisation = other_organisation

      setup_validator.validate_organisation(record)
      expect(record.errors["created_by"]).to be_empty
      expect(record.errors["owning_organisation_id"]).to be_empty
      expect(record.errors["managing_organisation_id"]).to be_empty
    end

    it "does not validate if managing organisation is missing" do
      record.created_by = user
      record.owning_organisation = other_organisation
      record.managing_organisation = nil

      setup_validator.validate_organisation(record)
      expect(record.errors["created_by"]).to be_empty
      expect(record.errors["owning_organisation_id"]).to be_empty
      expect(record.errors["managing_organisation_id"]).to be_empty
    end

    it "does not validate if owning organisation is missing" do
      record.created_by = user
      record.owning_organisation = nil
      record.managing_organisation = other_organisation

      setup_validator.validate_organisation(record)
      expect(record.errors["created_by"]).to be_empty
      expect(record.errors["owning_organisation_id"]).to be_empty
      expect(record.errors["managing_organisation_id"]).to be_empty
    end
  end
end
