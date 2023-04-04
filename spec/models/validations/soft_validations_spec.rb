require "rails_helper"

RSpec.describe Validations::SoftValidations do
  let(:organisation) { FactoryBot.create(:organisation, provider_type: "PRP") }
  let(:record) { FactoryBot.create(:lettings_log, owning_organisation: organisation) }

  before do
    Timecop.freeze(Time.zone.local(2021, 10, 10))
    Singleton.__init__(FormHandler)
  end

  after do
    Timecop.return
  end

  describe "rent min max validations" do
    before do
      LaRentRange.create!(
        ranges_rent_id: "1",
        la: "E07000223",
        beds: 1,
        lettype: 1,
        soft_min: 12.41,
        soft_max: 89.54,
        hard_min: 9.87,
        hard_max: 100.99,
        start_year: 2021,
      )

      record.la = "E07000223"
      record.needstype = 1
      record.rent_type = 0
      record.beds = 1
      record.period = 1
      record.startdate = Time.zone.today
    end

    context "when validating soft min" do
      before do
        record.brent = 11
      end

      it "returns out of soft min range if no startdate is given" do
        record.startdate = nil
        expect(record)
          .not_to be_rent_in_soft_min_range
      end

      it "returns out of soft min range if no brent is given" do
        record.brent = nil
        expect(record)
          .not_to be_rent_in_soft_min_range
      end

      it "returns true if weekly rent is in soft min range" do
        expect(record)
          .to be_rent_in_soft_min_range
      end
    end

    context "when validating soft max" do
      before do
        record.brent = 90
      end

      it "returns out of soft max range if no startdate is given" do
        record.startdate = nil
        expect(record)
          .not_to be_rent_in_soft_max_range
      end

      it "returns out of soft max range if no brent is given" do
        record.brent = nil
        expect(record)
          .not_to be_rent_in_soft_max_range
      end

      it "returns true if weekly rent is in soft max range" do
        expect(record)
          .to be_rent_in_soft_max_range
      end
    end
  end

  describe "retirement soft validations" do
    context "when the tenant is retired but under the expected retirement age" do
      context "when the tenant is female" do
        it "shows the interruption screen" do
          record.update!(age1: 43, sex1: "F", ecstat1: 5)
          expect(record.person_1_retired_under_soft_min_age?).to be true
        end
      end

      context "when the tenant is male" do
        it "shows the interruption screen" do
          record.update!(age1: 43, sex1: "M", ecstat1: 5)
          expect(record.person_1_retired_under_soft_min_age?).to be true
        end
      end

      context "when the tenant is non-binary" do
        it "shows the interruption screen" do
          record.update!(age1: 43, sex1: "X", ecstat1: 5)
          expect(record.person_1_retired_under_soft_min_age?).to be true
        end
      end
    end

    context "when the tenant is not retired but over the expected retirement age" do
      context "when the tenant is female" do
        it "shows the interruption screen" do
          record.update!(age1: 85, sex1: "F", ecstat1: 3)
          expect(record.person_1_not_retired_over_soft_max_age?).to be true
        end
      end

      context "when the tenant is male" do
        it "shows the interruption screen" do
          record.update!(age1: 85, sex1: "M", ecstat1: 3)
          expect(record.person_1_not_retired_over_soft_max_age?).to be true
        end
      end

      context "when the tenant is non-binary" do
        it "shows the interruption screen" do
          record.update!(age1: 85, sex1: "X", ecstat1: 3)
          expect(record.person_1_not_retired_over_soft_max_age?).to be true
        end
      end
    end

    context "when the tenant prefers not to say what their economic status is but is under the expected retirement age" do
      context "when the tenant is female" do
        it "does not show the interruption screen" do
          record.update!(age1: 43, sex1: "F", ecstat1: 10)
          expect(record.person_1_retired_under_soft_min_age?).to be false
        end
      end

      context "when the tenant is male" do
        it "does not show the interruption screen" do
          record.update!(age1: 43, sex1: "M", ecstat1: 10)
          expect(record.person_1_retired_under_soft_min_age?).to be false
        end
      end

      context "when the tenant is non-binary" do
        it "does not show the interruption screen" do
          record.update!(age1: 43, sex1: "X", ecstat1: 10)
          expect(record.person_1_retired_under_soft_min_age?).to be false
        end
      end
    end

    context "when the tenant prefers not to say what their economic status is but is over the expected retirement age" do
      context "when the tenant is female" do
        it "does not show the interruption screen" do
          record.update!(age1: 85, sex1: "F", ecstat1: 10)
          expect(record.person_1_not_retired_over_soft_max_age?).to be false
        end
      end

      context "when the tenant is male" do
        it "does not show the interruption screen" do
          record.update!(age1: 85, sex1: "M", ecstat1: 10)
          expect(record.person_1_not_retired_over_soft_max_age?).to be false
        end
      end

      context "when the tenant is non-binary" do
        it "does not show the interruption screen" do
          record.update!(age1: 85, sex1: "X", ecstat1: 10)
          expect(record.person_1_not_retired_over_soft_max_age?).to be false
        end
      end
    end
  end

  describe "pregnancy soft validations" do
    context "when there are no female tenants" do
      it "shows the interruption screen" do
        record.update!(age1: 43, sex1: "M", preg_occ: 1, hhmemb: 1, age1_known: 0)
        expect(record.no_females_in_a_pregnant_household?).to be true
      end
    end

    context "when there are no female tenants and age of other tenants is unknown" do
      it "shows the interruption screen" do
        record.update!(sex1: "M", preg_occ: 1, hhmemb: 1, age1_known: 1)
        expect(record.no_females_in_a_pregnant_household?).to be true
      end
    end

    context "when female tenants are under 16" do
      it "shows the interruption screen" do
        record.update!(age2: 14, sex2: "F", preg_occ: 1, hhmemb: 2, details_known_2: 0, age2_known: 0, age1: 18, sex1: "M", age1_known: 0)
        expect(record.female_in_pregnant_household_in_soft_validation_range?).to be true
      end
    end

    context "when female tenants are over 50" do
      it "shows the interruption screen" do
        record.update!(age1: 54, sex1: "F", preg_occ: 1, hhmemb: 1, age1_known: 0)
        expect(record.female_in_pregnant_household_in_soft_validation_range?).to be true
      end
    end

    context "when female tenants are outside of soft validation ranges" do
      it "does not show the interruption screen" do
        record.update!(age1: 44, sex1: "F", preg_occ: 1, hhmemb: 1)
        expect(record.no_females_in_a_pregnant_household?).to be false
        expect(record.female_in_pregnant_household_in_soft_validation_range?).to be false
      end
    end

    context "when the information about the tenants is not given" do
      it "does not show the interruption screen" do
        record.update!(preg_occ: 1, hhmemb: 2)
        expect(record.no_females_in_a_pregnant_household?).to be false
        expect(record.female_in_pregnant_household_in_soft_validation_range?).to be false
      end
    end
  end

  describe "major repairs date soft validations" do
    before do
      Timecop.freeze(Time.zone.local(2022, 2, 1))
    end

    after do
      Timecop.unfreeze
    end

    context "when the major repairs date is within 10 years of the tenancy start date" do
      it "shows the interruption screen" do
        record.update!(startdate: Time.zone.local(2022, 2, 1), mrcdate: Time.zone.local(2013, 2, 1))
        expect(record.major_repairs_date_in_soft_range?).to be true
      end
    end

    context "when the major repairs date is less than 2 years before the tenancy start date" do
      it "does not show the interruption screen" do
        record.update!(startdate: Time.zone.local(2022, 2, 1), mrcdate: Time.zone.local(2021, 2, 1))
        expect(record.major_repairs_date_in_soft_range?).to be false
      end
    end
  end

  describe "void date soft validations" do
    before do
      Timecop.freeze(Time.zone.local(2022, 2, 1))
    end

    after do
      Timecop.unfreeze
    end

    context "when the void date is within 10 years of the tenancy start date" do
      it "shows the interruption screen" do
        record.update!(startdate: Time.zone.local(2022, 2, 1), voiddate: Time.zone.local(2013, 2, 1))
        expect(record.voiddate_in_soft_range?).to be true
      end
    end

    context "when the void date is less than 2 years before the tenancy start date" do
      it "does not show the interruption screen" do
        record.update!(startdate: Time.zone.local(2022, 2, 1), voiddate: Time.zone.local(2021, 2, 1))
        expect(record.voiddate_in_soft_range?).to be false
      end
    end
  end

  describe "old persons shared ownership soft validations" do
    context "when it is a joint purchase and both buyers are over 64" do
      let(:record) { FactoryBot.build(:sales_log, jointpur: 1, age1: 65, age2: 66, type: 24) }

      it "returns false" do
        expect(record.buyers_age_for_old_persons_shared_ownership_invalid?).to be false
      end
    end

    context "when it is a joint purchase and first buyer is over 64" do
      let(:record) { FactoryBot.build(:sales_log, jointpur: 1, age1: 65, age2: 40, type: 24) }

      it "returns false" do
        expect(record.buyers_age_for_old_persons_shared_ownership_invalid?).to be false
      end
    end

    context "when it is a joint purchase and second buyer is over 64" do
      let(:record) { FactoryBot.build(:sales_log, jointpur: 1, age1: 43, age2: 64, type: 24) }

      it "returns false" do
        expect(record.buyers_age_for_old_persons_shared_ownership_invalid?).to be false
      end
    end

    context "when it is a joint purchase and neither of the buyers are over 64" do
      let(:record) { FactoryBot.build(:sales_log, jointpur: 1, age1: 43, age2: 33, type: 24) }

      it "returns true" do
        expect(record.buyers_age_for_old_persons_shared_ownership_invalid?).to be true
      end
    end

    context "when it is a joint purchase and first buyer is under 64 and the second buyers' age is unknown" do
      let(:record) { FactoryBot.build(:sales_log, jointpur: 1, age1: 43, age2_known: 1, type: 24) }

      it "returns true" do
        expect(record.buyers_age_for_old_persons_shared_ownership_invalid?).to be true
      end
    end

    context "when it is a joint purchase and neither of the buyers ages are known" do
      let(:record) { FactoryBot.build(:sales_log, jointpur: 1, age1_known: 1, age2_known: 1, type: 24) }

      it "returns true" do
        expect(record.buyers_age_for_old_persons_shared_ownership_invalid?).to be true
      end
    end

    context "when it is not a joint purchase and the buyer is over 64" do
      let(:record) { FactoryBot.build(:sales_log, jointpur: 2, age1: 70, type: 24) }

      it "returns false" do
        expect(record.buyers_age_for_old_persons_shared_ownership_invalid?).to be false
      end
    end

    context "when it is not a joint purchase and the buyer is under 64" do
      let(:record) { FactoryBot.build(:sales_log, jointpur: 2, age1: 20, type: 24) }

      it "returns true" do
        expect(record.buyers_age_for_old_persons_shared_ownership_invalid?).to be true
      end
    end

    context "when it is not a joint purchase and the buyers age is not known" do
      let(:record) { FactoryBot.build(:sales_log, jointpur: 2, age1_known: 1, type: 24) }

      it "returns true" do
        expect(record.buyers_age_for_old_persons_shared_ownership_invalid?).to be true
      end
    end
  end

  describe "#care_home_charge_expected_not_provided?" do
    it "returns false if is_carehome is 'No'" do
      record.period = 3
      record.is_carehome = 0
      record.chcharge = nil

      expect(record).not_to be_care_home_charge_expected_not_provided
    end

    it "returns false if is_carehome is not given" do
      record.period = 3
      record.is_carehome = nil
      record.chcharge = nil

      expect(record).not_to be_care_home_charge_expected_not_provided
    end

    it "returns false if chcharge is given" do
      record.period = 3
      record.is_carehome = 1
      record.chcharge = 40

      expect(record).not_to be_care_home_charge_expected_not_provided
    end

    it "returns true if is_carehome is 'Yes' and chcharge is not given" do
      record.period = 3
      record.is_carehome = 1
      record.chcharge = nil

      expect(record).to be_care_home_charge_expected_not_provided
    end
  end
end
