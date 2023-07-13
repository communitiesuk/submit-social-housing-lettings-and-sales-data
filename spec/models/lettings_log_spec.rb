require "rails_helper"
require "shared/shared_examples_for_derived_fields"
require "shared/shared_log_examples"

# rubocop:disable RSpec/MessageChain
RSpec.describe LettingsLog do
  let(:different_managing_organisation) { create(:organisation) }
  let(:created_by_user) { create(:user) }
  let(:owning_organisation) { created_by_user.organisation }
  let(:fake_2021_2022_form) { Form.new("spec/fixtures/forms/2021_2022.json") }

  around do |example|
    Timecop.freeze(Time.utc(2022, 1, 1)) do
      Singleton.__init__(FormHandler)
      example.run
    end
  end

  before do
    allow(FormHandler.instance).to receive(:current_lettings_form).and_return(fake_2021_2022_form)
  end

  include_examples "shared examples for derived fields", :lettings_log
  include_examples "shared log examples", :lettings_log

  it "inherits from log" do
    expect(described_class).to be < Log
    expect(described_class).to be < ApplicationRecord
  end

  it "is a not a sales log" do
    lettings_log = build(:lettings_log, created_by: created_by_user)
    expect(lettings_log.sales?).to be false
  end

  it "is a lettings log" do
    lettings_log = build(:lettings_log, created_by: created_by_user)
    expect(lettings_log).to be_lettings
  end

  describe "#form" do
    let(:lettings_log) { build(:lettings_log, created_by: created_by_user) }
    let(:lettings_log_2) { build(:lettings_log, startdate: Time.zone.local(2022, 1, 1), created_by: created_by_user) }
    let(:lettings_log_year_2) { build(:lettings_log, startdate: Time.zone.local(2023, 5, 1), created_by: created_by_user) }

    before do
      Timecop.freeze(2023, 1, 1)
    end

    after do
      Timecop.unfreeze
    end

    it "returns the correct form based on the start date" do
      expect(lettings_log.form_name).to be_nil
      expect(lettings_log.form).to be_a(Form)
      expect(lettings_log_2.form_name).to eq("previous_lettings")
      expect(lettings_log_2.form).to be_a(Form)
      expect(lettings_log_year_2.form_name).to eq("next_lettings")
      expect(lettings_log_year_2.form).to be_a(Form)
    end

    context "when a date outside the collection window is passed" do
      let(:lettings_log) { build(:lettings_log, startdate: Time.zone.local(2015, 1, 1), created_by: created_by_user) }

      it "returns the first form" do
        expect(lettings_log.form).to be_a(Form)
        expect(lettings_log.form.start_date.year).to eq(2021)
      end
    end
  end

  describe "#new" do
    context "when creating a record" do
      let(:lettings_log) do
        described_class.create(
          owning_organisation:,
          managing_organisation: owning_organisation,
          created_by: created_by_user,
        )
      end

      it "attaches the correct custom validator" do
        expect(lettings_log._validators.values.flatten.map(&:class))
          .to include(LettingsLogValidator)
      end
    end
  end

  describe "#update" do
    let(:lettings_log) { create(:lettings_log, created_by: created_by_user) }
    let(:validator) { lettings_log._validators[nil].first }

    after do
      lettings_log.update(age1: 25)
    end

    it "validates start date" do
      expect(validator).to receive(:validate_startdate)
    end

    it "validates intermediate rent product name" do
      expect(validator).to receive(:validate_irproduct_other)
    end

    it "validates other household member details" do
      expect(validator).to receive(:validate_household_number_of_other_members)
    end

    it "validates bedroom number" do
      expect(validator).to receive(:validate_shared_housing_rooms)
    end

    it "validates tenancy type" do
      expect(validator).to receive(:validate_fixed_term_tenancy)
      expect(validator).to receive(:validate_other_tenancy_type)
    end

    it "validates the previous postcode" do
      expect(validator).to receive(:validate_previous_accommodation_postcode)
    end

    it "validates the net income" do
      expect(validator).to receive(:validate_net_income)
    end

    it "validates reasonable preference" do
      expect(validator).to receive(:validate_reasonable_preference)
    end

    it "validates reason for leaving last settled home" do
      expect(validator).to receive(:validate_reason_for_leaving_last_settled_home)
    end

    it "validates previous housing situation" do
      expect(validator).to receive(:validate_previous_housing_situation)
    end

    it "validates the min and max of numeric questions" do
      expect(validator).to receive(:validate_numeric_min_max)
    end

    it "validates armed forces" do
      expect(validator).to receive(:validate_armed_forces)
    end

    it "validates property major repairs date" do
      expect(validator).to receive(:validate_property_major_repairs)
    end

    it "validates property void date" do
      expect(validator).to receive(:validate_property_void_date)
    end

    it "validates benefits as proportion of income" do
      expect(validator).to receive(:validate_net_income_uc_proportion)
    end

    it "validates outstanding rent amount" do
      expect(validator).to receive(:validate_outstanding_rent_amount)
    end

    it "validates the rent period" do
      expect(validator).to receive(:validate_rent_period)
    end

    it "validates housing benefit rent shortfall" do
      expect(validator).to receive(:validate_tshortfall)
    end

    it "validates let type" do
      expect(validator).to receive(:validate_unitletas)
    end

    it "validates reason for vacancy" do
      expect(validator).to receive(:validate_rsnvac)
    end

    it "validates referral" do
      expect(validator).to receive(:validate_referral)
    end
  end

  describe "status" do
    let(:completed_lettings_log) { create(:lettings_log, :completed) }

    context "when only a subsection that is hidden in tasklist is not completed" do
      let(:household_characteristics_subsection) { completed_lettings_log.form.get_subsection("household_characteristics") }

      before do
        allow(household_characteristics_subsection).to receive(:displayed_in_tasklist?).and_return(false)
        completed_lettings_log.update!(tenancycode: nil)
      end

      it "is set to completed" do
        expect(completed_lettings_log.in_progress?).to be(false)
        expect(completed_lettings_log.not_started?).to be(false)
        expect(completed_lettings_log.completed?).to be(true)
      end
    end
  end

  describe "weekly_net_income" do
    let(:net_income) { 5000 }
    let(:lettings_log) { build(:lettings_log, earnings: net_income) }

    it "returns input income if frequency is already weekly" do
      lettings_log.incfreq = 1
      expect(lettings_log.weekly_net_income).to eq(net_income)
    end

    it "calculates the correct weekly income from monthly income" do
      lettings_log.incfreq = 2
      expect(lettings_log.weekly_net_income).to eq(1154)
    end

    it "calculates the correct weekly income from yearly income" do
      lettings_log.incfreq = 3
      expect(lettings_log.weekly_net_income).to eq(96)
    end
  end

  describe "derived variables" do
    let!(:lettings_log) do
      described_class.create({
        managing_organisation: owning_organisation,
        owning_organisation:,
        created_by: created_by_user,
        postcode_full: "M1 1AE",
        ppostcode_full: "M2 2AE",
        startdate: Time.gm(2021, 10, 10),
        mrcdate: Time.gm(2021, 5, 4),
        voiddate: Time.gm(2021, 3, 3),
        net_income_known: 2,
        hhmemb: 7,
        rent_type: 4,
        hb: 1,
        hbrentshortfall: 1,
        created_at: Time.utc(2022, 2, 8, 16, 52, 15),
      })
    end

    it "correctly derives and saves partial and full major repairs date" do
      record_from_db = described_class.find(lettings_log.id)
      expect(record_from_db["mrcdate"].day).to eq(4)
      expect(record_from_db["mrcdate"].month).to eq(5)
      expect(record_from_db["mrcdate"].year).to eq(2021)
    end

    it "correctly derives and saves incref" do
      record_from_db = described_class.find(lettings_log.id)
      expect(record_from_db["incref"]).to eq(1)
    end

    it "correctly derives and saves renttype" do
      record_from_db = described_class.find(lettings_log.id)
      expect(lettings_log.renttype).to eq(3)
      expect(record_from_db["renttype"]).to eq(3)
    end

    context "when deriving lettype" do
      context "when the owning organisation is a PRP" do
        before { lettings_log.owning_organisation.update!(provider_type: 2) }

        context "when the rent type is intermediate rent and supported housing" do
          it "correctly derives and saves lettype" do
            lettings_log.update!(rent_type: 4, needstype: 2)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.lettype).to eq(10)
            expect(record_from_db["lettype"]).to eq(10)
          end
        end

        context "when the rent type is intermediate rent and general needs housing" do
          it "correctly derives and saves lettype" do
            lettings_log.update!(rent_type: 4, needstype: 1)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.lettype).to eq(9)
            expect(record_from_db["lettype"]).to eq(9)
          end
        end

        context "when the rent type is affordable rent and supported housing" do
          it "correctly derives and saves lettype" do
            lettings_log.update!(rent_type: 2, needstype: 2)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.lettype).to eq(6)
            expect(record_from_db["lettype"]).to eq(6)
          end
        end

        context "when the rent type is affordable rent and general needs housing" do
          it "correctly derives and saves lettype" do
            lettings_log.update!(rent_type: 2, needstype: 1)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.lettype).to eq(5)
            expect(record_from_db["lettype"]).to eq(5)
          end
        end

        context "when the rent type is social rent and supported housing" do
          it "correctly derives and saves lettype" do
            lettings_log.update!(rent_type: 0, needstype: 2)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.lettype).to eq(2)
            expect(record_from_db["lettype"]).to eq(2)
          end
        end

        context "when the rent type is social rent and general needs housing" do
          it "correctly derives and saves lettype" do
            lettings_log.update!(rent_type: 0, needstype: 1)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.lettype).to eq(1)
            expect(record_from_db["lettype"]).to eq(1)
          end
        end

        context "when the tenant is not in receipt of applicable benefits" do
          it "correctly resets total shortfall" do
            lettings_log.update!(hbrentshortfall: 2, wtshortfall: 100, hb: 9)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wtshortfall).to be_nil
            expect(record_from_db["wtshortfall"]).to be_nil
          end
        end

        context "when rent is paid bi-weekly" do
          it "correctly derives and saves weekly rent" do
            lettings_log.update!(brent: 100, period: 2)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wrent).to eq(50.0)
            expect(record_from_db["wrent"]).to eq(50.0)
          end

          it "correctly derives and saves weekly service charge" do
            lettings_log.update!(scharge: 70, period: 2)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wscharge).to eq(35.0)
            expect(record_from_db["wscharge"]).to eq(35.0)
          end

          it "correctly derives and saves weekly personal service charge" do
            lettings_log.update!(pscharge: 60, period: 2)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wpschrge).to eq(30.0)
            expect(record_from_db["wpschrge"]).to eq(30.0)
          end

          it "correctly derives and saves weekly support charge" do
            lettings_log.update!(supcharg: 80, period: 2)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wsupchrg).to eq(40.0)
            expect(record_from_db["wsupchrg"]).to eq(40.0)
          end

          it "correctly derives and saves weekly total charge" do
            lettings_log.update!(tcharge: 100, period: 2)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wtcharge).to eq(50.0)
            expect(record_from_db["wtcharge"]).to eq(50.0)
          end

          context "when the tenant has an outstanding amount after benefits" do
            context "when tenant is in receipt of housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 100, period: 2, hb: 1)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(50.0)
                expect(record_from_db["wtshortfall"]).to eq(50.0)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 100, period: 2, hb: 6)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(50.0)
                expect(record_from_db["wtshortfall"]).to eq(50.0)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 100, period: 2, hb: 8)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(50.0)
                expect(record_from_db["wtshortfall"]).to eq(50.0)
              end
            end
          end

          it "correctly derives floats" do
            lettings_log.update!(supcharg: 60.12, pscharge: 50.13, scharge: 60.98, brent: 60.97, period: 2)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wsupchrg).to eq(30.06)
            expect(lettings_log.wpschrge).to eq(25.06)
            expect(lettings_log.wscharge).to eq(30.49)
            expect(lettings_log.wrent).to eq(30.49)
            expect(lettings_log.wtcharge).to eq(116.1)
            expect(record_from_db["wsupchrg"]).to eq(30.06)
            expect(record_from_db["wpschrge"]).to eq(25.06)
            expect(record_from_db["wscharge"]).to eq(30.49)
            expect(record_from_db["wrent"]).to eq(30.49)
            expect(record_from_db["wtcharge"]).to eq(116.1)
          end
        end

        context "when rent is paid every 4 weeks" do
          it "correctly derives and saves weekly rent" do
            lettings_log.update!(brent: 120, period: 3)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wrent).to eq(30.0)
            expect(record_from_db["wrent"]).to eq(30.0)
          end

          it "correctly derives and saves weekly service charge" do
            lettings_log.update!(scharge: 120, period: 3)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wscharge).to eq(30.0)
            expect(record_from_db["wscharge"]).to eq(30.0)
          end

          it "correctly derives and saves weekly personal service charge" do
            lettings_log.update!(pscharge: 120, period: 3)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wpschrge).to eq(30.0)
            expect(record_from_db["wpschrge"]).to eq(30.0)
          end

          it "correctly derives and saves weekly support charge" do
            lettings_log.update!(supcharg: 120, period: 3)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wsupchrg).to eq(30.0)
            expect(record_from_db["wsupchrg"]).to eq(30.0)
          end

          it "correctly derives and saves weekly total charge" do
            lettings_log.update!(tcharge: 120, period: 3)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wtcharge).to eq(30.0)
            expect(record_from_db["wtcharge"]).to eq(30.0)
          end

          context "when the tenant has an outstanding amount after benefits" do
            context "when tenant is in receipt of housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 120, period: 3, hb: 1)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(30.0)
                expect(record_from_db["wtshortfall"]).to eq(30.0)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 120, period: 3, hb: 6)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(30.0)
                expect(record_from_db["wtshortfall"]).to eq(30.0)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 120, period: 3, hb: 8)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(30.0)
                expect(record_from_db["wtshortfall"]).to eq(30.0)
              end
            end
          end

          it "correctly derives floats" do
            lettings_log.update!(supcharg: 100.12, pscharge: 100.13, scharge: 100.98, brent: 100.97, period: 3)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wsupchrg).to eq(25.03)
            expect(lettings_log.wpschrge).to eq(25.03)
            expect(lettings_log.wscharge).to eq(25.24)
            expect(lettings_log.wrent).to eq(25.24)
            expect(lettings_log.wtcharge).to eq(100.55)
            expect(record_from_db["wsupchrg"]).to eq(25.03)
            expect(record_from_db["wpschrge"]).to eq(25.03)
            expect(record_from_db["wscharge"]).to eq(25.24)
            expect(record_from_db["wrent"]).to eq(25.24)
            expect(record_from_db["wtcharge"]).to eq(100.55)
          end
        end

        context "when rent is paid every calendar month" do
          it "correctly derives and saves weekly rent" do
            lettings_log.update!(brent: 130, period: 4)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wrent).to eq(30.0)
            expect(record_from_db["wrent"]).to eq(30.0)
          end

          it "correctly derives and saves weekly service charge" do
            lettings_log.update!(scharge: 130, period: 4)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wscharge).to eq(30.0)
            expect(record_from_db["wscharge"]).to eq(30.0)
          end

          it "correctly derives and saves weekly personal service charge" do
            lettings_log.update!(pscharge: 130, period: 4)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wpschrge).to eq(30.0)
            expect(record_from_db["wpschrge"]).to eq(30.0)
          end

          it "correctly derives and saves weekly support charge" do
            lettings_log.update!(supcharg: 130, period: 4)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wsupchrg).to eq(30.0)
            expect(record_from_db["wsupchrg"]).to eq(30.0)
          end

          it "correctly derives and saves weekly total charge" do
            lettings_log.update!(tcharge: 130, period: 4)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wtcharge).to eq(30.0)
            expect(record_from_db["wtcharge"]).to eq(30.0)
          end

          context "when the tenant has an outstanding amount after benefits" do
            context "when tenant is in receipt of housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 4, hb: 1)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(30.0)
                expect(record_from_db["wtshortfall"]).to eq(30.0)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 4, hb: 6)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(30.0)
                expect(record_from_db["wtshortfall"]).to eq(30.0)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 4, hb: 8)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(30.0)
                expect(record_from_db["wtshortfall"]).to eq(30.0)
              end
            end
          end

          it "correctly derives floats" do
            lettings_log.update!(supcharg: 100.12, pscharge: 100.13, scharge: 100.98, brent: 100.97, period: 4)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wsupchrg).to eq(23.10)
            expect(lettings_log.wpschrge).to eq(23.11)
            expect(lettings_log.wscharge).to eq(23.30)
            expect(lettings_log.wrent).to eq(23.30)
            expect(lettings_log.wtcharge).to eq(92.82)
            expect(record_from_db["wsupchrg"]).to eq(23.10)
            expect(record_from_db["wpschrge"]).to eq(23.11)
            expect(record_from_db["wscharge"]).to eq(23.30)
            expect(record_from_db["wrent"]).to eq(23.30)
            expect(record_from_db["wtcharge"]).to eq(92.82)
          end
        end

        context "when rent is paid weekly for 50 weeks" do
          it "correctly derives and saves weekly rent" do
            lettings_log.update!(brent: 130, period: 5)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wrent).to eq(125.0)
            expect(record_from_db["wrent"]).to eq(125.0)
          end

          it "correctly derives and saves weekly service charge" do
            lettings_log.update!(scharge: 20, period: 5)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wscharge).to eq(19.23)
            expect(record_from_db["wscharge"]).to eq(19.23)
          end

          it "correctly derives and saves weekly personal service charge" do
            lettings_log.update!(pscharge: 20, period: 5)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wpschrge).to eq(19.23)
            expect(record_from_db["wpschrge"]).to eq(19.23)
          end

          it "correctly derives and saves weekly support charge" do
            lettings_log.update!(supcharg: 20, period: 5)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wsupchrg).to eq(19.23)
            expect(record_from_db["wsupchrg"]).to eq(19.23)
          end

          it "correctly derives and saves weekly total charge" do
            lettings_log.update!(tcharge: 130, period: 5)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wtcharge).to eq(125.0)
            expect(record_from_db["wtcharge"]).to eq(125.0)
          end

          context "when the tenant has an outstanding amount after benefits" do
            context "when tenant is in receipt of housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 5, hb: 1)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(125.0)
                expect(record_from_db["wtshortfall"]).to eq(125.0)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 5, hb: 6)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(125.0)
                expect(record_from_db["wtshortfall"]).to eq(125.0)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 5, hb: 8)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(125.0)
                expect(record_from_db["wtshortfall"]).to eq(125.0)
              end
            end
          end

          it "correctly derives floats" do
            lettings_log.update!(supcharg: 20.12, pscharge: 20.13, scharge: 20.98, brent: 100.97, period: 5)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wsupchrg).to eq(19.35)
            expect(lettings_log.wpschrge).to eq(19.36)
            expect(lettings_log.wscharge).to eq(20.17)
            expect(lettings_log.wrent).to eq(97.09)
            expect(lettings_log.wtcharge).to eq(155.96)
            expect(record_from_db["wsupchrg"]).to eq(19.35)
            expect(record_from_db["wpschrge"]).to eq(19.36)
            expect(record_from_db["wscharge"]).to eq(20.17)
            expect(record_from_db["wrent"]).to eq(97.09)
            expect(record_from_db["wtcharge"]).to eq(155.96)
          end
        end

        context "when rent is paid weekly for 49 weeks" do
          it "correctly derives and saves weekly rent" do
            lettings_log.update!(brent: 130, period: 6)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wrent).to eq(122.5)
            expect(record_from_db["wrent"]).to eq(122.5)
          end

          it "correctly derives and saves weekly service charge" do
            lettings_log.update!(scharge: 30, period: 6)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wscharge).to eq(28.27)
            expect(record_from_db["wscharge"]).to eq(28.27)
          end

          it "correctly derives and saves weekly personal service charge" do
            lettings_log.update!(pscharge: 30, period: 6)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wpschrge).to eq(28.27)
            expect(record_from_db["wpschrge"]).to eq(28.27)
          end

          it "correctly derives and saves weekly support charge" do
            lettings_log.update!(supcharg: 30, period: 6)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wsupchrg).to eq(28.27)
            expect(record_from_db["wsupchrg"]).to eq(28.27)
          end

          it "correctly derives and saves weekly total charge" do
            lettings_log.update!(tcharge: 130, period: 6)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wtcharge).to eq(122.5)
            expect(record_from_db["wtcharge"]).to eq(122.5)
          end

          context "when the tenant has an outstanding amount after benefits" do
            context "when tenant is in receipt of housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 6, hb: 1)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(122.5)
                expect(record_from_db["wtshortfall"]).to eq(122.5)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 6, hb: 6)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(122.5)
                expect(record_from_db["wtshortfall"]).to eq(122.5)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 6, hb: 8)
                lettings_log.reload
                expect(lettings_log.wtshortfall).to eq(122.5)
              end
            end
          end

          it "correctly derives floats" do
            lettings_log.update!(supcharg: 30.12, pscharge: 30.13, scharge: 30.98, brent: 100.97, period: 6)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wsupchrg).to eq(28.38)
            expect(lettings_log.wpschrge).to eq(28.39)
            expect(lettings_log.wscharge).to eq(29.19)
            expect(lettings_log.wrent).to eq(95.14)
            expect(lettings_log.wtcharge).to eq(181.11)
            expect(record_from_db["wsupchrg"]).to eq(28.38)
            expect(record_from_db["wpschrge"]).to eq(28.39)
            expect(record_from_db["wscharge"]).to eq(29.19)
            expect(record_from_db["wrent"]).to eq(95.14)
            expect(record_from_db["wtcharge"]).to eq(181.11)
          end
        end

        context "when rent is paid weekly for 48 weeks" do
          it "correctly derives and saves weekly rent" do
            lettings_log.update!(brent: 130, period: 7)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wrent).to eq(120.0)
            expect(record_from_db["wrent"]).to eq(120.0)
          end

          it "correctly derives and saves weekly service charge" do
            lettings_log.update!(scharge: 30, period: 7)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wscharge).to eq(27.69)
            expect(record_from_db["wscharge"]).to eq(27.69)
          end

          it "correctly derives and saves weekly personal service charge" do
            lettings_log.update!(pscharge: 30, period: 7)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wpschrge).to eq(27.69)
            expect(record_from_db["wpschrge"]).to eq(27.69)
          end

          it "correctly derives and saves weekly support charge" do
            lettings_log.update!(supcharg: 30, period: 7)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wsupchrg).to eq(27.69)
            expect(record_from_db["wsupchrg"]).to eq(27.69)
          end

          it "correctly derives and saves weekly total charge" do
            lettings_log.update!(tcharge: 130, period: 7)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wtcharge).to eq(120.0)
            expect(record_from_db["wtcharge"]).to eq(120.0)
          end

          context "when the tenant has an outstanding amount after benefits" do
            context "when tenant is in receipt of housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 7, hb: 1)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(120.0)
                expect(record_from_db["wtshortfall"]).to eq(120.0)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 7, hb: 6)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(120.0)
                expect(record_from_db["wtshortfall"]).to eq(120.0)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 7, hb: 8)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(120.0)
                expect(record_from_db["wtshortfall"]).to eq(120.0)
              end
            end
          end

          it "correctly derives floats" do
            lettings_log.update!(supcharg: 30.12, pscharge: 30.13, scharge: 30.98, brent: 100.97, period: 7)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wsupchrg).to eq(27.8)
            expect(lettings_log.wpschrge).to eq(27.81)
            expect(lettings_log.wscharge).to eq(28.6)
            expect(lettings_log.wrent).to eq(93.20)
            expect(lettings_log.wtcharge).to eq(177.42)
            expect(record_from_db["wsupchrg"]).to eq(27.8)
            expect(record_from_db["wpschrge"]).to eq(27.81)
            expect(record_from_db["wscharge"]).to eq(28.6)
            expect(record_from_db["wrent"]).to eq(93.20)
            expect(record_from_db["wtcharge"]).to eq(177.42)
          end
        end

        context "when rent is paid weekly for 47 weeks" do
          it "correctly derives and saves weekly rent" do
            lettings_log.update!(brent: 130, period: 8)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wrent).to eq(117.5)
            expect(record_from_db["wrent"]).to eq(117.5)
          end

          it "correctly derives and saves weekly service charge" do
            lettings_log.update!(scharge: 30, period: 8)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wscharge).to eq(27.12)
            expect(record_from_db["wscharge"]).to eq(27.12)
          end

          it "correctly derives and saves weekly personal service charge" do
            lettings_log.update!(pscharge: 30, period: 8)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wpschrge).to eq(27.12)
            expect(record_from_db["wpschrge"]).to eq(27.12)
          end

          it "correctly derives and saves weekly support charge" do
            lettings_log.update!(supcharg: 30, period: 8)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wsupchrg).to eq(27.12)
            expect(record_from_db["wsupchrg"]).to eq(27.12)
          end

          it "correctly derives and saves weekly total charge" do
            lettings_log.update!(tcharge: 130, period: 8)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wtcharge).to eq(117.5)
            expect(record_from_db["wtcharge"]).to eq(117.5)
          end

          context "when the tenant has an outstanding amount after benefits" do
            context "when tenant is in receipt of housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 8, hb: 1)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(117.5)
                expect(record_from_db["wtshortfall"]).to eq(117.5)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 8, hb: 6)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(117.5)
                expect(record_from_db["wtshortfall"]).to eq(117.5)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 8, hb: 8)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(117.5)
                expect(record_from_db["wtshortfall"]).to eq(117.5)
              end
            end
          end

          it "correctly derives floats" do
            lettings_log.update!(supcharg: 30.12, pscharge: 30.13, scharge: 30.98, brent: 100.97, period: 8)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wsupchrg).to eq(27.22)
            expect(lettings_log.wpschrge).to eq(27.23)
            expect(lettings_log.wscharge).to eq(28)
            expect(lettings_log.wrent).to eq(91.26)
            expect(lettings_log.wtcharge).to eq(173.72)
            expect(record_from_db["wsupchrg"]).to eq(27.22)
            expect(record_from_db["wpschrge"]).to eq(27.23)
            expect(record_from_db["wscharge"]).to eq(28)
            expect(record_from_db["wrent"]).to eq(91.26)
            expect(record_from_db["wtcharge"]).to eq(173.72)
          end
        end

        context "when rent is paid weekly for 46 weeks" do
          it "correctly derives and saves weekly rent" do
            lettings_log.update!(brent: 130, period: 9)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wrent).to eq(115.0)
            expect(record_from_db["wrent"]).to eq(115.0)
          end

          it "correctly derives and saves weekly service charge" do
            lettings_log.update!(scharge: 30, period: 9)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wscharge).to eq(26.54)
            expect(record_from_db["wscharge"]).to eq(26.54)
          end

          it "correctly derives and saves weekly personal service charge" do
            lettings_log.update!(pscharge: 30, period: 9)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wpschrge).to eq(26.54)
            expect(record_from_db["wpschrge"]).to eq(26.54)
          end

          it "correctly derives and saves weekly support charge" do
            lettings_log.update!(supcharg: 30, period: 9)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wsupchrg).to eq(26.54)
            expect(record_from_db["wsupchrg"]).to eq(26.54)
          end

          it "correctly derives and saves weekly total charge" do
            lettings_log.update!(tcharge: 130, period: 9)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wtcharge).to eq(115.0)
            expect(record_from_db["wtcharge"]).to eq(115.0)
          end

          context "when the tenant has an outstanding amount after benefits" do
            context "when tenant is in receipt of housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 9, hb: 1)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(115.0)
                expect(record_from_db["wtshortfall"]).to eq(115.0)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 9, hb: 6)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(115.0)
                expect(record_from_db["wtshortfall"]).to eq(115.0)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 9, hb: 8)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(115.0)
                expect(record_from_db["wtshortfall"]).to eq(115.0)
              end
            end
          end

          it "correctly derives floats" do
            lettings_log.update!(supcharg: 30.12, pscharge: 30.13, scharge: 30.98, brent: 100.97, period: 9)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wsupchrg).to eq(26.64)
            expect(lettings_log.wpschrge).to eq(26.65)
            expect(lettings_log.wscharge).to eq(27.41)
            expect(lettings_log.wrent).to eq(89.32)
            expect(lettings_log.wtcharge).to eq(170.02)
            expect(record_from_db["wsupchrg"]).to eq(26.64)
            expect(record_from_db["wpschrge"]).to eq(26.65)
            expect(record_from_db["wscharge"]).to eq(27.41)
            expect(record_from_db["wrent"]).to eq(89.32)
            expect(record_from_db["wtcharge"]).to eq(170.02)
          end
        end

        context "when rent is paid weekly for 52 weeks" do
          it "correctly derives and saves weekly rent" do
            lettings_log.update!(brent: 130, period: 1)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wrent).to eq(130.0)
            expect(record_from_db["wrent"]).to eq(130.0)
          end

          it "correctly derives and saves weekly service charge" do
            lettings_log.update!(scharge: 30, period: 1)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wscharge).to eq(30.0)
            expect(record_from_db["wscharge"]).to eq(30.0)
          end

          it "correctly derives and saves weekly personal service charge" do
            lettings_log.update!(pscharge: 30, period: 1)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wpschrge).to eq(30.0)
            expect(record_from_db["wpschrge"]).to eq(30.0)
          end

          it "correctly derives and saves weekly support charge" do
            lettings_log.update!(supcharg: 30, period: 1)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wsupchrg).to eq(30.0)
            expect(record_from_db["wsupchrg"]).to eq(30.0)
          end

          it "correctly derives and saves weekly total charge" do
            lettings_log.update!(tcharge: 30, period: 1)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wtcharge).to eq(30.0)
            expect(record_from_db["wtcharge"]).to eq(30.0)
          end

          context "when the tenant has an outstanding amount after benefits" do
            context "when tenant is in receipt of housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 1, hb: 1)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(130.0)
                expect(record_from_db["wtshortfall"]).to eq(130.0)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 1, hb: 6)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(130.0)
                expect(record_from_db["wtshortfall"]).to eq(130.0)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 1, hb: 8)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(130.0)
                expect(record_from_db["wtshortfall"]).to eq(130.0)
              end
            end
          end

          it "correctly derives floats" do
            lettings_log.update!(supcharg: 30.12, pscharge: 25.13, scharge: 30.98, brent: 100.97, period: 1)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wsupchrg).to eq(30.12)
            expect(lettings_log.wpschrge).to eq(25.13)
            expect(lettings_log.wscharge).to eq(30.98)
            expect(lettings_log.wrent).to eq(100.97)
            expect(lettings_log.wtcharge).to eq(187.2)
            expect(record_from_db["wsupchrg"]).to eq(30.12)
            expect(record_from_db["wpschrge"]).to eq(25.13)
            expect(record_from_db["wscharge"]).to eq(30.98)
            expect(record_from_db["wrent"]).to eq(100.97)
            expect(record_from_db["wtcharge"]).to eq(187.2)
          end
        end

        context "when rent is paid weekly for 53 weeks" do
          it "correctly derives and saves weekly rent" do
            lettings_log.update!(brent: 130, period: 10)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wrent).to eq(132.5)
            expect(record_from_db["wrent"]).to eq(132.5)
          end

          it "correctly derives and saves weekly service charge" do
            lettings_log.update!(scharge: 30, period: 10)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wscharge).to eq(30.58)
            expect(record_from_db["wscharge"]).to eq(30.58)
          end

          it "correctly derives and saves weekly personal service charge" do
            lettings_log.update!(pscharge: 30, period: 10)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wpschrge).to eq(30.58)
            expect(record_from_db["wpschrge"]).to eq(30.58)
          end

          it "correctly derives and saves weekly support charge" do
            lettings_log.update!(supcharg: 30, period: 10)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wsupchrg).to eq(30.58)
            expect(record_from_db["wsupchrg"]).to eq(30.58)
          end

          it "correctly derives and saves weekly total charge" do
            lettings_log.update!(tcharge: 30, period: 10)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wtcharge).to eq(30.58)
            expect(record_from_db["wtcharge"]).to eq(30.58)
          end

          context "when the tenant has an outstanding amount after benefits" do
            context "when tenant is in receipt of housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 10, hb: 1)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(132.5)
                expect(record_from_db["wtshortfall"]).to eq(132.5)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 10, hb: 6)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(132.5)
                expect(record_from_db["wtshortfall"]).to eq(132.5)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                lettings_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 10, hb: 8)
                record_from_db = described_class.find(lettings_log.id)
                expect(lettings_log.wtshortfall).to eq(132.5)
                expect(record_from_db["wtshortfall"]).to eq(132.5)
              end
            end
          end

          it "correctly derives floats" do
            lettings_log.update!(supcharg: 30.12, pscharge: 25.13, scharge: 30.98, brent: 100.97, period: 10)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.wsupchrg).to eq(30.7)
            expect(lettings_log.wpschrge).to eq(25.61)
            expect(lettings_log.wscharge).to eq(31.58)
            expect(lettings_log.wrent).to eq(102.91)
            expect(lettings_log.wtcharge).to eq(190.8)
            expect(record_from_db["wsupchrg"]).to eq(30.7)
            expect(record_from_db["wpschrge"]).to eq(25.61)
            expect(record_from_db["wscharge"]).to eq(31.58)
            expect(record_from_db["wrent"]).to eq(102.91)
            expect(record_from_db["wtcharge"]).to eq(190.8)
          end
        end
      end

      context "when the owning organisation is a LA" do
        before { lettings_log.owning_organisation.update!(provider_type: "LA") }

        context "when the rent type is intermediate rent and supported housing" do
          it "correctly derives and saves lettype" do
            lettings_log.update!(rent_type: 4, needstype: 2)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.lettype).to eq(12)
            expect(record_from_db["lettype"]).to eq(12)
          end
        end

        context "when the rent type is intermediate rent and general needs housing" do
          it "correctly derives and saves lettype" do
            lettings_log.update!(rent_type: 4, needstype: 1)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.lettype).to eq(11)
            expect(record_from_db["lettype"]).to eq(11)
          end
        end

        context "when the rent type is affordable rent and supported housing" do
          it "correctly derives and saves lettype" do
            lettings_log.update!(rent_type: 2, needstype: 2)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.lettype).to eq(8)
            expect(record_from_db["lettype"]).to eq(8)
          end
        end

        context "when the rent type is affordable rent and general needs housing" do
          it "correctly derives and saves lettype" do
            lettings_log.update!(rent_type: 2, needstype: 1)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.lettype).to eq(7)
            expect(record_from_db["lettype"]).to eq(7)
          end
        end

        context "when the rent type is social rent and supported housing" do
          it "correctly derives and saves lettype" do
            lettings_log.update!(rent_type: 0, needstype: 2)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.lettype).to eq(4)
            expect(record_from_db["lettype"]).to eq(4)
          end
        end

        context "when the rent type is social rent and general needs housing" do
          it "correctly derives and saves lettype" do
            lettings_log.update!(rent_type: 0, needstype: 1)
            record_from_db = described_class.find(lettings_log.id)
            expect(lettings_log.lettype).to eq(3)
            expect(record_from_db["lettype"]).to eq(3)
          end
        end
      end
    end

    it "correctly derives and saves day, month, year from start date" do
      record_from_db = described_class.find(lettings_log.id)
      expect(record_from_db["startdate"].day).to eq(10)
      expect(record_from_db["startdate"].month).to eq(10)
      expect(record_from_db["startdate"].year).to eq(2021)
    end

    context "when any charge field is set" do
      before do
        lettings_log.update!(pscharge: 10)
      end

      it "derives that any blank ones are 0" do
        record_from_db = described_class.find(lettings_log.id)
        expect(record_from_db["supcharg"].to_f).to eq(0.0)
        expect(record_from_db["scharge"].to_f).to eq(0.0)
      end
    end

    def check_postcode_fields(postcode_field)
      record_from_db = described_class.find(lettings_log.id)
      expect(address_lettings_log[postcode_field]).to eq("M1 1AE")
      expect(record_from_db[postcode_field]).to eq("M1 1AE")
    end

    def check_previous_postcode_fields(postcode_field)
      record_from_db = described_class.find(address_lettings_log.id)
      expect(address_lettings_log[postcode_field]).to eq("M1 1AE")
      expect(record_from_db[postcode_field]).to eq("M1 1AE")
    end

    context "when saving addresses" do
      before do
        stub_request(:get, /api.postcodes.io/)
          .to_return(status: 200, body: "{\"status\":200,\"result\":{\"admin_district\":\"Manchester\",\"codes\":{\"admin_district\": \"E08000003\"}}}", headers: {})
      end

      let!(:address_lettings_log) do
        described_class.create({
          managing_organisation: owning_organisation,
          owning_organisation:,
          created_by: created_by_user,
          postcode_known: 1,
          postcode_full: "M1 1AE",
        })
      end

      def check_property_postcode_fields
        check_postcode_fields("postcode_full")
      end

      it "correctly formats previous postcode" do
        address_lettings_log.update!(postcode_full: "M1 1AE")
        check_property_postcode_fields

        address_lettings_log.update!(postcode_full: "m1 1ae")
        check_property_postcode_fields

        address_lettings_log.update!(postcode_full: "m11Ae")
        check_property_postcode_fields

        address_lettings_log.update!(postcode_full: "m11ae")
        check_property_postcode_fields
      end

      it "correctly infers la" do
        record_from_db = described_class.find(address_lettings_log.id)
        expect(address_lettings_log.la).to eq("E08000003")
        expect(record_from_db["la"]).to eq("E08000003")
      end

      it "errors if the property postcode is emptied" do
        expect { address_lettings_log.update!({ postcode_full: "" }) }
          .to raise_error(ActiveRecord::RecordInvalid, /#{I18n.t("validations.postcode")}/)
      end

      it "errors if the property postcode is not valid" do
        expect { address_lettings_log.update!({ postcode_full: "invalid_postcode" }) }
          .to raise_error(ActiveRecord::RecordInvalid, /#{I18n.t("validations.postcode")}/)
      end

      context "when the local authority lookup times out" do
        before do
          allow(Timeout).to receive(:timeout).and_raise(Timeout::Error)
        end

        it "logs a warning" do
          expect(Rails.logger).to receive(:warn).with("Postcodes.io lookup timed out")
          address_lettings_log.update!({ postcode_known: 1, postcode_full: "M1 1AD" })
        end
      end

      it "correctly resets all fields if property postcode not known" do
        address_lettings_log.update!({ postcode_known: 0 })

        record_from_db = described_class.find(address_lettings_log.id)
        expect(record_from_db["postcode_full"]).to eq(nil)
        expect(address_lettings_log.la).to eq(nil)
        expect(record_from_db["la"]).to eq(nil)
      end

      it "changes the LA if property postcode changes from not known to known and provided" do
        address_lettings_log.update!({ postcode_known: 0 })
        address_lettings_log.update!({ la: "E09000033" })

        record_from_db = described_class.find(address_lettings_log.id)
        expect(record_from_db["postcode_full"]).to eq(nil)
        expect(address_lettings_log.la).to eq("E09000033")
        expect(record_from_db["la"]).to eq("E09000033")

        address_lettings_log.update!({ postcode_known: 1, postcode_full: "M1 1AD" })

        record_from_db = described_class.find(address_lettings_log.id)
        expect(record_from_db["postcode_full"]).to eq("M1 1AD")
        expect(address_lettings_log.la).to eq("E08000003")
        expect(record_from_db["la"]).to eq("E08000003")
      end
    end

    context "when saving previous address" do
      before do
        stub_request(:get, /api.postcodes.io/)
          .to_return(status: 200, body: "{\"status\":200,\"result\":{\"admin_district\":\"Manchester\", \"codes\":{\"admin_district\": \"E08000003\"}}}", headers: {})
      end

      let!(:address_lettings_log) do
        described_class.create({
          managing_organisation: owning_organisation,
          owning_organisation:,
          created_by: created_by_user,
          ppcodenk: 1,
          ppostcode_full: "M1 1AE",
        })
      end

      def previous_postcode_fields
        check_previous_postcode_fields("ppostcode_full")
      end

      it "correctly formats previous postcode" do
        address_lettings_log.update!(ppostcode_full: "M1 1AE")
        previous_postcode_fields

        address_lettings_log.update!(ppostcode_full: "m1 1ae")
        previous_postcode_fields

        address_lettings_log.update!(ppostcode_full: "m11Ae")
        previous_postcode_fields

        address_lettings_log.update!(ppostcode_full: "m11ae")
        previous_postcode_fields
      end

      it "correctly infers prevloc" do
        record_from_db = described_class.find(address_lettings_log.id)
        expect(address_lettings_log.prevloc).to eq("E08000003")
        expect(record_from_db["prevloc"]).to eq("E08000003")
      end

      it "errors if the previous postcode is emptied" do
        expect { address_lettings_log.update!({ ppostcode_full: "" }) }
          .to raise_error(ActiveRecord::RecordInvalid, /#{I18n.t("validations.postcode")}/)
      end

      it "errors if the previous postcode is not valid" do
        expect { address_lettings_log.update!({ ppostcode_full: "invalid_postcode" }) }
          .to raise_error(ActiveRecord::RecordInvalid, /#{I18n.t("validations.postcode")}/)
      end

      it "correctly resets all fields if previous postcode not known" do
        address_lettings_log.update!({ ppcodenk: 0 })

        record_from_db = described_class.find(address_lettings_log.id)
        expect(record_from_db["ppostcode_full"]).to eq(nil)
        expect(address_lettings_log.prevloc).to eq(nil)
        expect(record_from_db["prevloc"]).to eq(nil)
      end

      it "correctly resets la if la is not known" do
        address_lettings_log.update!({ ppcodenk: 0 })
        address_lettings_log.update!({ previous_la_known: 1, prevloc: "S92000003" })
        record_from_db = described_class.find(address_lettings_log.id)
        expect(record_from_db["prevloc"]).to eq("S92000003")
        expect(address_lettings_log.prevloc).to eq("S92000003")

        address_lettings_log.update!({ previous_la_known: 0 })
        record_from_db = described_class.find(address_lettings_log.id)
        expect(address_lettings_log.prevloc).to eq(nil)
        expect(record_from_db["prevloc"]).to eq(nil)
      end

      it "changes the prevloc if previous postcode changes from not known to known and provided" do
        address_lettings_log.update!({ ppcodenk: 0 })
        address_lettings_log.update!({ previous_la_known: 1, prevloc: "E09000033" })

        record_from_db = described_class.find(address_lettings_log.id)
        expect(record_from_db["ppostcode_full"]).to eq(nil)
        expect(address_lettings_log.prevloc).to eq("E09000033")
        expect(record_from_db["prevloc"]).to eq("E09000033")

        address_lettings_log.update!({ ppcodenk: 0, ppostcode_full: "M1 1AD" })

        record_from_db = described_class.find(address_lettings_log.id)
        expect(record_from_db["ppostcode_full"]).to eq("M1 1AD")
        expect(address_lettings_log.prevloc).to eq("E08000003")
        expect(record_from_db["prevloc"]).to eq("E08000003")
      end
    end

    context "when saving rent and charges" do
      let!(:lettings_log) do
        described_class.create({
          managing_organisation: owning_organisation,
          owning_organisation:,
          created_by: created_by_user,
          brent: 5.77,
          scharge: 10.01,
          pscharge: 3,
          supcharg: 12.2,
        })
      end

      it "correctly sums rental charges" do
        record_from_db = described_class.find(lettings_log.id)
        expect(record_from_db["tcharge"]).to eq(30.98)
      end
    end

    context "when validating household members derived vars" do
      let!(:household_lettings_log) do
        described_class.create!({
          managing_organisation: owning_organisation,
          owning_organisation:,
          created_by: created_by_user,
          hhmemb: 3,
          relat2: "X",
          relat3: "C",
          relat4: "X",
          relat5: "C",
          relat7: "C",
          relat8: "X",
          age1: 22,
          age2: 16,
          age4: 60,
          age6: 88,
          age7: 14,
          age8: 42,
        })
      end

      it "correctly derives and saves totchild" do
        record_from_db = described_class.find(household_lettings_log.id)
        expect(record_from_db["totchild"]).to eq(3)
      end

      it "correctly derives and saves totelder" do
        record_from_db = described_class.find(household_lettings_log.id)
        expect(record_from_db["totelder"]).to eq(2)
      end

      it "correctly derives and saves totadult" do
        record_from_db = described_class.find(household_lettings_log.id)
        expect(record_from_db["totadult"]).to eq(3)
      end

      it "correctly derives economic status for tenants under 16" do
        record_from_db = described_class.find(household_lettings_log.id)
        expect(record_from_db["ecstat7"]).to eq(9)
      end

      it "correctly resets economic status when age changes from under 16" do
        household_lettings_log.update!(age7_known: 0, age7: 17)
        record_from_db = described_class.find(household_lettings_log.id)
        expect(record_from_db["ecstat7"]).to eq(nil)
      end
    end

    it "correctly derives and saves has_benefits" do
      record_from_db = described_class.find(lettings_log.id)
      expect(record_from_db["has_benefits"]).to eq(1)
    end

    context "when updating values that derive vacdays" do
      let(:lettings_log) { create(:lettings_log, startdate:) }

      context "when start date is set" do
        let(:startdate) { Time.zone.now }

        it "correctly derives vacdays when voiddate is set" do
          day_count = 3
          expect { lettings_log.update!(voiddate: startdate - day_count.days) }.to change(lettings_log, :vacdays).to day_count
          expect { lettings_log.update!(voiddate: nil) }.to change(lettings_log, :vacdays).from(day_count).to nil
        end

        it "correctly derives vacdays when mrcdate is set" do
          day_count = 3
          expect { lettings_log.update!(mrcdate: startdate - day_count.days) }.to change(lettings_log, :vacdays).to day_count
          expect { lettings_log.update!(mrcdate: nil) }.to change(lettings_log, :vacdays).from(day_count).to nil
        end
      end

      context "when start date is not set" do
        let(:startdate) { nil }

        it "correctly derives vacdays when voiddate is set" do
          day_count = 3
          lettings_log.update!(voiddate: Time.zone.now - day_count.days)
          expect(lettings_log.vacdays).to be nil
        end

        it "correctly derives vacdays when mrcdate is set" do
          day_count = 3
          lettings_log.update!(mrcdate: Time.zone.now - day_count.days)
          expect(lettings_log.vacdays).to be nil
        end
      end
    end

    context "when updating renewal" do
      let!(:lettings_log) do
        described_class.create({
          managing_organisation: owning_organisation,
          owning_organisation:,
          created_by: created_by_user,
          startdate: Time.zone.local(2021, 4, 10),
          created_at: Time.utc(2022, 2, 8, 16, 52, 15),
        })
      end

      it "correctly derives the length of time on local authority waiting list" do
        expect { lettings_log.update!(renewal: 1) }.to change(lettings_log, :waityear).to 2
        expect { lettings_log.update!(renewal: 0) }.to change(lettings_log, :waityear).from(2).to nil
      end

      it "correctly derives the number of times previously offered since becoming available" do
        expect { lettings_log.update!(renewal: 1) }.to change(lettings_log, :offered).to 0
        expect { lettings_log.update!(renewal: 0) }.to change(lettings_log, :offered).from(0).to nil
      end

      it "correctly derives referral if the letting is a renewal and clears it if it is not" do
        expect { lettings_log.update!(renewal: 1) }.to change(lettings_log, :referral).to 1
        expect { lettings_log.update!(renewal: 0) }.to change(lettings_log, :referral).from(1).to nil
      end

      it "correctly derives voiddate if the letting is a renewal and clears it if it is not" do
        expect { lettings_log.update!(renewal: 1) }.to change(lettings_log, :voiddate).to lettings_log.startdate
        expect { lettings_log.update!(renewal: 0) }.to change(lettings_log, :voiddate).from(lettings_log.startdate).to nil
      end

      it "correctly derives first_time_property_let_as_social_housing and clears it if it is not" do
        expect { lettings_log.update!(renewal: 1) }.to change(lettings_log, :first_time_property_let_as_social_housing).to 0
        expect { lettings_log.update!(renewal: 0) }.to change(lettings_log, :first_time_property_let_as_social_housing).from(0).to nil
      end

      it "correctly derives vacancy reason and clears it if it is not" do
        expect { lettings_log.update!(renewal: 1) }.to change(lettings_log, :rsnvac).to 14
        expect { lettings_log.update!(renewal: 0) }.to change(lettings_log, :rsnvac).from(14).to nil
      end

      it "derives vacdays as 0 if log is renewal" do
        expect { lettings_log.update!(renewal: 1) }.to change(lettings_log, :vacdays).to 0
      end

      it "correctly derives underoccupation_benefitcap if log is a renewal from 2021/22" do
        lettings_log.update!(renewal: 1)
        expect(lettings_log.underoccupation_benefitcap).to be 2
      end

      it "clears underoccupation_benefitcap if log is no longer a renewal" do
        expect { lettings_log.update!(renewal: 1) }.to change(lettings_log, :underoccupation_benefitcap).to 2
        expect { lettings_log.update!(renewal: 0) }.to change(lettings_log, :underoccupation_benefitcap).from(2).to nil
      end

      it "clears underoccupation_benefitcap if log is no longer in 2021/22" do
        expect { lettings_log.update!(renewal: 1) }.to change(lettings_log, :underoccupation_benefitcap).to 2
        Timecop.return
        expect { lettings_log.update!(startdate: Time.zone.local(2023, 1, 1)) }.to change(lettings_log, :underoccupation_benefitcap).from(2).to nil
      end

      context "when the log is general needs" do
        context "and the managing organisation is a private registered provider" do
          before do
            lettings_log.managing_organisation.update!(provider_type: "PRP")
            lettings_log.update!(needstype: 1, renewal: 1)
          end

          it "correctly derives prevten" do
            expect(lettings_log.prevten).to be 32
          end

          it "clears prevten if the log is marked as supported housing" do
            lettings_log.update!(needstype: 2)
            expect(lettings_log.prevten).to be nil
          end

          it "clears prevten if renewal is update to no" do
            lettings_log.update!(renewal: 0)
            expect(lettings_log.prevten).to be nil
          end
        end

        context "and the managing organisation is a local authority" do
          before do
            lettings_log.managing_organisation.update!(provider_type: "LA")
            lettings_log.update!(needstype: 1, renewal: 1)
          end

          it "correctly derives prevten" do
            expect(lettings_log.prevten).to be 30
          end

          it "clears prevten if the log is marked as supported housing" do
            expect { lettings_log.update!(needstype: 2) }.to change(lettings_log, :prevten).to nil
          end

          it "clears prevten if renewal is update to no" do
            expect { lettings_log.update!(renewal: 0) }.to change(lettings_log, :prevten).to nil
          end
        end
      end

      context "and updating rent_type" do
        let(:irproduct_other) { nil }

        around do |example|
          Timecop.freeze(now) do
            Singleton.__init__(FormHandler)
            lettings_log.update!(rent_type:, irproduct_other:, startdate: now)
            example.run
          end
        end

        context "when collection year is 2022/23 or earlier" do
          let(:now) { Time.zone.local(2023, 1, 1) }

          context "when rent_type is Social Rent" do
            let(:rent_type) { 0 }

            it "derives the most recent let type as Social Rent basis if it is a renewal and clears it if it is not" do
              expect { lettings_log.update!(renewal: 1) }.to change(lettings_log, :unitletas).to 1
              expect { lettings_log.update!(renewal: 0) }.to change(lettings_log, :unitletas).from(1).to nil
            end
          end

          context "when rent_type is Affordable Rent" do
            let(:rent_type) { 1 }

            it "derives the most recent let type as Affordable Rent basis if it is a renewal and clears it if it is not" do
              expect { lettings_log.update!(renewal: 1) }.to change(lettings_log, :unitletas).to 2
              expect { lettings_log.update!(renewal: 0) }.to change(lettings_log, :unitletas).from(2).to nil
            end
          end

          context "when rent_type is London Affordable Rent" do
            let(:rent_type) { 2 }

            it "derives the most recent let type as Affordable Rent basis if it is a renewal and clears it if it is not" do
              expect { lettings_log.update!(renewal: 1) }.to change(lettings_log, :unitletas).to 2
              expect { lettings_log.update!(renewal: 0) }.to change(lettings_log, :unitletas).from(2).to nil
            end
          end

          context "when rent_type is Rent to Buy" do
            let(:rent_type) { 3 }

            it "derives the most recent let type as Intermediate Rent basis if it is a renewal and clears it if it is not" do
              expect { lettings_log.update!(renewal: 1) }.to change(lettings_log, :unitletas).to 4
              expect { lettings_log.update!(renewal: 0) }.to change(lettings_log, :unitletas).from(4).to nil
            end
          end

          context "when rent_type is London Living Rent" do
            let(:rent_type) { 4 }

            it "derives the most recent let type as Intermediate Rent basis if it is a renewal and clears it if it is not" do
              expect { lettings_log.update!(renewal: 1) }.to change(lettings_log, :unitletas).to 4
              expect { lettings_log.update!(renewal: 0) }.to change(lettings_log, :unitletas).from(4).to nil
            end
          end

          context "when rent_type is Other intermediate rent product" do
            let(:rent_type) { 5 }
            let(:irproduct_other) { "Rent first" }

            it "derives the most recent let type as Intermediate Rent basis if it is a renewal and clears it if it is not" do
              expect { lettings_log.update!(renewal: 1) }.to change(lettings_log, :unitletas).to 4
              expect { lettings_log.update!(renewal: 0) }.to change(lettings_log, :unitletas).from(4).to nil
            end
          end
        end

        context "when collection year is 2023/24 or later" do
          let(:now) { Time.zone.local(2024, 1, 1) }

          context "when rent_type is Social Rent" do
            let(:rent_type) { 0 }

            it "derives the most recent let type as Social Rent basis if it is a renewal and clears it if it is not" do
              expect { lettings_log.update!(renewal: 1) }.to change(lettings_log, :unitletas).to 1
              expect { lettings_log.update!(renewal: 0) }.to change(lettings_log, :unitletas).from(1).to nil
            end
          end

          context "when rent_type is Affordable Rent" do
            let(:rent_type) { 1 }

            it "derives the most recent let type as Affordable Rent basis if it is a renewal and clears it if it is not" do
              expect { lettings_log.update!(renewal: 1) }.to change(lettings_log, :unitletas).to 2
              expect { lettings_log.update!(renewal: 0) }.to change(lettings_log, :unitletas).from(2).to nil
            end
          end

          context "when rent_type is London Affordable Rent" do
            let(:rent_type) { 2 }

            it "derives the most recent let type as London Affordable Rent basis if it is a renewal and clears it if it is not" do
              expect { lettings_log.update!(renewal: 1) }.to change(lettings_log, :unitletas).to 5
              expect { lettings_log.update!(renewal: 0) }.to change(lettings_log, :unitletas).from(5).to nil
            end
          end

          context "when rent_type is Rent to Buy" do
            let(:rent_type) { 3 }

            it "derives the most recent let type as Rent to Buy basis if it is a renewal and clears it if it is not" do
              expect { lettings_log.update!(renewal: 1) }.to change(lettings_log, :unitletas).to 6
              expect { lettings_log.update!(renewal: 0) }.to change(lettings_log, :unitletas).from(6).to nil
            end
          end

          context "when rent_type is London Living Rent" do
            let(:rent_type) { 4 }

            it "derives the most recent let type as London Living Rent basis if it is a renewal and clears it if it is not" do
              expect { lettings_log.update!(renewal: 1) }.to change(lettings_log, :unitletas).to 7
              expect { lettings_log.update!(renewal: 0) }.to change(lettings_log, :unitletas).from(7).to nil
            end
          end

          context "when rent_type is Other intermediate rent product" do
            let(:rent_type) { 5 }
            let(:irproduct_other) { "Rent first" }

            it "derives the most recent let type as Another Intermediate Rent basis if it is a renewal and clears it if it is not" do
              expect { lettings_log.update!(renewal: 1) }.to change(lettings_log, :unitletas).to 8
              expect { lettings_log.update!(renewal: 0) }.to change(lettings_log, :unitletas).from(8).to nil
            end
          end
        end
      end
    end

    context "when updating rent type" do
      let(:irproduct_other) { nil }

      before do
        lettings_log.update!(rent_type:, irproduct_other:)
      end

      context "when rent_type is Social Rent" do
        let(:rent_type) { 0 }

        it "derives renttype as Social Rent" do
          expect(lettings_log.renttype).to be 1
        end
      end

      context "when rent_type is Affordable Rent" do
        let(:rent_type) { 1 }

        it "derives renttype as Affordable Rent" do
          expect(lettings_log.renttype).to be 2
        end
      end

      context "when rent_type is London Affordable Rent" do
        let(:rent_type) { 2 }

        it "derives renttype as Affordable Rent" do
          expect(lettings_log.renttype).to be 2
        end
      end

      context "when rent_type is Rent to Buy" do
        let(:rent_type) { 3 }

        it "derives renttype as Intermediate Rent" do
          expect(lettings_log.renttype).to be 3
        end
      end

      context "when rent_type is London Living Rent" do
        let(:rent_type) { 4 }

        it "derives renttype as Intermediate Rent" do
          expect(lettings_log.renttype).to be 3
        end
      end

      context "when rent_type is Other intermediate rent product" do
        let(:rent_type) { 5 }
        let(:irproduct_other) { "Rent first" }

        it "derives renttype as Intermediate Rent" do
          expect(lettings_log.renttype).to be 3
        end
      end
    end

    context "when answering the household characteristics questions" do
      let!(:lettings_log) do
        described_class.create({
          managing_organisation: owning_organisation,
          owning_organisation:,
          created_by: created_by_user,
          age1_known: 1,
          sex1: "R",
          relat2: "R",
          ecstat1: 10,
        })
      end

      it "correctly derives and saves refused" do
        record_from_db = described_class.find(lettings_log.id)
        expect(record_from_db["refused"]).to eq(1)
        expect(lettings_log["refused"]).to eq(1)
      end
    end

    context "when it is supported housing and a care home charge has been supplied" do
      let!(:lettings_log) do
        described_class.create({
          managing_organisation: owning_organisation,
          owning_organisation:,
          created_by: created_by_user,
          needstype: 2,
        })
      end

      context "when the care home charge is paid bi-weekly" do
        it "correctly derives and saves weekly care home charge" do
          lettings_log.update!(chcharge: 100, period: 2)
          record_from_db = described_class.find(lettings_log.id)
          expect(lettings_log.wchchrg).to eq(50.0)
          expect(record_from_db["wchchrg"]).to eq(50.0)
        end

        it "correctly derives floats" do
          lettings_log.update!(chcharge: 100.12, period: 2)
          record_from_db = described_class.find(lettings_log.id)
          expect(lettings_log.wchchrg).to eq(50.06)
          expect(record_from_db["wchchrg"]).to eq(50.06)
        end
      end

      context "when the care home charge is paid every 4 weeks" do
        it "correctly derives and saves weekly care home charge" do
          lettings_log.update!(chcharge: 120, period: 3)
          record_from_db = described_class.find(lettings_log.id)
          expect(lettings_log.wchchrg).to eq(30.0)
          expect(record_from_db["wchchrg"]).to eq(30.0)
        end

        it "correctly derives floats" do
          lettings_log.update!(chcharge: 100.12, period: 3)
          record_from_db = described_class.find(lettings_log.id)
          expect(lettings_log.wchchrg).to eq(25.03)
          expect(record_from_db["wchchrg"]).to eq(25.03)
        end
      end

      context "when the care home charge is paid every calendar month" do
        it "correctly derives and saves weekly care home charge" do
          lettings_log.update!(chcharge: 130, period: 4)
          record_from_db = described_class.find(lettings_log.id)
          expect(lettings_log.wchchrg).to eq(30.0)
          expect(record_from_db["wchchrg"]).to eq(30.0)
        end

        it "correctly derives floats" do
          lettings_log.update!(chcharge: 100.12, period: 4)
          record_from_db = described_class.find(lettings_log.id)
          expect(lettings_log.wchchrg).to eq(23.10)
          expect(record_from_db["wchchrg"]).to eq(23.10)
        end
      end

      context "when the care home charge is paid weekly for 50 weeks" do
        it "correctly derives and saves weekly care home charge" do
          lettings_log.update!(chcharge: 130, period: 5)
          record_from_db = described_class.find(lettings_log.id)
          expect(lettings_log.wchchrg).to eq(125.0)
          expect(record_from_db["wchchrg"]).to eq(125.0)
        end

        it "correctly derives floats" do
          lettings_log.update!(chcharge: 100.12, period: 5)
          record_from_db = described_class.find(lettings_log.id)
          expect(lettings_log.wchchrg).to eq(96.27)
          expect(record_from_db["wchchrg"]).to eq(96.27)
        end
      end

      context "when the care home charge is paid weekly for 49 weeks" do
        it "correctly derives and saves weekly care home charge" do
          lettings_log.update!(chcharge: 130, period: 6)
          record_from_db = described_class.find(lettings_log.id)
          expect(lettings_log.wchchrg).to eq(122.5)
          expect(record_from_db["wchchrg"]).to eq(122.5)
        end

        it "correctly derives floats" do
          lettings_log.update!(chcharge: 100.12, period: 6)
          record_from_db = described_class.find(lettings_log.id)
          expect(lettings_log.wchchrg).to eq(94.34)
          expect(record_from_db["wchchrg"]).to eq(94.34)
        end
      end

      context "when the care home charge is paid weekly for 48 weeks" do
        it "correctly derives and saves weekly care home charge" do
          lettings_log.update!(chcharge: 130, period: 7)
          record_from_db = described_class.find(lettings_log.id)
          expect(lettings_log.wchchrg).to eq(120.0)
          expect(record_from_db["wchchrg"]).to eq(120.0)
        end

        it "correctly derives floats" do
          lettings_log.update!(chcharge: 100.12, period: 7)
          record_from_db = described_class.find(lettings_log.id)
          expect(lettings_log.wchchrg).to eq(92.42)
          expect(record_from_db["wchchrg"]).to eq(92.42)
        end
      end

      context "when the care home charge is paid weekly for 47 weeks" do
        it "correctly derives and saves weekly care home charge" do
          lettings_log.update!(chcharge: 130, period: 8)
          record_from_db = described_class.find(lettings_log.id)
          expect(lettings_log.wchchrg).to eq(117.5)
          expect(record_from_db["wchchrg"]).to eq(117.5)
        end

        it "correctly derives floats" do
          lettings_log.update!(chcharge: 100.12, period: 8)
          record_from_db = described_class.find(lettings_log.id)
          expect(lettings_log.wchchrg).to eq(90.49)
          expect(record_from_db["wchchrg"]).to eq(90.49)
        end
      end

      context "when the care home charge is paid weekly for 46 weeks" do
        it "correctly derives and saves weekly care home charge" do
          lettings_log.update!(chcharge: 130, period: 9)
          record_from_db = described_class.find(lettings_log.id)
          expect(lettings_log.wchchrg).to eq(115.0)
          expect(record_from_db["wchchrg"]).to eq(115.0)
        end

        it "correctly derives floats" do
          lettings_log.update!(chcharge: 100.12, period: 9)
          record_from_db = described_class.find(lettings_log.id)
          expect(lettings_log.wchchrg).to eq(88.57)
          expect(record_from_db["wchchrg"]).to eq(88.57)
        end
      end

      context "when the care home charge is paid weekly for 52 weeks" do
        it "correctly derives and saves weekly care home charge" do
          lettings_log.update!(chcharge: 130, period: 1)
          record_from_db = described_class.find(lettings_log.id)
          expect(lettings_log.wchchrg).to eq(130.0)
          expect(record_from_db["wchchrg"]).to eq(130.0)
        end

        it "correctly derives floats" do
          lettings_log.update!(chcharge: 100.12, period: 1)
          record_from_db = described_class.find(lettings_log.id)
          expect(lettings_log.wchchrg).to eq(100.12)
          expect(record_from_db["wchchrg"]).to eq(100.12)
        end
      end
    end

    context "when the data provider is filling in the reason for the property being vacant" do
      let!(:first_let_lettings_log) do
        described_class.create({
          managing_organisation: owning_organisation,
          owning_organisation:,
          created_by: created_by_user,
          first_time_property_let_as_social_housing: 1,
        })
      end

      let!(:relet_lettings_log) do
        described_class.create({
          managing_organisation: owning_organisation,
          owning_organisation:,
          created_by: created_by_user,
          first_time_property_let_as_social_housing: 0,
        })
      end

      it "the newprop variable is correctly derived and saved as 1 for a first let vacancy reason" do
        first_let_lettings_log.update!({ rsnvac: 15 })
        record_from_db = described_class.find(first_let_lettings_log.id)
        expect(record_from_db["newprop"]).to eq(1)
        expect(first_let_lettings_log["newprop"]).to eq(1)
      end

      it "the newprop variable is correctly derived and saved as 2 for anything that is not a first let vacancy reason" do
        relet_lettings_log.update!({ rsnvac: 2 })
        record_from_db = described_class.find(relet_lettings_log.id)
        expect(record_from_db["newprop"]).to eq(2)
        expect(relet_lettings_log["newprop"]).to eq(2)
      end
    end

    context "when a total shortfall is provided" do
      it "derives that tshortfall is known" do
        lettings_log.update!({ tshortfall: 10 })
        record_from_db = described_class.find(lettings_log.id)
        expect(record_from_db["tshortfall_known"]).to eq(0)
        expect(lettings_log["tshortfall_known"]).to eq(0)
      end
    end

    context "when a lettings log is a supported housing log" do
      let(:real_2021_2022_form) { Form.new("config/forms/2021_2022.json") }

      before do
        lettings_log.needstype = 2
        allow(FormHandler.instance).to receive(:get_form).and_return(real_2021_2022_form)
      end

      context "and a scheme with a single log is selected" do
        let(:scheme) { create(:scheme) }
        let!(:location) { create(:location, scheme:) }

        before do
          Timecop.freeze(Time.zone.local(2022, 4, 2))
          lettings_log.update!(startdate: Time.zone.local(2022, 4, 2), scheme:)
          Timecop.unfreeze
        end

        it "derives the scheme location" do
          record_from_db = described_class.find(lettings_log.id)
          expect(record_from_db["location_id"]).to eq(location.id)
          expect(lettings_log["location_id"]).to eq(location.id)
        end

        context "and the location has multiple local authorities for different years" do
          before do
            LocalAuthorityLink.create!(local_authority_id: LocalAuthority.find_by(code: "E07000030").id, linked_local_authority_id: LocalAuthority.find_by(code: "E06000063").id)
            location.update!(location_code: "E07000030")
            Timecop.freeze(startdate)
            Singleton.__init__(FormHandler)
            lettings_log.update!(startdate:)
            lettings_log.reload
          end

          after do
            Timecop.unfreeze
            Singleton.__init__(FormHandler)
          end

          context "with 22/23" do
            let(:startdate) { Time.zone.local(2022, 4, 2) }

            it "returns the correct la" do
              expect(lettings_log["location_id"]).to eq(location.id)
              expect(lettings_log.la).to eq("E07000030")
            end
          end

          context "with 23/24" do
            let(:startdate) { Time.zone.local(2023, 4, 2) }

            it "returns the correct la" do
              expect(lettings_log["location_id"]).to eq(location.id)
              expect(lettings_log.la).to eq("E06000063")
            end
          end
        end

        context "and the location no local authorities associated with the location_code" do
          before do
            location.update!(location_code: "E01231231")
            lettings_log.update!(location:)
          end

          it "returns the correct la" do
            expect(location.location_code).to eq("E01231231")
            expect(lettings_log["location_id"]).to eq(location.id)
            expect(lettings_log.la).to eq("E01231231")
          end
        end
      end

      context "and not renewal" do
        let(:scheme) { create(:scheme) }
        let(:location) { create(:location, scheme:, postcode: "M11AE", type_of_unit: 1, mobility_type: "W") }

        let(:supported_housing_lettings_log) do
          described_class.create!({
            managing_organisation: owning_organisation,
            owning_organisation:,
            created_by: created_by_user,
            needstype: 2,
            scheme_id: scheme.id,
            location_id: location.id,
            renewal: 0,
          })
        end

        before do
          stub_request(:get, /api.postcodes.io/)
            .to_return(status: 200, body: "{\"status\":200,\"result\":{\"admin_district\":\"Manchester\",\"codes\":{\"admin_district\": \"E08000003\"}}}", headers: {})
        end

        it "correctly infers and saves la" do
          record_from_db = described_class.find(supported_housing_lettings_log.id)
          expect(record_from_db["la"]).to be_nil
          expect(supported_housing_lettings_log.la).to eq("E08000003")
        end

        it "correctly infers and saves postcode" do
          record_from_db = described_class.find(supported_housing_lettings_log.id)
          expect(record_from_db["postcode_full"]).to be_nil
          expect(supported_housing_lettings_log.postcode_full).to eq("M1 1AE")
        end

        it "unittype_sh method returns the type_of_unit of the location" do
          expect(supported_housing_lettings_log.unittype_sh).to eq(1)
        end

        it "correctly infers and saves wchair" do
          record_from_db = described_class.find(supported_housing_lettings_log.id)
          expect(record_from_db["wchair"]).to eq(1)
        end
      end
    end

    context "when saving accessibility needs" do
      it "derives housingneeds_h as true if 'Don't know' is selected for housingneeds" do
        lettings_log.update!({ housingneeds: 3 })
        record_from_db = described_class.find(lettings_log.id)
        not_selected_housingneeds = %w[housingneeds_a housingneeds_b housingneeds_c housingneeds_f housingneeds_g]
        not_selected_housingneeds.each do |housingneed|
          expect(record_from_db[housingneed]).to eq(0)
          expect(lettings_log[housingneed]).to eq(0)
        end
        expect(record_from_db["housingneeds_h"]).to eq(1)
        expect(lettings_log["housingneeds_h"]).to eq(1)
      end

      it "derives housingneeds_g as true if 'No' is selected for housingneeds" do
        lettings_log.update!({ housingneeds: 2 })
        record_from_db = described_class.find(lettings_log.id)
        not_selected_housingneeds = %w[housingneeds_a housingneeds_b housingneeds_c housingneeds_f housingneeds_h]
        not_selected_housingneeds.each do |housingneed|
          expect(record_from_db[housingneed]).to eq(0)
          expect(lettings_log[housingneed]).to eq(0)
        end
        expect(record_from_db["housingneeds_g"]).to eq(1)
        expect(lettings_log["housingneeds_g"]).to eq(1)
      end

      it "derives housingneeds_a as true if 'Fully wheelchair accessible' is selected for housingneeds_type" do
        lettings_log.update!({ housingneeds: 1, housingneeds_type: 0 })
        record_from_db = described_class.find(lettings_log.id)
        not_selected_housingneeds = %w[housingneeds_b housingneeds_c housingneeds_f housingneeds_g housingneeds_h]
        not_selected_housingneeds.each do |housingneed|
          expect(record_from_db[housingneed]).to eq(0)
          expect(lettings_log[housingneed]).to eq(0)
        end
        expect(record_from_db["housingneeds_a"]).to eq(1)
        expect(lettings_log["housingneeds_a"]).to eq(1)
      end

      it "derives housingneeds_b as true if 'Wheelchair access to essential rooms' is selected for housingneeds_type" do
        lettings_log.update!({ housingneeds: 1, housingneeds_type: 1 })
        record_from_db = described_class.find(lettings_log.id)
        not_selected_housingneeds = %w[housingneeds_a housingneeds_c housingneeds_f housingneeds_g housingneeds_h]
        not_selected_housingneeds.each do |housingneed|
          expect(record_from_db[housingneed]).to eq(0)
          expect(lettings_log[housingneed]).to eq(0)
        end
        expect(record_from_db["housingneeds_b"]).to eq(1)
        expect(lettings_log["housingneeds_b"]).to eq(1)
      end

      it "derives housingneeds_c if 'Level access housing' is selected for housingneeds_type" do
        lettings_log.update!({ housingneeds: 1, housingneeds_type: 2 })
        record_from_db = described_class.find(lettings_log.id)
        not_selected_housingneeds = %w[housingneeds_a housingneeds_b housingneeds_f housingneeds_g housingneeds_h]
        not_selected_housingneeds.each do |housingneed|
          expect(record_from_db[housingneed]).to eq(0)
          expect(lettings_log[housingneed]).to eq(0)
        end
        expect(record_from_db["housingneeds_c"]).to eq(1)
        expect(lettings_log["housingneeds_c"]).to eq(1)
      end

      it "derives housingneeds_f if 'Yes' is selected for housingneeds_other" do
        lettings_log.update!({ housingneeds: 1, housingneeds_other: 1 })
        record_from_db = described_class.find(lettings_log.id)
        not_selected_housingneeds = %w[housingneeds_a housingneeds_b housingneeds_c housingneeds_g housingneeds_h]
        not_selected_housingneeds.each do |housingneed|
          expect(record_from_db[housingneed]).to eq(0)
          expect(lettings_log[housingneed]).to eq(0)
        end
        expect(record_from_db["housingneeds_f"]).to eq(1)
        expect(lettings_log["housingneeds_f"]).to eq(1)
      end

      it "clears previously set housingneeds if 'No' is selected for housingneeds" do
        lettings_log.update!({ housingneeds: 1, housingneeds_type: 2, housingneeds_other: 1 })
        record_from_db = described_class.find(lettings_log.id)
        expect(record_from_db["housingneeds_c"]).to eq(1)
        expect(lettings_log["housingneeds_c"]).to eq(1)
        expect(record_from_db["housingneeds_f"]).to eq(1)
        expect(lettings_log["housingneeds_f"]).to eq(1)

        lettings_log.update!({ housingneeds: 2 })
        record_from_db = described_class.find(lettings_log.id)
        not_selected_housingneeds = %w[housingneeds_a housingneeds_b housingneeds_c housingneeds_f housingneeds_h]
        not_selected_housingneeds.each do |housingneed|
          expect(record_from_db[housingneed]).to eq(0)
          expect(lettings_log[housingneed]).to eq(0)
        end
        expect(record_from_db["housingneeds_g"]).to eq(1)
        expect(lettings_log["housingneeds_g"]).to eq(1)
      end
    end
  end

  describe "optional fields" do
    let(:lettings_log) { create(:lettings_log) }

    context "when tshortfall is marked as not known" do
      it "makes tshortfall optional" do
        lettings_log.update!({ tshortfall: nil, tshortfall_known: 1 })
        expect(lettings_log.optional_fields).to include("tshortfall")
      end
    end

    context "when saledate is before 2023" do
      let(:lettings_log) { build(:lettings_log, startdate: Time.zone.parse("2022-07-01")) }

      it "returns optional fields" do
        expect(lettings_log.optional_fields).to eq(%w[
          first_time_property_let_as_social_housing
          tenancycode
          propcode
          chcharge
          tenancylength
        ])
      end
    end

    context "when saledate is after 2023" do
      let(:lettings_log) { build(:lettings_log, startdate: Time.zone.parse("2023-07-01")) }

      it "returns optional fields" do
        expect(lettings_log.optional_fields).to eq(%w[
          first_time_property_let_as_social_housing
          tenancycode
          propcode
          chcharge
          tenancylength
          address_line2
          county
          postcode_full
        ])
      end
    end
  end

  describe "resetting invalidated fields" do
    let(:scheme) { create(:scheme, owning_organisation: created_by_user.organisation) }
    let!(:location) { create(:location, location_code: "E07000223", scheme:) }
    let(:lettings_log) do
      create(
        :lettings_log,
        renewal: 0,
        rsnvac: 5,
        first_time_property_let_as_social_housing: 0,
        startdate: Time.zone.tomorrow,
        voiddate: Time.zone.today,
        mrcdate: Time.zone.today,
        rent_type: 2,
        needstype: 2,
        period: 1,
        beds: 1,
        brent: 7.17,
        scharge: 1,
        pscharge: 1,
        supcharg: 1,
        created_by: created_by_user,
      )
    end

    before do
      LaRentRange.create!(
        ranges_rent_id: "1",
        la: "E07000223",
        beds: 0,
        lettype: 8,
        soft_min: 12.41,
        soft_max: 89.54,
        hard_min: 10.87,
        hard_max: 100.99,
        start_year: lettings_log.collection_start_year,
      )
    end

    context "when a question that has already been answered, no longer has met dependencies" do
      let(:lettings_log) { create(:lettings_log, :in_progress, cbl: 1, preg_occ: 2, wchair: 2) }

      it "clears the answer" do
        expect { lettings_log.update!(preg_occ: nil) }.to change(lettings_log, :cbl).from(1).to(nil)
      end

      context "when the question type does not have answer options" do
        let(:lettings_log) { create(:lettings_log, :in_progress, housingneeds_a: 1, age1: 19) }

        it "clears the answer" do
          expect { lettings_log.update!(housingneeds_a: 0) }.to change(lettings_log, :age1).from(19).to(nil)
        end
      end

      context "when the question type has answer options" do
        let(:lettings_log) { create(:lettings_log, :in_progress, illness: 1, illness_type_1: 1) }

        it "clears the answer" do
          expect { lettings_log.update!(illness: 2) }.to change(lettings_log, :illness_type_1).from(1).to(nil)
        end
      end
    end

    context "with two pages having the same question key, only one's dependency is met" do
      let(:lettings_log) { create(:lettings_log, :in_progress, cbl: 0, preg_occ: 2, wchair: 2) }

      it "does not clear the value for answers that apply to both pages" do
        expect(lettings_log.cbl).to eq(0)
      end

      it "does clear the value for answers that do not apply for invalidated page" do
        lettings_log.update!({ cbl: 1 })
        lettings_log.update!({ preg_occ: 1 })

        expect(lettings_log.cbl).to eq(nil)
      end
    end

    context "when a non select question associated with several pages is routed to" do
      let(:lettings_log) { create(:lettings_log, :in_progress, period: 2, needstype: 1, renewal: 0) }

      it "does not clear the answer value" do
        lettings_log.update!({ unitletas: 1 })
        lettings_log.reload
        expect(lettings_log.unitletas).to eq(1)
      end
    end

    context "when the lettings log does not have a valid form set yet" do
      let(:lettings_log) { create(:lettings_log) }

      it "does not throw an error" do
        expect { lettings_log.update(startdate: Time.zone.local(2015, 1, 1)) }.not_to raise_error
      end
    end

    context "when it changes from a supported housing to not a supported housing" do
      let(:location) { create(:location, mobility_type: "A", postcode: "SW1P 4DG") }
      let(:lettings_log) { create(:lettings_log, location:) }

      it "resets inferred wchair value" do
        expect { lettings_log.update!(needstype: 2) }.to change(lettings_log, :wchair).to(2)
        expect { lettings_log.update!(needstype: 1) }.to change(lettings_log, :wchair).from(2).to(nil)
      end

      it "resets location" do
        lettings_log.update!(needstype: 2)
        expect { lettings_log.update!(needstype: 1) }.to change(lettings_log, :location_id).from(location.id).to(nil)
      end
    end

    context "when a support user changes the owning organisation of the log" do
      let(:lettings_log) { create(:lettings_log, created_by: created_by_user) }
      let(:organisation_2) { create(:organisation) }

      context "when the organisation selected doesn't match the scheme set" do
        let(:scheme) { create(:scheme, owning_organisation: created_by_user.organisation) }
        let(:location) { create(:location, scheme:) }
        let(:lettings_log) { create(:lettings_log, owning_organisation: nil, needstype: 2, scheme_id: scheme.id) }

        it "clears the scheme value" do
          lettings_log.update!(owning_organisation: organisation_2)
          expect(lettings_log.reload.scheme).to be nil
        end
      end

      context "when the organisation selected still matches the scheme set" do
        let(:scheme) { create(:scheme, owning_organisation: organisation_2) }
        let(:location) { create(:location, scheme:) }
        let(:lettings_log) { create(:lettings_log, owning_organisation: nil, needstype: 2, scheme_id: scheme.id) }

        it "does not clear the scheme value" do
          lettings_log.update!(owning_organisation: organisation_2)
          expect(lettings_log.reload.scheme_id).to eq(scheme.id)
        end
      end
    end

    context "when the log is unresolved" do
      before do
        lettings_log.update!(unresolved: true)
      end

      context "and the new startdate triggers void date validation" do
        it "clears void date value" do
          lettings_log.update!(startdate: Time.zone.yesterday)
          lettings_log.reload
          expect(lettings_log.startdate).to eq(Time.zone.yesterday)
          expect(lettings_log.voiddate).to eq(nil)
        end

        it "does not impact other validations" do
          expect { lettings_log.update!(startdate: Time.zone.yesterday, first_time_property_let_as_social_housing: 0, rsnvac: 16) }
            .to raise_error(ActiveRecord::RecordInvalid, /Enter a reason for vacancy that is not 'first let' if unit has been previously let as social housing/)
        end
      end

      context "and the new startdate triggers major repairs date validation" do
        it "clears major repairs date value" do
          lettings_log.update!(startdate: Time.zone.yesterday)
          lettings_log.reload
          expect(lettings_log.startdate).to eq(Time.zone.yesterday)
          expect(lettings_log.mrcdate).to eq(nil)
        end
      end

      context "and the new location triggers the rent range validation" do
        around do |example|
          Timecop.freeze(Time.zone.local(2022, 4, 1)) do
            Singleton.__init__(FormHandler)
            example.run
          end
          Timecop.return
          Singleton.__init__(FormHandler)
        end

        it "clears rent values" do
          lettings_log.update!(location:, scheme:)
          lettings_log.reload
          expect(lettings_log.location).to eq(location)
          expect(lettings_log.brent).to eq(nil)
          expect(lettings_log.scharge).to eq(nil)
          expect(lettings_log.pscharge).to eq(nil)
          expect(lettings_log.supcharg).to eq(nil)
          expect(lettings_log.tcharge).to eq(nil)
        end

        it "does not impact other validations" do
          expect { lettings_log.update!(location:, scheme:, first_time_property_let_as_social_housing: 0, rsnvac: 16) }
            .to raise_error(ActiveRecord::RecordInvalid, /Enter a reason for vacancy that is not 'first let' if unit has been previously let as social housing/)
        end
      end
    end

    context "when the log is resolved" do
      context "and the new startdate triggers void date validation" do
        it "doesn't clear void date value" do
          expect { lettings_log.update!(startdate: Time.zone.yesterday) }.to raise_error(ActiveRecord::RecordInvalid, /Enter a void date that is before the tenancy start date/)
          expect(lettings_log.startdate).to eq(Time.zone.yesterday)
          expect(lettings_log.voiddate).to eq(Time.zone.today)
        end
      end

      context "and the new startdate triggers major repairs date validation" do
        it "doesn't clear major repairs date value" do
          expect { lettings_log.update!(startdate: Time.zone.yesterday) }.to raise_error(ActiveRecord::RecordInvalid, /Enter a major repairs date that is before the tenancy start date/)
          expect(lettings_log.startdate).to eq(Time.zone.yesterday)
          expect(lettings_log.mrcdate).to eq(Time.zone.today)
        end
      end

      context "and the new location triggers brent validation" do
        it "doesn't clear rent values" do
          expect { lettings_log.update!(location:, scheme:) }.to raise_error(ActiveRecord::RecordInvalid, /Rent is below the absolute minimum expected/)
          expect(lettings_log.brent).to eq(7.17)
          expect(lettings_log.scharge).to eq(1)
          expect(lettings_log.pscharge).to eq(1)
          expect(lettings_log.supcharg).to eq(1)
        end
      end
    end
  end

  describe "tshortfall_unknown?" do
    context "when tshortfall is nil" do
      let(:lettings_log) { create(:lettings_log, :in_progress, tshortfall_known: nil) }

      it "returns false" do
        expect(lettings_log.tshortfall_unknown?).to be false
      end
    end

    context "when tshortfall is No" do
      let(:lettings_log) { create(:lettings_log, :in_progress, tshortfall_known: 1) }

      it "returns false" do
        expect(lettings_log.tshortfall_unknown?).to be true
      end
    end

    context "when tshortfall is Yes" do
      let(:lettings_log) { create(:lettings_log, :in_progress, tshortfall_known: 0) }

      it "returns false" do
        expect(lettings_log.tshortfall_unknown?).to be false
      end
    end
  end

  describe "paper trail" do
    let(:lettings_log) { create(:lettings_log, :in_progress) }

    it "creates a record of changes to a log" do
      expect { lettings_log.update!(age1: 64) }.to change(lettings_log.versions, :count).by(1)
    end

    it "allows lettings logs to be restored to a previous version" do
      lettings_log.update!(age1: 63)
      expect(lettings_log.paper_trail.previous_version.age1).to eq(17)
    end
  end

  describe "soft values for period" do
    let(:lettings_log) { create(:lettings_log) }

    before do
      LaRentRange.create!(
        ranges_rent_id: "1",
        la: "E07000223",
        beds: 1,
        lettype: 1,
        soft_min: 100,
        soft_max: 400,
        hard_min: 50,
        hard_max: 500,
        start_year: 2021,
      )

      lettings_log.la = "E07000223"
      lettings_log.lettype = 1
      lettings_log.beds = 1
      lettings_log.startdate = Time.zone.local(2021, 10, 10)
    end

    context "when period is weekly for 52 weeks" do
      it "returns weekly soft min for 52 weeks" do
        lettings_log.period = 1
        expect(lettings_log.soft_min_for_period).to eq("£100.00 every week")
      end

      it "returns weekly soft max for 52 weeks" do
        lettings_log.period = 1
        expect(lettings_log.soft_max_for_period).to eq("£400.00 every week")
      end
    end

    context "when period is weekly for 47 weeks" do
      it "returns weekly soft min for 47 weeks" do
        lettings_log.period = 8
        expect(lettings_log.soft_min_for_period).to eq("£110.64 every week")
      end

      it "returns weekly soft max for 47 weeks" do
        lettings_log.period = 8
        expect(lettings_log.soft_max_for_period).to eq("£442.55 every week")
      end
    end
  end

  describe "scopes" do
    let!(:lettings_log_1) { create(:lettings_log, :in_progress, startdate: Time.utc(2021, 5, 3), mrcdate: Time.utc(2021, 5, 3), voiddate: Time.utc(2021, 5, 3), created_by: created_by_user) }
    let!(:lettings_log_2) { create(:lettings_log, :completed, startdate: Time.utc(2021, 5, 3), mrcdate: Time.utc(2021, 5, 3), voiddate: Time.utc(2021, 5, 3), created_by: created_by_user) }

    before do
      Timecop.freeze(Time.utc(2022, 6, 3))
      create(:lettings_log, startdate: Time.utc(2022, 6, 3))
    end

    after do
      Timecop.unfreeze
    end

    context "when searching logs" do
      let!(:lettings_log_to_search) { create(:lettings_log, :completed) }

      before do
        create_list(:lettings_log, 5, :completed)
      end

      describe "#filter_by_id" do
        it "allows searching by a log ID" do
          result = described_class.filter_by_id(lettings_log_to_search.id.to_s)
          expect(result.count).to eq(1)
          expect(result.first.id).to eq lettings_log_to_search.id
        end
      end

      describe "#filter_by_tenant_code" do
        it "allows searching by a Tenant Code" do
          result = described_class.filter_by_tenant_code(lettings_log_to_search.tenancycode)
          expect(result.count).to eq(1)
          expect(result.first.id).to eq lettings_log_to_search.id
        end

        context "when tenant_code has lower case letters" do
          let(:matching_tenant_code_lower_case) { lettings_log_to_search.tenancycode.downcase }

          it "allows searching by a Tenant Code" do
            result = described_class.filter_by_tenant_code(matching_tenant_code_lower_case)
            expect(result.count).to eq(1)
            expect(result.first.id).to eq lettings_log_to_search.id
          end
        end
      end

      describe "#filter_by_propcode" do
        it "allows searching by a Property Reference" do
          result = described_class.filter_by_propcode(lettings_log_to_search.propcode)
          expect(result.count).to eq(1)
          expect(result.first.id).to eq lettings_log_to_search.id
        end

        context "when propcode has lower case letters" do
          let(:matching_propcode_lower_case) { lettings_log_to_search.propcode.downcase }

          it "allows searching by a Property Reference" do
            result = described_class.filter_by_propcode(matching_propcode_lower_case)
            expect(result.count).to eq(1)
            expect(result.first.id).to eq lettings_log_to_search.id
          end
        end
      end

      describe "#filter_by_postcode" do
        it "allows searching by a Property Postcode" do
          result = described_class.filter_by_postcode(lettings_log_to_search.postcode_full)
          expect(result.count).to eq(1)
          expect(result.first.id).to eq lettings_log_to_search.id
        end

        context "when lettings log is supported housing" do
          let(:location) { create(:location, postcode: "W6 0ST") }

          before do
            lettings_log_to_search.update!(needstype: 2, location:)
          end

          it "allows searching by a Property Postcode" do
            result = described_class.filter_by_location_postcode("W6 0ST")
            expect(result.count).to eq(1)
            expect(result.first.id).to eq lettings_log_to_search.id
          end
        end
      end

      describe "#search_by" do
        it "allows searching using ID" do
          result = described_class.search_by(lettings_log_to_search.id.to_s)
          expect(result.count).to eq(1)
          expect(result.first.id).to eq lettings_log_to_search.id
        end

        it "allows searching using tenancy code" do
          result = described_class.search_by(lettings_log_to_search.tenancycode)
          expect(result.count).to eq(1)
          expect(result.first.id).to eq lettings_log_to_search.id
        end

        it "allows searching by a Property Reference" do
          result = described_class.search_by(lettings_log_to_search.propcode)
          expect(result.count).to eq(1)
          expect(result.first.id).to eq lettings_log_to_search.id
        end

        it "allows searching by a Property Postcode" do
          result = described_class.search_by(lettings_log_to_search.postcode_full)
          expect(result.count).to eq(1)
          expect(result.first.id).to eq lettings_log_to_search.id
        end

        context "when lettings log is supported housing" do
          let(:location) { create(:location, postcode: "W6 0ST") }

          before do
            lettings_log_to_search.update!(needstype: 2, location:)
          end

          it "allows searching by a Property Postcode" do
            result = described_class.search_by("W6 0ST")
            expect(result.count).to eq(1)
            expect(result.first.id).to eq lettings_log_to_search.id
          end
        end

        context "when postcode has spaces and lower case letters" do
          let(:matching_postcode_lower_case_with_spaces) { lettings_log_to_search.postcode_full.downcase.chars.insert(3, " ").join }

          it "allows searching by a Property Postcode" do
            result = described_class.search_by(matching_postcode_lower_case_with_spaces)
            expect(result.count).to eq(1)
            expect(result.first.id).to eq lettings_log_to_search.id
          end
        end
      end
    end

    context "when filtering by year" do
      before do
        Timecop.freeze(Time.utc(2021, 5, 3))
      end

      after do
        Timecop.unfreeze
      end

      it "allows filtering on a single year" do
        expect(described_class.filter_by_years(%w[2021]).count).to eq(2)
      end

      it "allows filtering by multiple years using OR" do
        expect(described_class.filter_by_years(%w[2021 2022]).count).to eq(3)
      end

      it "can filter by year(s) AND status" do
        expect(described_class.filter_by_years(%w[2021 2022]).filter_by_status("completed").count).to eq(1)
      end

      it "filters based on date boundaries correctly" do
        lettings_log_1.startdate = Time.zone.local(2022, 4, 1)
        lettings_log_1.save!(validate: false)
        lettings_log_2.startdate = Time.zone.local(2022, 3, 31)
        lettings_log_2.save!(validate: false)

        expect(described_class.filter_by_years(%w[2021]).count).to eq(1)
        expect(described_class.filter_by_years(%w[2022]).count).to eq(2)
      end
    end

    context "when filtering by organisation" do
      let(:organisation_1) { create(:organisation) }
      let(:organisation_2) { create(:organisation) }
      let(:organisation_3) { create(:organisation) }

      before do
        create(:lettings_log, :in_progress, owning_organisation: organisation_1, managing_organisation: organisation_1, created_by: nil)
        create(:lettings_log, :completed, owning_organisation: organisation_1, managing_organisation: organisation_2, created_by: nil)
        create(:lettings_log, :completed, owning_organisation: organisation_2, managing_organisation: organisation_1, created_by: nil)
        create(:lettings_log, :completed, owning_organisation: organisation_2, managing_organisation: organisation_2, created_by: nil)
      end

      it "filters by given organisation" do
        expect(described_class.filter_by_organisation([organisation_1]).count).to eq(3)
        expect(described_class.filter_by_organisation([organisation_1, organisation_2]).count).to eq(4)
        expect(described_class.filter_by_organisation([organisation_3]).count).to eq(0)
      end
    end

    context "when filtering by owning organisation" do
      let(:organisation_1) { create(:organisation) }
      let(:organisation_2) { create(:organisation) }
      let(:organisation_3) { create(:organisation) }

      before do
        create(:lettings_log, :in_progress, owning_organisation: organisation_1, managing_organisation: organisation_1, created_by: nil)
        create(:lettings_log, :completed, owning_organisation: organisation_1, managing_organisation: organisation_2, created_by: nil)
        create(:lettings_log, :completed, owning_organisation: organisation_2, managing_organisation: organisation_1, created_by: nil)
        create(:lettings_log, :completed, owning_organisation: organisation_2, managing_organisation: organisation_2, created_by: nil)
      end

      it "filters by given owning organisation" do
        expect(described_class.filter_by_owning_organisation([organisation_1]).count).to eq(2)
        expect(described_class.filter_by_owning_organisation([organisation_1, organisation_2]).count).to eq(4)
        expect(described_class.filter_by_owning_organisation([organisation_3]).count).to eq(0)
      end
    end

    context "when filtering on status" do
      it "allows filtering on a single status" do
        expect(described_class.filter_by_status(%w[in_progress]).count).to eq(2)
      end

      it "allows filtering on multiple statuses" do
        expect(described_class.filter_by_status(%w[in_progress completed]).count).to eq(3)
      end
    end

    context "when filtering by user" do
      before do
        PaperTrail::Version.find_by(item_id: lettings_log_1.id, event: "create").update!(whodunnit: created_by_user.to_global_id.uri.to_s)
        PaperTrail::Version.find_by(item_id: lettings_log_2.id, event: "create").update!(whodunnit: created_by_user.to_global_id.uri.to_s)
      end

      it "allows filtering on current user" do
        expect(described_class.filter_by_user(%w[yours], created_by_user).count).to eq(2)
      end

      it "returns all logs when all logs selected" do
        expect(described_class.filter_by_user(%w[all], created_by_user).count).to eq(3)
      end

      it "returns all logs when all and your users selected" do
        expect(described_class.filter_by_user(%w[all yours], created_by_user).count).to eq(3)
      end
    end

    context "when filtering duplicate logs" do
      let(:log) { create(:lettings_log, :duplicate) }
      let!(:duplicate_log) { create(:lettings_log, :duplicate) }

      it "returns all duplicate logs for given log" do
        expect(described_class.duplicate_logs(log).count).to eq(1)
      end

      it "returns duplicate log" do
        expect(described_class.duplicate_logs(log)).to include(duplicate_log)
      end

      it "does not return the given log" do
        expect(described_class.duplicate_logs(log)).not_to include(log)
      end

      context "when there is a deleted duplicate log" do
        let!(:deleted_duplicate_log) { create(:lettings_log, :duplicate, discarded_at: Time.zone.now) }

        it "does not return the deleted log as a duplicate" do
          expect(described_class.duplicate_logs(log)).not_to include(deleted_duplicate_log)
        end
      end

      context "when there is a log with a different start date" do
        let!(:different_start_date_log) { create(:lettings_log, :duplicate, startdate: Time.zone.tomorrow) }

        it "does not return a log with a different start date as a duplicate" do
          expect(described_class.duplicate_logs(log)).not_to include(different_start_date_log)
        end
      end

      context "when there is a log with a different age1" do
        let!(:different_age1) { create(:lettings_log, :duplicate, age1: 50) }

        it "does not return a log with a different age1 as a duplicate" do
          expect(described_class.duplicate_logs(log)).not_to include(different_age1)
        end
      end

      context "when there is a log with a different sex1" do
        let!(:different_sex1) { create(:lettings_log, :duplicate, sex1: "F") }

        it "does not return a log with a different sex1 as a duplicate" do
          expect(described_class.duplicate_logs(log)).not_to include(different_sex1)
        end
      end

      context "when there is a log with a different ecstat1" do
        let!(:different_ecstat1) { create(:lettings_log, :duplicate, ecstat1: 1) }

        it "does not return a log with a different ecstat1 as a duplicate" do
          expect(described_class.duplicate_logs(log)).not_to include(different_ecstat1)
        end
      end

      context "when there is a log with a different tcharge" do
        let!(:different_tcharge) { create(:lettings_log, :duplicate, brent: 100) }

        it "does not return a log with a different tcharge as a duplicate" do
          expect(described_class.duplicate_logs(log)).not_to include(different_tcharge)
        end
      end

      context "when there is a log with a different tenancycode" do
        let!(:different_tenancycode) { create(:lettings_log, :duplicate, tenancycode: "different") }

        it "does not return a log with a different tenancycode as a duplicate" do
          expect(described_class.duplicate_logs(log)).not_to include(different_tenancycode)
        end
      end

      context "when there is a log with a different postcode_full" do
        let!(:different_postcode_full) { create(:lettings_log, :duplicate, postcode_full: "B1 1AA") }

        it "does not return a log with a different postcode_full as a duplicate" do
          expect(described_class.duplicate_logs(log)).not_to include(different_postcode_full)
        end
      end

      context "when there is a log with nil values for duplicate check fields" do
        let!(:duplicate_check_fields_not_given) { create(:lettings_log, :duplicate, age1: nil, sex1: nil, ecstat1: nil, postcode_known: 2, postcode_full: nil) }

        it "does not return a log with nil values as a duplicate" do
          log.update!(age1: nil, sex1: nil, ecstat1: nil, postcode_known: 2, postcode_full: nil)
          expect(described_class.duplicate_logs(log)).not_to include(duplicate_check_fields_not_given)
        end
      end

      context "when there is a log with nil values for tenancycode" do
        let!(:tenancycode_not_given) { create(:lettings_log, :duplicate, tenancycode: nil) }

        it "returns the log as a duplicate if tenancy code is nil" do
          log.update!(tenancycode: nil)
          expect(described_class.duplicate_logs(log)).to include(tenancycode_not_given)
        end
      end

      context "when there is a log with age1 not known" do
        let!(:age1_not_known) { create(:lettings_log, :duplicate, age1_known: 1, age1: nil) }

        it "returns the log as a duplicate if age1 is not known" do
          log.update!(age1_known: 1, age1: nil)
          expect(described_class.duplicate_logs(log)).to include(age1_not_known)
        end
      end

      context "when there is a duplicate supported housing log" do
        let(:scheme) { create(:scheme) }
        let(:location) { create(:location, scheme:) }
        let(:location_2) { create(:location, scheme:) }
        let(:supported_housing_log) { create(:lettings_log, :duplicate, needstype: 2, location:, scheme:) }
        let!(:duplicate_supported_housing_log) { create(:lettings_log, :duplicate, needstype: 2, location:, scheme:) }

        it "returns the log as a duplicate" do
          expect(described_class.duplicate_logs(supported_housing_log)).to include(duplicate_supported_housing_log)
        end

        it "does not return the log if the locations are different" do
          duplicate_supported_housing_log.update!(location: location_2)
          expect(described_class.duplicate_logs(supported_housing_log)).not_to include(duplicate_supported_housing_log)
        end

        it "does not compare tcharge if there are no household charges" do
          supported_housing_log.update!(household_charge: 1, supcharg: nil, brent: nil, scharge: nil, pscharge: nil, tcharge: nil)
          duplicate_supported_housing_log.update!(household_charge: 1, supcharg: nil, brent: nil, scharge: nil, pscharge: nil, tcharge: nil)
          expect(described_class.duplicate_logs(supported_housing_log)).to include(duplicate_supported_housing_log)
        end

        it "compares chcharge if it's a carehome" do
          supported_housing_log.update!(is_carehome: 1, chcharge: 100, supcharg: nil, brent: nil, scharge: nil, pscharge: nil, tcharge: nil)
          duplicate_supported_housing_log.update!(is_carehome: 1, chcharge: 100, supcharg: nil, brent: nil, scharge: nil, pscharge: nil, tcharge: nil)
          expect(described_class.duplicate_logs(supported_housing_log)).to include(duplicate_supported_housing_log)
        end

        it "does not return a duplicate if carehome charge is not given" do
          supported_housing_log.update!(is_carehome: 1, chcharge: nil, supcharg: nil, brent: nil, scharge: nil, pscharge: nil, tcharge: nil)
          duplicate_supported_housing_log.update!(is_carehome: 1, chcharge: nil, supcharg: nil, brent: nil, scharge: nil, pscharge: nil, tcharge: nil)
          expect(described_class.duplicate_logs(supported_housing_log)).not_to include(duplicate_supported_housing_log)
        end
      end
    end
  end

  describe "#retirement_age_for_person" do
    context "when a person gender is Male" do
      let(:lettings_log) { build(:lettings_log, sex1: "M") }

      it "returns the expected retirement age" do
        expect(lettings_log.retirement_age_for_person_1).to eq(67)
      end

      it "returns the expected plural" do
        expect(lettings_log.plural_gender_for_person_1).to eq("male and non-binary people")
      end
    end

    context "when a person gender is Female" do
      let(:lettings_log) { build(:lettings_log, sex2: "F") }

      it "returns the expected retirement age" do
        expect(lettings_log.retirement_age_for_person_2).to eq(60)
      end

      it "returns the expected plural" do
        expect(lettings_log.plural_gender_for_person_2).to eq("females")
      end
    end

    context "when a person gender is Non-Binary" do
      let(:lettings_log) { build(:lettings_log, sex3: "X") }

      it "returns the expected retirement age" do
        expect(lettings_log.retirement_age_for_person_3).to eq(67)
      end

      it "returns the expected plural" do
        expect(lettings_log.plural_gender_for_person_3).to eq("male and non-binary people")
      end
    end

    context "when the person gender is not set" do
      let(:lettings_log) { build(:lettings_log) }

      it "returns nil" do
        expect(lettings_log.retirement_age_for_person_3).to be_nil
      end

      it "returns the expected plural" do
        expect(lettings_log.plural_gender_for_person_3).to be_nil
      end
    end

    context "when a postcode contains unicode characters" do
      let(:lettings_log) { build(:lettings_log, postcode_full: "SR81LS\u00A0") }

      it "triggers a validation error" do
        expect { lettings_log.save! }.to raise_error(ActiveRecord::RecordInvalid, /Enter a postcode in the correct format/)
      end
    end
  end

  describe "#blank_invalid_non_setup_fields!" do
    context "when a setup field is invalid" do
      subject(:model) { described_class.new(needstype: 404) }

      it "does not blank it" do
        model.valid?
        expect { model.blank_invalid_non_setup_fields! }.not_to change(model, :needstype)
      end
    end

    context "when a non setup field is invalid" do
      subject(:model) { build(:lettings_log, :completed, offered: 234) }

      it "blanks it" do
        model.valid?
        expect { model.blank_invalid_non_setup_fields! }.to change(model, :offered)
      end
    end
  end

  describe "#beds_for_la_rent_range" do
    context "when beds nil" do
      let(:lettings_log) { build(:lettings_log, beds: nil) }

      it "returns nil" do
        expect(lettings_log.beds_for_la_rent_range).to be_nil
      end
    end

    context "when beds <= 4" do
      let(:lettings_log) { build(:lettings_log, beds: 4) }

      it "returns number of beds" do
        expect(lettings_log.beds_for_la_rent_range).to eq(4)
      end
    end

    context "when beds > 4" do
      let(:lettings_log) { build(:lettings_log, beds: 40) }

      it "returns max number of beds" do
        expect(lettings_log.beds_for_la_rent_range).to eq(4)
      end
    end
  end

  describe "#collection_period_open?" do
    let(:log) { build(:lettings_log, startdate:) }

    context "when startdate is nil" do
      let(:startdate) { nil }

      it "returns false" do
        expect(log.collection_period_open?).to eq(true)
      end
    end

    context "when older_than_previous_collection_year" do
      let(:previous_collection_start_date) { Time.zone.local(2050, 4, 1) }
      let(:startdate) { previous_collection_start_date - 1.day }

      before do
        allow(log).to receive(:previous_collection_start_date).and_return(previous_collection_start_date)
      end

      it "returns true" do
        expect(log.collection_period_open?).to eq(false)
      end
    end

    context "when form end date is in the future" do
      let(:startdate) { nil }

      before do
        allow(log).to receive_message_chain(:form, :new_logs_end_date).and_return(Time.zone.now + 1.day)
      end

      it "returns true" do
        expect(log.collection_period_open?).to eq(true)
      end
    end

    context "when form end date is in the past" do
      let(:startdate) { Time.zone.local(2020, 4, 1) }

      before do
        allow(log).to receive_message_chain(:form, :new_logs_end_date).and_return(Time.zone.now - 1.day)
      end

      it "returns false" do
        expect(log.collection_period_open?).to eq(false)
      end
    end
  end
end
# rubocop:enable RSpec/MessageChain
