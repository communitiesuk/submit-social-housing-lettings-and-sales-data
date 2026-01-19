require "rails_helper"

RSpec.describe Validations::SoftValidations do
  let(:organisation) { FactoryBot.build(:organisation, provider_type: "PRP", id: 123) }
  let(:record) { FactoryBot.build(:lettings_log, owning_organisation: organisation) }

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
      record.startdate = Time.zone.local(2021, 10, 10)
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
    before do
      record.age1 = age1
      record.ecstat1 = ecstat1
    end

    context "when the tenant is under the expected retirement age" do
      let(:age1) { 60 }

      context "and the tenant's economic status is nil" do
        let(:ecstat1) { nil }

        it "does not show the interruption screen" do
          expect(record).not_to be_person_1_retired_under_soft_min_age
        end
      end

      context "and the tenant is retired" do
        let(:ecstat1) { 5 }

        it "does show the interruption screen" do
          expect(record).to be_person_1_retired_under_soft_min_age
        end
      end

      context "and the tenant is not retired" do
        let(:ecstat1) { 3 }

        it "does not show the interruption screen" do
          expect(record).not_to be_person_1_retired_under_soft_min_age
        end
      end

      context "and the tenant prefers not to say" do
        let(:ecstat1) { 10 }

        it "does not show the interruption screen" do
          expect(record).not_to be_person_1_retired_under_soft_min_age
        end
      end
    end

    context "when the tenant is over the expected retirement age" do
      let(:age1) { 70 }

      context "and the tenant's economic status is nil" do
        let(:ecstat1) { nil }

        it "does not show the interruption screen" do
          expect(record).not_to be_person_1_not_retired_over_soft_max_age
        end
      end

      context "and the tenant is retired" do
        let(:ecstat1) { 5 }

        it "does not show the interruption screen" do
          expect(record).not_to be_person_1_not_retired_over_soft_max_age
        end
      end

      context "and the tenant is not retired" do
        let(:ecstat1) { 3 }

        it "does show the interruption screen" do
          expect(record).to be_person_1_not_retired_over_soft_max_age
        end
      end

      context "and the tenant prefers not to say" do
        let(:ecstat1) { 10 }

        it "does not show the interruption screen" do
          expect(record).not_to be_person_1_not_retired_over_soft_max_age
        end
      end
    end
  end

  describe "pregnancy soft validations" do
    context "when all tenants are male" do
      it "shows the interruption screen" do
        record.age1 = 43
        record.sex1 = "M"
        record.preg_occ = 1
        record.hhmemb = 1
        record.age1_known = 0
        expect(record.all_male_tenants_in_a_pregnant_household?).to be true
      end
    end

    context "when there all tenants are male and age of tenants is unknown" do
      it "shows the interruption screen" do
        record.sex1 = "M"
        record.preg_occ = 1
        record.hhmemb = 1
        record.age1_known = 1
        expect(record.all_male_tenants_in_a_pregnant_household?).to be true
      end
    end

    context "when all tenants are male and household members are over 8" do
      it "does not show the interruption screen" do
        (1..8).each do |n|
          record.send("sex#{n}=", "M")
          record.send("age#{n}=", 30)
          record.send("age#{n}_known=", 0)
          record.send("details_known_#{n}=", 0) unless n == 1
        end
        record.preg_occ = 1
        record.hhmemb = 9
        expect(record.all_male_tenants_in_a_pregnant_household?).to be false
      end
    end

    context "when female tenants are under 16" do
      it "shows the interruption screen" do
        record.age2 = 14
        record.sex2 = "F"
        record.preg_occ = 1
        record.hhmemb = 2
        record.details_known_2 = 0
        record.age2_known = 0
        record.age1 = 18
        record.sex1 = "M"
        record.age1_known = 0
        expect(record.female_in_pregnant_household_in_soft_validation_range?).to be true
      end
    end

    context "when female tenants are over 50" do
      it "shows the interruption screen" do
        record.age1 = 54
        record.sex1 = "F"
        record.preg_occ = 1
        record.hhmemb = 1
        record.age1_known = 0
        expect(record.female_in_pregnant_household_in_soft_validation_range?).to be true
      end
    end

    context "when female tenants are outside of soft validation ranges" do
      it "does not show the interruption screen" do
        record.age1 = 44
        record.sex1 = "F"
        record.preg_occ = 1
        record.hhmemb = 1
        expect(record.all_male_tenants_in_a_pregnant_household?).to be false
        expect(record.female_in_pregnant_household_in_soft_validation_range?).to be false
      end
    end

    context "when the information about the tenants is not given" do
      it "does not show the interruption screen" do
        record.preg_occ = 1
        record.hhmemb = 2
        expect(record.all_male_tenants_in_a_pregnant_household?).to be false
        expect(record.female_in_pregnant_household_in_soft_validation_range?).to be false
      end
    end

    context "when number of household members is over 8" do
      it "does not show the interruption screen" do
        (1..8).each do |n|
          record.send("sex#{n}=", "F")
          record.send("age#{n}=", 50)
          record.send("age#{n}_known=", 0)
          record.send("details_known_#{n}=", 0) unless n == 1
        end
        record.preg_occ = 1
        record.hhmemb = 9
        expect(record.female_in_pregnant_household_in_soft_validation_range?).to be false
      end
    end
  end

  describe "major repairs date soft validations" do
    context "when the major repairs date is within 10 years of the tenancy start date" do
      it "shows the interruption screen" do
        record.startdate = Time.zone.local(2022, 2, 1)
        record.mrcdate = Time.zone.local(2013, 2, 1)
        expect(record.major_repairs_date_in_soft_range?).to be true
      end
    end

    context "when the major repairs date is less than 2 years before the tenancy start date" do
      it "does not show the interruption screen" do
        record.startdate = Time.zone.local(2022, 2, 1)
        record.mrcdate = Time.zone.local(2021, 2, 1)
        expect(record.major_repairs_date_in_soft_range?).to be false
      end
    end

    context "with 2025 logs" do
      context "when the void date is within 20 years of the tenancy start date" do
        it "shows the interruption screen" do
          record.startdate = Time.zone.local(2026, 2, 1)
          record.mrcdate = Time.zone.local(2007, 2, 1)
          expect(record.major_repairs_date_in_soft_range?).to be true
        end
      end

      context "when the void date is less than 2 years before the tenancy start date" do
        it "does not show the interruption screen" do
          record.startdate = Time.zone.local(2026, 2, 1)
          record.mrcdate = Time.zone.local(2025, 2, 1)
          expect(record.major_repairs_date_in_soft_range?).to be false
        end
      end
    end
  end

  describe "void date soft validations" do
    context "when the void date is within 10 years of the tenancy start date" do
      it "shows the interruption screen" do
        record.startdate = Time.zone.local(2022, 2, 1)
        record.voiddate = Time.zone.local(2013, 2, 1)
        expect(record.voiddate_in_soft_range?).to be true
      end
    end

    context "when the void date is less than 2 years before the tenancy start date" do
      it "does not show the interruption screen" do
        record.startdate = Time.zone.local(2022, 2, 1)
        record.voiddate = Time.zone.local(2021, 2, 1)
        expect(record.voiddate_in_soft_range?).to be false
      end
    end

    context "with 2025 logs" do
      context "when the void date is within 20 years of the tenancy start date" do
        it "shows the interruption screen" do
          record.startdate = Time.zone.local(2026, 2, 1)
          record.voiddate = Time.zone.local(2007, 2, 1)
          expect(record.voiddate_in_soft_range?).to be true
        end
      end

      context "when the void date is less than 2 years before the tenancy start date" do
        it "does not show the interruption screen" do
          record.startdate = Time.zone.local(2026, 2, 1)
          record.voiddate = Time.zone.local(2025, 2, 1)
          expect(record.voiddate_in_soft_range?).to be false
        end
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

  describe "#la_referral_for_general_needs?" do
    it "returns false if needstype is 'Supported Housing'" do
      record.needstype = 2
      record.referral = 4

      expect(record).not_to be_la_referral_for_general_needs
    end

    it "returns false if needstype is not given" do
      record.needstype = nil
      record.referral = 4

      expect(record).not_to be_la_referral_for_general_needs
    end

    it "returns false if referral is not given" do
      record.needstype = 1
      record.referral = nil

      expect(record).not_to be_la_referral_for_general_needs
    end

    it "returns true if needstype is 'General needs' and referral is 4" do
      record.needstype = 1
      record.referral = 4

      expect(record).to be_la_referral_for_general_needs
    end
  end

  describe "scharge_in_soft_max_range?" do
    context "and organisation is PRP" do
      before do
        record.owning_organisation.update(provider_type: "PRP")
      end

      it "returns false if scharge is not given" do
        record.scharge = nil
        record.needstype = 1
        record.period = 1

        expect(record).not_to be_scharge_in_soft_max_range
      end

      it "returns false if period is not given" do
        record.scharge = 201
        record.needstype = 1
        record.period = nil

        expect(record).not_to be_scharge_in_soft_max_range
      end

      [{
        period: { label: "weekly", value: 1 },
        scharge: 34,
        description: "under soft max (35)",
      },
       {
         period: { label: "monthly", value: 4 },
         scharge: 100,
         description: "under soft max (35)",
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         scharge: 69,
         description: "under soft max (35)",
       },
       {
         period: { label: "weekly", value: 1 },
         scharge: 801,
         description: "over hard max (800)",
       },
       {
         period: { label: "monthly", value: 4 },
         scharge: 3471,
         description: "over hard max (800)",
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         scharge: 1601,
         description: "over hard max (800)",
       }].each do |test_case|
        it "returns false if scharge is #{test_case[:description]} for general needs #{test_case[:period][:label]}" do
          record.scharge = test_case[:scharge]
          record.needstype = 1
          record.period = test_case[:period][:value]

          expect(record).not_to be_scharge_in_soft_max_range
        end
      end

      [{
        period: { label: "weekly", value: 1 },
        scharge: 199,
        description: "under soft max (200)",
      },
       {
         period: { label: "monthly", value: 4 },
         scharge: 400,
         description: "under soft max (200)",
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         scharge: 399,
         description: "under soft max (200)",
       },
       {
         period: { label: "weekly", value: 1 },
         scharge: 801,
         description: "over hard max (800)",
       },
       {
         period: { label: "monthly", value: 4 },
         scharge: 3471,
         description: "over hard max (800)",
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         scharge: 1601,
         description: "over hard max (800)",
       }].each do |test_case|
        it "returns false if scharge is #{test_case[:description]} for supported housing #{test_case[:period][:label]}" do
          record.scharge = test_case[:scharge]
          record.needstype = 2
          record.period = test_case[:period][:value]

          expect(record).not_to be_scharge_in_soft_max_range
        end
      end

      [{
        period: { label: "weekly", value: 1 },
        scharge: 36,
      },
       {
         period: { label: "monthly", value: 4 },
         scharge: 180,
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         scharge: 71,
       }].each do |test_case|
        it "returns true if scharge is over soft max for general needs #{test_case[:period][:label]} (35)" do
          record.scharge = test_case[:scharge]
          record.needstype = 1
          record.period = test_case[:period][:value]

          expect(record).to be_scharge_in_soft_max_range
        end
      end

      [{
        period: { label: "weekly", value: 1 },
        scharge: 201,
      },
       {
         period: { label: "monthly", value: 4 },
         scharge: 1000,
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         scharge: 401,
       }].each do |test_case|
        it "returns true if scharge is over soft max for supported housing #{test_case[:period][:label]} (200)" do
          record.scharge = test_case[:scharge]
          record.needstype = 2
          record.period = test_case[:period][:value]

          expect(record).to be_scharge_in_soft_max_range
        end
      end
    end

    context "and organisation is LA" do
      before do
        record.owning_organisation.update(provider_type: "LA")
      end

      it "returns false if scharge is not given" do
        record.scharge = nil
        record.needstype = 1
        record.period = 1

        expect(record).not_to be_scharge_in_soft_max_range
      end

      it "returns false if period is not given" do
        record.scharge = 201
        record.needstype = 1
        record.period = nil

        expect(record).not_to be_scharge_in_soft_max_range
      end

      [{
        period: { label: "weekly", value: 1 },
        scharge: 24,
        description: "under soft max (25)",
      },
       {
         period: { label: "monthly", value: 4 },
         scharge: 88,
         description: "under soft max (25)",
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         scharge: 49,
         description: "under soft max (25)",
       },
       {
         period: { label: "weekly", value: 1 },
         scharge: 501,
         description: "over hard max (500)",
       },
       {
         period: { label: "monthly", value: 4 },
         scharge: 2167,
         description: "over hard max (500)",
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         scharge: 1001,
         description: "over hard max (500)",
       }].each do |test_case|
        it "returns false if scharge is #{test_case[:description]} for general needs #{test_case[:period][:label]}" do
          record.scharge = test_case[:scharge]
          record.needstype = 1
          record.period = test_case[:period][:value]

          expect(record).not_to be_scharge_in_soft_max_range
        end
      end

      [{
        period: { label: "weekly", value: 1 },
        scharge: 99,
        description: "under soft max (100)",
      },
       {
         period: { label: "monthly", value: 4 },
         scharge: 400,
         description: "under soft max (100)",
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         scharge: 199,
         description: "under soft max (100)",
       },
       {
         period: { label: "weekly", value: 1 },
         scharge: 501,
         description: "over hard max (500)",
       },
       {
         period: { label: "monthly", value: 4 },
         scharge: 2167,
         description: "over hard max (500)",
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         scharge: 1001,
         description: "over hard max (500)",
       }].each do |test_case|
        it "returns false if scharge is #{test_case[:description]} for supported housing #{test_case[:period][:label]}" do
          record.scharge = test_case[:scharge]
          record.needstype = 2
          record.period = test_case[:period][:value]

          expect(record).not_to be_scharge_in_soft_max_range
        end
      end

      [{
        period: { label: "weekly", value: 1 },
        scharge: 26,
      },
       {
         period: { label: "monthly", value: 4 },
         scharge: 120,
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         scharge: 51,
       }].each do |test_case|
        it "returns true if scharge is over soft max for general needs #{test_case[:period][:label]} (25)" do
          record.scharge = test_case[:scharge]
          record.needstype = 1
          record.period = test_case[:period][:value]

          expect(record).to be_scharge_in_soft_max_range
        end
      end

      [{
        period: { label: "weekly", value: 1 },
        scharge: 101,
      },
       {
         period: { label: "monthly", value: 4 },
         scharge: 450,
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         scharge: 201,
       }].each do |test_case|
        it "returns true if scharge is over soft max for supported housing #{test_case[:period][:label]} (100)" do
          record.scharge = test_case[:scharge]
          record.needstype = 2
          record.period = test_case[:period][:value]

          expect(record).to be_scharge_in_soft_max_range
        end
      end
    end
  end

  describe "pscharge_in_soft_max_range?" do
    context "and organisation is PRP" do
      before do
        record.owning_organisation.update(provider_type: "PRP")
      end

      it "returns false if pscharge is not given" do
        record.pscharge = nil
        record.needstype = 1
        record.period = 1

        expect(record).not_to be_pscharge_in_soft_max_range
      end

      it "returns false if period is not given" do
        record.pscharge = 201
        record.needstype = 1
        record.period = nil

        expect(record).not_to be_pscharge_in_soft_max_range
      end

      [{
        period: { label: "weekly", value: 1 },
        pscharge: 34,
        description: "under soft max (35)",
      },
       {
         period: { label: "monthly", value: 4 },
         pscharge: 100,
         description: "under soft max (35)",
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         pscharge: 69,
         description: "under soft max (35)",
       },
       {
         period: { label: "weekly", value: 1 },
         pscharge: 701,
         description: "over hard max (700)",
       },
       {
         period: { label: "monthly", value: 4 },
         pscharge: 3034,
         description: "over hard max (700)",
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         pscharge: 1401,
         description: "over hard max (700)",
       }].each do |test_case|
        it "returns false if pscharge is #{test_case[:description]} for general needs #{test_case[:period][:label]}" do
          record.pscharge = test_case[:pscharge]
          record.needstype = 1
          record.period = test_case[:period][:value]

          expect(record).not_to be_pscharge_in_soft_max_range
        end
      end

      [{
        period: { label: "weekly", value: 1 },
        pscharge: 99,
        description: "under soft max (100)",
      },
       {
         period: { label: "monthly", value: 4 },
         pscharge: 400,
         description: "under soft max (100)",
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         pscharge: 199,
         description: "under soft max (100)",
       },
       {
         period: { label: "weekly", value: 1 },
         pscharge: 701,
         description: "over hard max (700)",
       },
       {
         period: { label: "monthly", value: 4 },
         pscharge: 3034,
         description: "over hard max (700)",
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         pscharge: 1401,
         description: "over hard max (700)",
       }].each do |test_case|
        it "returns false if pscharge is #{test_case[:description]} for supported housing #{test_case[:period][:label]}" do
          record.pscharge = test_case[:pscharge]
          record.needstype = 2
          record.period = test_case[:period][:value]

          expect(record).not_to be_pscharge_in_soft_max_range
        end
      end

      [{
        period: { label: "weekly", value: 1 },
        pscharge: 36,
      },
       {
         period: { label: "monthly", value: 4 },
         pscharge: 180,
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         pscharge: 71,
       }].each do |test_case|
        it "returns true if pscharge is over soft max for general needs #{test_case[:period][:label]} (35)" do
          record.pscharge = test_case[:pscharge]
          record.needstype = 1
          record.period = test_case[:period][:value]

          expect(record).to be_pscharge_in_soft_max_range
        end
      end

      [{
        period: { label: "weekly", value: 1 },
        pscharge: 101,
      },
       {
         period: { label: "monthly", value: 4 },
         pscharge: 450,
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         pscharge: 201,
       }].each do |test_case|
        it "returns true if pscharge is over soft max for supported housing #{test_case[:period][:label]} (100)" do
          record.pscharge = test_case[:pscharge]
          record.needstype = 2
          record.period = test_case[:period][:value]

          expect(record).to be_pscharge_in_soft_max_range
        end
      end
    end

    context "and organisation is LA" do
      before do
        record.owning_organisation.update(provider_type: "LA")
      end

      it "returns false if pscharge is not given" do
        record.pscharge = nil
        record.needstype = 1
        record.period = 1

        expect(record).not_to be_pscharge_in_soft_max_range
      end

      it "returns false if period is not given" do
        record.pscharge = 201
        record.needstype = 1
        record.period = nil

        expect(record).not_to be_pscharge_in_soft_max_range
      end

      [{
        period: { label: "weekly", value: 1 },
        pscharge: 24,
        description: "under soft max (25)",
      },
       {
         period: { label: "monthly", value: 4 },
         pscharge: 88,
         description: "under soft max (25)",
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         pscharge: 49,
         description: "under soft max (25)",
       },
       {
         period: { label: "weekly", value: 1 },
         pscharge: 201,
         description: "over hard max (200)",
       },
       {
         period: { label: "monthly", value: 4 },
         pscharge: 867,
         description: "over hard max (200)",
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         pscharge: 401,
         description: "over hard max (200)",
       }].each do |test_case|
        it "returns false if pscharge is #{test_case[:description]} for general needs #{test_case[:period][:label]}" do
          record.pscharge = test_case[:pscharge]
          record.needstype = 1
          record.period = test_case[:period][:value]

          expect(record).not_to be_pscharge_in_soft_max_range
        end
      end

      [{
        period: { label: "weekly", value: 1 },
        pscharge: 74,
        description: "under soft max (75)",
      },
       {
         period: { label: "monthly", value: 4 },
         pscharge: 250,
         description: "under soft max (75)",
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         pscharge: 149,
         description: "under soft max (75)",
       },
       {
         period: { label: "weekly", value: 1 },
         pscharge: 201,
         description: "over hard max (200)",
       },
       {
         period: { label: "monthly", value: 4 },
         pscharge: 867,
         description: "over hard max (200)",
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         pscharge: 401,
         description: "over hard max (200)",
       }].each do |test_case|
        it "returns false if pscharge is #{test_case[:description]} for supported housing #{test_case[:period][:label]}" do
          record.pscharge = test_case[:pscharge]
          record.needstype = 2
          record.period = test_case[:period][:value]

          expect(record).not_to be_pscharge_in_soft_max_range
        end
      end

      [{
        period: { label: "weekly", value: 1 },
        pscharge: 26,
      },
       {
         period: { label: "monthly", value: 4 },
         pscharge: 120,
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         pscharge: 51,
       }].each do |test_case|
        it "returns true if pscharge is over soft max for general needs #{test_case[:period][:label]} (25)" do
          record.pscharge = test_case[:pscharge]
          record.needstype = 1
          record.period = test_case[:period][:value]

          expect(record).to be_pscharge_in_soft_max_range
        end
      end

      [{
        period: { label: "weekly", value: 1 },
        pscharge: 76,
      },
       {
         period: { label: "monthly", value: 4 },
         pscharge: 350,
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         pscharge: 151,
       }].each do |test_case|
        it "returns true if pscharge is over soft max for supported housing #{test_case[:period][:label]} (75)" do
          record.pscharge = test_case[:pscharge]
          record.needstype = 2
          record.period = test_case[:period][:value]

          expect(record).to be_pscharge_in_soft_max_range
        end
      end
    end
  end

  describe "supcharg_in_soft_max_range?" do
    context "and organisation is PRP" do
      before do
        record.owning_organisation.update(provider_type: "PRP")
      end

      it "returns false if supcharg is not given" do
        record.supcharg = nil
        record.needstype = 1
        record.period = 1

        expect(record).not_to be_supcharg_in_soft_max_range
      end

      it "returns false if period is not given" do
        record.supcharg = 201
        record.needstype = 1
        record.period = nil

        expect(record).not_to be_supcharg_in_soft_max_range
      end

      [{
        period: { label: "weekly", value: 1 },
        supcharg: 34,
        description: "under soft max (35)",
      },
       {
         period: { label: "monthly", value: 4 },
         supcharg: 100,
         description: "under soft max (35)",
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         supcharg: 69,
         description: "under soft max (35)",
       },
       {
         period: { label: "weekly", value: 1 },
         supcharg: 801,
         description: "over hard max (800)",
       },
       {
         period: { label: "monthly", value: 4 },
         supcharg: 3467,
         description: "over hard max (800)",
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         supcharg: 1601,
         description: "over hard max (800)",
       }].each do |test_case|
        it "returns false if supcharg is #{test_case[:description]} for general needs #{test_case[:period][:label]}" do
          record.supcharg = test_case[:supcharg]
          record.needstype = 1
          record.period = test_case[:period][:value]

          expect(record).not_to be_supcharg_in_soft_max_range
        end
      end

      [{
        period: { label: "weekly", value: 1 },
        supcharg: 84,
        description: "under soft max (85)",
      },
       {
         period: { label: "monthly", value: 4 },
         supcharg: 320,
         description: "under soft max (85)",
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         supcharg: 169,
         description: "under soft max (85)",
       },
       {
         period: { label: "weekly", value: 1 },
         supcharg: 801,
         description: "over hard max (800)",
       },
       {
         period: { label: "monthly", value: 4 },
         supcharg: 3467,
         description: "over hard max (800)",
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         supcharg: 1601,
         description: "over hard max (800)",
       }].each do |test_case|
        it "returns false if supcharg is #{test_case[:description]} for supported housing #{test_case[:period][:label]}" do
          record.supcharg = test_case[:supcharg]
          record.needstype = 2
          record.period = test_case[:period][:value]

          expect(record).not_to be_supcharg_in_soft_max_range
        end
      end

      [{
        period: { label: "weekly", value: 1 },
        supcharg: 36,
      },
       {
         period: { label: "monthly", value: 4 },
         supcharg: 180,
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         supcharg: 71,
       }].each do |test_case|
        it "returns true if supcharg is over soft max for general needs #{test_case[:period][:label]} (35)" do
          record.supcharg = test_case[:supcharg]
          record.needstype = 1
          record.period = test_case[:period][:value]

          expect(record).to be_supcharg_in_soft_max_range
        end
      end

      [{
        period: { label: "weekly", value: 1 },
        supcharg: 86,
      },
       {
         period: { label: "monthly", value: 4 },
         supcharg: 400,
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         supcharg: 171,
       }].each do |test_case|
        it "returns true if supcharg is over soft max for supported housing #{test_case[:period][:label]} (85)" do
          record.supcharg = test_case[:supcharg]
          record.needstype = 2
          record.period = test_case[:period][:value]

          expect(record).to be_supcharg_in_soft_max_range
        end
      end
    end

    context "and organisation is LA" do
      before do
        record.owning_organisation.update(provider_type: "LA")
      end

      it "returns false if supcharg is not given" do
        record.supcharg = nil
        record.needstype = 1
        record.period = 1

        expect(record).not_to be_supcharg_in_soft_max_range
      end

      it "returns false if period is not given" do
        record.supcharg = 201
        record.needstype = 1
        record.period = nil

        expect(record).not_to be_supcharg_in_soft_max_range
      end

      [{
        period: { label: "weekly", value: 1 },
        supcharg: 24,
        description: "under soft max (25)",
      },
       {
         period: { label: "monthly", value: 4 },
         supcharg: 88,
         description: "under soft max (25)",
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         supcharg: 49,
         description: "under soft max (25)",
       },
       {
         period: { label: "weekly", value: 1 },
         supcharg: 201,
         description: "over hard max (200)",
       },
       {
         period: { label: "monthly", value: 4 },
         supcharg: 867,
         description: "over hard max (200)",
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         supcharg: 401,
         description: "over hard max (200)",
       }].each do |test_case|
        it "returns false if supcharg is #{test_case[:description]} for general needs #{test_case[:period][:label]}" do
          record.supcharg = test_case[:supcharg]
          record.needstype = 1
          record.period = test_case[:period][:value]

          expect(record).not_to be_supcharg_in_soft_max_range
        end
      end

      [{
        period: { label: "weekly", value: 1 },
        supcharg: 74,
        description: "under soft max (75)",
      },
       {
         period: { label: "monthly", value: 4 },
         supcharg: 250,
         description: "under soft max (75)",
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         supcharg: 149,
         description: "under soft max (75)",
       },
       {
         period: { label: "weekly", value: 1 },
         supcharg: 201,
         description: "over hard max (200)",
       },
       {
         period: { label: "monthly", value: 4 },
         supcharg: 867,
         description: "over hard max (200)",
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         supcharg: 401,
         description: "over hard max (200)",
       }].each do |test_case|
        it "returns false if supcharg is #{test_case[:description]} for supported housing #{test_case[:period][:label]}" do
          record.supcharg = test_case[:supcharg]
          record.needstype = 2
          record.period = test_case[:period][:value]

          expect(record).not_to be_supcharg_in_soft_max_range
        end
      end

      [{
        period: { label: "weekly", value: 1 },
        supcharg: 26,
      },
       {
         period: { label: "monthly", value: 4 },
         supcharg: 120,
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         supcharg: 51,
       }].each do |test_case|
        it "returns true if supcharg is over soft max for general needs #{test_case[:period][:label]} (25)" do
          record.supcharg = test_case[:supcharg]
          record.needstype = 1
          record.period = test_case[:period][:value]

          expect(record).to be_supcharg_in_soft_max_range
        end
      end

      [{
        period: { label: "weekly", value: 1 },
        supcharg: 76,
      },
       {
         period: { label: "monthly", value: 4 },
         supcharg: 350,
       },
       {
         period: { label: "every 2 weeks", value: 2 },
         supcharg: 151,
       }].each do |test_case|
        it "returns true if supcharg is over soft max for supported housing #{test_case[:period][:label]} (75)" do
          record.supcharg = test_case[:supcharg]
          record.needstype = 2
          record.period = test_case[:period][:value]

          expect(record).to be_supcharg_in_soft_max_range
        end
      end
    end
  end

  describe "reasonother_might_be_existing_category?" do
    it "returns true if reasonother is exactly in the 'likely existing category' list" do
      record.reasonother = "Domestic Abuse"

      expect(record).to be_reasonother_might_be_existing_category
    end

    it "returns true if any word of reasonother is exactly in the 'likely existing category' list" do
      record.reasonother = "Was decanted from somewhere"

      expect(record).to be_reasonother_might_be_existing_category
    end

    it "is not case sensitive when matching" do
      record.reasonother = "domestic abuse"

      expect(record).to be_reasonother_might_be_existing_category
    end

    it "returns false if no part of reasonother is in the 'likely existing category' list" do
      record.reasonother = "other"

      expect(record).not_to be_reasonother_might_be_existing_category
    end

    it "returns false if match to the 'likely existing category' list is only part of a word" do
      record.reasonother = "wasdecanted"

      expect(record).not_to be_reasonother_might_be_existing_category
    end

    it "ignores neighbouring non-alphabet for matching" do
      record.reasonother = "1Domestic abuse."

      expect(record).to be_reasonother_might_be_existing_category
    end
  end

  describe "at_least_one_working_situation_is_sickness_and_household_sickness_is_no" do
    it "returns true if one person has working situation as illness and household sickness is no" do
      record.illness = 2
      record.hhmemb = 2
      record.ecstat1 = 8
      record.ecstat2 = 1

      expect(record.at_least_one_working_situation_is_sickness_and_household_sickness_is_no?).to be true
    end

    it "returns true if all people has working situation as illness and household sickness is no" do
      record.illness = 2
      record.hhmemb = 2
      record.ecstat1 = 8
      record.ecstat2 = 8

      expect(record.at_least_one_working_situation_is_sickness_and_household_sickness_is_no?).to be true
    end

    it "returns false if household sickness is yes" do
      record.illness = 1
      record.hhmemb = 2
      record.ecstat1 = 8
      record.ecstat2 = 1

      expect(record.at_least_one_working_situation_is_sickness_and_household_sickness_is_no?).to be false
    end

    it "returns false if no working situation is illness" do
      record.illness = 2
      record.hhmemb = 2
      record.ecstat1 = 1
      record.ecstat2 = 1

      expect(record.at_least_one_working_situation_is_sickness_and_household_sickness_is_no?).to be false
    end
  end
end
