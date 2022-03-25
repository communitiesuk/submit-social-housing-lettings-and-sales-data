require "rails_helper"

RSpec.describe CaseLog do
  let(:owning_organisation) { FactoryBot.create(:organisation) }
  let(:managing_organisation) { owning_organisation }

  describe "#form" do
    let(:case_log) { FactoryBot.build(:case_log) }
    let(:case_log_2) { FactoryBot.build(:case_log, startdate: Time.zone.local(2022, 1, 1)) }
    let(:case_log_year_2) { FactoryBot.build(:case_log, startdate: Time.zone.local(2023, 5, 1)) }

    it "has returns the correct form based on the start date" do
      expect(case_log.form_name).to be_nil
      expect(case_log.form).to be_a(Form)
      expect(case_log_2.form_name).to eq("2021_2022")
      expect(case_log_2.form).to be_a(Form)
      expect(case_log_year_2.form_name).to eq("2023_2024")
      expect(case_log_year_2.form).to be_a(Form)
    end

    context "when a date outside the collection window is passed" do
      let(:case_log) { FactoryBot.build(:case_log, startdate: Time.zone.local(2015, 1, 1)) }

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
          managing_organisation:,
        )
      end

      it "attaches the correct custom validator" do
        expect(case_log._validators.values.flatten.map(&:class))
          .to include(CaseLogValidator)
      end
    end
  end

  describe "#update" do
    let(:case_log) { FactoryBot.create(:case_log) }
    let(:validator) { case_log._validators[nil].first }

    after do
      case_log.update(age1: 25)
    end

    it "validates start date" do
      expect(validator).to receive(:validate_startdate)
    end

    it "validates intermediate rent product name" do
      expect(validator).to receive(:validate_intermediate_rent_product_name)
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

    it "validates local authority" do
      expect(validator).to receive(:validate_la)
    end

    it "validates benefits as proportion of income" do
      expect(validator).to receive(:validate_net_income_uc_proportion)
    end

    it "validates outstanding rent amount" do
      expect(validator).to receive(:validate_outstanding_rent_amount)
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
      case_log.incfreq = 0
      expect(case_log.weekly_net_income).to eq(net_income)
    end

    it "calculates the correct weekly income from monthly income" do
      case_log.incfreq = 1
      expect(case_log.weekly_net_income).to eq(1154)
    end

    it "calculates the correct weekly income from yearly income" do
      case_log.incfreq = 2
      expect(case_log.weekly_net_income).to eq(417)
    end
  end

  describe "derived variables" do
    let(:organisation) { FactoryBot.create(:organisation, provider_type: "PRP") }
    let!(:case_log) do
      described_class.create({
        managing_organisation: organisation,
        owning_organisation: organisation,
        property_postcode: "M1 1AE",
        previous_postcode: "M2 2AE",
        startdate: Time.gm(2021, 10, 10),
        mrcdate: Time.gm(2021, 5, 4),
        property_void_date: Time.gm(2021, 3, 3),
        net_income_known: 2,
        other_hhmemb: 6,
        rent_type: 4,
        needstype: 1,
        hb: 1,
        hbrentshortfall: 1,
      })
    end

    it "correctly derives and saves partial and full postcodes" do
      record_from_db = ActiveRecord::Base.connection.execute("select postcode, postcod2 from case_logs where id=#{case_log.id}").to_a[0]
      expect(record_from_db["postcode"]).to eq("M1")
      expect(record_from_db["postcod2"]).to eq("1AE")
    end

    it "correctly derives and saves partial and full previous postcodes" do
      record_from_db = ActiveRecord::Base.connection.execute("select ppostc1, ppostc2 from case_logs where id=#{case_log.id}").to_a[0]
      expect(record_from_db["ppostc1"]).to eq("M2")
      expect(record_from_db["ppostc2"]).to eq("2AE")
    end

    it "correctly derives and saves partial and full major repairs date" do
      record_from_db = ActiveRecord::Base.connection.execute("select mrcday, mrcmonth, mrcyear, mrcdate from case_logs where id=#{case_log.id}").to_a[0]
      expect(record_from_db["mrcdate"].day).to eq(4)
      expect(record_from_db["mrcdate"].month).to eq(5)
      expect(record_from_db["mrcdate"].year).to eq(2021)
      expect(record_from_db["mrcday"]).to eq(4)
      expect(record_from_db["mrcmonth"]).to eq(5)
      expect(record_from_db["mrcyear"]).to eq(2021)
    end

    it "correctly derives and saves partial and full major property void date" do
      record_from_db = ActiveRecord::Base.connection.execute("select vday, vmonth, vyear, property_void_date from case_logs where id=#{case_log.id}").to_a[0]
      expect(record_from_db["property_void_date"].day).to eq(3)
      expect(record_from_db["property_void_date"].month).to eq(3)
      expect(record_from_db["property_void_date"].year).to eq(2021)
      expect(record_from_db["vday"]).to eq(3)
      expect(record_from_db["vmonth"]).to eq(3)
      expect(record_from_db["vyear"]).to eq(2021)
    end

    it "correctly derives and saves incref" do
      record_from_db = ActiveRecord::Base.connection.execute("select incref from case_logs where id=#{case_log.id}").to_a[0]
      expect(record_from_db["incref"]).to eq(1)
    end

    it "correctly derives and saves hhmemb" do
      record_from_db = ActiveRecord::Base.connection.execute("select hhmemb from case_logs where id=#{case_log.id}").to_a[0]
      expect(record_from_db["hhmemb"]).to eq(7)
    end

    it "correctly derives and saves renttype" do
      record_from_db = ActiveRecord::Base.connection.execute("select renttype from case_logs where id=#{case_log.id}").to_a[0]
      expect(case_log.renttype).to eq(3)
      expect(record_from_db["renttype"]).to eq(3)
    end

    context "when deriving lettype" do
      context "when the owning organisation is a PRP" do
        context "when the rent type is intermediate rent and supported housing" do
          it "correctly derives and saves lettype" do
            case_log.update!(rent_type: 4, needstype: 0)
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
            case_log.update!(rent_type: 2, needstype: 0)
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
            case_log.update!(rent_type: 0, needstype: 0)
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
            case_log.update!(wtshortfall: 100, hb: 9)
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
            case_log.update!(scharge: 100, period: 2)
            record_from_db = ActiveRecord::Base.connection.execute("select wscharge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wscharge).to eq(50.0)
            expect(record_from_db["wscharge"]).to eq(50.0)
          end

          it "correctly derives and saves weekly personal service charge" do
            case_log.update!(pscharge: 100, period: 2)
            record_from_db = ActiveRecord::Base.connection.execute("select wpschrge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wpschrge).to eq(50.0)
            expect(record_from_db["wpschrge"]).to eq(50.0)
          end

          it "correctly derives and saves weekly support charge" do
            case_log.update!(supcharg: 100, period: 2)
            record_from_db = ActiveRecord::Base.connection.execute("select wsupchrg from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(50.0)
            expect(record_from_db["wsupchrg"]).to eq(50.0)
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
                case_log.update!(hbrentshortfall: 0, tshortfall: 100, period: 2, hb: 1)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(50.0)
                expect(record_from_db["wtshortfall"]).to eq(50.0)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 0, tshortfall: 100, period: 2, hb: 6)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(50.0)
                expect(record_from_db["wtshortfall"]).to eq(50.0)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 0, tshortfall: 100, period: 2, hb: 8)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(50.0)
                expect(record_from_db["wtshortfall"]).to eq(50.0)
              end
            end
          end

          it "correctly derives floats" do
            case_log.update!(supcharg: 100.12, pscharge: 100.13, scharge: 100.98, brent: 100.97, period: 2)
            record_from_db = ActiveRecord::Base.connection.execute("select wtcharge, wsupchrg, wpschrge, wscharge, wrent from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(50.06)
            expect(case_log.wpschrge).to eq(50.07)
            expect(case_log.wscharge).to eq(50.49)
            expect(case_log.wrent).to eq(50.49)
            expect(case_log.wtcharge).to eq(201.1)
            expect(record_from_db["wsupchrg"]).to eq(50.06)
            expect(record_from_db["wpschrge"]).to eq(50.07)
            expect(record_from_db["wscharge"]).to eq(50.49)
            expect(record_from_db["wrent"]).to eq(50.49)
            expect(record_from_db["wtcharge"]).to eq(201.1)
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
                case_log.update!(hbrentshortfall: 0, tshortfall: 120, period: 3, hb: 1)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(30.0)
                expect(record_from_db["wtshortfall"]).to eq(30.0)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 0, tshortfall: 120, period: 3, hb: 6)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(30.0)
                expect(record_from_db["wtshortfall"]).to eq(30.0)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 0, tshortfall: 120, period: 3, hb: 8)
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
                case_log.update!(hbrentshortfall: 0, tshortfall: 130, period: 4, hb: 1)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(30.0)
                expect(record_from_db["wtshortfall"]).to eq(30.0)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 0, tshortfall: 130, period: 4, hb: 6)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(30.0)
                expect(record_from_db["wtshortfall"]).to eq(30.0)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 0, tshortfall: 130, period: 4, hb: 8)
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
            case_log.update!(scharge: 130, period: 5)
            record_from_db = ActiveRecord::Base.connection.execute("select wscharge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wscharge).to eq(125.0)
            expect(record_from_db["wscharge"]).to eq(125.0)
          end

          it "correctly derives and saves weekly personal service charge" do
            case_log.update!(pscharge: 130, period: 5)
            record_from_db = ActiveRecord::Base.connection.execute("select wpschrge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wpschrge).to eq(125.0)
            expect(record_from_db["wpschrge"]).to eq(125.0)
          end

          it "correctly derives and saves weekly support charge" do
            case_log.update!(supcharg: 130, period: 5)
            record_from_db = ActiveRecord::Base.connection.execute("select wsupchrg from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(125.0)
            expect(record_from_db["wsupchrg"]).to eq(125.0)
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
                case_log.update!(hbrentshortfall: 0, tshortfall: 130, period: 5, hb: 1)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(125.0)
                expect(record_from_db["wtshortfall"]).to eq(125.0)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 0, tshortfall: 130, period: 5, hb: 6)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(125.0)
                expect(record_from_db["wtshortfall"]).to eq(125.0)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 0, tshortfall: 130, period: 5, hb: 8)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(125.0)
                expect(record_from_db["wtshortfall"]).to eq(125.0)
              end
            end
          end

          it "correctly derives floats" do
            case_log.update!(supcharg: 100.12, pscharge: 100.13, scharge: 100.98, brent: 100.97, period: 5)
            record_from_db = ActiveRecord::Base.connection.execute("select wtcharge, wsupchrg, wpschrge, wscharge, wrent from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(96.27)
            expect(case_log.wpschrge).to eq(96.28)
            expect(case_log.wscharge).to eq(97.1)
            expect(case_log.wrent).to eq(97.09)
            expect(case_log.wtcharge).to eq(386.73)
            expect(record_from_db["wsupchrg"]).to eq(96.27)
            expect(record_from_db["wpschrge"]).to eq(96.28)
            expect(record_from_db["wscharge"]).to eq(97.1)
            expect(record_from_db["wrent"]).to eq(97.09)
            expect(record_from_db["wtcharge"]).to eq(386.73)
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
            case_log.update!(scharge: 130, period: 6)
            record_from_db = ActiveRecord::Base.connection.execute("select wscharge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wscharge).to eq(122.5)
            expect(record_from_db["wscharge"]).to eq(122.5)
          end

          it "correctly derives and saves weekly personal service charge" do
            case_log.update!(pscharge: 130, period: 6)
            record_from_db = ActiveRecord::Base.connection.execute("select wpschrge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wpschrge).to eq(122.5)
            expect(record_from_db["wpschrge"]).to eq(122.5)
          end

          it "correctly derives and saves weekly support charge" do
            case_log.update!(supcharg: 130, period: 6)
            record_from_db = ActiveRecord::Base.connection.execute("select wsupchrg from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(122.5)
            expect(record_from_db["wsupchrg"]).to eq(122.5)
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
                case_log.update!(hbrentshortfall: 0, tshortfall: 130, period: 6, hb: 1)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(122.5)
                expect(record_from_db["wtshortfall"]).to eq(122.5)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 0, tshortfall: 130, period: 6, hb: 6)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(122.5)
                expect(record_from_db["wtshortfall"]).to eq(122.5)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 0, tshortfall: 130, period: 6, hb: 8)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(122.5)
                expect(record_from_db["wtshortfall"]).to eq(122.5)
              end
            end
          end

          it "correctly derives floats" do
            case_log.update!(supcharg: 100.12, pscharge: 100.13, scharge: 100.98, brent: 100.97, period: 6)
            record_from_db = ActiveRecord::Base.connection.execute("select wtcharge, wsupchrg, wpschrge, wscharge, wrent from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(94.34)
            expect(case_log.wpschrge).to eq(94.35)
            expect(case_log.wscharge).to eq(95.15)
            expect(case_log.wrent).to eq(95.14)
            expect(case_log.wtcharge).to eq(379)
            expect(record_from_db["wsupchrg"]).to eq(94.34)
            expect(record_from_db["wpschrge"]).to eq(94.35)
            expect(record_from_db["wscharge"]).to eq(95.15)
            expect(record_from_db["wrent"]).to eq(95.14)
            expect(record_from_db["wtcharge"]).to eq(379)
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
            case_log.update!(scharge: 130, period: 7)
            record_from_db = ActiveRecord::Base.connection.execute("select wscharge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wscharge).to eq(120.0)
            expect(record_from_db["wscharge"]).to eq(120.0)
          end

          it "correctly derives and saves weekly personal service charge" do
            case_log.update!(pscharge: 130, period: 7)
            record_from_db = ActiveRecord::Base.connection.execute("select wpschrge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wpschrge).to eq(120.0)
            expect(record_from_db["wpschrge"]).to eq(120.0)
          end

          it "correctly derives and saves weekly support charge" do
            case_log.update!(supcharg: 130, period: 7)
            record_from_db = ActiveRecord::Base.connection.execute("select wsupchrg from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(120.0)
            expect(record_from_db["wsupchrg"]).to eq(120.0)
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
                case_log.update!(hbrentshortfall: 0, tshortfall: 130, period: 7, hb: 1)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(120.0)
                expect(record_from_db["wtshortfall"]).to eq(120.0)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 0, tshortfall: 130, period: 7, hb: 6)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(120.0)
                expect(record_from_db["wtshortfall"]).to eq(120.0)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 0, tshortfall: 130, period: 7, hb: 8)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(120.0)
                expect(record_from_db["wtshortfall"]).to eq(120.0)
              end
            end
          end

          it "correctly derives floats" do
            case_log.update!(supcharg: 100.12, pscharge: 100.13, scharge: 100.98, brent: 100.97, period: 7)
            record_from_db = ActiveRecord::Base.connection.execute("select wtcharge, wsupchrg, wpschrge, wscharge, wrent from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(92.42)
            expect(case_log.wpschrge).to eq(92.43)
            expect(case_log.wscharge).to eq(93.21)
            expect(case_log.wrent).to eq(93.20)
            expect(case_log.wtcharge).to eq(371.26)
            expect(record_from_db["wsupchrg"]).to eq(92.42)
            expect(record_from_db["wpschrge"]).to eq(92.43)
            expect(record_from_db["wscharge"]).to eq(93.21)
            expect(record_from_db["wrent"]).to eq(93.20)
            expect(record_from_db["wtcharge"]).to eq(371.26)
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
            case_log.update!(scharge: 130, period: 8)
            record_from_db = ActiveRecord::Base.connection.execute("select wscharge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wscharge).to eq(117.5)
            expect(record_from_db["wscharge"]).to eq(117.5)
          end

          it "correctly derives and saves weekly personal service charge" do
            case_log.update!(pscharge: 130, period: 8)
            record_from_db = ActiveRecord::Base.connection.execute("select wpschrge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wpschrge).to eq(117.5)
            expect(record_from_db["wpschrge"]).to eq(117.5)
          end

          it "correctly derives and saves weekly support charge" do
            case_log.update!(supcharg: 130, period: 8)
            record_from_db = ActiveRecord::Base.connection.execute("select wsupchrg from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(117.5)
            expect(record_from_db["wsupchrg"]).to eq(117.5)
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
                case_log.update!(hbrentshortfall: 0, tshortfall: 130, period: 8, hb: 1)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(117.5)
                expect(record_from_db["wtshortfall"]).to eq(117.5)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 0, tshortfall: 130, period: 8, hb: 6)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(117.5)
                expect(record_from_db["wtshortfall"]).to eq(117.5)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 0, tshortfall: 130, period: 8, hb: 8)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(117.5)
                expect(record_from_db["wtshortfall"]).to eq(117.5)
              end
            end
          end

          it "correctly derives floats" do
            case_log.update!(supcharg: 100.12, pscharge: 100.13, scharge: 100.98, brent: 100.97, period: 8)
            record_from_db = ActiveRecord::Base.connection.execute("select wtcharge, wsupchrg, wpschrge, wscharge, wrent from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(90.49)
            expect(case_log.wpschrge).to eq(90.50)
            expect(case_log.wscharge).to eq(91.27)
            expect(case_log.wrent).to eq(91.26)
            expect(case_log.wtcharge).to eq(363.53)
            expect(record_from_db["wsupchrg"]).to eq(90.49)
            expect(record_from_db["wpschrge"]).to eq(90.50)
            expect(record_from_db["wscharge"]).to eq(91.27)
            expect(record_from_db["wrent"]).to eq(91.26)
            expect(record_from_db["wtcharge"]).to eq(363.53)
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
            case_log.update!(scharge: 130, period: 9)
            record_from_db = ActiveRecord::Base.connection.execute("select wscharge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wscharge).to eq(115.0)
            expect(record_from_db["wscharge"]).to eq(115.0)
          end

          it "correctly derives and saves weekly personal service charge" do
            case_log.update!(pscharge: 130, period: 9)
            record_from_db = ActiveRecord::Base.connection.execute("select wpschrge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wpschrge).to eq(115.0)
            expect(record_from_db["wpschrge"]).to eq(115.0)
          end

          it "correctly derives and saves weekly support charge" do
            case_log.update!(supcharg: 130, period: 9)
            record_from_db = ActiveRecord::Base.connection.execute("select wsupchrg from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(115.0)
            expect(record_from_db["wsupchrg"]).to eq(115.0)
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
                case_log.update!(hbrentshortfall: 0, tshortfall: 130, period: 9, hb: 1)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(115.0)
                expect(record_from_db["wtshortfall"]).to eq(115.0)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 0, tshortfall: 130, period: 9, hb: 6)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(115.0)
                expect(record_from_db["wtshortfall"]).to eq(115.0)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 0, tshortfall: 130, period: 9, hb: 8)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(115.0)
                expect(record_from_db["wtshortfall"]).to eq(115.0)
              end
            end
          end

          it "correctly derives floats" do
            case_log.update!(supcharg: 100.12, pscharge: 100.13, scharge: 100.98, brent: 100.97, period: 9)
            record_from_db = ActiveRecord::Base.connection.execute("select wtcharge, wsupchrg, wpschrge, wscharge, wrent from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(88.57)
            expect(case_log.wpschrge).to eq(88.58)
            expect(case_log.wscharge).to eq(89.33)
            expect(case_log.wrent).to eq(89.32)
            expect(case_log.wtcharge).to eq(355.79)
            expect(record_from_db["wsupchrg"]).to eq(88.57)
            expect(record_from_db["wpschrge"]).to eq(88.58)
            expect(record_from_db["wscharge"]).to eq(89.33)
            expect(record_from_db["wrent"]).to eq(89.32)
            expect(record_from_db["wtcharge"]).to eq(355.79)
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
            case_log.update!(scharge: 130, period: 1)
            record_from_db = ActiveRecord::Base.connection.execute("select wscharge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wscharge).to eq(130.0)
            expect(record_from_db["wscharge"]).to eq(130.0)
          end

          it "correctly derives and saves weekly personal service charge" do
            case_log.update!(pscharge: 130, period: 1)
            record_from_db = ActiveRecord::Base.connection.execute("select wpschrge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wpschrge).to eq(130.0)
            expect(record_from_db["wpschrge"]).to eq(130.0)
          end

          it "correctly derives and saves weekly support charge" do
            case_log.update!(supcharg: 130, period: 1)
            record_from_db = ActiveRecord::Base.connection.execute("select wsupchrg from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(130.0)
            expect(record_from_db["wsupchrg"]).to eq(130.0)
          end

          it "correctly derives and saves weekly total charge" do
            case_log.update!(tcharge: 130, period: 1)
            record_from_db = ActiveRecord::Base.connection.execute("select wtcharge from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wtcharge).to eq(130.0)
            expect(record_from_db["wtcharge"]).to eq(130.0)
          end

          context "when the tenant has an outstanding amount after benefits" do
            context "when tenant is in receipt of housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 0, tshortfall: 130, period: 1, hb: 1)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(130.0)
                expect(record_from_db["wtshortfall"]).to eq(130.0)
              end
            end

            context "when tenant is in receipt of universal credit with housing element exc. housing benefit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 0, tshortfall: 130, period: 1, hb: 6)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(130.0)
                expect(record_from_db["wtshortfall"]).to eq(130.0)
              end
            end

            context "when tenant is in receipt of housing benefit and universal credit" do
              it "correctly derives and saves weekly total shortfall" do
                case_log.update!(hbrentshortfall: 0, tshortfall: 130, period: 1, hb: 8)
                record_from_db = ActiveRecord::Base.connection.execute("select wtshortfall from case_logs where id=#{case_log.id}").to_a[0]
                expect(case_log.wtshortfall).to eq(130.0)
                expect(record_from_db["wtshortfall"]).to eq(130.0)
              end
            end
          end

          it "correctly derives floats" do
            case_log.update!(supcharg: 100.12, pscharge: 100.13, scharge: 100.98, brent: 100.97, period: 1)
            record_from_db = ActiveRecord::Base.connection.execute("select wtcharge, wsupchrg, wpschrge, wscharge, wrent from case_logs where id=#{case_log.id}").to_a[0]
            expect(case_log.wsupchrg).to eq(100.12)
            expect(case_log.wpschrge).to eq(100.13)
            expect(case_log.wscharge).to eq(100.98)
            expect(case_log.wrent).to eq(100.97)
            expect(case_log.wtcharge).to eq(402.2)
            expect(record_from_db["wsupchrg"]).to eq(100.12)
            expect(record_from_db["wpschrge"]).to eq(100.13)
            expect(record_from_db["wscharge"]).to eq(100.98)
            expect(record_from_db["wrent"]).to eq(100.97)
            expect(record_from_db["wtcharge"]).to eq(402.2)
          end
        end
      end

      context "when the owning organisation is an LA" do
        let(:organisation) { FactoryBot.create(:organisation, provider_type: "LA") }

        context "when the rent type is intermediate rent and supported housing" do
          it "correctly derives and saves lettype" do
            case_log.update!(rent_type: 4, needstype: 0)
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
            case_log.update!(rent_type: 2, needstype: 0)
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
            case_log.update!(rent_type: 0, needstype: 0)
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
      record_from_db = ActiveRecord::Base.connection.execute("select day, month, year, startdate from case_logs where id=#{case_log.id}").to_a[0]
      expect(record_from_db["startdate"].day).to eq(10)
      expect(record_from_db["startdate"].month).to eq(10)
      expect(record_from_db["startdate"].year).to eq(2021)
      expect(record_from_db["day"]).to eq(10)
      expect(record_from_db["month"]).to eq(10)
      expect(record_from_db["year"]).to eq(2021)
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

    context "when saving addresses" do
      before do
        stub_request(:get, /api.postcodes.io/)
          .to_return(status: 200, body: "{\"status\":200,\"result\":{\"admin_district\":\"Manchester\",\"codes\":{\"admin_district\": \"E08000003\"}}}", headers: {})
      end

      let!(:address_case_log) do
        described_class.create({
          managing_organisation: organisation,
          owning_organisation: organisation,
          postcode_known: 1,
          property_postcode: "M1 1AE",
        })
      end

      it "correctly infers la" do
        record_from_db = ActiveRecord::Base.connection.execute("select la from case_logs where id=#{address_case_log.id}").to_a[0]
        expect(address_case_log.la).to eq("E08000003")
        expect(record_from_db["la"]).to eq("E08000003")
      end

      it "errors if the property postcode is emptied" do
        expect { address_case_log.update!({ property_postcode: "" }) }
          .to raise_error(ActiveRecord::RecordInvalid, /#{I18n.t("validations.postcode")}/)
      end

      it "errors if the property postcode is not valid" do
        expect { address_case_log.update!({ property_postcode: "invalid_postcode" }) }
          .to raise_error(ActiveRecord::RecordInvalid, /#{I18n.t("validations.postcode")}/)
      end

      context "when the local authority lookup times out" do
        before do
          allow(Timeout).to receive(:timeout).and_raise(Timeout::Error)
        end

        it "logs a warning" do
          expect(Rails.logger).to receive(:warn).with("Postcodes.io lookup timed out")
          address_case_log.update!({ postcode_known: 1, property_postcode: "M1 1AD" })
        end
      end

      it "correctly resets all fields if property postcode not known" do
        address_case_log.update!({ postcode_known: 0 })

        record_from_db = ActiveRecord::Base.connection.execute("select la, property_postcode from case_logs where id=#{address_case_log.id}").to_a[0]
        expect(record_from_db["property_postcode"]).to eq(nil)
        expect(address_case_log.la).to eq(nil)
        expect(record_from_db["la"]).to eq(nil)
      end

      it "changes the LA if property postcode changes from not known to known and provided" do
        address_case_log.update!({ postcode_known: 0 })
        address_case_log.update!({ la_known: 1, la: "E09000033" })

        record_from_db = ActiveRecord::Base.connection.execute("select la, property_postcode from case_logs where id=#{address_case_log.id}").to_a[0]
        expect(record_from_db["property_postcode"]).to eq(nil)
        expect(address_case_log.la).to eq("E09000033")
        expect(record_from_db["la"]).to eq("E09000033")

        address_case_log.update!({ postcode_known: 1, property_postcode: "M1 1AD" })

        record_from_db = ActiveRecord::Base.connection.execute("select la, property_postcode from case_logs where id=#{address_case_log.id}").to_a[0]
        expect(record_from_db["property_postcode"]).to eq("M1 1AD")
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
          managing_organisation: organisation,
          owning_organisation: organisation,
          previous_postcode_known: 1,
          previous_postcode: "M1 1AE",
        })
      end

      it "correctly infers prevloc" do
        record_from_db = ActiveRecord::Base.connection.execute("select prevloc from case_logs where id=#{address_case_log.id}").to_a[0]
        expect(address_case_log.prevloc).to eq("E08000003")
        expect(record_from_db["prevloc"]).to eq("E08000003")
      end

      it "errors if the previous postcode is emptied" do
        expect { address_case_log.update!({ previous_postcode: "" }) }
          .to raise_error(ActiveRecord::RecordInvalid, /#{I18n.t("validations.postcode")}/)
      end

      it "errors if the previous postcode is not valid" do
        expect { address_case_log.update!({ previous_postcode: "invalid_postcode" }) }
          .to raise_error(ActiveRecord::RecordInvalid, /#{I18n.t("validations.postcode")}/)
      end

      it "correctly resets all fields if previous postcode not known" do
        address_case_log.update!({ previous_postcode_known: 0 })

        record_from_db = ActiveRecord::Base.connection.execute("select prevloc, previous_postcode from case_logs where id=#{address_case_log.id}").to_a[0]
        expect(record_from_db["previous_postcode"]).to eq(nil)
        expect(address_case_log.prevloc).to eq(nil)
        expect(record_from_db["prevloc"]).to eq(nil)
      end

      it "correctly resets la if la is not known" do
        address_case_log.update!({ previous_postcode_known: 0 })
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
        address_case_log.update!({ previous_postcode_known: 0 })
        address_case_log.update!({ previous_la_known: 1, prevloc: "E09000033" })

        record_from_db = ActiveRecord::Base.connection.execute("select prevloc, previous_postcode from case_logs where id=#{address_case_log.id}").to_a[0]
        expect(record_from_db["previous_postcode"]).to eq(nil)
        expect(address_case_log.prevloc).to eq("E09000033")
        expect(record_from_db["prevloc"]).to eq("E09000033")

        address_case_log.update!({ previous_postcode_known: 0, previous_postcode: "M1 1AD" })

        record_from_db = ActiveRecord::Base.connection.execute("select prevloc, previous_postcode from case_logs where id=#{address_case_log.id}").to_a[0]
        expect(record_from_db["previous_postcode"]).to eq("M1 1AD")
        expect(address_case_log.prevloc).to eq("E08000003")
        expect(record_from_db["prevloc"]).to eq("E08000003")
      end
    end

    context "when saving rent and charges" do
      let!(:case_log) do
        described_class.create({
          managing_organisation: organisation,
          owning_organisation: organisation,
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
        described_class.create({
          managing_organisation: organisation,
          owning_organisation: organisation,
          other_hhmemb: 4,
          relat2: "C",
          relat3: "C",
          relat4: "X",
          relat5: "C",
          relat7: "X",
          relat8: "X",
          age1: 22,
          age2: 14,
          age4: 60,
          age6: 88,
          age7: 16,
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
    end

    it "correctly derives and saves has_benefits" do
      record_from_db = ActiveRecord::Base.connection.execute("select has_benefits from case_logs where id=#{case_log.id}").to_a[0]
      expect(record_from_db["has_benefits"]).to eq(1)
    end

    context "when it is a renewal" do
      let!(:case_log) do
        described_class.create({
          managing_organisation: organisation,
          owning_organisation: organisation,
          renewal: 1,
          year: 2021,
        })
      end

      it "correctly derives and saves layear" do
        record_from_db = ActiveRecord::Base.connection.execute("select layear from case_logs where id=#{case_log.id}").to_a[0]
        expect(record_from_db["layear"]).to eq(1)
        expect(case_log["layear"]).to eq(1)
      end

      it "correctly derives and saves underoccupation_benefitcap if year is 2021" do
        record_from_db = ActiveRecord::Base.connection.execute("select underoccupation_benefitcap from case_logs where id=#{case_log.id}").to_a[0]
        expect(record_from_db["underoccupation_benefitcap"]).to eq(2)
        expect(case_log["underoccupation_benefitcap"]).to eq(2)
      end

      it "correctly derives and saves prevten" do
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
          managing_organisation: organisation,
          owning_organisation: organisation,
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
          managing_organisation: organisation,
          owning_organisation: organisation,
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
          managing_organisation: organisation,
          owning_organisation: organisation,
          needstype: 0,
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
  end

  describe "resetting invalidated fields" do
    context "when a question that has already been answered, no longer has met dependencies" do
      let(:case_log) { FactoryBot.create(:case_log, :in_progress, cbl: 1, preg_occ: 1, wchair: 1) }

      it "clears the answer" do
        expect { case_log.update!(preg_occ: nil) }.to change(case_log, :cbl).from(1).to(nil)
      end

      context "when the question type does not have answer options" do
        let(:case_log) { FactoryBot.create(:case_log, :in_progress, housingneeds_a: 1, tenant_code: "test") }

        it "clears the answer" do
          expect { case_log.update!(housingneeds_a: 0) }.to change(case_log, :tenant_code).from("test").to(nil)
        end
      end
    end

    context "with two pages having the same question key, only one's dependency is met" do
      let(:case_log) { FactoryBot.create(:case_log, :in_progress, cbl: 0, preg_occ: 1, wchair: 1) }

      it "does not clear the value for answers that apply to both pages" do
        expect(case_log.cbl).to eq(0)
      end

      it "does clear the value for answers that do not apply for invalidated page" do
        case_log.update!({ wchair: 1, sex2: "F", age2: 33 })
        case_log.update!({ cbl: 1 })
        case_log.update!({ preg_occ: 0 })

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

      it "resets inferred layear value" do
        case_log.update!({ renewal: 1 })

        record_from_db = ActiveRecord::Base.connection.execute("select layear from case_logs where id=#{case_log.id}").to_a[0]
        expect(record_from_db["layear"]).to eq(1)
        expect(case_log["layear"]).to eq(1)

        case_log.update!({ renewal: 0 })
        record_from_db = ActiveRecord::Base.connection.execute("select layear from case_logs where id=#{case_log.id}").to_a[0]
        expect(record_from_db["layear"]).to eq(nil)
        expect(case_log["layear"]).to eq(nil)
      end
    end

    context "when it is not a renewal" do
      let(:case_log) { FactoryBot.create(:case_log) }

      it "saves layear value" do
        case_log.update!({ renewal: 0, layear: 2 })

        record_from_db = ActiveRecord::Base.connection.execute("select layear from case_logs where id=#{case_log.id}").to_a[0]
        expect(record_from_db["layear"]).to eq(2)
        expect(case_log["layear"]).to eq(2)
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
end
