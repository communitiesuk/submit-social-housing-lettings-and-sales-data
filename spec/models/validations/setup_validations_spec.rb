require "rails_helper"

RSpec.describe Validations::SetupValidations do
  subject(:setup_validator) { setup_validator_class.new }

  let(:setup_validator_class) { Class.new { include Validations::SetupValidations } }
  let(:record) { build(:lettings_log) }

  describe "tenancy start date" do
    context "when in 2022 to 2023 collection" do
      context "when in the crossover period" do
        before do
          allow(Time).to receive(:now).and_return(Time.zone.local(2022, 4, 1))
          record.created_at = Time.zone.local(2022, 4, 1)
        end

        it "cannot be before the first collection window start date" do
          record.startdate = Time.zone.local(2021, 1, 1)
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 2021 to 2022 or 2022 to 2023 collection years, which is between 1st April 2021 and 31st March 2023")
        end

        it "cannot be after the second collection window end date" do
          record.startdate = Time.zone.local(2023, 7, 1, 6)
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 2021 to 2022 or 2022 to 2023 collection years, which is between 1st April 2021 and 31st March 2023")
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
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 2022 to 2023 collection year, which is between 1st April 2022 and 31st March 2023")
        end

        it "cannot be after the second collection window end date" do
          record.startdate = Time.zone.local(2023, 7, 1, 6)
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 2022 to 2023 collection year, which is between 1st April 2022 and 31st March 2023")
        end
      end
    end

    context "when in 2023 to 2024 collection" do
      context "when in the crossover period" do
        before do
          allow(Time).to receive(:now).and_return(Time.zone.local(2023, 4, 1))
          record.created_at = Time.zone.local(2023, 4, 1)
        end

        it "cannot be before the first collection window start date" do
          record.startdate = Time.zone.local(2022, 1, 1)
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 2022 to 2023 or 2023 to 2024 collection years, which is between 1st April 2022 and 31st March 2024")
        end

        it "cannot be after the second collection window end date" do
          record.startdate = Time.zone.local(2024, 7, 1, 6)
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 2022 to 2023 or 2023 to 2024 collection years, which is between 1st April 2022 and 31st March 2024")
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
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 2023 to 2024 collection year, which is between 1st April 2023 and 31st March 2024")
        end

        it "cannot be after the second collection window end date" do
          record.startdate = Time.zone.local(2024, 7, 1, 6)
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 2023 to 2024 collection year, which is between 1st April 2023 and 31st March 2024")
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
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 2023 to 2024 collection year, which is between 1st April 2023 and 31st March 2024")
        end

        xit "can edit already created logs for the previous collection year" do
          record.startdate = Time.zone.local(2023, 1, 2)
          record.save!(validate: false)
          record.startdate = Time.zone.local(2023, 1, 1)
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).not_to include(match "Enter a date within the 2023 to 2024 collection year, which is between 1st April 2023 and 31st March 2024")
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
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 2023 to 2024 collection year, which is between 1st April 2023 and 31st March 2024")
        end

        it "cannot edit already created logs for the previous collection year" do
          record.startdate = Time.zone.local(2023, 1, 2)
          record.save!(validate: false)
          record.startdate = Time.zone.local(2023, 1, 1)
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to include(match "Enter a date within the 2023 to 2024 collection year, which is between 1st April 2023 and 31st March 2024")
        end
      end
    end

    context "when attempted startdate is more than 14 days from the current date" do
      before do
        allow(Time).to receive(:now).and_return(Time.zone.local(2024, 3, 1))
      end

      it "adds an error to startdate" do
        record.startdate = Time.zone.local(2024, 3, 31)
        setup_validator.validate_startdate_setup(record)
        expect(record.errors["startdate"]).to include(match I18n.t("validations.lettings.setup.startdate.not_within.next_two_weeks"))
      end

      context "and the attempted startdate is in a future collection year" do
        it "adds both errors to startdate, with the collection year error first" do
          record.startdate = Time.zone.local(2024, 4, 1)
          setup_validator.validate_startdate_setup(record)
          expect(record.errors["startdate"].length).to be >= 2
          expect(record.errors["startdate"][0]).to eq("Enter a date within the 2023 to 2024 collection year, which is between 1st April 2023 and 31st March 2024.")
          expect(record.errors["startdate"][1]).to eq(I18n.t("validations.lettings.setup.startdate.not_within.next_two_weeks"))
        end
      end
    end

    context "when organisations were merged" do
      let(:absorbing_organisation) { create(:organisation, created_at: Time.zone.local(2023, 1, 30, 4, 5, 6), available_from: Time.zone.local(2023, 2, 1, 4, 5, 6), name: "Absorbing org") }
      let(:absorbing_organisation_2) { create(:organisation, created_at: Time.zone.local(2023, 1, 30), available_from: Time.zone.local(2023, 2, 1), name: "Absorbing org 2") }
      let(:merged_organisation) { create(:organisation, name: "Merged org") }
      let(:merged_organisation_2) { create(:organisation, name: "Merged org 2") }

      before do
        allow(Time).to receive(:now).and_return(Time.zone.local(2023, 5, 1))
        merged_organisation.update!(absorbing_organisation:, merge_date: Time.zone.local(2023, 2, 2))
        merged_organisation_2.update!(absorbing_organisation:, merge_date: Time.zone.local(2023, 2, 2))
      end

      context "and owning organisation is no longer active" do
        it "does not allow startdate after organisation has been merged" do
          record.startdate = Time.zone.local(2023, 3, 1)
          record.owning_organisation_id = merged_organisation.id
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to include(match "Enter a date when the owning organisation was active. Merged org became inactive on 2 February 2023 and was replaced by Absorbing org.")
        end

        it "allows startdate before organisation has been merged" do
          record.startdate = Time.zone.local(2023, 1, 1)
          record.owning_organisation_id = merged_organisation.id
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to be_empty
        end
      end

      context "and owning organisation is not yet active during the startdate" do
        it "does not allow startdate before absorbing organisation has become available" do
          record.startdate = Time.zone.local(2023, 1, 1)
          record.owning_organisation_id = absorbing_organisation.id
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to include(match "Enter a date when the owning organisation was active. Absorbing org became active on 1 February 2023.")
        end

        it "allows startdate after absorbing organisation has become available" do
          record.startdate = Time.zone.local(2023, 2, 2)
          record.owning_organisation_id = absorbing_organisation.id
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to be_empty
        end

        it "allows startdate if organisation does not have available from date" do
          record.startdate = Time.zone.local(2023, 1, 1)
          absorbing_organisation.update!(available_from: nil)
          record.owning_organisation_id = absorbing_organisation.id
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to be_empty
        end
      end

      context "and managing organisation is no longer active during the startdate" do
        it "does not allow startdate after organisation has been merged" do
          record.startdate = Time.zone.local(2023, 3, 1)
          record.managing_organisation_id = merged_organisation.id
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to include(match "Enter a date when the managing organisation was active. Merged org became inactive on 2 February 2023 and was replaced by Absorbing org.")
        end

        it "allows startdate before organisation has been merged" do
          record.startdate = Time.zone.local(2023, 1, 1)
          record.managing_organisation_id = merged_organisation.id
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to be_empty
        end
      end

      context "and managing organisation is not yet active during the startdate" do
        it "does not allow startdate before absorbing organisation has become available'" do
          record.startdate = Time.zone.local(2023, 1, 1)
          record.managing_organisation_id = absorbing_organisation.id
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to include(match "Enter a date when the managing organisation was active. Absorbing org became active on 1 February 2023.")
        end

        it "allows startdate after absorbing organisation has become available" do
          record.startdate = Time.zone.local(2023, 2, 2)
          record.managing_organisation_id = absorbing_organisation.id
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to be_empty
        end

        it "allows startdate if organisation does not have available from date" do
          record.startdate = Time.zone.local(2023, 1, 1)
          absorbing_organisation.update!(available_from: nil)
          record.managing_organisation_id = absorbing_organisation.id
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to be_empty
        end
      end

      context "and owning and managing organisation is no longer active during the startdate" do
        it "does not allow startdate after organisation has been merged" do
          record.startdate = Time.zone.local(2023, 3, 1)
          record.managing_organisation_id = merged_organisation.id
          record.owning_organisation_id = merged_organisation.id
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to include(match "Enter a date when the owning and managing organisation was active. Merged org became inactive on 2 February 2023 and was replaced by Absorbing org.")
        end

        it "allows startdate before organisation has been merged" do
          record.startdate = Time.zone.local(2023, 1, 1)
          record.managing_organisation_id = merged_organisation.id
          record.owning_organisation_id = merged_organisation.id
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to be_empty
        end
      end

      context "and owning and managing organisation is not yet active during the startdate" do
        it "does not allow startdate before absorbing organisation has become available" do
          record.startdate = Time.zone.local(2023, 1, 1)
          record.managing_organisation_id = absorbing_organisation.id
          record.owning_organisation_id = absorbing_organisation.id
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to include(match "Enter a date when the owning and managing organisation was active. Absorbing org became active on 1 February 2023.")
        end

        it "allows startdate after absorbing organisation has become available" do
          record.startdate = Time.zone.local(2023, 2, 1)
          record.managing_organisation_id = absorbing_organisation.id
          record.owning_organisation_id = absorbing_organisation.id
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to be_empty
        end

        it "allows startdate if organisation does not have available from date" do
          record.startdate = Time.zone.local(2023, 1, 1)
          absorbing_organisation.update!(available_from: nil)
          record.managing_organisation_id = absorbing_organisation.id
          record.owning_organisation_id = absorbing_organisation.id
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to be_empty
        end
      end

      context "and owning and managing organisations are no longer active during the startdate" do
        it "does not allow startdate after organisation have been merged" do
          record.startdate = Time.zone.local(2023, 2, 2)
          record.managing_organisation_id = merged_organisation.id
          record.owning_organisation_id = merged_organisation_2.id
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to include(match "Enter a date when the owning and managing organisations were active. Merged org 2 and Merged org became inactive on 2 February 2023 and were replaced by Absorbing org.")
        end

        it "allows startdate before organisations have been merged" do
          record.startdate = Time.zone.local(2023, 1, 1)
          record.managing_organisation_id = merged_organisation.id
          record.owning_organisation_id = merged_organisation_2.id
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to be_empty
        end
      end

      context "and owning and managing organisations are from different merges and no longer active during the startdate" do
        before do
          merged_organisation_2.update!(absorbing_organisation: absorbing_organisation_2, merge_date: Time.zone.local(2023, 2, 2))
        end

        it "does not allow startdate after organisations have been merged" do
          record.startdate = Time.zone.local(2023, 3, 1)
          record.managing_organisation_id = merged_organisation.id
          record.owning_organisation_id = merged_organisation_2.id
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to include(match "Enter a date when the owning and managing organisations were active. Merged org 2 became inactive on 2 February 2023 and was replaced by Absorbing org 2. Merged org became inactive on 2 February 2023 and was replaced by Absorbing org.")
        end

        it "allows startdate before organisations have been merged" do
          record.startdate = Time.zone.local(2023, 1, 1)
          record.managing_organisation_id = merged_organisation.id
          record.owning_organisation_id = merged_organisation_2.id
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to be_empty
        end
      end

      context "and owning and managing organisation have different merges and are not yet active during the startdate" do
        before do
          merged_organisation_2.update!(absorbing_organisation: absorbing_organisation_2, merge_date: Time.zone.local(2023, 2, 2))
        end

        it "does not allow startdate before absorbing organisation has become available" do
          record.startdate = Time.zone.local(2023, 1, 1)
          record.managing_organisation_id = absorbing_organisation.id
          record.owning_organisation_id = absorbing_organisation_2.id
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to include(match "Enter a date when the owning and managing organisations were active. Absorbing org 2 became active on 1 February 2023, and Absorbing org became active on 1 February 2023.")
        end

        it "allows startdate after absorbing organisation has become available" do
          record.startdate = Time.zone.local(2023, 2, 2)
          record.managing_organisation_id = absorbing_organisation.id
          record.owning_organisation_id = absorbing_organisation.id
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to be_empty
        end

        it "allows startdate if organisation does not have available from date" do
          absorbing_organisation.update!(available_from: nil)
          record.startdate = Time.zone.local(2023, 1, 1)
          record.managing_organisation_id = absorbing_organisation.id
          record.owning_organisation_id = absorbing_organisation.id
          setup_validator.validate_startdate_setup(record)
          setup_validator.validate_merged_organisations_start_date(record)
          expect(record.errors["startdate"]).to be_empty
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
        .to include(match I18n.t("validations.lettings.setup.intermediate_rent_product_name.blank"))
    end

    it "adds an error when the intermediate rent product name is blank but the rent type was given as other intermediate rent product" do
      record.rent_type = 5
      record.irproduct_other = ""
      setup_validator.validate_irproduct_other(record)
      expect(record.errors["irproduct_other"])
        .to include(match I18n.t("validations.lettings.setup.intermediate_rent_product_name.blank"))
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
        scheme_deactivation_period = build(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), scheme:)
        scheme_deactivation_period.save!(validate: false)
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
        scheme_deactivation_period = build(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), reactivation_date: Time.zone.local(2022, 8, 4), scheme:)
        scheme_deactivation_period.save!(validate: false)
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
        scheme_deactivation_period = build(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 2), reactivation_date: Time.zone.local(2022, 8, 3), scheme:)
        scheme_deactivation_period_2 = build(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), reactivation_date: Time.zone.local(2022, 8, 4), scheme:)
        scheme_deactivation_period_3 = build(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 1), reactivation_date: Time.zone.local(2022, 9, 4), scheme:)
        scheme_deactivation_period.save!(validate: false)
        scheme_deactivation_period_2.save!(validate: false)
        scheme_deactivation_period_3.save!(validate: false)
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

    context "with a scheme with no locations active on the start date & no location set" do
      let(:scheme) { create(:scheme) }
      let(:location) { create(:location, scheme:) }

      before do
        location_deactivation_period = build(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), location:)
        location_deactivation_period.save!(validate: false)
        location.reload
      end

      it "produces error when scheme does not have any active locations on the tenancy start date" do
        record.startdate = Time.zone.local(2022, 7, 5)
        record.scheme = scheme
        setup_validator.validate_scheme(record)
        expect(record.errors["startdate"]).to include(match I18n.t("validations.setup.startdate.scheme.locations_inactive.startdate", name: scheme.service_name))
        expect(record.errors["scheme_id"]).to include(match I18n.t("validations.setup.startdate.scheme.locations_inactive.startdate", name: scheme.service_name))
      end

      it "produces no error when scheme has active locations on the tenancy start date" do
        record.startdate = Time.zone.local(2022, 6, 1)
        record.scheme = scheme
        setup_validator.validate_scheme(record)
        expect(record.errors["startdate"]).to be_empty
      end
    end

    context "with a scheme with no locations active on the start date & location also set" do
      let(:scheme) { create(:scheme) }
      let(:location) { create(:location, scheme:) }

      before do
        location_deactivation_period = build(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), location:)
        location_deactivation_period.save!(validate: false)
        location.reload
      end

      it "produces error when scheme does not have any active locations on the tenancy start date" do
        record.startdate = Time.zone.local(2022, 7, 5)
        record.scheme = scheme
        record.location = location
        setup_validator.validate_scheme(record)
        expect(record.errors["startdate"]).to include(match I18n.t("validations.setup.startdate.scheme.locations_inactive.startdate", name: scheme.service_name))
        expect(record.errors["startdate"]).not_to include(match I18n.t("validations.setup.startdate.location.deactivated.startdate", postcode: location.postcode))
      end

      it "produces no error when scheme has active locations on the tenancy start date" do
        record.startdate = Time.zone.local(2022, 6, 1)
        record.scheme = scheme
        record.location = location
        setup_validator.validate_scheme(record)
        expect(record.errors["startdate"]).to be_empty
      end
    end

    context "with an incomplete scheme" do
      let(:scheme) { create(:scheme, :incomplete) }

      it "adds an error to scheme_id" do
        record.scheme = scheme
        setup_validator.validate_scheme(record)
        expect(record.errors["scheme_id"]).to include(I18n.t("validations.lettings.setup.scheme.incomplete"))
      end
    end
  end

  describe "#validate_location" do
    context "with a deactivated location" do
      let(:scheme) { create(:scheme) }
      let(:location) { create(:location, scheme:) }

      before do
        location_deactivation_period = build(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), location:)
        location_deactivation_period.save!(validate: false)
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
        location_deactivation_period = build(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), reactivation_date: Time.zone.local(2022, 8, 4), location:)
        location_deactivation_period.save!(validate: false)
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
        location_deactivation_period = build(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 2), reactivation_date: Time.zone.local(2022, 8, 3), location:)
        location_deactivation_period_2 = build(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), reactivation_date: Time.zone.local(2022, 8, 4), location:)
        location_deactivation_period_3 = build(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 1), reactivation_date: Time.zone.local(2022, 9, 4), location:)
        location_deactivation_period.save!(validate: false)
        location_deactivation_period_2.save!(validate: false)
        location_deactivation_period_3.save!(validate: false)
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

    context "with an incomplete location" do
      let(:scheme) { create(:scheme) }
      let(:location) { create(:location, :incomplete, scheme:) }

      it "produces error when location is incomplete" do
        record.location = location
        setup_validator.validate_location(record)
        expect(record.errors["location_id"])
          .to include("This location is incomplete. Select another location or update this one.")
      end

      it "produces no error when location is completes" do
        location.update!(units: 1)
        location.reload
        record.location = location
        setup_validator.validate_location(record)
        expect(record.errors["location_id"]).to be_empty
      end
    end

    context "with the chosen location inactive on the tenancy start date" do
      let(:scheme) { create(:scheme) }
      let(:location) { create(:location, scheme:) }

      before do
        location_deactivation_period = build(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), location:)
        location_deactivation_period.save!(validate: false)
        location.reload
      end

      it "produces the location error when the chosen location is inactive on the tenancy start date" do
        record.startdate = Time.zone.local(2022, 7, 5)
        record.location = location
        setup_validator.validate_location(record)
        expect(record.errors["startdate"]).to include(match I18n.t("validations.setup.startdate.location.deactivated.startdate", postcode: location.postcode))
      end

      it "produces no error when the chosen location is active on the tenancy start date" do
        record.startdate = Time.zone.local(2022, 6, 1)
        record.location = location
        setup_validator.validate_location(record)
        expect(record.errors["startdate"]).to be_empty
      end
    end
  end

  describe "#validate_organisation" do
    let(:user) { create(:user) }
    let(:other_organisation) { create(:organisation, name: "other org") }

    it "validates if neither managing nor owning organisation is the same as assigned_to user organisation" do
      record.assigned_to = user
      record.owning_organisation = other_organisation
      record.managing_organisation = other_organisation

      setup_validator.validate_organisation(record)
      expect(record.errors["assigned_to"]).to include(I18n.t("validations.lettings.setup.assigned_to.invalid"))
      expect(record.errors["owning_organisation_id"]).to include(I18n.t("validations.lettings.setup.owning_organisation.invalid"))
      expect(record.errors["managing_organisation_id"]).to include(I18n.t("validations.lettings.setup.managing_organisation.invalid"))
    end

    it "does not validate if either managing or owning organisation is the same as current user organisation" do
      record.assigned_to = user
      record.owning_organisation = user.organisation
      record.managing_organisation = other_organisation

      setup_validator.validate_organisation(record)
      expect(record.errors["assigned_to"]).to be_empty
      expect(record.errors["owning_organisation_id"]).to be_empty
      expect(record.errors["managing_organisation_id"]).to be_empty
    end

    it "does not validate if current user is missing" do
      record.assigned_to = nil
      record.owning_organisation = other_organisation
      record.managing_organisation = other_organisation

      setup_validator.validate_organisation(record)
      expect(record.errors["assigned_to"]).to be_empty
      expect(record.errors["owning_organisation_id"]).to be_empty
      expect(record.errors["managing_organisation_id"]).to be_empty
    end

    it "does not validate if managing organisation is missing" do
      record.assigned_to = user
      record.owning_organisation = other_organisation
      record.managing_organisation = nil

      setup_validator.validate_organisation(record)
      expect(record.errors["assigned_to"]).to be_empty
      expect(record.errors["owning_organisation_id"]).to be_empty
      expect(record.errors["managing_organisation_id"]).to be_empty
    end

    it "does not validate if owning organisation is missing" do
      record.assigned_to = user
      record.owning_organisation = nil
      record.managing_organisation = other_organisation

      setup_validator.validate_organisation(record)
      expect(record.errors["assigned_to"]).to be_empty
      expect(record.errors["owning_organisation_id"]).to be_empty
      expect(record.errors["managing_organisation_id"]).to be_empty
    end

    context "when organisations are merged" do
      let(:absorbing_organisation) { create(:organisation, created_at: Time.zone.local(2023, 2, 1, 4, 5, 6), available_from: Time.zone.local(2023, 2, 1, 4, 5, 6), name: "Absorbing org") }
      let(:merged_organisation) { create(:organisation, name: "Merged org") }

      before do
        merged_organisation.merge_date = Time.zone.local(2023, 2, 2)
        merged_organisation.absorbing_organisation = absorbing_organisation
        merged_organisation.save!(validate: false)
      end

      context "and owning organisation is no longer active" do
        it "does not allow organisation that has been merged" do
          record.startdate = Time.zone.local(2023, 3, 1)
          record.owning_organisation_id = merged_organisation.id
          setup_validator.validate_organisation(record)
          expect(record.errors["owning_organisation_id"]).to include(match "The owning organisation must be active on the tenancy start date. Merged org became inactive on 2 February 2023 and was replaced by Absorbing org.")
        end

        it "allows organisation before it has been merged" do
          record.startdate = Time.zone.local(2023, 1, 1)
          record.owning_organisation_id = merged_organisation.id
          setup_validator.validate_organisation(record)
          expect(record.errors["owning_organisation_id"]).to be_empty
        end
      end

      context "and owning organisation is not yet active during the startdate" do
        it "does not allow absorbing organisation before it has become available'" do
          record.startdate = Time.zone.local(2023, 1, 1)
          record.owning_organisation_id = absorbing_organisation.id
          setup_validator.validate_organisation(record)
          expect(record.errors["owning_organisation_id"]).to include(match "The owning organisation must be active on the tenancy start date. Absorbing org became active on 1 February 2023.")
        end

        it "allows absorbing organisation after it has become available" do
          record.startdate = Time.zone.local(2023, 2, 2)
          record.owning_organisation_id = absorbing_organisation.id
          setup_validator.validate_organisation(record)
          expect(record.errors["owning_organisation_id"]).to be_empty
        end

        it "allows startdate if organisation does not have available from date" do
          absorbing_organisation.update!(available_from: nil)
          record.startdate = Time.zone.local(2023, 1, 1)
          record.owning_organisation_id = absorbing_organisation.id
          setup_validator.validate_organisation(record)
          expect(record.errors["owning_organisation_id"]).to be_empty
        end
      end

      context "when managing organisation is no longer active" do
        it "does not allow organisation that has been merged" do
          record.startdate = Time.zone.local(2023, 3, 1)
          record.managing_organisation_id = merged_organisation.id
          setup_validator.validate_organisation(record)
          expect(record.errors["managing_organisation_id"]).to include(match "The managing organisation must be active on the tenancy start date. Merged org became inactive on 2 February 2023 and was replaced by Absorbing org.")
        end

        it "allows organisation before it has been merged" do
          record.startdate = Time.zone.local(2023, 1, 1)
          record.managing_organisation_id = merged_organisation.id
          setup_validator.validate_organisation(record)
          expect(record.errors["managing_organisation_id"]).to be_empty
        end
      end

      context "when managing organisation is not yet active during the startdate" do
        it "does not allow absorbing organisation before it has become available" do
          record.startdate = Time.zone.local(2023, 1, 1)
          record.managing_organisation_id = absorbing_organisation.id
          setup_validator.validate_organisation(record)
          expect(record.errors["managing_organisation_id"]).to include(match "The managing organisation must be active on the tenancy start date. Absorbing org became active on 1 February 2023.")
        end

        it "allows absorbing organisation after it has become available'" do
          record.startdate = Time.zone.local(2023, 2, 2)
          record.managing_organisation_id = absorbing_organisation.id
          setup_validator.validate_organisation(record)
          expect(record.errors["managing_organisation_id"]).to be_empty
        end

        it "allows startdate if organisation does not have available from date" do
          absorbing_organisation.update!(available_from: nil)
          record.startdate = Time.zone.local(2023, 1, 1)
          record.managing_organisation_id = absorbing_organisation.id
          setup_validator.validate_organisation(record)
          expect(record.errors["managing_organisation_id"]).to be_empty
        end
      end
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
          .to include(match I18n.t("validations.lettings.setup.scheme.no_completed_locations"))
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
      let(:log) { build(:lettings_log, :in_progress) }
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
