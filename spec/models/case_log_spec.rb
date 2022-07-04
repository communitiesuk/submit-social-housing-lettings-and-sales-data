require "rails_helper"

RSpec.describe CaseLog do
  let(:owning_organisation) { FactoryBot.create(:organisation) }
  let(:different_managing_organisation) { FactoryBot.create(:organisation) }
  let(:created_by_user) { FactoryBot.create(:user) }

  describe "#form" do
    let(:case_log) { FactoryBot.build(:case_log, created_by: created_by_user) }
    let(:case_log_2) { FactoryBot.build(:case_log, startdate: Time.zone.local(2022, 1, 1), created_by: created_by_user) }
    let(:case_log_year_2) { FactoryBot.build(:case_log, startdate: Time.zone.local(2023, 5, 1), created_by: created_by_user) }

    it "has returns the correct form based on the start date" do
      expect(case_log.form_name).to be_nil
      expect(case_log.form).to be_a(Form)
      expect(case_log_2.form_name).to eq("2021_2022")
      expect(case_log_2.form).to be_a(Form)
      expect(case_log_year_2.form_name).to eq("2023_2024")
      expect(case_log_year_2.form).to be_a(Form)
    end

    context "when a date outside the collection window is passed" do
      let(:case_log) { FactoryBot.build(:case_log, startdate: Time.zone.local(2015, 1, 1), created_by: created_by_user) }

      it "returns the first form" do
        expect(case_log.form).to be_a(Form)
        expect(case_log.form.start_date.year).to eq(2021)
      end
    end
  end

  describe "#new" do
    context "when creating a record" do
      let(:case_log) do
        described_class.create(
          owning_organisation:,
          managing_organisation: owning_organisation,
          created_by: created_by_user,
        )
      end

      it "attaches the correct custom validator" do
        expect(case_log._validators.values.flatten.map(&:class))
          .to include(CaseLogValidator)
      end
    end
  end

  describe "#update" do
    let(:case_log) { FactoryBot.create(:case_log, created_by: created_by_user) }
    let(:validator) { case_log._validators[nil].first }

    after do
      case_log.update(age1: 25)
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

    it "validates number of times the property has been relet" do
      expect(validator).to receive(:validate_property_number_of_times_relet)
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

    it "validates accessibility requirements" do
      expect(validator).to receive(:validate_accessibility_requirements)
    end

    it "validates referral" do
      expect(validator).to receive(:validate_referral)
    end
  end

  describe "status" do
    let!(:empty_case_log) { FactoryBot.create(:case_log) }
    let!(:in_progress_case_log) { FactoryBot.create(:case_log, :in_progress) }
    let!(:completed_case_log) { FactoryBot.create(:case_log, :completed) }

    it "is set to not started for an empty case log" do
      expect(empty_case_log.not_started?).to be(true)
      expect(empty_case_log.in_progress?).to be(false)
      expect(empty_case_log.completed?).to be(false)
    end

    it "is set to in progress for a started case log" do
      expect(in_progress_case_log.in_progress?).to be(true)
      expect(in_progress_case_log.not_started?).to be(false)
      expect(in_progress_case_log.completed?).to be(false)
    end

    it "is set to completed for a completed case log" do
      expect(completed_case_log.in_progress?).to be(false)
      expect(completed_case_log.not_started?).to be(false)
      expect(completed_case_log.completed?).to be(true)
    end
  end

  describe "weekly_net_income" do
    let(:net_income) { 5000 }
    let(:case_log) { FactoryBot.build(:case_log, earnings: net_income) }

    it "returns input income if frequency is already weekly" do
      case_log.incfreq = 1
      expect(case_log.weekly_net_income).to eq(net_income)
    end

    it "calculates the correct weekly income from monthly income" do
      case_log.incfreq = 2
      expect(case_log.weekly_net_income).to eq(1154)
    end

    it "calculates the correct weekly income from yearly income" do
      case_log.incfreq = 3
      expect(case_log.weekly_net_income).to eq(96)
    end
  end

  describe "derived variables" do
    let!(:case_log) do
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
      })
    end

    context "when a case log is created in production" do
      before do
        allow(Rails.env).to receive(:production?).and_return(true)
      end

      it "derives that all forms are general needs" do
        case_log = FactoryBot.create(:case_log)
        record_from_db = ActiveRecord::Base.connection.execute("select needstype from case_logs where id=#{case_log.id}").to_a[0]
        expect(record_from_db["needstype"]).to eq(1)
        expect(case_log["needstype"]).to eq(1)
      end
    end

    it "correctly derives and saves partial and full major repairs date" do
      record_from_db = ActiveRecord::Base.connection.execute("select mrcdate from case_logs where id=#{case_log.id}").to_a[0]
      expect(record_from_db["mrcdate"].day).to eq(4)
      expect(record_from_db["mrcdate"].month).to eq(5)
      expect(record_from_db["mrcdate"].year).to eq(2021)
    end

    it "correctly derives and saves partial and full major property void date" do
      record_from_db = ActiveRecord::Base.connection.execute("select voiddate from case_logs where id=#{case_log.id}").to_a[0]
      expect(record_from_db["voiddate"].day).to eq(3)
      expect(record_from_db["voiddate"].month).to eq(3)
      expect(record_from_db["voiddate"].year).to eq(2021)
    end

    it "correctly derives and saves incref" do
      record_from_db = ActiveRecord::Base.connection.execute("select incref from case_logs where id=#{case_log.id}").to_a[0]
      expect(record_from_db["incref"]).to eq(1)
    end

    it "correctly derives and saves renttype" do
      record_from_db = ActiveRecord::Base.connection.execute("select renttype from case_logs where id=#{case_log.id}").to_a[0]
      expect(case_log.renttype).to eq(3)
      expect(record_from_db["renttype"]).to eq(3)
    end

    context "when deriving lettype" do
      context "when the owning organisation is a PRP" do
        before { case_log.owning_organisation.update!(provider_type: 2) }

        context "when the rent type is intermediate rent and supported housing" do
          it "correctly derives and saves lettype" do
            case_log.update!(rent_type: 4, needstype: 2)
            record_from_db = ActiveRecord::Base.connection.execute("select lettype from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.lettype).to eq(10)
            expect(record_from_db["lettype"]).to eq(10)
          end
        end

        context "when the rent type is intermediate rent and general needs housing" do
          it "correctly derives and saves lettype" do
            case_log.update!(rent_type: 4, needstype: 1)
            record_from_db = ActiveRecord::Base.connection.execute("select lettype from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.lettype).to eq(9)
            expect(record_from_db["lettype"]).to eq(9)
          end
        end

        context "when the rent type is affordable rent and supported housing" do
          it "correctly derives and saves lettype" do
            case_log.update!(rent_type: 2, needstype: 2)
            record_from_db = ActiveRecord::Base.connection.execute("select lettype from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.lettype).to eq(6)
            expect(record_from_db["lettype"]).to eq(6)
          end
        end

        context "when the rent type is affordable rent and general needs housing" do
          it "correctly derives and saves lettype" do
            case_log.update!(rent_type: 2, needstype: 1)
            record_from_db = ActiveRecord::Base.connection.execute("select lettype from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.lettype).to eq(5)
            expect(record_from_db["lettype"]).to eq(5)
          end
        end

        context "when the rent type is social rent and supported housing" do
          it "correctly derives and saves lettype" do
            case_log.update!(rent_type: 0, needstype: 2)
            record_from_db = ActiveRecord::Base.connection.execute("select lettype from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.lettype).to eq(2)
            expect(record_from_db["lettype"]).to eq(2)
          end
        end

        context "when the rent type is social rent and general needs housing" do
          it "correctly derives and saves lettype" do
            case_log.update!(rent_type: 0, needstype: 1)
            record_from_db = ActiveRecord::Base.connection.execute("select lettype from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.lettype).to eq(1)
            expect(record_from_db["lettype"]).to eq(1)
          end
        end

        context "when the tenant is not in receipt of applicable benefits" do
          it "correctly resets total shortfall" do
            case_log.update!(hbrentshortfall: 2, wtshortfall: 100, hb: 9)
            record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wtshortfall).to be_nil
            expect(record_from_db["wtshortfall"]).to be_nil
          end
        end

        context "when rent is paid bi-weekly" do
          it "correctly derives and saves weekly rent" do
            case_log.update!(brent: 100, period: 2)
            record_from_db = ActiveRecord::Base.connection.execute("select wrent from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wrent).to eq(50.0)
            expect(record_from_db["wrent"]).to eq(50.0)
          end

          it "correctly derives and saves weekly service charge" do
            case_log.update!(scharge: 70, period: 2)
            record_from_db = ActiveRecord::Base.connection.execute("select wscharge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wscharge).to eq(35.0)
            expect(record_from_db["wscharge"]).to eq(35.0)
          end

          it "correctly derives and saves weekly personal service charge" do
            case_log.update!(pscharge: 60, period: 2)
            record_from_db = ActiveRecord::Base.connection.execute("select wpschrge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wpschrge).to eq(30.0)
            expect(record_from_db["wpschrge"]).to eq(30.0)
          end

          it "correctly derives and saves weekly support charge" do
            case_log.update!(supcharg: 80, period: 2)
            record_from_db = ActiveRecord::Base.connection.execute("select wsupchrg from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(40.0)
            expect(record_from_db["wsupchrg"]).to eq(40.0)
          end

          it "correctly derives and saves weekly total charge" do
            case_log.update!(tcharge: 100, period: 2)
            record_from_db = ActiveRecord::Base.connection.execute("select wtcharge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wtcharge).to eq(50.0)
            expect(record_from_db["wtcharge"]).to eq(50.0)
          end

          context "when the tenant has an outstanding amount after benefits" do
            context "when tenant is in receipt of housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 1, tshortfall: 100, period: 2, hb: 1)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(50.0)
                expect(record_from_db["wtshortfall"]).to eq(50.0)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 1, tshortfall: 100, period: 2, hb: 6)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(50.0)
                expect(record_from_db["wtshortfall"]).to eq(50.0)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 1, tshortfall: 100, period: 2, hb: 8)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(50.0)
                expect(record_from_db["wtshortfall"]).to eq(50.0)
              end
            end
          end

          it "correctly derives floats" do
            case_log.update!(supcharg: 60.12, pscharge: 50.13, scharge: 60.98, brent: 60.97, period: 2)
            record_from_db = ActiveRecord::Base.connection.execute("select wtcharge, wsupchrg, wpschrge, wscharge, wrent from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(30.06)
            expect(case_log.wpschrge).to eq(25.06)
            expect(case_log.wscharge).to eq(30.49)
            expect(case_log.wrent).to eq(30.49)
            expect(case_log.wtcharge).to eq(116.1)
            expect(record_from_db["wsupchrg"]).to eq(30.06)
            expect(record_from_db["wpschrge"]).to eq(25.06)
            expect(record_from_db["wscharge"]).to eq(30.49)
            expect(record_from_db["wrent"]).to eq(30.49)
            expect(record_from_db["wtcharge"]).to eq(116.1)
          end
        end

        context "when rent is paid every 4 weeks" do
          it "correctly derives and saves weekly rent" do
            case_log.update!(brent: 120, period: 3)
            record_from_db = ActiveRecord::Base.connection.execute("select wrent from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wrent).to eq(30.0)
            expect(record_from_db["wrent"]).to eq(30.0)
          end

          it "correctly derives and saves weekly service charge" do
            case_log.update!(scharge: 120, period: 3)
            record_from_db = ActiveRecord::Base.connection.execute("select wscharge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wscharge).to eq(30.0)
            expect(record_from_db["wscharge"]).to eq(30.0)
          end

          it "correctly derives and saves weekly personal service charge" do
            case_log.update!(pscharge: 120, period: 3)
            record_from_db = ActiveRecord::Base.connection.execute("select wpschrge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wpschrge).to eq(30.0)
            expect(record_from_db["wpschrge"]).to eq(30.0)
          end

          it "correctly derives and saves weekly support charge" do
            case_log.update!(supcharg: 120, period: 3)
            record_from_db = ActiveRecord::Base.connection.execute("select wsupchrg from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(30.0)
            expect(record_from_db["wsupchrg"]).to eq(30.0)
          end

          it "correctly derives and saves weekly total charge" do
            case_log.update!(tcharge: 120, period: 3)
            record_from_db = ActiveRecord::Base.connection.execute("select wtcharge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wtcharge).to eq(30.0)
            expect(record_from_db["wtcharge"]).to eq(30.0)
          end

          context "when the tenant has an outstanding amount after benefits" do
            context "when tenant is in receipt of housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 1, tshortfall: 120, period: 3, hb: 1)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(30.0)
                expect(record_from_db["wtshortfall"]).to eq(30.0)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 1, tshortfall: 120, period: 3, hb: 6)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(30.0)
                expect(record_from_db["wtshortfall"]).to eq(30.0)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 1, tshortfall: 120, period: 3, hb: 8)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(30.0)
                expect(record_from_db["wtshortfall"]).to eq(30.0)
              end
            end
          end

          it "correctly derives floats" do
            case_log.update!(supcharg: 100.12, pscharge: 100.13, scharge: 100.98, brent: 100.97, period: 3)
            record_from_db = ActiveRecord::Base.connection.execute("select wtcharge, wsupchrg, wpschrge, wscharge, wrent from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(25.03)
            expect(case_log.wpschrge).to eq(25.03)
            expect(case_log.wscharge).to eq(25.24)
            expect(case_log.wrent).to eq(25.24)
            expect(case_log.wtcharge).to eq(100.55)
            expect(record_from_db["wsupchrg"]).to eq(25.03)
            expect(record_from_db["wpschrge"]).to eq(25.03)
            expect(record_from_db["wscharge"]).to eq(25.24)
            expect(record_from_db["wrent"]).to eq(25.24)
            expect(record_from_db["wtcharge"]).to eq(100.55)
          end
        end

        context "when rent is paid every calendar month" do
          it "correctly derives and saves weekly rent" do
            case_log.update!(brent: 130, period: 4)
            record_from_db = ActiveRecord::Base.connection.execute("select wrent from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wrent).to eq(30.0)
            expect(record_from_db["wrent"]).to eq(30.0)
          end

          it "correctly derives and saves weekly service charge" do
            case_log.update!(scharge: 130, period: 4)
            record_from_db = ActiveRecord::Base.connection.execute("select wscharge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wscharge).to eq(30.0)
            expect(record_from_db["wscharge"]).to eq(30.0)
          end

          it "correctly derives and saves weekly personal service charge" do
            case_log.update!(pscharge: 130, period: 4)
            record_from_db = ActiveRecord::Base.connection.execute("select wpschrge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wpschrge).to eq(30.0)
            expect(record_from_db["wpschrge"]).to eq(30.0)
          end

          it "correctly derives and saves weekly support charge" do
            case_log.update!(supcharg: 130, period: 4)
            record_from_db = ActiveRecord::Base.connection.execute("select wsupchrg from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(30.0)
            expect(record_from_db["wsupchrg"]).to eq(30.0)
          end

          it "correctly derives and saves weekly total charge" do
            case_log.update!(tcharge: 130, period: 4)
            record_from_db = ActiveRecord::Base.connection.execute("select wtcharge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wtcharge).to eq(30.0)
            expect(record_from_db["wtcharge"]).to eq(30.0)
          end

          context "when the tenant has an outstanding amount after benefits" do
            context "when tenant is in receipt of housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 4, hb: 1)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(30.0)
                expect(record_from_db["wtshortfall"]).to eq(30.0)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 4, hb: 6)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(30.0)
                expect(record_from_db["wtshortfall"]).to eq(30.0)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 4, hb: 8)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(30.0)
                expect(record_from_db["wtshortfall"]).to eq(30.0)
              end
            end
          end

          it "correctly derives floats" do
            case_log.update!(supcharg: 100.12, pscharge: 100.13, scharge: 100.98, brent: 100.97, period: 4)
            record_from_db = ActiveRecord::Base.connection.execute("select wtcharge, wsupchrg, wpschrge, wscharge, wrent from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(23.10)
            expect(case_log.wpschrge).to eq(23.11)
            expect(case_log.wscharge).to eq(23.30)
            expect(case_log.wrent).to eq(23.30)
            expect(case_log.wtcharge).to eq(92.82)
            expect(record_from_db["wsupchrg"]).to eq(23.10)
            expect(record_from_db["wpschrge"]).to eq(23.11)
            expect(record_from_db["wscharge"]).to eq(23.30)
            expect(record_from_db["wrent"]).to eq(23.30)
            expect(record_from_db["wtcharge"]).to eq(92.82)
          end
        end

        context "when rent is paid weekly for 50 weeks" do
          it "correctly derives and saves weekly rent" do
            case_log.update!(brent: 130, period: 5)
            record_from_db = ActiveRecord::Base.connection.execute("select wrent from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wrent).to eq(125.0)
            expect(record_from_db["wrent"]).to eq(125.0)
          end

          it "correctly derives and saves weekly service charge" do
            case_log.update!(scharge: 20, period: 5)
            record_from_db = ActiveRecord::Base.connection.execute("select wscharge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wscharge).to eq(19.23)
            expect(record_from_db["wscharge"]).to eq(19.23)
          end

          it "correctly derives and saves weekly personal service charge" do
            case_log.update!(pscharge: 20, period: 5)
            record_from_db = ActiveRecord::Base.connection.execute("select wpschrge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wpschrge).to eq(19.23)
            expect(record_from_db["wpschrge"]).to eq(19.23)
          end

          it "correctly derives and saves weekly support charge" do
            case_log.update!(supcharg: 20, period: 5)
            record_from_db = ActiveRecord::Base.connection.execute("select wsupchrg from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(19.23)
            expect(record_from_db["wsupchrg"]).to eq(19.23)
          end

          it "correctly derives and saves weekly total charge" do
            case_log.update!(tcharge: 130, period: 5)
            record_from_db = ActiveRecord::Base.connection.execute("select wtcharge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wtcharge).to eq(125.0)
            expect(record_from_db["wtcharge"]).to eq(125.0)
          end

          context "when the tenant has an outstanding amount after benefits" do
            context "when tenant is in receipt of housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 5, hb: 1)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(125.0)
                expect(record_from_db["wtshortfall"]).to eq(125.0)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 5, hb: 6)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(125.0)
                expect(record_from_db["wtshortfall"]).to eq(125.0)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 5, hb: 8)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(125.0)
                expect(record_from_db["wtshortfall"]).to eq(125.0)
              end
            end
          end

          it "correctly derives floats" do
            case_log.update!(supcharg: 20.12, pscharge: 20.13, scharge: 20.98, brent: 100.97, period: 5)
            record_from_db = ActiveRecord::Base.connection.execute("select wtcharge, wsupchrg, wpschrge, wscharge, wrent from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(19.35)
            expect(case_log.wpschrge).to eq(19.36)
            expect(case_log.wscharge).to eq(20.17)
            expect(case_log.wrent).to eq(97.09)
            expect(case_log.wtcharge).to eq(155.96)
            expect(record_from_db["wsupchrg"]).to eq(19.35)
            expect(record_from_db["wpschrge"]).to eq(19.36)
            expect(record_from_db["wscharge"]).to eq(20.17)
            expect(record_from_db["wrent"]).to eq(97.09)
            expect(record_from_db["wtcharge"]).to eq(155.96)
          end
        end

        context "when rent is paid weekly for 49 weeks" do
          it "correctly derives and saves weekly rent" do
            case_log.update!(brent: 130, period: 6)
            record_from_db = ActiveRecord::Base.connection.execute("select wrent from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wrent).to eq(122.5)
            expect(record_from_db["wrent"]).to eq(122.5)
          end

          it "correctly derives and saves weekly service charge" do
            case_log.update!(scharge: 30, period: 6)
            record_from_db = ActiveRecord::Base.connection.execute("select wscharge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wscharge).to eq(28.27)
            expect(record_from_db["wscharge"]).to eq(28.27)
          end

          it "correctly derives and saves weekly personal service charge" do
            case_log.update!(pscharge: 30, period: 6)
            record_from_db = ActiveRecord::Base.connection.execute("select wpschrge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wpschrge).to eq(28.27)
            expect(record_from_db["wpschrge"]).to eq(28.27)
          end

          it "correctly derives and saves weekly support charge" do
            case_log.update!(supcharg: 30, period: 6)
            record_from_db = ActiveRecord::Base.connection.execute("select wsupchrg from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(28.27)
            expect(record_from_db["wsupchrg"]).to eq(28.27)
          end

          it "correctly derives and saves weekly total charge" do
            case_log.update!(tcharge: 130, period: 6)
            record_from_db = ActiveRecord::Base.connection.execute("select wtcharge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wtcharge).to eq(122.5)
            expect(record_from_db["wtcharge"]).to eq(122.5)
          end

          context "when the tenant has an outstanding amount after benefits" do
            context "when tenant is in receipt of housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 6, hb: 1)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(122.5)
                expect(record_from_db["wtshortfall"]).to eq(122.5)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 6, hb: 6)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(122.5)
                expect(record_from_db["wtshortfall"]).to eq(122.5)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 6, hb: 8)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(122.5)
                expect(record_from_db["wtshortfall"]).to eq(122.5)
              end
            end
          end

          it "correctly derives floats" do
            case_log.update!(supcharg: 30.12, pscharge: 30.13, scharge: 30.98, brent: 100.97, period: 6)
            record_from_db = ActiveRecord::Base.connection.execute("select wtcharge, wsupchrg, wpschrge, wscharge, wrent from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(28.38)
            expect(case_log.wpschrge).to eq(28.39)
            expect(case_log.wscharge).to eq(29.19)
            expect(case_log.wrent).to eq(95.14)
            expect(case_log.wtcharge).to eq(181.11)
            expect(record_from_db["wsupchrg"]).to eq(28.38)
            expect(record_from_db["wpschrge"]).to eq(28.39)
            expect(record_from_db["wscharge"]).to eq(29.19)
            expect(record_from_db["wrent"]).to eq(95.14)
            expect(record_from_db["wtcharge"]).to eq(181.11)
          end
        end

        context "when rent is paid weekly for 48 weeks" do
          it "correctly derives and saves weekly rent" do
            case_log.update!(brent: 130, period: 7)
            record_from_db = ActiveRecord::Base.connection.execute("select wrent from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wrent).to eq(120.0)
            expect(record_from_db["wrent"]).to eq(120.0)
          end

          it "correctly derives and saves weekly service charge" do
            case_log.update!(scharge: 30, period: 7)
            record_from_db = ActiveRecord::Base.connection.execute("select wscharge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wscharge).to eq(27.69)
            expect(record_from_db["wscharge"]).to eq(27.69)
          end

          it "correctly derives and saves weekly personal service charge" do
            case_log.update!(pscharge: 30, period: 7)
            record_from_db = ActiveRecord::Base.connection.execute("select wpschrge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wpschrge).to eq(27.69)
            expect(record_from_db["wpschrge"]).to eq(27.69)
          end

          it "correctly derives and saves weekly support charge" do
            case_log.update!(supcharg: 30, period: 7)
            record_from_db = ActiveRecord::Base.connection.execute("select wsupchrg from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(27.69)
            expect(record_from_db["wsupchrg"]).to eq(27.69)
          end

          it "correctly derives and saves weekly total charge" do
            case_log.update!(tcharge: 130, period: 7)
            record_from_db = ActiveRecord::Base.connection.execute("select wtcharge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wtcharge).to eq(120.0)
            expect(record_from_db["wtcharge"]).to eq(120.0)
          end

          context "when the tenant has an outstanding amount after benefits" do
            context "when tenant is in receipt of housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 7, hb: 1)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(120.0)
                expect(record_from_db["wtshortfall"]).to eq(120.0)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 7, hb: 6)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(120.0)
                expect(record_from_db["wtshortfall"]).to eq(120.0)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 7, hb: 8)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(120.0)
                expect(record_from_db["wtshortfall"]).to eq(120.0)
              end
            end
          end

          it "correctly derives floats" do
            case_log.update!(supcharg: 30.12, pscharge: 30.13, scharge: 30.98, brent: 100.97, period: 7)
            record_from_db = ActiveRecord::Base.connection.execute("select wtcharge, wsupchrg, wpschrge, wscharge, wrent from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(27.8)
            expect(case_log.wpschrge).to eq(27.81)
            expect(case_log.wscharge).to eq(28.6)
            expect(case_log.wrent).to eq(93.20)
            expect(case_log.wtcharge).to eq(177.42)
            expect(record_from_db["wsupchrg"]).to eq(27.8)
            expect(record_from_db["wpschrge"]).to eq(27.81)
            expect(record_from_db["wscharge"]).to eq(28.6)
            expect(record_from_db["wrent"]).to eq(93.20)
            expect(record_from_db["wtcharge"]).to eq(177.42)
          end
        end

        context "when rent is paid weekly for 47 weeks" do
          it "correctly derives and saves weekly rent" do
            case_log.update!(brent: 130, period: 8)
            record_from_db = ActiveRecord::Base.connection.execute("select wrent from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wrent).to eq(117.5)
            expect(record_from_db["wrent"]).to eq(117.5)
          end

          it "correctly derives and saves weekly service charge" do
            case_log.update!(scharge: 30, period: 8)
            record_from_db = ActiveRecord::Base.connection.execute("select wscharge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wscharge).to eq(27.12)
            expect(record_from_db["wscharge"]).to eq(27.12)
          end

          it "correctly derives and saves weekly personal service charge" do
            case_log.update!(pscharge: 30, period: 8)
            record_from_db = ActiveRecord::Base.connection.execute("select wpschrge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wpschrge).to eq(27.12)
            expect(record_from_db["wpschrge"]).to eq(27.12)
          end

          it "correctly derives and saves weekly support charge" do
            case_log.update!(supcharg: 30, period: 8)
            record_from_db = ActiveRecord::Base.connection.execute("select wsupchrg from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(27.12)
            expect(record_from_db["wsupchrg"]).to eq(27.12)
          end

          it "correctly derives and saves weekly total charge" do
            case_log.update!(tcharge: 130, period: 8)
            record_from_db = ActiveRecord::Base.connection.execute("select wtcharge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wtcharge).to eq(117.5)
            expect(record_from_db["wtcharge"]).to eq(117.5)
          end

          context "when the tenant has an outstanding amount after benefits" do
            context "when tenant is in receipt of housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 8, hb: 1)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(117.5)
                expect(record_from_db["wtshortfall"]).to eq(117.5)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 8, hb: 6)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(117.5)
                expect(record_from_db["wtshortfall"]).to eq(117.5)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 8, hb: 8)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(117.5)
                expect(record_from_db["wtshortfall"]).to eq(117.5)
              end
            end
          end

          it "correctly derives floats" do
            case_log.update!(supcharg: 30.12, pscharge: 30.13, scharge: 30.98, brent: 100.97, period: 8)
            record_from_db = ActiveRecord::Base.connection.execute("select wtcharge, wsupchrg, wpschrge, wscharge, wrent from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(27.22)
            expect(case_log.wpschrge).to eq(27.23)
            expect(case_log.wscharge).to eq(28)
            expect(case_log.wrent).to eq(91.26)
            expect(case_log.wtcharge).to eq(173.72)
            expect(record_from_db["wsupchrg"]).to eq(27.22)
            expect(record_from_db["wpschrge"]).to eq(27.23)
            expect(record_from_db["wscharge"]).to eq(28)
            expect(record_from_db["wrent"]).to eq(91.26)
            expect(record_from_db["wtcharge"]).to eq(173.72)
          end
        end

        context "when rent is paid weekly for 46 weeks" do
          it "correctly derives and saves weekly rent" do
            case_log.update!(brent: 130, period: 9)
            record_from_db = ActiveRecord::Base.connection.execute("select wrent from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wrent).to eq(115.0)
            expect(record_from_db["wrent"]).to eq(115.0)
          end

          it "correctly derives and saves weekly service charge" do
            case_log.update!(scharge: 30, period: 9)
            record_from_db = ActiveRecord::Base.connection.execute("select wscharge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wscharge).to eq(26.54)
            expect(record_from_db["wscharge"]).to eq(26.54)
          end

          it "correctly derives and saves weekly personal service charge" do
            case_log.update!(pscharge: 30, period: 9)
            record_from_db = ActiveRecord::Base.connection.execute("select wpschrge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wpschrge).to eq(26.54)
            expect(record_from_db["wpschrge"]).to eq(26.54)
          end

          it "correctly derives and saves weekly support charge" do
            case_log.update!(supcharg: 30, period: 9)
            record_from_db = ActiveRecord::Base.connection.execute("select wsupchrg from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(26.54)
            expect(record_from_db["wsupchrg"]).to eq(26.54)
          end

          it "correctly derives and saves weekly total charge" do
            case_log.update!(tcharge: 130, period: 9)
            record_from_db = ActiveRecord::Base.connection.execute("select wtcharge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wtcharge).to eq(115.0)
            expect(record_from_db["wtcharge"]).to eq(115.0)
          end

          context "when the tenant has an outstanding amount after benefits" do
            context "when tenant is in receipt of housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 9, hb: 1)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(115.0)
                expect(record_from_db["wtshortfall"]).to eq(115.0)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 9, hb: 6)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(115.0)
                expect(record_from_db["wtshortfall"]).to eq(115.0)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 9, hb: 8)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(115.0)
                expect(record_from_db["wtshortfall"]).to eq(115.0)
              end
            end
          end

          it "correctly derives floats" do
            case_log.update!(supcharg: 30.12, pscharge: 30.13, scharge: 30.98, brent: 100.97, period: 9)
            record_from_db = ActiveRecord::Base.connection.execute("select wtcharge, wsupchrg, wpschrge, wscharge, wrent from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(26.64)
            expect(case_log.wpschrge).to eq(26.65)
            expect(case_log.wscharge).to eq(27.41)
            expect(case_log.wrent).to eq(89.32)
            expect(case_log.wtcharge).to eq(170.02)
            expect(record_from_db["wsupchrg"]).to eq(26.64)
            expect(record_from_db["wpschrge"]).to eq(26.65)
            expect(record_from_db["wscharge"]).to eq(27.41)
            expect(record_from_db["wrent"]).to eq(89.32)
            expect(record_from_db["wtcharge"]).to eq(170.02)
          end
        end

        context "when rent is paid weekly for 52 weeks" do
          it "correctly derives and saves weekly rent" do
            case_log.update!(brent: 130, period: 1)
            record_from_db = ActiveRecord::Base.connection.execute("select wrent from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wrent).to eq(130.0)
            expect(record_from_db["wrent"]).to eq(130.0)
          end

          it "correctly derives and saves weekly service charge" do
            case_log.update!(scharge: 30, period: 1)
            record_from_db = ActiveRecord::Base.connection.execute("select wscharge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wscharge).to eq(30.0)
            expect(record_from_db["wscharge"]).to eq(30.0)
          end

          it "correctly derives and saves weekly personal service charge" do
            case_log.update!(pscharge: 30, period: 1)
            record_from_db = ActiveRecord::Base.connection.execute("select wpschrge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wpschrge).to eq(30.0)
            expect(record_from_db["wpschrge"]).to eq(30.0)
          end

          it "correctly derives and saves weekly support charge" do
            case_log.update!(supcharg: 30, period: 1)
            record_from_db = ActiveRecord::Base.connection.execute("select wsupchrg from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(30.0)
            expect(record_from_db["wsupchrg"]).to eq(30.0)
          end

          it "correctly derives and saves weekly total charge" do
            case_log.update!(tcharge: 30, period: 1)
            record_from_db = ActiveRecord::Base.connection.execute("select wtcharge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wtcharge).to eq(30.0)
            expect(record_from_db["wtcharge"]).to eq(30.0)
          end

          context "when the tenant has an outstanding amount after benefits" do
            context "when tenant is in receipt of housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 1, hb: 1)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(130.0)
                expect(record_from_db["wtshortfall"]).to eq(130.0)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 1, hb: 6)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(130.0)
                expect(record_from_db["wtshortfall"]).to eq(130.0)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 1, tshortfall: 130, period: 1, hb: 8)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(130.0)
                expect(record_from_db["wtshortfall"]).to eq(130.0)
              end
            end
          end

          it "correctly derives floats" do
            case_log.update!(supcharg: 30.12, pscharge: 25.13, scharge: 30.98, brent: 100.97, period: 1)
            record_from_db = ActiveRecord::Base.connection.execute("select wtcharge, wsupchrg, wpschrge, wscharge, wrent from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(30.12)
            expect(case_log.wpschrge).to eq(25.13)
            expect(case_log.wscharge).to eq(30.98)
            expect(case_log.wrent).to eq(100.97)
            expect(case_log.wtcharge).to eq(187.2)
            expect(record_from_db["wsupchrg"]).to eq(30.12)
            expect(record_from_db["wpschrge"]).to eq(25.13)
            expect(record_from_db["wscharge"]).to eq(30.98)
            expect(record_from_db["wrent"]).to eq(100.97)
            expect(record_from_db["wtcharge"]).to eq(187.2)
          end
        end
      end

      context "when the owning organisation is a LA" do
        before { case_log.owning_organisation.update!(provider_type: "LA") }

        context "when the rent type is intermediate rent and supported housing" do
          it "correctly derives and saves lettype" do
            case_log.update!(rent_type: 4, needstype: 2)
            record_from_db = ActiveRecord::Base.connection.execute("select lettype from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.lettype).to eq(12)
            expect(record_from_db["lettype"]).to eq(12)
          end
        end

        context "when the rent type is intermediate rent and general needs housing" do
          it "correctly derives and saves lettype" do
            case_log.update!(rent_type: 4, needstype: 1)
            record_from_db = ActiveRecord::Base.connection.execute("select lettype from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.lettype).to eq(11)
            expect(record_from_db["lettype"]).to eq(11)
          end
        end

        context "when the rent type is affordable rent and supported housing" do
          it "correctly derives and saves lettype" do
            case_log.update!(rent_type: 2, needstype: 2)
            record_from_db = ActiveRecord::Base.connection.execute("select lettype from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.lettype).to eq(8)
            expect(record_from_db["lettype"]).to eq(8)
          end
        end

        context "when the rent type is affordable rent and general needs housing" do
          it "correctly derives and saves lettype" do
            case_log.update!(rent_type: 2, needstype: 1)
            record_from_db = ActiveRecord::Base.connection.execute("select lettype from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.lettype).to eq(7)
            expect(record_from_db["lettype"]).to eq(7)
          end
        end

        context "when the rent type is social rent and supported housing" do
          it "correctly derives and saves lettype" do
            case_log.update!(rent_type: 0, needstype: 2)
            record_from_db = ActiveRecord::Base.connection.execute("select lettype from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.lettype).to eq(4)
            expect(record_from_db["lettype"]).to eq(4)
          end
        end

        context "when the rent type is social rent and general needs housing" do
          it "correctly derives and saves lettype" do
            case_log.update!(rent_type: 0, needstype: 1)
            record_from_db = ActiveRecord::Base.connection.execute("select lettype from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.lettype).to eq(3)
            expect(record_from_db["lettype"]).to eq(3)
          end
        end
      end
    end

    it "correctly derives and saves day, month, year from start date" do
      record_from_db = ActiveRecord::Base.connection.execute("select startdate from case_logs where id=#{case_log.id}").to_a[0]
      expect(record_from_db["startdate"].day).to eq(10)
      expect(record_from_db["startdate"].month).to eq(10)
      expect(record_from_db["startdate"].year).to eq(2021)
    end

    context "when any charge field is set" do
      before do
        case_log.update!(pscharge: 10)
      end

      it "derives that any blank ones are 0" do
        record_from_db = ActiveRecord::Base.connection.execute("select supcharg, scharge from case_logs where id=#{case_log.id}").to_a[0]
        expect(record_from_db["supcharg"].to_f).to eq(0.0)
        expect(record_from_db["scharge"].to_f).to eq(0.0)
      end
    end

    def check_postcode_fields(postcode_field)
      record_from_db = ActiveRecord::Base.connection.execute("select #{postcode_field} from case_logs where id=#{address_case_log.id}").to_a[0]
      expect(address_case_log[postcode_field]).to eq("M11AE")
      expect(record_from_db[postcode_field]).to eq("M11AE")
    end

    def check_previous_postcode_fields(postcode_field)
      record_from_db = ActiveRecord::Base.connection.execute("select #{postcode_field} from case_logs where id=#{address_case_log.id}").to_a[0]
      expect(address_case_log[postcode_field]).to eq("M11AE")
      expect(record_from_db[postcode_field]).to eq("M11AE")
    end

    context "when saving addresses" do
      before do
        stub_request(:get, /api.postcodes.io/)
          .to_return(status: 200, body: "{\"status\":200,\"result\":{\"admin_district\":\"Manchester\",\"codes\":{\"admin_district\": \"E08000003\"}}}", headers: {})
      end

      let!(:address_case_log) do
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
        address_case_log.update!(postcode_full: "M1 1AE")
        check_property_postcode_fields

        address_case_log.update!(postcode_full: "m1 1ae")
        check_property_postcode_fields

        address_case_log.update!(postcode_full: "m11Ae")
        check_property_postcode_fields

        address_case_log.update!(postcode_full: "m11ae")
        check_property_postcode_fields
      end

      it "correctly infers la" do
        record_from_db = ActiveRecord::Base.connection.execute("select la from case_logs where id=#{address_case_log.id}").to_a[0]
        expect(address_case_log.la).to eq("E08000003")
        expect(record_from_db["la"]).to eq("E08000003")
      end

      it "errors if the property postcode is emptied" do
        expect { address_case_log.update!({ postcode_full: "" }) }
          .to raise_error(ActiveRecord::RecordInvalid, /#{I18n.t("validations.postcode")}/)
      end

      it "errors if the property postcode is not valid" do
        expect { address_case_log.update!({ postcode_full: "invalid_postcode" }) }
          .to raise_error(ActiveRecord::RecordInvalid, /#{I18n.t("validations.postcode")}/)
      end

      context "when the local authority lookup times out" do
        before do
          allow(Timeout).to receive(:timeout).and_raise(Timeout::Error)
        end

        it "logs a warning" do
          expect(Rails.logger).to receive(:warn).with("Postcodes.io lookup timed out")
          address_case_log.update!({ postcode_known: 1, postcode_full: "M1 1AD" })
        end
      end

      it "correctly resets all fields if property postcode not known" do
        address_case_log.update!({ postcode_known: 0 })

        record_from_db = ActiveRecord::Base.connection.execute("select la, postcode_full from case_logs where id=#{address_case_log.id}").to_a[0]
        expect(record_from_db["postcode_full"]).to eq(nil)
        expect(address_case_log.la).to eq(nil)
        expect(record_from_db["la"]).to eq(nil)
      end

      it "changes the LA if property postcode changes from not known to known and provided" do
        address_case_log.update!({ postcode_known: 0 })
        address_case_log.update!({ la: "E09000033" })

        record_from_db = ActiveRecord::Base.connection.execute("select la, postcode_full from case_logs where id=#{address_case_log.id}").to_a[0]
        expect(record_from_db["postcode_full"]).to eq(nil)
        expect(address_case_log.la).to eq("E09000033")
        expect(record_from_db["la"]).to eq("E09000033")

        address_case_log.update!({ postcode_known: 1, postcode_full: "M1 1AD" })

        record_from_db = ActiveRecord::Base.connection.execute("select la, postcode_full from case_logs where id=#{address_case_log.id}").to_a[0]
        expect(record_from_db["postcode_full"]).to eq("M11AD")
        expect(address_case_log.la).to eq("E08000003")
        expect(record_from_db["la"]).to eq("E08000003")
      end
    end

    context "when saving previous address" do
      before do
        stub_request(:get, /api.postcodes.io/)
          .to_return(status: 200, body: "{\"status\":200,\"result\":{\"admin_district\":\"Manchester\", \"codes\":{\"admin_district\": \"E08000003\"}}}", headers: {})
      end

      let!(:address_case_log) do
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
        address_case_log.update!(ppostcode_full: "M1 1AE")
        previous_postcode_fields

        address_case_log.update!(ppostcode_full: "m1 1ae")
        previous_postcode_fields

        address_case_log.update!(ppostcode_full: "m11Ae")
        previous_postcode_fields

        address_case_log.update!(ppostcode_full: "m11ae")
        previous_postcode_fields
      end

      it "correctly infers prevloc" do
        record_from_db = ActiveRecord::Base.connection.execute("select prevloc from case_logs where id=#{address_case_log.id}").to_a[0]
        expect(address_case_log.prevloc).to eq("E08000003")
        expect(record_from_db["prevloc"]).to eq("E08000003")
      end

      it "errors if the previous postcode is emptied" do
        expect { address_case_log.update!({ ppostcode_full: "" }) }
          .to raise_error(ActiveRecord::RecordInvalid, /#{I18n.t("validations.postcode")}/)
      end

      it "errors if the previous postcode is not valid" do
        expect { address_case_log.update!({ ppostcode_full: "invalid_postcode" }) }
          .to raise_error(ActiveRecord::RecordInvalid, /#{I18n.t("validations.postcode")}/)
      end

      it "correctly resets all fields if previous postcode not known" do
        address_case_log.update!({ ppcodenk: 0 })

        record_from_db = ActiveRecord::Base.connection.execute("select prevloc, ppostcode_full from case_logs where id=#{address_case_log.id}").to_a[0]
        expect(record_from_db["ppostcode_full"]).to eq(nil)
        expect(address_case_log.prevloc).to eq(nil)
        expect(record_from_db["prevloc"]).to eq(nil)
      end

      it "correctly resets la if la is not known" do
        address_case_log.update!({ ppcodenk: 0 })
        address_case_log.update!({ previous_la_known: 1, prevloc: "S92000003" })
        record_from_db = ActiveRecord::Base.connection.execute("select prevloc from case_logs where id=#{address_case_log.id}").to_a[0]
        expect(record_from_db["prevloc"]).to eq("S92000003")
        expect(address_case_log.prevloc).to eq("S92000003")

        address_case_log.update!({ previous_la_known: 0 })
        record_from_db = ActiveRecord::Base.connection.execute("select prevloc from case_logs where id=#{address_case_log.id}").to_a[0]
        expect(address_case_log.prevloc).to eq(nil)
        expect(record_from_db["prevloc"]).to eq(nil)
      end

      it "changes the prevloc if previous postcode changes from not known to known and provided" do
        address_case_log.update!({ ppcodenk: 0 })
        address_case_log.update!({ previous_la_known: 1, prevloc: "E09000033" })

        record_from_db = ActiveRecord::Base.connection.execute("select prevloc, ppostcode_full from case_logs where id=#{address_case_log.id}").to_a[0]
        expect(record_from_db["ppostcode_full"]).to eq(nil)
        expect(address_case_log.prevloc).to eq("E09000033")
        expect(record_from_db["prevloc"]).to eq("E09000033")

        address_case_log.update!({ ppcodenk: 0, ppostcode_full: "M1 1AD" })

        record_from_db = ActiveRecord::Base.connection.execute("select prevloc, ppostcode_full from case_logs where id=#{address_case_log.id}").to_a[0]
        expect(record_from_db["ppostcode_full"]).to eq("M11AD")
        expect(address_case_log.prevloc).to eq("E08000003")
        expect(record_from_db["prevloc"]).to eq("E08000003")
      end
    end

    context "when saving rent and charges" do
      let!(:case_log) do
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
        record_from_db = ActiveRecord::Base.connection.execute("select tcharge from case_logs where id=#{case_log.id}").to_a[0]
        expect(record_from_db["tcharge"]).to eq(30.98)
      end
    end

    context "when validating household members derived vars" do
      let!(:household_case_log) do
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
        record_from_db = ActiveRecord::Base.connection.execute("select totchild from case_logs where id=#{household_case_log.id}").to_a[0]
        expect(record_from_db["totchild"]).to eq(3)
      end

      it "correctly derives and saves totelder" do
        record_from_db = ActiveRecord::Base.connection.execute("select totelder from case_logs where id=#{household_case_log.id}").to_a[0]
        expect(record_from_db["totelder"]).to eq(2)
      end

      it "correctly derives and saves totadult" do
        record_from_db = ActiveRecord::Base.connection.execute("select totadult from case_logs where id=#{household_case_log.id}").to_a[0]
        expect(record_from_db["totadult"]).to eq(3)
      end

      it "correctly derives economic status for tenants under 16" do
        record_from_db = ActiveRecord::Base.connection.execute("select ecstat7 from case_logs where id=#{household_case_log.id}").to_a[0]
        expect(record_from_db["ecstat7"]).to eq(9)
      end

      it "correctly resets economic status when age changes from under 16" do
        household_case_log.update!(age7_known: 0, age7: 17)
        record_from_db = ActiveRecord::Base.connection.execute("select ecstat7 from case_logs where id=#{household_case_log.id}").to_a[0]
        expect(record_from_db["ecstat7"]).to eq(nil)
      end
    end

    it "correctly derives and saves has_benefits" do
      record_from_db = ActiveRecord::Base.connection.execute("select has_benefits from case_logs where id=#{case_log.id}").to_a[0]
      expect(record_from_db["has_benefits"]).to eq(1)
    end

    context "when it is a renewal" do
      let!(:case_log) do
        described_class.create({
          managing_organisation: owning_organisation,
          owning_organisation:,
          created_by: created_by_user,
          renewal: 1,
          startdate: Time.zone.local(2021, 4, 10),
        })
      end

      it "correctly derives and saves waityear" do
        record_from_db = ActiveRecord::Base.connection.execute("select waityear from case_logs where id=#{case_log.id}").to_a[0]
        expect(record_from_db["waityear"]).to eq(2)
        expect(case_log["waityear"]).to eq(2)
      end

      it "correctly derives and saves underoccupation_benefitcap if year is 2021" do
        record_from_db = ActiveRecord::Base.connection.execute("select underoccupation_benefitcap from case_logs where id=#{case_log.id}").to_a[0]
        expect(record_from_db["underoccupation_benefitcap"]).to eq(2)
        expect(case_log["underoccupation_benefitcap"]).to eq(2)
      end

      it "correctly derives and saves prevten" do
        case_log.managing_organisation.update!({ provider_type: "PRP" })
        case_log.update!({ needstype: 1 })

        record_from_db = ActiveRecord::Base.connection.execute("select prevten from case_logs where id=#{case_log.id}").to_a[0]
        expect(record_from_db["prevten"]).to eq(32)
        expect(case_log["prevten"]).to eq(32)

        case_log.managing_organisation.update!({ provider_type: "LA" })
        case_log.update!({ needstype: 1 })

        record_from_db = ActiveRecord::Base.connection.execute("select prevten from case_logs where id=#{case_log.id}").to_a[0]
        expect(record_from_db["prevten"]).to eq(30)
        expect(case_log["prevten"]).to eq(30)
      end

      it "correctly derives and saves referral" do
        record_from_db = ActiveRecord::Base.connection.execute("select referral from case_logs where id=#{case_log.id}").to_a[0]
        expect(record_from_db["referral"]).to eq(0)
        expect(case_log["referral"]).to eq(0)
      end
    end

    context "when answering the household characteristics questions" do
      let!(:case_log) do
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
        record_from_db = ActiveRecord::Base.connection.execute("select refused from case_logs where id=#{case_log.id}").to_a[0]
        expect(record_from_db["refused"]).to eq(1)
        expect(case_log["refused"]).to eq(1)
      end
    end

    context "when the data provider is filling in household needs" do
      let!(:case_log) do
        described_class.create({
          managing_organisation: owning_organisation,
          owning_organisation:,
          created_by: created_by_user,
        })
      end

      it "correctly derives and saves housing neeeds as 1" do
        case_log.update!(housingneeds_a: 1)
        record_from_db = ActiveRecord::Base.connection.execute("select housingneeds from case_logs where id=#{case_log.id}").to_a[0]
        expect(record_from_db["housingneeds"]).to eq(1)
      end

      it "correctly derives and saves housing neeeds as 2" do
        case_log.update!(housingneeds_g: 1)
        record_from_db = ActiveRecord::Base.connection.execute("select housingneeds from case_logs where id=#{case_log.id}").to_a[0]
        expect(record_from_db["housingneeds"]).to eq(2)
      end

      it "correctly derives and saves housing neeeds as 3" do
        case_log.update!(housingneeds_h: 1)
        record_from_db = ActiveRecord::Base.connection.execute("select housingneeds from case_logs where id=#{case_log.id}").to_a[0]
        expect(record_from_db["housingneeds"]).to eq(3)
      end
    end

    context "when it is supported housing and a care home charge has been supplied" do
      let!(:case_log) do
        described_class.create({
          managing_organisation: owning_organisation,
          owning_organisation:,
          created_by: created_by_user,
          needstype: 2,
        })
      end

      context "when the care home charge is paid bi-weekly" do
        it "correctly derives and saves weekly care home charge" do
          case_log.update!(chcharge: 100, period: 2)
          record_from_db = ActiveRecord::Base.connection.execute("select wchchrg from case_logs where id=#{case_log.id}").to_a[0]
          expect(case_log.wchchrg).to eq(50.0)
          expect(record_from_db["wchchrg"]).to eq(50.0)
        end

        it "correctly derives floats" do
          case_log.update!(chcharge: 100.12, period: 2)
          record_from_db = ActiveRecord::Base.connection.execute("select wchchrg from case_logs where id=#{case_log.id}").to_a[0]
          expect(case_log.wchchrg).to eq(50.06)
          expect(record_from_db["wchchrg"]).to eq(50.06)
        end
      end

      context "when the care home charge is paid every 4 weeks" do
        it "correctly derives and saves weekly care home charge" do
          case_log.update!(chcharge: 120, period: 3)
          record_from_db = ActiveRecord::Base.connection.execute("select wchchrg from case_logs where id=#{case_log.id}").to_a[0]
          expect(case_log.wchchrg).to eq(30.0)
          expect(record_from_db["wchchrg"]).to eq(30.0)
        end

        it "correctly derives floats" do
          case_log.update!(chcharge: 100.12, period: 3)
          record_from_db = ActiveRecord::Base.connection.execute("select wchchrg from case_logs where id=#{case_log.id}").to_a[0]
          expect(case_log.wchchrg).to eq(25.03)
          expect(record_from_db["wchchrg"]).to eq(25.03)
        end
      end

      context "when the care home charge is paid every calendar month" do
        it "correctly derives and saves weekly care home charge" do
          case_log.update!(chcharge: 130, period: 4)
          record_from_db = ActiveRecord::Base.connection.execute("select wchchrg from case_logs where id=#{case_log.id}").to_a[0]
          expect(case_log.wchchrg).to eq(30.0)
          expect(record_from_db["wchchrg"]).to eq(30.0)
        end

        it "correctly derives floats" do
          case_log.update!(chcharge: 100.12, period: 4)
          record_from_db = ActiveRecord::Base.connection.execute("select wchchrg from case_logs where id=#{case_log.id}").to_a[0]
          expect(case_log.wchchrg).to eq(23.10)
          expect(record_from_db["wchchrg"]).to eq(23.10)
        end
      end

      context "when the care home charge is paid weekly for 50 weeks" do
        it "correctly derives and saves weekly care home charge" do
          case_log.update!(chcharge: 130, period: 5)
          record_from_db = ActiveRecord::Base.connection.execute("select wchchrg from case_logs where id=#{case_log.id}").to_a[0]
          expect(case_log.wchchrg).to eq(125.0)
          expect(record_from_db["wchchrg"]).to eq(125.0)
        end

        it "correctly derives floats" do
          case_log.update!(chcharge: 100.12, period: 5)
          record_from_db = ActiveRecord::Base.connection.execute("select wchchrg from case_logs where id=#{case_log.id}").to_a[0]
          expect(case_log.wchchrg).to eq(96.27)
          expect(record_from_db["wchchrg"]).to eq(96.27)
        end
      end

      context "when the care home charge is paid weekly for 49 weeks" do
        it "correctly derives and saves weekly care home charge" do
          case_log.update!(chcharge: 130, period: 6)
          record_from_db = ActiveRecord::Base.connection.execute("select wchchrg from case_logs where id=#{case_log.id}").to_a[0]
          expect(case_log.wchchrg).to eq(122.5)
          expect(record_from_db["wchchrg"]).to eq(122.5)
        end

        it "correctly derives floats" do
          case_log.update!(chcharge: 100.12, period: 6)
          record_from_db = ActiveRecord::Base.connection.execute("select wchchrg from case_logs where id=#{case_log.id}").to_a[0]
          expect(case_log.wchchrg).to eq(94.34)
          expect(record_from_db["wchchrg"]).to eq(94.34)
        end
      end

      context "when the care home charge is paid weekly for 48 weeks" do
        it "correctly derives and saves weekly care home charge" do
          case_log.update!(chcharge: 130, period: 7)
          record_from_db = ActiveRecord::Base.connection.execute("select wchchrg from case_logs where id=#{case_log.id}").to_a[0]
          expect(case_log.wchchrg).to eq(120.0)
          expect(record_from_db["wchchrg"]).to eq(120.0)
        end

        it "correctly derives floats" do
          case_log.update!(chcharge: 100.12, period: 7)
          record_from_db = ActiveRecord::Base.connection.execute("select wchchrg from case_logs where id=#{case_log.id}").to_a[0]
          expect(case_log.wchchrg).to eq(92.42)
          expect(record_from_db["wchchrg"]).to eq(92.42)
        end
      end

      context "when the care home charge is paid weekly for 47 weeks" do
        it "correctly derives and saves weekly care home charge" do
          case_log.update!(chcharge: 130, period: 8)
          record_from_db = ActiveRecord::Base.connection.execute("select wchchrg from case_logs where id=#{case_log.id}").to_a[0]
          expect(case_log.wchchrg).to eq(117.5)
          expect(record_from_db["wchchrg"]).to eq(117.5)
        end

        it "correctly derives floats" do
          case_log.update!(chcharge: 100.12, period: 8)
          record_from_db = ActiveRecord::Base.connection.execute("select wchchrg from case_logs where id=#{case_log.id}").to_a[0]
          expect(case_log.wchchrg).to eq(90.49)
          expect(record_from_db["wchchrg"]).to eq(90.49)
        end
      end

      context "when the care home charge is paid weekly for 46 weeks" do
        it "correctly derives and saves weekly care home charge" do
          case_log.update!(chcharge: 130, period: 9)
          record_from_db = ActiveRecord::Base.connection.execute("select wchchrg from case_logs where id=#{case_log.id}").to_a[0]
          expect(case_log.wchchrg).to eq(115.0)
          expect(record_from_db["wchchrg"]).to eq(115.0)
        end

        it "correctly derives floats" do
          case_log.update!(chcharge: 100.12, period: 9)
          record_from_db = ActiveRecord::Base.connection.execute("select wchchrg from case_logs where id=#{case_log.id}").to_a[0]
          expect(case_log.wchchrg).to eq(88.57)
          expect(record_from_db["wchchrg"]).to eq(88.57)
        end
      end

      context "when the care home charge is paid weekly for 52 weeks" do
        it "correctly derives and saves weekly care home charge" do
          case_log.update!(chcharge: 130, period: 1)
          record_from_db = ActiveRecord::Base.connection.execute("select wchchrg from case_logs where id=#{case_log.id}").to_a[0]
          expect(case_log.wchchrg).to eq(130.0)
          expect(record_from_db["wchchrg"]).to eq(130.0)
        end

        it "correctly derives floats" do
          case_log.update!(chcharge: 100.12, period: 1)
          record_from_db = ActiveRecord::Base.connection.execute("select wchchrg from case_logs where id=#{case_log.id}").to_a[0]
          expect(case_log.wchchrg).to eq(100.12)
          expect(record_from_db["wchchrg"]).to eq(100.12)
        end
      end
    end

    context "when the data provider is filling in the reason for the property being vacant" do
      let!(:first_let_case_log) do
        described_class.create({
          managing_organisation: owning_organisation,
          owning_organisation:,
          created_by: created_by_user,
          first_time_property_let_as_social_housing: 1,
        })
      end

      let!(:relet_case_log) do
        described_class.create({
          managing_organisation: owning_organisation,
          owning_organisation:,
          created_by: created_by_user,
          first_time_property_let_as_social_housing: 0,
        })
      end

      it "the newprop variable is correctly derived and saved as 1 for a first let vacancy reason" do
        first_let_case_log.update!({ rsnvac: 15 })
        record_from_db = ActiveRecord::Base.connection.execute("select newprop from case_logs where id=#{first_let_case_log.id}").to_a[0]
        expect(record_from_db["newprop"]).to eq(1)
        expect(first_let_case_log["newprop"]).to eq(1)
      end

      it "the newprop variable is correctly derived and saved as 2 for anything that is not a first let vacancy reason" do
        relet_case_log.update!({ rsnvac: 2 })
        record_from_db = ActiveRecord::Base.connection.execute("select newprop from case_logs where id=#{relet_case_log.id}").to_a[0]
        expect(record_from_db["newprop"]).to eq(2)
        expect(relet_case_log["newprop"]).to eq(2)
      end
    end

    context "when a total shortfall is provided" do
      it "derives that tshortfall is known" do
        case_log.update!({ tshortfall: 10 })
        record_from_db = ActiveRecord::Base.connection.execute("select tshortfall_known from case_logs where id=#{case_log.id}").to_a[0]
        expect(record_from_db["tshortfall_known"]).to eq(0)
        expect(case_log["tshortfall_known"]).to eq(0)
      end
    end

    context "when a case log is a supported housing log" do
      before { case_log.needstype = 2 }

      context "and a scheme with a single log is selected" do
        let(:scheme) { FactoryBot.create(:scheme) }
        let!(:location) { FactoryBot.create(:location, scheme:) }

        before { case_log.update!(scheme:) }

        it "derives the scheme location" do
          record_from_db = ActiveRecord::Base.connection.execute("select location_id from case_logs where id=#{case_log.id}").to_a[0]
          expect(record_from_db["location_id"]).to eq(location.id)
          expect(case_log["location_id"]).to eq(location.id)
        end
      end
    end
  end

  describe "optional fields" do
    let(:case_log) { FactoryBot.create(:case_log) }

    context "when tshortfall is marked as not known" do
      it "makes tshortfall optional" do
        case_log.update!({ tshortfall: nil, tshortfall_known: 1 })
        expect(case_log.optional_fields).to include("tshortfall")
      end
    end
  end

  describe "resetting invalidated fields" do
    context "when a question that has already been answered, no longer has met dependencies" do
      let(:case_log) { FactoryBot.create(:case_log, :in_progress, cbl: 1, preg_occ: 2, wchair: 1) }

      it "clears the answer" do
        expect { case_log.update!(preg_occ: nil) }.to change(case_log, :cbl).from(1).to(nil)
      end

      context "when the question type does not have answer options" do
        let(:case_log) { FactoryBot.create(:case_log, :in_progress, housingneeds_a: 1, age1: 19) }

        it "clears the answer" do
          expect { case_log.update!(housingneeds_a: 0) }.to change(case_log, :age1).from(19).to(nil)
        end
      end

      context "when the question type has answer options" do
        let(:case_log) { FactoryBot.create(:case_log, :in_progress, illness: 1, illness_type_1: 1) }

        it "clears the answer" do
          expect { case_log.update!(illness: 0) }.to change(case_log, :illness_type_1).from(1).to(nil)
        end
      end
    end

    context "with two pages having the same question key, only one's dependency is met" do
      let(:case_log) { FactoryBot.create(:case_log, :in_progress, cbl: 0, preg_occ: 2, wchair: 1) }

      it "does not clear the value for answers that apply to both pages" do
        expect(case_log.cbl).to eq(0)
      end

      it "does clear the value for answers that do not apply for invalidated page" do
        case_log.update!({ wchair: 1, sex2: "F", age2: 33 })
        case_log.update!({ cbl: 1 })
        case_log.update!({ preg_occ: 1 })

        expect(case_log.cbl).to eq(nil)
      end
    end

    context "when a non select question associated with several pages is routed to" do
      let(:case_log) { FactoryBot.create(:case_log, :in_progress, period: 2) }

      it "does not clear the answer value" do
        case_log.update!({ offered: 4 })
        case_log.reload
        expect(case_log.offered).to eq(4)
      end
    end

    context "when the case log does not have a valid form set yet" do
      let(:case_log) { FactoryBot.create(:case_log) }

      it "does not throw an error" do
        expect { case_log.update(startdate: Time.zone.local(2015, 1, 1)) }.not_to raise_error
      end
    end

    context "when it changes from a renewal to not a renewal" do
      let(:case_log) { FactoryBot.create(:case_log) }

      it "resets inferred waityear value" do
        case_log.update!({ renewal: 1 })

        record_from_db = ActiveRecord::Base.connection.execute("select waityear from case_logs where id=#{case_log.id}").to_a[0]
        expect(record_from_db["waityear"]).to eq(2)
        expect(case_log["waityear"]).to eq(2)

        case_log.update!({ renewal: 0 })
        record_from_db = ActiveRecord::Base.connection.execute("select waityear from case_logs where id=#{case_log.id}").to_a[0]
        expect(record_from_db["waityear"]).to eq(nil)
        expect(case_log["waityear"]).to eq(nil)
      end
    end

    context "when it is not a renewal" do
      let(:case_log) { FactoryBot.create(:case_log) }

      it "saves waityear value" do
        case_log.update!({ renewal: 0, waityear: 2 })

        record_from_db = ActiveRecord::Base.connection.execute("select waityear from case_logs where id=#{case_log.id}").to_a[0]
        expect(record_from_db["waityear"]).to eq(2)
        expect(case_log["waityear"]).to eq(2)
      end
    end

    context "when a support user changes the owning organisation of the log" do
      let(:case_log) { FactoryBot.create(:case_log, created_by: created_by_user) }
      let(:organisation_2) { FactoryBot.create(:organisation) }

      it "clears the created by user set" do
        expect { case_log.update!(owning_organisation: organisation_2) }
          .to change { case_log.reload.created_by }.from(created_by_user).to(nil)
      end
    end
  end

  describe "tshortfall_unknown?" do
    context "when tshortfall is nil" do
      let(:case_log) { FactoryBot.create(:case_log, :in_progress, tshortfall_known: nil) }

      it "returns false" do
        expect(case_log.tshortfall_unknown?).to be false
      end
    end

    context "when tshortfall is No" do
      let(:case_log) { FactoryBot.create(:case_log, :in_progress, tshortfall_known: 1) }

      it "returns false" do
        expect(case_log.tshortfall_unknown?).to be true
      end
    end

    context "when tshortfall is Yes" do
      let(:case_log) { FactoryBot.create(:case_log, :in_progress, tshortfall_known: 0) }

      it "returns false" do
        expect(case_log.tshortfall_unknown?).to be false
      end
    end
  end

  describe "paper trail" do
    let(:case_log) { FactoryBot.create(:case_log, :in_progress) }

    it "creates a record of changes to a log" do
      expect { case_log.update!(age1: 64) }.to change(case_log.versions, :count).by(1)
    end

    it "allows case logs to be restored to a previous version" do
      case_log.update!(age1: 63)
      expect(case_log.paper_trail.previous_version.age1).to eq(17)
    end
  end

  describe "soft values for period" do
    let(:case_log) { FactoryBot.create(:case_log) }

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

      case_log.la = "E07000223"
      case_log.lettype = 1
      case_log.beds = 1
      case_log.startdate = Time.zone.local(2021, 10, 10)
    end

    context "when period is weekly for 52 weeks" do
      it "returns weekly soft min for 52 weeks" do
        case_log.period = 1
        expect(case_log.soft_min_for_period).to eq("100.0 every week")
      end

      it "returns weekly soft max for 52 weeks" do
        case_log.period = 1
        expect(case_log.soft_max_for_period).to eq("400.0 every week")
      end
    end

    context "when period is weekly for 47 weeks" do
      it "returns weekly soft min for 47 weeks" do
        case_log.period = 8
        expect(case_log.soft_min_for_period).to eq("110.64 every week")
      end

      it "returns weekly soft max for 47 weeks" do
        case_log.period = 8
        expect(case_log.soft_max_for_period).to eq("442.55 every week")
      end
    end
  end

  describe "scopes" do
    let!(:case_log_1) { FactoryBot.create(:case_log, :in_progress, startdate: Time.utc(2021, 5, 3), created_by: created_by_user) }
    let!(:case_log_2) { FactoryBot.create(:case_log, :completed, startdate: Time.utc(2021, 5, 3), created_by: created_by_user) }

    before do
      Timecop.freeze(Time.utc(2022, 6, 3))
      FactoryBot.create(:case_log, startdate: Time.utc(2022, 6, 3))
    end

    after do
      Timecop.unfreeze
    end

    context "when searching logs" do
      let!(:case_log_to_search) { FactoryBot.create(:case_log, :completed) }

      before do
        FactoryBot.create_list(:case_log, 5, :completed)
      end

      describe "#filter_by_id" do
        it "allows searching by a log ID" do
          result = described_class.filter_by_id(case_log_to_search.id.to_s)
          expect(result.count).to eq(1)
          expect(result.first.id).to eq case_log_to_search.id
        end
      end

      describe "#filter_by_tenant_code" do
        it "allows searching by a Tenant Code" do
          result = described_class.filter_by_tenant_code(case_log_to_search.tenancycode)
          expect(result.count).to eq(1)
          expect(result.first.id).to eq case_log_to_search.id
        end

        context "when tenant_code has lower case letters" do
          let(:matching_tenant_code_lower_case) { case_log_to_search.tenancycode.downcase }

          it "allows searching by a Tenant Code" do
            result = described_class.filter_by_tenant_code(matching_tenant_code_lower_case)
            expect(result.count).to eq(1)
            expect(result.first.id).to eq case_log_to_search.id
          end
        end
      end

      describe "#filter_by_propcode" do
        it "allows searching by a Property Reference" do
          result = described_class.filter_by_propcode(case_log_to_search.propcode)
          expect(result.count).to eq(1)
          expect(result.first.id).to eq case_log_to_search.id
        end

        context "when propcode has lower case letters" do
          let(:matching_propcode_lower_case) { case_log_to_search.propcode.downcase }

          it "allows searching by a Property Reference" do
            result = described_class.filter_by_propcode(matching_propcode_lower_case)
            expect(result.count).to eq(1)
            expect(result.first.id).to eq case_log_to_search.id
          end
        end
      end

      describe "#filter_by_postcode" do
        it "allows searching by a Property Postcode" do
          result = described_class.filter_by_postcode(case_log_to_search.postcode_full)
          expect(result.count).to eq(1)
          expect(result.first.id).to eq case_log_to_search.id
        end
      end

      describe "#search_by" do
        it "allows searching using ID" do
          result = described_class.search_by(case_log_to_search.id.to_s)
          expect(result.count).to eq(1)
          expect(result.first.id).to eq case_log_to_search.id
        end

        it "allows searching using tenancy code" do
          result = described_class.search_by(case_log_to_search.tenancycode)
          expect(result.count).to eq(1)
          expect(result.first.id).to eq case_log_to_search.id
        end

        it "allows searching by a Property Reference" do
          result = described_class.search_by(case_log_to_search.propcode)
          expect(result.count).to eq(1)
          expect(result.first.id).to eq case_log_to_search.id
        end

        it "allows searching by a Property Postcode" do
          result = described_class.search_by(case_log_to_search.postcode_full)
          expect(result.count).to eq(1)
          expect(result.first.id).to eq case_log_to_search.id
        end

        context "when postcode has spaces and lower case letters" do
          let(:matching_postcode_lower_case_with_spaces) { case_log_to_search.postcode_full.downcase.chars.insert(3, " ").join }

          it "allows searching by a Property Postcode" do
            result = described_class.search_by(matching_postcode_lower_case_with_spaces)
            expect(result.count).to eq(1)
            expect(result.first.id).to eq case_log_to_search.id
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
        case_log_1.startdate = Time.zone.local(2022, 4, 1)
        case_log_1.save!(validate: false)
        case_log_2.startdate = Time.zone.local(2022, 3, 31)
        case_log_2.save!(validate: false)

        expect(described_class.filter_by_years(%w[2021]).count).to eq(1)
        expect(described_class.filter_by_years(%w[2022]).count).to eq(2)
      end
    end

    context "when filtering by organisation" do
      let(:organisation_1) { FactoryBot.create(:organisation) }
      let(:organisation_2) { FactoryBot.create(:organisation) }
      let(:organisation_3) { FactoryBot.create(:organisation) }

      before do
        FactoryBot.create(:case_log, :in_progress, owning_organisation: organisation_1, managing_organisation: organisation_1)
        FactoryBot.create(:case_log, :completed, owning_organisation: organisation_1, managing_organisation: organisation_2)
        FactoryBot.create(:case_log, :completed, owning_organisation: organisation_2, managing_organisation: organisation_1)
        FactoryBot.create(:case_log, :completed, owning_organisation: organisation_2, managing_organisation: organisation_2)
      end

      it "filters by given organisation id" do
        expect(described_class.filter_by_organisation([organisation_1.id]).count).to eq(3)
        expect(described_class.filter_by_organisation([organisation_1.id, organisation_2.id]).count).to eq(4)
        expect(described_class.filter_by_organisation([organisation_3.id]).count).to eq(0)
      end

      it "filters by given organisation" do
        expect(described_class.filter_by_organisation([organisation_1]).count).to eq(3)
        expect(described_class.filter_by_organisation([organisation_1, organisation_2]).count).to eq(4)
        expect(described_class.filter_by_organisation([organisation_3]).count).to eq(0)
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
        PaperTrail::Version.find_by(item_id: case_log_1.id, event: "create").update!(whodunnit: created_by_user.to_global_id.uri.to_s)
        PaperTrail::Version.find_by(item_id: case_log_2.id, event: "create").update!(whodunnit: created_by_user.to_global_id.uri.to_s)
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
  end

  describe "#retirement_age_for_person" do
    context "when a person gender is Male" do
      let(:case_log) { FactoryBot.build(:case_log, sex1: "M") }

      it "returns the expected retirement age" do
        expect(case_log.retirement_age_for_person_1).to eq(67)
      end

      it "returns the expected plural" do
        expect(case_log.plural_gender_for_person_1).to eq("male and non-binary people")
      end
    end

    context "when a person gender is Female" do
      let(:case_log) { FactoryBot.build(:case_log, sex2: "F") }

      it "returns the expected retirement age" do
        expect(case_log.retirement_age_for_person_2).to eq(60)
      end

      it "returns the expected plural" do
        expect(case_log.plural_gender_for_person_2).to eq("females")
      end
    end

    context "when a person gender is Non-Binary" do
      let(:case_log) { FactoryBot.build(:case_log, sex3: "X") }

      it "returns the expected retirement age" do
        expect(case_log.retirement_age_for_person_3).to eq(67)
      end

      it "returns the expected plural" do
        expect(case_log.plural_gender_for_person_3).to eq("male and non-binary people")
      end
    end

    context "when the person gender is not set" do
      let(:case_log) { FactoryBot.build(:case_log) }

      it "returns nil" do
        expect(case_log.retirement_age_for_person_3).to be_nil
      end

      it "returns the expected plural" do
        expect(case_log.plural_gender_for_person_3).to be_nil
      end
    end

    context "when a postcode contains unicode characters" do
      let(:case_log) { FactoryBot.build(:case_log, postcode_full: "SR81LS\u00A0") }

      it "triggers a validation error" do
        expect { case_log.save! }.to raise_error(ActiveRecord::RecordInvalid, /Enter a postcode in the correct format/)
      end
    end
  end

  describe "supported_housing_schemes_enabled?" do
    it "returns true for the case log if the environment is not production" do
      case_log = FactoryBot.create(:case_log)
      expect(case_log.supported_housing_schemes_enabled?).to eq(true)
    end

    context "when in the production environment" do
      before do
        allow(Rails.env).to receive(:production?).and_return(true)
      end

      it "returns false for a case log" do
        case_log = FactoryBot.create(:case_log)
        expect(case_log.supported_housing_schemes_enabled?).to eq(false)
      end
    end
  end
end
