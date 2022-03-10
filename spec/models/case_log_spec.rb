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

    context "when soft validations exist" do
      context "with an income in upper soft range" do
        let(:case_log) do
          FactoryBot.create(:case_log,
                            ecstat1: 1,
                            earnings: 750,
                            incfreq: 0)
        end

        it "updates soft errors" do
          expect(case_log.has_no_unresolved_soft_errors?).to be false
          expect(case_log.soft_errors["override_net_income_validation"].message)
            .to match(I18n.t("soft_validations.net_income.in_soft_max_range.message"))
        end
      end

      context "with an income in lower soft validation range" do
        let(:case_log) do
          FactoryBot.create(:case_log,
                            ecstat1: 1,
                            earnings: 120,
                            incfreq: 0)
        end

        it "updates soft errors" do
          expect(case_log.has_no_unresolved_soft_errors?).to be false
          expect(case_log.soft_errors["override_net_income_validation"].message)
            .to match(I18n.t("soft_validations.net_income.in_soft_min_range.message"))
        end
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
      expect(validator).to receive(:validate_tenancy_type)
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
        net_income_known: 2,
        other_hhmemb: 6,
        rent_type: 4,
        needstype: 1,
        hb: 0,
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
          relat2: 1,
          relat3: 1,
          relat4: 2,
          relat5: 1,
          relat7: 2,
          relat8: 2,
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
      case_log.reload

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
  end

  describe "resetting invalidated fields" do
    context "when a question that has already been answered, no longer has met dependencies" do
      let(:case_log) { FactoryBot.create(:case_log, :in_progress, cbl: 1, preg_occ: 1, wchair: 1) }

      it "clears the answer" do
        expect { case_log.update!(preg_occ: nil) }.to change(case_log, :cbl).from(1).to(nil)
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
