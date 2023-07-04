require "rails_helper"

RSpec.describe Validations::SetupValidations do
  subject(:setup_validator) { setup_validator_class.new }

  let(:setup_validator_class) { Class.new { include Validations::SetupValidations } }
  let(:record) { create(:lettings_log) }

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

      context "when after the new logs end date but before edit end date for the previous period" do
        before do
          allow(Time).to receive(:now).and_return(Time.zone.local(2024, 1, 8))
        end

        it "cannot create new logs for the previous collection year" do
          record.update!(startdate: nil)
          record.startdate = Time.zone.local(2023, 1, 1)
          setup_validator.validate_startdate_setup(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 23/24 collection year, which is between 1st April 2023 and 31st March 2024")
        end

        xit "can edit already created logs for the previous collection year" do
          record.startdate = Time.zone.local(2023, 1, 2)
          record.save!(validate: false)
          record.startdate = Time.zone.local(2023, 1, 1)
          setup_validator.validate_startdate_setup(record)
          expect(record.errors["startdate"]).not_to include(match "Enter a date within the 23/24 collection year, which is between 1st April 2023 and 31st March 2024")
        end
      end

      context "when after the new logs end date and after the edit end date for the previous period" do
        before do
          allow(Time).to receive(:now).and_return(Time.zone.local(2024, 1, 8))
        end

        it "cannot create new logs for the previous collection year" do
          record.update!(startdate: nil)
          record.startdate = Time.zone.local(2023, 1, 1)
          setup_validator.validate_startdate_setup(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 23/24 collection year, which is between 1st April 2023 and 31st March 2024")
        end

        it "cannot edit already created logs for the previous collection year" do
          record.startdate = Time.zone.local(2023, 1, 2)
          record.save!(validate: false)
          record.startdate = Time.zone.local(2023, 1, 1)
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
    context "with a deactivated scheme" do
      let(:scheme) { create(:scheme) }

      before do
        create(:location, scheme:)
        create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), scheme:)
        scheme.reload
      end

      it "produces error when tenancy start date is during deactivated scheme period" do
        record.startdate = Time.zone.local(2022, 7, 5)
        record.scheme = scheme
        setup_validator.validate_scheme(record)
        expect(record.errors["startdate"])
          .to include(match I18n.t("validations.setup.startdate.scheme.deactivated.startdate", name: scheme.service_name, date: "4 June 2022"))
        expect(record.errors["scheme_id"])
          .to include(match I18n.t("validations.setup.startdate.scheme.deactivated.scheme_id", name: scheme.service_name, date: "4 June 2022"))
      end

      it "produces no error when tenancy start date is during an active scheme period" do
        record.startdate = Time.zone.local(2022, 6, 1)
        record.scheme = scheme
        setup_validator.validate_scheme(record)
        expect(record.errors["startdate"]).to be_empty
        expect(record.errors["scheme_id"]).to be_empty
      end
    end

    context "with a scheme that is reactivating soon" do
      let(:scheme) { create(:scheme) }

      before do
        create(:location, scheme:)
        create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), reactivation_date: Time.zone.local(2022, 8, 4), scheme:)
        scheme.reload
      end

      it "produces error when tenancy start date is during deactivated scheme period" do
        record.startdate = Time.zone.local(2022, 7, 5)
        record.scheme = scheme
        setup_validator.validate_scheme(record)
        expect(record.errors["startdate"])
          .to include(match I18n.t("validations.setup.startdate.scheme.reactivating_soon.startdate", name: scheme.service_name, date: "4 August 2022"))
        expect(record.errors["scheme_id"])
          .to include(match I18n.t("validations.setup.startdate.scheme.reactivating_soon.scheme_id", name: scheme.service_name, date: "4 August 2022"))
      end

      it "produces no error when tenancy start date is during an active scheme period" do
        record.startdate = Time.zone.local(2022, 9, 1)
        record.scheme = scheme
        setup_validator.validate_scheme(record)
        expect(record.errors["startdate"]).to be_empty
        expect(record.errors["scheme_id"]).to be_empty
      end
    end

    context "with a scheme that has many reactivations soon" do
      let(:scheme) { create(:scheme) }

      before do
        create(:location, scheme:)
        create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), reactivation_date: Time.zone.local(2022, 8, 4), scheme:)
        create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 2), reactivation_date: Time.zone.local(2022, 8, 3), scheme:)
        create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 1), reactivation_date: Time.zone.local(2022, 9, 4), scheme:)
        scheme.reload
      end

      it "produces error when tenancy start date is during deactivated scheme period" do
        record.startdate = Time.zone.local(2022, 7, 5)
        record.scheme = scheme
        setup_validator.validate_scheme(record)
        expect(record.errors["startdate"])
          .to include(match I18n.t("validations.setup.startdate.scheme.reactivating_soon.startdate", name: scheme.service_name, date: "4 September 2022"))
        expect(record.errors["scheme_id"])
          .to include(match I18n.t("validations.setup.startdate.scheme.reactivating_soon.scheme_id", name: scheme.service_name, date: "4 September 2022"))
      end

      it "produces no error when tenancy start date is during an active scheme period" do
        record.startdate = Time.zone.local(2022, 10, 1)
        record.scheme = scheme
        setup_validator.validate_scheme(record)
        expect(record.errors["startdate"]).to be_empty
        expect(record.errors["scheme_id"]).to be_empty
      end
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
        setup_validator.validate_scheme(record)
        expect(record.errors["startdate"])
          .to include(match I18n.t("validations.setup.startdate.location.deactivated.startdate", postcode: location.postcode, date: "4 June 2022"))
        expect(record.errors["location_id"])
          .to include(match I18n.t("validations.setup.startdate.location.deactivated.location_id", postcode: location.postcode, date: "4 June 2022"))
      end

      it "produces no error when tenancy start date is during an active location period" do
        record.startdate = Time.zone.local(2022, 6, 1)
        record.location = location
        setup_validator.validate_scheme(record)
        expect(record.errors["startdate"]).to be_empty
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
        setup_validator.validate_scheme(record)
        expect(record.errors["startdate"])
          .to include(match I18n.t("validations.setup.startdate.location.reactivating_soon.startdate", postcode: location.postcode, date: "4 August 2022"))
        expect(record.errors["location_id"])
          .to include(match I18n.t("validations.setup.startdate.location.reactivating_soon.location_id", postcode: location.postcode, date: "4 August 2022"))
      end

      it "produces no error when tenancy start date is during an active location period" do
        record.startdate = Time.zone.local(2022, 9, 1)
        record.location = location
        setup_validator.validate_scheme(record)
        expect(record.errors["startdate"]).to be_empty
        expect(record.errors["location_id"]).to be_empty
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
        setup_validator.validate_scheme(record)
        expect(record.errors["startdate"])
          .to include(match I18n.t("validations.setup.startdate.location.reactivating_soon.startdate", postcode: location.postcode, date: "4 September 2022"))
        expect(record.errors["location_id"])
          .to include(match I18n.t("validations.setup.startdate.location.reactivating_soon.location_id", postcode: location.postcode, date: "4 September 2022"))
      end

      it "produces no error when tenancy start date is during an active location period" do
        record.startdate = Time.zone.local(2022, 10, 1)
        record.location = location
        setup_validator.validate_scheme(record)
        expect(record.errors["startdate"]).to be_empty
        expect(record.errors["location_id"]).to be_empty
      end
    end

    context "with a location that is activating soon (has no deactivation periods)" do
      let(:scheme) { create(:scheme) }
      let(:location) { create(:location, scheme:, startdate: Time.zone.local(2022, 9, 15)) }

      it "produces no error" do
        record.startdate = Time.zone.local(2022, 10, 15)
        record.location = location
        setup_validator.validate_scheme(record)
        expect(record.errors["startdate"]).to be_empty
        expect(record.errors["location_id"]).to be_empty
      end

      it "produces an error when the date is before available_from date" do
        record.startdate = Time.zone.local(2022, 8, 15)
        record.location = location
        setup_validator.validate_scheme(record)
        expect(record.errors["startdate"])
          .to include(match I18n.t("validations.setup.startdate.location.activating_soon.startdate", postcode: location.postcode, date: "15 September 2022"))
        expect(record.errors["location_id"])
          .to include(match I18n.t("validations.setup.startdate.location.activating_soon.location_id", postcode: location.postcode, date: "15 September 2022"))
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
        expect(record.errors["startdate"])
          .to include(match I18n.t("validations.setup.startdate.location.deactivated.startdate", postcode: location.postcode, date: "4 June 2022"))
        expect(record.errors["location_id"])
          .to include(match I18n.t("validations.setup.startdate.location.deactivated.location_id", postcode: location.postcode, date: "4 June 2022"))
      end

      it "produces no error when tenancy start date is during an active location period" do
        record.startdate = Time.zone.local(2022, 6, 1)
        record.location = location
        setup_validator.validate_location(record)
        expect(record.errors["startdate"]).to be_empty
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
        expect(record.errors["startdate"])
          .to include(match I18n.t("validations.setup.startdate.location.reactivating_soon.startdate", postcode: location.postcode, date: "4 August 2022"))
        expect(record.errors["location_id"])
          .to include(match I18n.t("validations.setup.startdate.location.reactivating_soon.location_id", postcode: location.postcode, date: "4 August 2022"))
      end

      it "produces no error when tenancy start date is during an active location period" do
        record.startdate = Time.zone.local(2022, 9, 1)
        record.location = location
        setup_validator.validate_location(record)
        expect(record.errors["startdate"]).to be_empty
        expect(record.errors["location_id"]).to be_empty
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
        setup_validator.validate_location(record)
        expect(record.errors["startdate"])
          .to include(match I18n.t("validations.setup.startdate.location.reactivating_soon.startdate", postcode: location.postcode, date: "4 September 2022"))
        expect(record.errors["location_id"])
          .to include(match I18n.t("validations.setup.startdate.location.reactivating_soon.location_id", postcode: location.postcode, date: "4 September 2022"))
      end

      it "produces no error when tenancy start date is during an active location period" do
        record.startdate = Time.zone.local(2022, 10, 1)
        record.location = location
        setup_validator.validate_location(record)
        expect(record.errors["startdate"]).to be_empty
        expect(record.errors["location_id"]).to be_empty
      end
    end

    context "with a location that is activating soon (has no deactivation periods)" do
      let(:scheme) { create(:scheme) }
      let(:location) { create(:location, scheme:, startdate: Time.zone.local(2022, 9, 15)) }

      it "produces no error" do
        record.startdate = Time.zone.local(2022, 10, 15)
        record.location = location
        setup_validator.validate_location(record)
        expect(record.errors["startdate"]).to be_empty
        expect(record.errors["location_id"]).to be_empty
      end

      it "produces an error when the date is before available_from date" do
        record.startdate = Time.zone.local(2022, 8, 15)
        record.location = location
        setup_validator.validate_location(record)
        expect(record.errors["startdate"])
          .to include(match I18n.t("validations.setup.startdate.location.activating_soon.startdate", postcode: location.postcode, date: "15 September 2022"))
        expect(record.errors["location_id"])
          .to include(match I18n.t("validations.setup.startdate.location.activating_soon.location_id", postcode: location.postcode, date: "15 September 2022"))
      end
    end
  end

  describe "#validate_organisation" do
    let(:user) { create(:user) }
    let(:other_organisation) { create(:organisation) }

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

  describe "#validate_scheme_has_confirmed_locations_validation" do
    let(:scheme) { create(:scheme) }

    context "with a scheme that has no confirmed locations" do
      before do
        create(:location, scheme:, postcode: nil)
        scheme.reload
      end

      it "produces an error" do
        record.scheme = scheme
        setup_validator.validate_scheme_has_confirmed_locations_validation(record)
        expect(record.errors["scheme_id"])
          .to include(match I18n.t("validations.scheme.no_completed_locations"))
      end
    end

    context "with a scheme that has confirmed locations" do
      before do
        create(:location, scheme:)
        scheme.reload
      end

      it "does not produce an error" do
        record.scheme = scheme
        setup_validator.validate_scheme_has_confirmed_locations_validation(record)
        expect(record.errors["scheme_id"])
          .to be_empty
      end
    end
  end

  describe "#validate_managing_organisation_data_sharing_agremeent_signed" do
    before do
      allow(FeatureToggle).to receive(:new_data_protection_confirmation?).and_return(false)
    end

    it "is valid if the DSA is signed" do
      log = build(:lettings_log, :in_progress, owning_organisation: create(:organisation))

      expect(log).to be_valid
    end

    it "is valid when owning_organisation nil" do
      log = build(:lettings_log, owning_organisation: nil)

      expect(log).to be_valid
    end

    it "is not valid if the DSA is not signed" do
      log = build(:lettings_log, owning_organisation: create(:organisation, :without_dpc))

      expect(log).to be_valid
    end
  end

  context "when flag enabled" do
    before do
      allow(FeatureToggle).to receive(:new_data_protection_confirmation?).and_return(true)
    end

    it "is valid if the Data Protection Confirmation is signed" do
      log = build(:lettings_log, :in_progress, managing_organisation: create(:organisation))

      expect(log).to be_valid
    end

    it "is valid when managing_organisation nil" do
      log = build(:lettings_log, managing_organisation: nil)

      expect(log).to be_valid
    end

    it "is not valid if the Data Protection Confirmation is not signed" do
      log = build(:lettings_log, managing_organisation: create(:organisation, :without_dpc))

      expect(log).not_to be_valid
      expect(log.errors[:managing_organisation_id]).to eq(["The organisation must accept the Data Sharing Agreement before it can be selected as the managing organisation."])
    end

    context "when updating" do
      let(:log) { create(:lettings_log, :in_progress) }
      let(:org_with_dpc) { create(:organisation) }
      let(:org_without_dpc) { create(:organisation, :without_dpc) }

      it "is valid when changing to another org with a signed Data Protection Confirmation" do
        expect { log.managing_organisation = org_with_dpc }.to not_change(log, :valid?)
      end

      it "invalid when changing to another org without a signed Data Protection Confirmation" do
        expect { log.managing_organisation = org_without_dpc }.to change(log, :valid?).from(true).to(false).and(change { log.errors[:managing_organisation_id] }.to(["The organisation must accept the Data Sharing Agreement before it can be selected as the managing organisation."]))
      end
    end
  end
end
