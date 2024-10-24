require "rails_helper"

RSpec.describe Validations::Sales::SetupValidations do
  subject(:setup_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::Sales::SetupValidations } }

  describe "#validate_saledate_collection_year" do
    context "with sales_in_crossover_period == false" do
      before do
        allow(FormHandler.instance).to receive(:sales_in_crossover_period?).and_return(false)
      end

      context "when saledate is blank" do
        let(:record) { build(:sales_log, saledate: nil) }

        it "does not add an error" do
          setup_validator.validate_saledate_collection_year(record)

          expect(record.errors).to be_empty
        end
      end

      context "when saledate is in the open collection year" do
        let(:record) { build(:sales_log, :saledate_today) }

        it "does not add an error" do
          setup_validator.validate_saledate_collection_year(record)

          expect(record.errors).to be_empty
        end
      end

      context "when saledate is before the open collection year" do
        let(:record) { build(:sales_log, saledate: Time.zone.today - 3.years) }

        it "adds error" do
          setup_validator.validate_saledate_collection_year(record)

          expect(record.errors[:saledate]).to include(/Enter a date within the \d{4} to \d{4} collection year, which is between 1st April \d{4} and 31st March \d{4}/)
        end
      end

      context "when saledate is after the open collection year" do
        let(:record) { build(:sales_log, saledate: Time.zone.today + 2.years) }

        it "adds error" do
          setup_validator.validate_saledate_collection_year(record)

          expect(record.errors[:saledate]).to include(/Enter a date within the \d{4} to \d{4} collection year, which is between 1st April \d{4} and 31st March \d{4}/)
        end
      end
    end

    context "with sales_in_crossover_period == true" do
      before do
        allow(FormHandler.instance).to receive(:sales_in_crossover_period?).and_return(true)
      end

      context "when saledate is blank" do
        let(:record) { build(:sales_log, saledate: nil) }

        it "does not add an error" do
          setup_validator.validate_saledate_collection_year(record)

          expect(record.errors).to be_empty
        end
      end

      context "when saledate is in an open previous collection year" do
        let(:record) { build(:sales_log, saledate: Time.zone.local(2024, 1, 1)) }

        before do
          allow(FormHandler.instance).to receive(:sales_in_crossover_period?).and_return(true)
        end

        it "does not add an error" do
          setup_validator.validate_saledate_collection_year(record)

          expect(record.errors).to be_empty
        end
      end

      context "when saledate is before an open collection year" do
        let(:record) { build(:sales_log, saledate: Time.zone.local(2020, 5, 1)) }

        before do
          allow(FormHandler.instance).to receive(:sales_in_crossover_period?).and_return(true)
        end

        it "adds error" do
          setup_validator.validate_saledate_collection_year(record)

          expect(record.errors[:saledate]).to include("Enter a date within the 2023 to 2024 or 2024 to 2025 collection years, which is between 1st April 2023 and 31st March 2025.")
        end
      end

      context "when saledate is after an open collection year" do
        let(:record) { build(:sales_log, saledate: Time.zone.local(2025, 4, 1)) }

        before do
          allow(FormHandler.instance).to receive(:sales_in_crossover_period?).and_return(true)
        end

        it "adds error" do
          setup_validator.validate_saledate_collection_year(record)

          expect(record.errors[:saledate]).to include("Enter a date within the 2023 to 2024 or 2024 to 2025 collection years, which is between 1st April 2023 and 31st March 2025.")
        end
      end

      context "when current time is after the new logs end date but before edit end date for the previous period" do
        let(:record) { build(:sales_log, saledate: nil) }

        before do
          allow(Time).to receive(:now).and_return(Time.zone.local(2025, 1, 8))
        end

        it "cannot create new logs for the archived collection year" do
          record.saledate = Time.zone.local(2023, 1, 1)
          setup_validator.validate_saledate_collection_year(record)
          expect(record.errors["saledate"]).to include(match "Enter a date within the 2023 to 2024 or 2024 to 2025 collection years, which is between 1st April 2023 and 31st March 2025.")
        end

        it "can edit already created logs for the previous collection year" do
          record.saledate = Time.zone.local(2024, 1, 2)
          record.save!(validate: false)
          record.saledate = Time.zone.local(2024, 1, 1)
          setup_validator.validate_saledate_collection_year(record)
          expect(record.errors["saledate"]).not_to include(match "Enter a date within the 2024 to 2025 collection year, which is between 1st April 2024 and 31st March 2025.")
        end
      end

      context "when after the new logs end date and after the edit end date for the previous period" do
        let(:record) { build(:sales_log, saledate: Time.zone.local(2025, 4, 1)) }

        before do
          allow(Time).to receive(:now).and_return(Time.zone.local(2025, 1, 8))
        end

        it "cannot create new logs for the archived collection year" do
          record.update!(saledate: nil)
          record.saledate = Time.zone.local(2023, 1, 1)
          setup_validator.validate_saledate_collection_year(record)
          expect(record.errors["saledate"]).to include(match "Enter a date within the 2023 to 2024 or 2024 to 2025 collection years, which is between 1st April 2023 and 31st March 2025.")
        end

        it "cannot edit already created logs for the archived collection year" do
          record.saledate = Time.zone.local(2023, 1, 2)
          record.save!(validate: false)
          record.saledate = Time.zone.local(2023, 1, 1)
          setup_validator.validate_saledate_collection_year(record)
          expect(record.errors["saledate"]).to include(match "Enter a date within the 2023 to 2024 or 2024 to 2025 collection years, which is between 1st April 2023 and 31st March 2025.")
        end
      end
    end
  end

  describe "#validate_saledate_two_weeks" do
    context "when saledate is blank" do
      let(:record) { build(:sales_log, saledate: nil) }

      it "does not add an error" do
        setup_validator.validate_saledate_two_weeks(record)

        expect(record.errors).to be_empty
      end
    end

    context "when saledate is less than 14 days after today" do
      let(:record) { build(:sales_log, saledate: Time.zone.today + 10.days) }

      it "does not add an error" do
        setup_validator.validate_saledate_two_weeks(record)

        expect(record.errors).to be_empty
      end
    end

    context "when saledate is more than 14 days after today" do
      let(:record) { build(:sales_log, saledate: Time.zone.today + 15.days) }

      it "adds an error" do
        setup_validator.validate_saledate_two_weeks(record)

        expect(record.errors[:saledate]).to include("Sale completion date must not be later than 14 days from today’s date.")
      end
    end
  end

  describe "#validate_merged_organisations_saledate" do
    let(:record) { build(:sales_log) }
    let(:absorbing_organisation) { create(:organisation, created_at: Time.zone.local(2023, 2, 1), available_from: Time.zone.local(2023, 2, 1), name: "Absorbing org") }
    let(:merged_organisation) { create(:organisation, name: "Merged org") }

    before do
      merged_organisation.update!(absorbing_organisation:, merge_date: Time.zone.local(2023, 2, 2))
    end

    context "and owning organisation is no longer active" do
      it "does not allow saledate after organisation has been merged" do
        record.saledate = Time.zone.local(2023, 3, 1)
        record.owning_organisation_id = merged_organisation.id
        setup_validator.validate_merged_organisations_saledate(record)
        expect(record.errors["saledate"]).to include(match "Enter a date when the owning organisation was active. Merged org became inactive on 2 February 2023 and was replaced by Absorbing org.")
      end

      it "allows saledate before organisation has been merged" do
        record.saledate = Time.zone.local(2023, 1, 1)
        record.owning_organisation_id = merged_organisation.id
        setup_validator.validate_merged_organisations_saledate(record)
        expect(record.errors["saledate"]).to be_empty
      end
    end

    context "and owning organisation is not yet active during the saledate" do
      it "does not allow saledate before absorbing organisation has become available" do
        record.saledate = Time.zone.local(2023, 1, 1)
        record.owning_organisation_id = absorbing_organisation.id
        setup_validator.validate_merged_organisations_saledate(record)
        expect(record.errors["saledate"]).to include(match "Enter a date when the owning organisation was active. Absorbing org became active on 1 February 2023.")
      end

      it "allows saledate after absorbing organisation has become available" do
        record.saledate = Time.zone.local(2023, 2, 2)
        record.owning_organisation_id = absorbing_organisation.id
        setup_validator.validate_merged_organisations_saledate(record)
        expect(record.errors["saledate"]).to be_empty
      end

      it "allows saledate if available from is not given" do
        record.saledate = Time.zone.local(2023, 1, 1)
        absorbing_organisation.update!(available_from: nil)
        record.owning_organisation_id = absorbing_organisation.id
        setup_validator.validate_merged_organisations_saledate(record)
        expect(record.errors["saledate"]).to be_empty
      end
    end
  end

  describe "#validate_organisation" do
    let(:record) { build(:sales_log) }

    context "when organisations are merged" do
      let(:absorbing_organisation) { create(:organisation, created_at: Time.zone.local(2023, 2, 1), available_from: Time.zone.local(2023, 2, 1), name: "Absorbing org") }
      let(:merged_organisation) { create(:organisation, name: "Merged org") }

      before do
        merged_organisation.update!(merge_date: Time.zone.local(2023, 2, 2), absorbing_organisation:)
      end

      context "and owning organisation is no longer active" do
        it "does not allow organisation that has been merged" do
          record.saledate = Time.zone.local(2023, 3, 1)
          record.owning_organisation_id = merged_organisation.id
          setup_validator.validate_organisation(record)
          expect(record.errors["owning_organisation_id"]).to include(match "The owning organisation must be active on the sale completion date. Merged org became inactive on 2 February 2023 and was replaced by Absorbing org.")
        end

        it "allows organisation before it has been merged" do
          record.saledate = Time.zone.local(2023, 1, 1)
          record.owning_organisation_id = merged_organisation.id
          setup_validator.validate_organisation(record)
          expect(record.errors["owning_organisation_id"]).to be_empty
        end
      end

      context "and owning organisation is not yet active during the saledate" do
        it "does not allow absorbing organisation before it has become available" do
          record.saledate = Time.zone.local(2023, 1, 1)
          record.owning_organisation_id = absorbing_organisation.id
          setup_validator.validate_organisation(record)
          expect(record.errors["owning_organisation_id"]).to include(match "The owning organisation must be active on the sale completion date. Absorbing org became active on 1 February 2023.")
        end

        it "allows absorbing organisation after it has become available" do
          record.saledate = Time.zone.local(2023, 2, 2)
          record.owning_organisation_id = absorbing_organisation.id
          setup_validator.validate_organisation(record)
          expect(record.errors["owning_organisation_id"]).to be_empty
        end

        it "allows absorbing organisation if available from is not given" do
          record.saledate = Time.zone.local(2023, 1, 1)
          absorbing_organisation.update!(available_from: nil)
          record.owning_organisation_id = absorbing_organisation.id
          setup_validator.validate_organisation(record)
          expect(record.errors["owning_organisation_id"]).to be_empty
        end
      end
    end
  end
end
