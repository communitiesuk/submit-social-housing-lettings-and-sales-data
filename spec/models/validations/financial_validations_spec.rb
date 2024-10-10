require "rails_helper"

RSpec.describe Validations::FinancialValidations do
  subject(:financial_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::FinancialValidations } }
  let(:record) { FactoryBot.create(:lettings_log) }
  let(:fake_2021_2022_form) { Form.new("spec/fixtures/forms/2021_2022.json") }

  before do
    allow(FormHandler.instance).to receive(:current_lettings_form).and_return(fake_2021_2022_form)
  end

  describe "earnings and income frequency" do
    it "when earnings are provided it validates that income frequency must be provided" do
      record.earnings = 500
      record.incfreq = nil
      financial_validator.validate_net_income(record)
      expect(record.errors["incfreq"])
        .to include(match I18n.t("validations.financial.earnings.freq_missing"))
      expect(record.errors["earnings"])
        .to include(match I18n.t("validations.financial.earnings.freq_missing"))
    end

    it "when income frequency is provided it validates that earnings must be provided" do
      record.earnings = nil
      record.incfreq = 1
      financial_validator.validate_net_income(record)
      expect(record.errors["earnings"])
        .to include(match I18n.t("validations.financial.earnings.earnings_missing"))
      expect(record.errors["incfreq"])
        .to include(match I18n.t("validations.financial.earnings.earnings_missing"))
    end
  end

  describe "benefits proportion validations" do
    context "when the proportion is all" do
      it "validates that the lead tenant is not in full time employment" do
        record.benefits = 0
        record.ecstat1 = 1
        financial_validator.validate_net_income_uc_proportion(record)
        expect(record.errors["benefits"]).to include(match I18n.t("validations.financial.benefits.part_or_full_time"))
      end

      it "validates that the lead tenant is not in part time employment" do
        record.benefits = 0
        record.ecstat1 = 0
        financial_validator.validate_net_income_uc_proportion(record)
        expect(record.errors["benefits"]).to include(match I18n.t("validations.financial.benefits.part_or_full_time"))
      end

      it "expects that the lead tenant is not in full-time or part-time employment" do
        record.benefits = 0
        record.ecstat1 = 4
        financial_validator.validate_net_income_uc_proportion(record)
        expect(record.errors["benefits"]).to be_empty
      end

      it "validates that the tenant’s partner is not in full time employment" do
        record.benefits = 0
        record.ecstat2 = 0
        record.relat2 = "P"
        financial_validator.validate_net_income_uc_proportion(record)
        expect(record.errors["benefits"]).to include(match I18n.t("validations.financial.benefits.part_or_full_time"))
      end

      it "expects that the tenant’s partner is not in full-time or part-time employment" do
        record.benefits = 0
        record.ecstat2 = 4
        record.relat2 = "P"
        financial_validator.validate_net_income_uc_proportion(record)
        expect(record.errors["benefits"]).to be_empty
      end
    end
  end

  describe "outstanding rent amount validations" do
    context "when outstanding rent or charges is no" do
      it "validates that no shortfall is provided" do
        record.hbrentshortfall = 2
        record.tshortfall = 99
        financial_validator.validate_outstanding_rent_amount(record)
        expect(record.errors["tshortfall"])
          .to include(match I18n.t("validations.financial.tshortfall.outstanding_amount_not_expected"))
      end
    end

    context "when outstanding rent or charges is yes" do
      let(:record) { FactoryBot.create(:lettings_log, :setup_completed, startdate: Time.zone.now) }

      it "expects that a shortfall is provided" do
        record.hbrentshortfall = 1
        record.tshortfall = 99
        financial_validator.validate_outstanding_rent_amount(record)
        expect(record.errors["tshortfall"]).to be_empty
      end

      it "validates that the shortfall is a positive £ amount" do
        record.hb = 6
        record.hbrentshortfall = 1
        record.tshortfall_known = 0
        record.tshortfall = 0
        record.period = 2
        record.set_derived_fields!
        financial_validator.validate_rent_amount(record)
        expect(record.errors["tshortfall"])
          .to include(match I18n.t("validations.financial.tshortfall.must_be_positive"))
      end

      it "validates that total charge is no less than the shortfall" do
        record.hb = 6
        record.hbrentshortfall = 1
        record.tshortfall_known = 0
        record.tshortfall = 299.50
        record.brent = 198
        record.scharge = 50
        record.period = 2
        record.set_derived_fields!
        financial_validator.validate_rent_amount(record)
        expect(record.errors["tcharge"])
          .to include(match I18n.t("validations.financial.tcharge.less_than_shortfall"))
        expect(record.errors["tshortfall"])
          .to include(match I18n.t("validations.financial.tshortfall.more_than_total_charge"))
      end

      it "validates that carehome charge is no less than the shortfall" do
        record.hb = 6
        record.hbrentshortfall = 1
        record.tshortfall_known = 0
        record.tshortfall = 299.50
        record.chcharge = 198
        record.needstype = 2
        record.period = 2
        record.set_derived_fields!
        financial_validator.validate_rent_amount(record)
        expect(record.errors["chcharge"])
          .to include(match I18n.t("validations.financial.carehome.less_than_shortfall"))
        expect(record.errors["tshortfall"])
          .to include(match I18n.t("validations.financial.tshortfall.more_than_carehome_charge"))
      end

      it "expects that rent can be less than the shortfall if total charge is higher" do
        record.hb = 6
        record.hbrentshortfall = 1
        record.tshortfall_known = 0
        record.tshortfall = 299.50
        record.brent = 198
        record.scharge = 102
        record.period = 2
        record.set_derived_fields!
        financial_validator.validate_rent_amount(record)
        expect(record.errors).to be_empty
      end
    end
  end

  describe "rent period validations" do
    let(:organisation) { create(:organisation) }
    let(:user) { create(:user, organisation:) }
    let(:record) { create(:lettings_log, owning_organisation: organisation, managing_organisation: organisation, assigned_to: user) }
    let(:used_period) { 2 }

    before do
      create(:organisation_rent_period, organisation:, rent_period: used_period)
      record.period = period
    end

    context "when the log uses a period that the org allows" do
      let(:period) { used_period }

      it "does not apply a validation" do
        financial_validator.validate_rent_period(record)
        expect(record.errors["period"]).to be_empty
      end
    end

    context "when the log uses a period that the org does not allow" do
      let(:period) { used_period + 1 }

      it "does apply a validation" do
        financial_validator.validate_rent_period(record)
        expect(record.errors["period"])
          .to include(match I18n.t(
            "validations.financial.rent_period.invalid_for_org.period",
            org_name: user.organisation.name,
            rent_period: "every 4 weeks",
          ))
        expect(record.errors["managing_organisation_id"])
          .to include(match I18n.t(
            "validations.financial.rent_period.invalid_for_org.managing_org",
            org_name: user.organisation.name,
            rent_period: "every 4 weeks",
          ))
      end
    end
  end

  describe "housing benefit rent shortfall validations" do
    before { record.startdate = Time.zone.local(2022, 5, 1) }

    context "when shortfall is yes" do
      it "validates that housing benefit is not none" do
        record.hbrentshortfall = 1
        record.hb = 9
        financial_validator.validate_tshortfall(record)
        expect(record.errors["tshortfall"])
          .to include(match I18n.t("validations.financial.hbrentshortfall.outstanding_no_benefits"))
      end

      it "validates that housing benefit is not don't know" do
        record.hbrentshortfall = 1
        record.hb = 3
        financial_validator.validate_tshortfall(record)
        expect(record.errors["tshortfall"])
          .to include(match I18n.t("validations.financial.hbrentshortfall.outstanding_no_benefits"))
      end

      it "validates that housing benefit is not Universal Credit without housing benefit (prior to 22/23)" do
        record.startdate = Time.zone.local(2022, 3, 1)
        record.hbrentshortfall = 1
        record.hb = 7
        financial_validator.validate_tshortfall(record)
        expect(record.errors["tshortfall"])
          .to include(match I18n.t("validations.financial.hbrentshortfall.outstanding_no_benefits"))
      end

      it "validates that housing benefit is provided" do
        record.hbrentshortfall = 1
        record.hb = 1
        financial_validator.validate_tshortfall(record)
        expect(record.errors["tshortfall"]).to be_empty
      end
    end
  end

  describe "net income validations" do
    it "validates that the net income is within the expected range for the household’s employment status" do
      record.startdate = Time.zone.local(2023, 5, 1)
      record.earnings = 200
      record.incfreq = 1
      record.hhmemb = 1
      record.ecstat1 = 1
      financial_validator.validate_net_income(record)
      expect(record.errors["earnings"]).to be_empty
    end

    context "when the net income is higher than the hard max for their employment status" do
      it "adds an error" do
        record.startdate = Time.zone.local(2023, 5, 1)
        record.earnings = 5000
        record.incfreq = 1
        record.hhmemb = 1
        record.ecstat1 = 1
        financial_validator.validate_net_income(record)
        expect(record.errors["earnings"])
          .to eq(["The household’s income cannot be greater than £1,230.00 per week given the household’s working situation."])
        expect(record.errors["ecstat1"])
          .to eq(["The household’s income of £5,000.00 weekly is too high given the household’s working situation."])
        expect(record.errors["hhmemb"])
          .to eq(["The household’s income of £5,000.00 weekly is too high for this number of tenants. Change either the household income or number of tenants."])
      end
    end

    context "when the net income is lower than the hard min for their employment status" do
      it "adds an error" do
        record.startdate = Time.zone.local(2023, 5, 1)
        record.earnings = 50
        record.incfreq = 1
        record.hhmemb = 1
        record.ecstat1 = 1
        financial_validator.validate_net_income(record)
        expect(record.errors["earnings"])
          .to eq(["The household’s income cannot be less than £90.00 per week given the household’s working situation."])
        expect(record.errors["ecstat1"])
          .to eq(["The household’s income of £50.00 weekly is too low given the household’s working situation."])
        expect(record.errors["hhmemb"])
          .to eq(["The household’s income of £50.00 weekly is too low for this number of tenants. Change either the household income or number of tenants."])
      end
    end

    context "when there is more than one household member" do
      it "allows income levels based on all working situations combined" do
        record.startdate = Time.zone.local(2023, 5, 1)
        record.earnings = 5000
        record.incfreq = 1
        record.hhmemb = 4
        record.ecstat1 = 1
        record.ecstat2 = 1
        record.ecstat3 = 8
        record.ecstat4 = 9
        financial_validator.validate_net_income(record)
        expect(record.errors["earnings"]).to be_empty
      end

      it "uses the combined value in error messages" do
        record.startdate = Time.zone.local(2023, 5, 1)
        record.earnings = 100
        record.incfreq = 1
        record.hhmemb = 3
        record.ecstat1 = 1
        record.ecstat2 = 2
        record.ecstat3 = 9
        financial_validator.validate_net_income(record)
        expect(record.errors["earnings"])
          .to eq(["The household’s income cannot be less than £150.00 per week given the household’s working situation."])
      end

      it "adds errors to relevant fields for each tenant when income is too high" do
        record.startdate = Time.zone.local(2023, 5, 1)
        record.earnings = 5000
        record.incfreq = 1
        record.hhmemb = 3
        record.ecstat1 = 1
        record.ecstat2 = 2
        record.age3 = 12
        record.ecstat3 = 9
        financial_validator.validate_net_income(record)
        (1..record.hhmemb).each do |n|
          expect(record.errors["ecstat#{n}"])
            .to eq(["The household’s income of £5,000.00 weekly is too high given the household’s working situation."])
        end
        expect(record.errors["age1"]).to be_empty
        expect(record.errors["age2"]).to be_empty
        expect(record.errors["age3"])
          .to eq(["The household’s income of £5,000.00 weekly is too high for the number of adults. Change either the household income or the age of the tenants."])
        (record.hhmemb + 1..8).each do |n|
          expect(record.errors["ecstat#{n}"]).to be_empty
          expect(record.errors["age#{n}"]).to be_empty
        end
      end

      it "adds errors to relevant fields for each tenant when income is too low" do
        record.startdate = Time.zone.local(2023, 5, 1)
        record.earnings = 50
        record.incfreq = 1
        record.hhmemb = 3
        record.ecstat1 = 1
        record.ecstat2 = 2
        record.age3 = 12
        record.ecstat3 = 9
        financial_validator.validate_net_income(record)
        (1..record.hhmemb).each do |n|
          expect(record.errors["ecstat#{n}"])
            .to eq(["The household’s income of £50.00 weekly is too low given the household’s working situation."])
        end
        (record.hhmemb + 1..8).each do |n|
          expect(record.errors["ecstat#{n}"]).to be_empty
        end
      end

      context "when the net income is lower than the hard min for their employment status for 22/23 collection" do
        it "does not add an error" do
          record.startdate = Time.zone.local(2022, 5, 1)
          record.earnings = 50
          record.incfreq = 1
          record.hhmemb = 1
          record.ecstat1 = 1
          financial_validator.validate_net_income(record)
          expect(record.errors["earnings"]).to be_empty
          expect(record.errors["ecstat1"]).to be_empty
          expect(record.errors["hhmemb"]).to be_empty
        end
      end
    end
  end

  describe "financial validations" do
    context "when currency is negative" do
      it "returns error" do
        record.earnings = -8
        record.brent = -2
        record.scharge = -134
        record.pscharge = -10_024
        record.supcharg = -1

        financial_validator.validate_negative_currency(record)
        expect(record.errors["earnings"])
          .to include(match I18n.t("validations.financial.negative_currency"))
        expect(record.errors["brent"])
          .to include(match I18n.t("validations.financial.negative_currency"))
        expect(record.errors["scharge"])
          .to include(match I18n.t("validations.financial.negative_currency"))
        expect(record.errors["pscharge"])
          .to include(match I18n.t("validations.financial.negative_currency"))
        expect(record.errors["supcharg"])
          .to include(match I18n.t("validations.financial.negative_currency"))
      end
    end

    context "when the field allows decimals" do
      it "correctly co-erces values" do
        record.brent = "20"
        record.pscharge = "0.0"
        record.period = "2"
        financial_validator.validate_numeric_min_max(record)
        expect(record.errors["pscharge"]).to be_empty
      end
    end
  end

  describe "rent and charges validations" do
    let!(:location) { FactoryBot.create(:location, location_code: "E07000223") }

    context "when the owning organisation is a private registered provider" do
      before { record.owning_organisation.provider_type = 2 }

      context "when needstype is general needs" do
        before { record.needstype = 1 }

        [{
          period: { label: "weekly for 52 weeks", value: 1 },
          charge: { field: "scharge", value: 801 },
          charge_name: "service charge",
          maximum_per_period: "£800.00",
        },
         {
           period: { label: "every calendar month", value: 4 },
           charge: { field: "scharge", value: 3471 },
           charge_name: "service charge",
           maximum_per_period: "£3,466.00",
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "scharge", value: 1601 },
           charge_name: "service charge",
           maximum_per_period: "£1,600.00",
         },
         {
           period: { label: "weekly for 52 weeks", value: 1 },
           charge: { field: "pscharge", value: 701 },
           charge_name: "personal service charge",
           maximum_per_period: "£700.00",
         },
         {
           period: { label: "every calendar month", value: 4 },
           charge: { field: "pscharge", value: 3200 },
           charge_name: "personal service charge",
           maximum_per_period: "£3,033.00",
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "pscharge", value: 1401 },
           charge_name: "personal service charge",
           maximum_per_period: "£1,400.00",
         },
         {
           period: { label: "weekly for 52 weeks", value: 1 },
           charge: { field: "supcharg", value: 801 },
           charge_name: "support charge",
           maximum_per_period: "£800.00",
         },
         {
           period: { label: "every calendar month", value: 4 },
           charge: { field: "supcharg", value: 3471 },
           charge_name: "support charge",
           maximum_per_period: "£3,466.00",
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "supcharg", value: 1601 },
           charge_name: "support charge",
           maximum_per_period: "£1,600.00",
         }].each do |test_case|
          it "does not allow charges outside the range when period is #{test_case[:period][:label]}" do
            record.period = test_case[:period][:value]
            record[test_case[:charge][:field]] = test_case[:charge][:value]
            financial_validator.validate_rent_amount(record)
            expect(record.errors[test_case[:charge][:field]])
              .to include(match I18n.t("validations.financial.rent.out_of_range", charge_name: test_case[:charge_name], maximum_per_period: test_case[:maximum_per_period], frequency: test_case[:period][:label], letting_type: "general needs", provider_type: "private registered provider"))
          end
        end

        [{
          period: { label: "weekly for 52 weeks", value: 1 },
          charge: { field: "scharge", value: 799 },
        },
         {
           period: { label: "every calendar month", value: 4 },
           charge: { field: "scharge", value: 3400 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "scharge", value: 1599 },
         },
         {
           period: { label: "weekly for 52 weeks", value: 1 },
           charge: { field: "pscharge", value: 699 },
         },
         {
           period: { label: "every calendar month", value: 4 },
           charge: { field: "pscharge", value: 2500 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "pscharge", value: 1399 },
         },
         {
           period: { label: "weekly for 52 weeks", value: 1 },
           charge: { field: "supcharg", value: 799 },
         },
         {
           period: { label: "every calendar month", value: 4 },
           charge: { field: "supcharg", value: 3000 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "supcharg", value: 1599 },
         }].each do |test_case|
          it "does allow charges inside the range when period is #{test_case[:period][:label]}" do
            record.period = test_case[:period][:value]
            record[test_case[:charge][:field]] = test_case[:charge][:value]
            financial_validator.validate_rent_amount(record)
            expect(record.errors[test_case[:charge][:field]])
              .to be_empty
          end
        end
      end

      context "when needstype is supported housing" do
        before { record.needstype = 2 }

        [{
          period: { label: "weekly for 52 weeks", value: 1 },
          charge: { field: "scharge", value: 801 },
          charge_name: "service charge",
          maximum_per_period: "£800.00",
        },
         {
           period: { label: "every calendar month", value: 4 },
           charge: { field: "scharge", value: 3471 },
           charge_name: "service charge",
           maximum_per_period: "£3,466.00",
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "scharge", value: 1601 },
           charge_name: "service charge",
           maximum_per_period: "£1,600.00",
         },
         {
           period: { label: "weekly for 52 weeks", value: 1 },
           charge: { field: "pscharge", value: 701 },
           charge_name: "personal service charge",
           maximum_per_period: "£700.00",
         },
         {
           period: { label: "every calendar month", value: 4 },
           charge: { field: "pscharge", value: 3200 },
           charge_name: "personal service charge",
           maximum_per_period: "£3,033.00",
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "pscharge", value: 1401 },
           charge_name: "personal service charge",
           maximum_per_period: "£1,400.00",
         },
         {
           period: { label: "weekly for 52 weeks", value: 1 },
           charge: { field: "supcharg", value: 801 },
           charge_name: "support charge",
           maximum_per_period: "£800.00",
         },
         {
           period: { label: "every calendar month", value: 4 },
           charge: { field: "supcharg", value: 3471 },
           charge_name: "support charge",
           maximum_per_period: "£3,466.00",
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "supcharg", value: 1601 },
           charge_name: "support charge",
           maximum_per_period: "£1,600.00",
         }].each do |test_case|
          it "does not allow charges outside the range when period is #{test_case[:period][:label]}" do
            record.period = test_case[:period][:value]
            record[test_case[:charge][:field]] = test_case[:charge][:value]
            financial_validator.validate_rent_amount(record)
            expect(record.errors[test_case[:charge][:field]])
              .to include(match I18n.t("validations.financial.rent.out_of_range", charge_name: test_case[:charge_name], maximum_per_period: test_case[:maximum_per_period], frequency: test_case[:period][:label], letting_type: "supported housing", provider_type: "private registered provider"))
          end
        end

        [{
          period: { label: "weekly for 52 weeks", value: 1 },
          charge: { field: "scharge", value: 799 },
        },
         {
           period: { label: "every calendar month", value: 4 },
           charge: { field: "scharge", value: 3400 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "scharge", value: 1599 },
         },
         {
           period: { label: "weekly for 52 weeks", value: 1 },
           charge: { field: "pscharge", value: 699 },
         },
         {
           period: { label: "every calendar month", value: 4 },
           charge: { field: "pscharge", value: 2500 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "pscharge", value: 1399 },
         },
         {
           period: { label: "weekly for 52 weeks", value: 1 },
           charge: { field: "supcharg", value: 799 },
         },
         {
           period: { label: "every calendar month", value: 4 },
           charge: { field: "supcharg", value: 3400 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "supcharg", value: 1599 },
         }].each do |test_case|
          it "does allow charges inside the range when period is #{test_case[:period][:label]}" do
            record.period = test_case[:period][:value]
            record[test_case[:charge][:field]] = test_case[:charge][:value]
            financial_validator.validate_rent_amount(record)
            expect(record.errors[test_case[:charge][:field]])
              .to be_empty
          end
        end
      end
    end

    context "when the owning organisation is a local authority" do
      before { record.owning_organisation.provider_type = 1 }

      context "when needstype is general needs" do
        before { record.needstype = 1 }

        [{
          period: { label: "weekly for 52 weeks", value: 1 },
          charge: { field: "scharge", value: 501 },
          charge_name: "service charge",
          maximum_per_period: "£500.00",
        },
         {
           period: { label: "every calendar month", value: 4 },
           charge: { field: "scharge", value: 2300 },
           charge_name: "service charge",
           maximum_per_period: "£2,166.00",
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "scharge", value: 1001 },
           charge_name: "service charge",
           maximum_per_period: "£1,000.00",
         },
         {
           period: { label: "weekly for 52 weeks", value: 1 },
           charge: { field: "pscharge", value: 201 },
           charge_name: "personal service charge",
           maximum_per_period: "£200.00",
         },
         {
           period: { label: "every calendar month", value: 4 },
           charge: { field: "pscharge", value: 1000 },
           charge_name: "personal service charge",
           maximum_per_period: "£866.00",
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "pscharge", value: 401 },
           charge_name: "personal service charge",
           maximum_per_period: "£400.00",
         },
         {
           period: { label: "weekly for 52 weeks", value: 1 },
           charge: { field: "supcharg", value: 201 },
           charge_name: "support charge",
           maximum_per_period: "£200.00",
         },
         {
           period: { label: "every calendar month", value: 4 },
           charge: { field: "supcharg", value: 1000 },
           charge_name: "support charge",
           maximum_per_period: "£866.00",
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "supcharg", value: 401 },
           charge_name: "support charge",
           maximum_per_period: "£400.00",
         }].each do |test_case|
          it "does not allow charges outside the range when period is #{test_case[:period][:label]}" do
            record.period = test_case[:period][:value]
            record[test_case[:charge][:field]] = test_case[:charge][:value]
            financial_validator.validate_rent_amount(record)
            expect(record.errors[test_case[:charge][:field]])
              .to include(match I18n.t("validations.financial.rent.out_of_range", charge_name: test_case[:charge_name], maximum_per_period: test_case[:maximum_per_period], frequency: test_case[:period][:label], letting_type: "general needs", provider_type: "local authority"))
          end
        end

        [{
          period: { label: "weekly for 52 weeks", value: 1 },
          charge: { field: "scharge", value: 499 },
        },
         {
           period: { label: "every calendar month", value: 4 },
           charge: { field: "scharge", value: 2000 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "scharge", value: 999 },
         },
         {
           period: { label: "weekly for 52 weeks", value: 1 },
           charge: { field: "pscharge", value: 199 },
         },
         {
           period: { label: "every calendar month", value: 4 },
           charge: { field: "pscharge", value: 800 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "pscharge", value: 399 },
         },
         {
           period: { label: "weekly for 52 weeks", value: 1 },
           charge: { field: "supcharg", value: 199.99 },
         },
         {
           period: { label: "every calendar month", value: 4 },
           charge: { field: "supcharg", value: 800 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "supcharg", value: 399 },
         }].each do |test_case|
          it "does allow charges inside the range when period is #{test_case[:period][:label]}" do
            record.period = test_case[:period][:value]
            record[test_case[:charge][:field]] = test_case[:charge][:value]
            financial_validator.validate_rent_amount(record)
            expect(record.errors[test_case[:charge][:field]])
              .to be_empty
          end
        end
      end

      context "when needstype is supported housing" do
        before { record.needstype = 2 }

        [{
          period: { label: "weekly for 52 weeks", value: 1 },
          charge: { field: "scharge", value: 501 },
          charge_name: "service charge",
          maximum_per_period: "£500.00",
        },
         {
           period: { label: "every calendar month", value: 4 },
           charge: { field: "scharge", value: 2300 },
           charge_name: "service charge",
           maximum_per_period: "£2,166.00",
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "scharge", value: 1001 },
           charge_name: "service charge",
           maximum_per_period: "£1,000.00",
         },
         {
           period: { label: "weekly for 52 weeks", value: 1 },
           charge: { field: "pscharge", value: 201 },
           charge_name: "personal service charge",
           maximum_per_period: "£200.00",
         },
         {
           period: { label: "every calendar month", value: 4 },
           charge: { field: "pscharge", value: 1000 },
           charge_name: "personal service charge",
           maximum_per_period: "£866.00",
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "pscharge", value: 401 },
           charge_name: "personal service charge",
           maximum_per_period: "£400.00",
         },
         {
           period: { label: "weekly for 52 weeks", value: 1 },
           charge: { field: "supcharg", value: 201 },
           charge_name: "support charge",
           maximum_per_period: "£200.00",
         },
         {
           period: { label: "every calendar month", value: 4 },
           charge: { field: "supcharg", value: 1000 },
           charge_name: "support charge",
           maximum_per_period: "£866.00",
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "supcharg", value: 401 },
           charge_name: "support charge",
           maximum_per_period: "£400.00",
         }].each do |test_case|
          it "does not allow charges outside the range when period is #{test_case[:period][:label]}" do
            record.period = test_case[:period][:value]
            record[test_case[:charge][:field]] = test_case[:charge][:value]
            financial_validator.validate_rent_amount(record)
            expect(record.errors[test_case[:charge][:field]])
              .to include(match I18n.t("validations.financial.rent.out_of_range", charge_name: test_case[:charge_name], maximum_per_period: test_case[:maximum_per_period], frequency: test_case[:period][:label], letting_type: "supported housing", provider_type: "local authority"))
          end
        end

        context "when charges are not given" do
          [{
            period: { label: "weekly for 52 weeks", value: 1 },
            charge: { field: "scharge", value: nil },
          },
           {
             period: { label: "weekly for 52 weeks", value: 1 },
             charge: { field: "pscharge", value: nil },
           },
           {
             period: { label: "weekly for 52 weeks", value: 1 },
             charge: { field: "supcharg", value: nil },
           }].each do |test_case|
            it "does not error" do
              record.period = test_case[:period][:value]
              record[test_case[:charge][:field]] = test_case[:charge][:value]
              financial_validator.validate_rent_amount(record)
              expect(record.errors[test_case[:charge][:field]])
                .to be_empty
            end
          end
        end

        [{
          period: { label: "weekly for 52 weeks", value: 1 },
          charge: { field: "scharge", value: 499 },
        },
         {
           period: { label: "every calendar month", value: 4 },
           charge: { field: "scharge", value: 2000 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "scharge", value: 999 },
         },
         {
           period: { label: "weekly for 52 weeks", value: 1 },
           charge: { field: "pscharge", value: 199 },
         },
         {
           period: { label: "every calendar month", value: 4 },
           charge: { field: "pscharge", value: 800 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "pscharge", value: 399 },
         },
         {
           period: { label: "weekly for 52 weeks", value: 1 },
           charge: { field: "supcharg", value: 199.99 },
         },
         {
           period: { label: "every calendar month", value: 4 },
           charge: { field: "supcharg", value: 800 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "supcharg", value: 399 },
         }].each do |test_case|
          it "does allow charges inside the range when period is #{test_case[:period][:label]}" do
            record.period = test_case[:period][:value]
            record[test_case[:charge][:field]] = test_case[:charge][:value]
            financial_validator.validate_rent_amount(record)
            expect(record.errors[test_case[:charge][:field]])
              .to be_empty
          end
        end
      end

      context "when period is weekly" do
        it "validates that total charge is at least 10 per week" do
          record.period = 1
          record.tcharge = 9
          financial_validator.validate_rent_amount(record)
          expect(record.errors["tcharge"])
                .to include(match I18n.t("validations.financial.tcharge.under_10"))
        end

        it "allows the total charge to be over 10 per week" do
          record.period = 1
          record.tcharge = 10
          financial_validator.validate_rent_amount(record)
          expect(record.errors["tcharge"])
                .to be_empty
        end
      end

      context "when period is every 2 weeks" do
        it "validates that total charge is at least 10 per week" do
          record.period = 2
          record.tcharge = 19.99
          financial_validator.validate_rent_amount(record)
          expect(record.errors["tcharge"])
                .to include(match I18n.t("validations.financial.tcharge.under_10"))
        end

        it "allows the total charge to be over 10 per week" do
          record.period = 2
          record.tcharge = 20
          financial_validator.validate_rent_amount(record)
          expect(record.errors["tcharge"])
                .to be_empty
        end
      end

      context "when entering charges" do
        it "returns an error for 3 charge types selected" do
          record.tcharge = 19.99
          record.chcharge = 20
          record.household_charge = 1
          financial_validator.validate_rent_amount(record)
          expect(record.errors["tcharge"])
            .to include(match I18n.t("validations.financial.charges.complete_1_of_3"))
          expect(record.errors["chcharge"])
            .to include(match I18n.t("validations.financial.charges.complete_1_of_3"))
          expect(record.errors["household_charge"])
            .to include(match I18n.t("validations.financial.charges.complete_1_of_3"))
        end

        it "returns an error for tcharge and chcharge types selected" do
          record.tcharge = 19.99
          record.chcharge = 20
          financial_validator.validate_rent_amount(record)
          expect(record.errors["household_charge"])
            .to be_empty
          expect(record.errors["tcharge"])
            .to include(match I18n.t("validations.financial.charges.complete_1_of_3"))
          expect(record.errors["chcharge"])
            .to include(match I18n.t("validations.financial.charges.complete_1_of_3"))
        end

        it "returns an error for tcharge type and household_charge not paid selected" do
          record.tcharge = 19.99
          record.household_charge = 1
          financial_validator.validate_rent_amount(record)
          expect(record.errors["chcharge"])
            .to be_empty
          expect(record.errors["tcharge"])
            .to include(match I18n.t("validations.financial.charges.complete_1_of_3"))
          expect(record.errors["household_charge"])
            .to include(match I18n.t("validations.financial.charges.complete_1_of_3"))
        end

        it "returns an error for chcharge type and household_charge not paid selected" do
          record.chcharge = 20
          record.household_charge = 1
          financial_validator.validate_rent_amount(record)
          expect(record.errors["tcharge"])
            .to be_empty
          expect(record.errors["chcharge"])
            .to include(match I18n.t("validations.financial.charges.complete_1_of_3"))
          expect(record.errors["household_charge"])
            .to include(match I18n.t("validations.financial.charges.complete_1_of_3"))
        end
      end

      it "does not return an error for household_charge being no" do
        record.household_charge = 1
        financial_validator.validate_rent_amount(record)
        expect(record.errors["tcharge"])
          .to be_empty
        expect(record.errors["chcharge"])
          .to be_empty
        expect(record.errors["household_charge"])
          .to be_empty
      end

      it "does not return an error for chcharge being selected" do
        record.household_charge = 0
        record.chcharge = 20
        financial_validator.validate_rent_amount(record)
        expect(record.errors["tcharge"])
          .to be_empty
        expect(record.errors["chcharge"])
          .to be_empty
        expect(record.errors["household_charge"])
          .to be_empty
      end

      it "does not return an error for tcharge being selected" do
        record.household_charge = 0
        record.tcharge = 19.99
        financial_validator.validate_rent_amount(record)
        expect(record.errors["tcharge"])
          .to be_empty
        expect(record.errors["chcharge"])
          .to be_empty
        expect(record.errors["household_charge"])
          .to be_empty
      end

      context "when validating ranges based on LA and needstype" do
        before do
          LaRentRange.create!(
            ranges_rent_id: "1",
            la: "E07000223",
            beds: 4,
            lettype: 1,
            soft_min: 12.41,
            soft_max: 89.54,
            hard_min: 9.87,
            hard_max: 100.99,
            start_year: 2021,
          )
          LaRentRange.create!(
            ranges_rent_id: "2",
            la: "E07000223",
            beds: 0,
            lettype: 2,
            soft_min: 12.41,
            soft_max: 89.54,
            hard_min: 9.87,
            hard_max: 100.99,
            start_year: 2021,
          )
        end

        it "validates hard minimum for general needs" do
          record.needstype = 1
          record.lettype = 1
          record.period = 1
          record.la = "E07000223"
          record.beds = 4
          record.startdate = Time.zone.local(2021, 9, 17)
          record.brent = 9.17

          financial_validator.validate_rent_amount(record)
          expect(record.errors["brent"])
            .to include(match I18n.t("validations.financial.brent.below_hard_min"))
        end

        it "validates hard minimum for supported housing" do
          record.needstype = 2
          record.lettype = 2
          record.period = 1
          record.location = location
          record.startdate = Time.zone.local(2021, 9, 17)
          record.brent = 9.17

          financial_validator.validate_rent_amount(record)
          expect(record.errors["brent"])
            .to include(match I18n.t("validations.financial.brent.below_hard_min"))

          %w[beds la postcode_known scheme_id location_id rent_type needstype period].each do |field|
            expect(record.errors[field])
              .to include(match I18n.t("validations.financial.brent.#{field}.below_hard_min"))
          end
        end

        it "validates hard max for general needs" do
          record.needstype = 1
          record.lettype = 1
          record.period = 1
          record.la = "E07000223"
          record.beds = 4
          record.startdate = Time.zone.local(2021, 9, 17)
          record.brent = 200

          financial_validator.validate_rent_amount(record)
          expect(record.errors["brent"])
            .to include(match I18n.t("validations.financial.brent.above_hard_max"))

          %w[beds la postcode_known scheme_id location_id rent_type needstype period].each do |field|
            expect(record.errors[field])
              .to include(match I18n.t("validations.financial.brent.#{field}.above_hard_max"))
          end
        end

        it "validates hard max for supported housing" do
          record.needstype = 2
          record.lettype = 2
          record.period = 1
          record.location = location
          record.startdate = Time.zone.local(2021, 9, 17)
          record.brent = 200

          financial_validator.validate_rent_amount(record)
          expect(record.errors["brent"])
            .to include(match I18n.t("validations.financial.brent.above_hard_max"))

          %w[beds la postcode_known scheme_id location_id rent_type needstype period].each do |field|
            expect(record.errors[field])
              .to include(match I18n.t("validations.financial.brent.#{field}.above_hard_max"))
          end
        end

        it "validates hard max for correct collection year" do
          record.lettype = 1
          record.period = 1
          record.la = "E07000223"
          record.startdate = Time.zone.local(2022, 2, 5)
          record.beds = 4
          record.brent = 200

          financial_validator.validate_rent_amount(record)
          expect(record.errors["brent"])
            .to include(match I18n.t("validations.financial.brent.above_hard_max"))

          %w[beds la postcode_known scheme_id location_id rent_type needstype period].each do |field|
            expect(record.errors[field])
              .to include(match I18n.t("validations.financial.brent.#{field}.above_hard_max"))
          end
        end

        it "does not error if some of the fields are missing" do
          record.managing_organisation.provider_type = 2
          record.startdate = Time.zone.local(2021, 9, 17)
          record.brent = 200

          financial_validator.validate_rent_amount(record)
          expect(record.errors["brent"])
            .to be_empty
        end
      end
    end

    context "when the accommodation is care home" do
      before do
        record.is_carehome = 1
      end

      context "and charges are over the valid limit (£1,000 per week)" do
        it "validates charge when period is weekly for 52 weeks" do
          record.period = 1
          record.chcharge = 5001
          financial_validator.validate_care_home_charges(record)
          expect(record.errors["chcharge"])
            .to include("Household rent and other charges must be between £10.00 and £5,000.00 if paying weekly for 52 weeks.")
          expect(record.errors["period"])
            .to include("Household rent and other charges must be between £10.00 and £5,000.00 if paying weekly for 52 weeks.")
        end

        it "validates charge when period is monthly" do
          record.period = 4
          record.chcharge = 21_667
          financial_validator.validate_care_home_charges(record)
          expect(record.errors["chcharge"])
            .to include("Household rent and other charges must be between £43.00 and £21,666.00 if paying every calendar month.")
          expect(record.errors["period"])
            .to include("Household rent and other charges must be between £43.00 and £21,666.00 if paying every calendar month.")
        end

        it "validates charge when period is every 2 weeks" do
          record.period = 2
          record.chcharge = 12_001
          financial_validator.validate_care_home_charges(record)
          expect(record.errors["chcharge"])
            .to include("Household rent and other charges must be between £20.00 and £10,000.00 if paying every 2 weeks.")
          expect(record.errors["period"])
            .to include("Household rent and other charges must be between £20.00 and £10,000.00 if paying every 2 weeks.")
        end

        it "validates charge when period is every 4 weeks" do
          record.period = 3
          record.chcharge = 24_001
          financial_validator.validate_care_home_charges(record)
          expect(record.errors["chcharge"])
            .to include("Household rent and other charges must be between £40.00 and £20,000.00 if paying every 4 weeks.")
          expect(record.errors["period"])
            .to include("Household rent and other charges must be between £40.00 and £20,000.00 if paying every 4 weeks.")
        end
      end

      context "and charges are within the valid limit (£1,000 per week)" do
        it "does not throw error when period is weekly for 52 weeks" do
          record.period = 1
          record.chcharge = 999
          financial_validator.validate_care_home_charges(record)
          expect(record.errors["chcharge"]).to be_empty
          expect(record.errors["period"]).to be_empty
        end

        it "does not throw error when period is monthly" do
          record.period = 4
          record.chcharge = 4333
          financial_validator.validate_care_home_charges(record)
          expect(record.errors["chcharge"]).to be_empty
          expect(record.errors["period"]).to be_empty
        end

        it "does not throw error when period is every 2 weeks" do
          record.period = 2
          record.chcharge = 1999.99
          financial_validator.validate_care_home_charges(record)
          expect(record.errors["chcharge"]).to be_empty
          expect(record.errors["period"]).to be_empty
        end

        it "does not throw error when period is every 4 weeks" do
          record.period = 3
          record.chcharge = 3999
          financial_validator.validate_care_home_charges(record)
          expect(record.errors["chcharge"]).to be_empty
          expect(record.errors["period"]).to be_empty
        end
      end

      context "and charges are not provided" do
        xit "throws an error" do
          record.period = 3
          record.chcharge = nil
          financial_validator.validate_care_home_charges(record)
          expect(record.errors["chcharge"])
            .to include(match I18n.t("validations.financial.carehome.not_provided", period: "every 4 weeks"))
          expect(record.errors["is_carehome"])
            .to include(match I18n.t("validations.financial.carehome.not_provided", period: "every 4 weeks"))
        end
      end

      context "and charges under valid limit (£10pw)" do
        it "validates charge when period is weekly for 52 weeks" do
          record.period = 1
          record.chcharge = 9
          financial_validator.validate_care_home_charges(record)
          expect(record.errors["chcharge"])
            .to include("Household rent and other charges must be between £10.00 and £5,000.00 if paying weekly for 52 weeks.")
          expect(record.errors["period"])
            .to include("Household rent and other charges must be between £10.00 and £5,000.00 if paying weekly for 52 weeks.")
        end

        it "validates charge when period is monthly" do
          record.period = 4
          record.chcharge = 42
          financial_validator.validate_care_home_charges(record)
          expect(record.errors["chcharge"])
            .to include("Household rent and other charges must be between £43.00 and £21,666.00 if paying every calendar month.")
          expect(record.errors["period"])
            .to include("Household rent and other charges must be between £43.00 and £21,666.00 if paying every calendar month.")
        end

        it "validates charge when period is every 2 weeks" do
          record.period = 2
          record.chcharge = 19
          financial_validator.validate_care_home_charges(record)
          expect(record.errors["chcharge"])
            .to include("Household rent and other charges must be between £20.00 and £10,000.00 if paying every 2 weeks.")
          expect(record.errors["period"])
            .to include("Household rent and other charges must be between £20.00 and £10,000.00 if paying every 2 weeks.")
        end

        it "validates charge when period is every 4 weeks" do
          record.period = 3
          record.chcharge = 39
          financial_validator.validate_care_home_charges(record)
          expect(record.errors["chcharge"])
            .to include("Household rent and other charges must be between £40.00 and £20,000.00 if paying every 4 weeks.")
          expect(record.errors["period"])
            .to include("Household rent and other charges must be between £40.00 and £20,000.00 if paying every 4 weeks.")
        end
      end
    end
  end
end
