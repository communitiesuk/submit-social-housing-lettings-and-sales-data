require "rails_helper"
require "shared/shared_examples_for_derived_fields"
require "shared/shared_log_examples"

# rubocop:disable RSpec/MessageChain
RSpec.describe LettingsLog do
  let(:different_managing_organisation) { create(:organisation) }
  let(:assigned_to_user) { create(:user) }
  let(:owning_organisation) { assigned_to_user.organisation }
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
    lettings_log = build(:lettings_log, assigned_to: assigned_to_user)
    expect(lettings_log.sales?).to be false
  end

  it "is a lettings log" do
    lettings_log = build(:lettings_log, assigned_to: assigned_to_user)
    expect(lettings_log).to be_lettings
  end

  describe "#form" do
    let(:lettings_log) { build(:lettings_log, assigned_to: assigned_to_user) }
    let(:lettings_log_2) { build(:lettings_log, startdate: Time.zone.local(2022, 1, 1), assigned_to: assigned_to_user) }
    let(:lettings_log_year_2) { build(:lettings_log, startdate: Time.zone.local(2023, 5, 1), assigned_to: assigned_to_user) }

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
      let(:lettings_log) { build(:lettings_log, startdate: Time.zone.local(2015, 1, 1), assigned_to: assigned_to_user) }

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
          assigned_to: assigned_to_user,
        )
      end

      it "attaches the correct custom validator" do
        expect(lettings_log._validators.values.flatten.map(&:class))
          .to include(LettingsLogValidator)
      end
    end
  end

  describe "#update" do
    let(:lettings_log) { create(:lettings_log, assigned_to: assigned_to_user) }
    let(:validator) { lettings_log._validators[nil].first }

    after do
      lettings_log.update(age1: 25)
    end

    it "correctly allows net_income_value_check to be set when earnings is near a range boundary" do
      log = create(:lettings_log, :setup_completed, hhmemb: 2, ecstat1: 1, details_known_2: 0, age2_known: 0, age2: 10, incfreq: 1, net_income_known: 0, earnings: 191)
      log.update!(net_income_value_check: 0)
      log.reload
      expect(log.net_income_value_check).to be 0
    end

    it "validates start date" do
      expect(validator).to receive(:validate_startdate)
    end

    it "validates intermediate rent product name" do
      expect(validator).to receive(:validate_irproduct_other)
    end

    it "validates partner count" do
      expect(validator).to receive(:validate_partner_count)
    end

    it "validates person age matches economic status" do
      expect(validator).to receive(:validate_person_age_matches_economic_status)
    end

    it "validates person age matches relationship" do
      expect(validator).to receive(:validate_person_age_matches_relationship)
    end

    it "validates person age and relationship matches economic status" do
      expect(validator).to receive(:validate_person_age_and_relationship_matches_economic_status)
    end

    it "validates bedroom number" do
      expect(validator).to receive(:validate_shared_housing_rooms)
    end

    it "validates tenancy type" do
      expect(validator).to receive(:validate_other_tenancy_type)
    end

    it "validates tenancy length" do
      expect(validator).to receive(:validate_supported_housing_fixed_tenancy_length)
      expect(validator).to receive(:validate_general_needs_fixed_tenancy_length_affordable_social_rent)
      expect(validator).to receive(:validate_general_needs_fixed_tenancy_length_intermediate_rent)
      expect(validator).to receive(:validate_periodic_tenancy_length)
      expect(validator).to receive(:validate_tenancy_length_blank_when_not_required)
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
      create(
        :lettings_log,
        managing_organisation: owning_organisation,
        owning_organisation:,
        assigned_to: assigned_to_user,
        postcode_full: "M1 1AE",
        ppostcode_full: "M2 2AE",
        startdate: Time.gm(2021, 10, 10),
        mrcdate: Time.gm(2021, 5, 4),
        voiddate: Time.gm(2021, 3, 3),
        net_income_known: 2, # refused
        hhmemb: 7,
        rent_type: 4,
        hb: 1,
        hbrentshortfall: 1,
        created_at: Time.utc(2022, 2, 8, 16, 52, 15),
      )
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
        stub_request(:get, /api\.postcodes\.io/)
          .to_return(status: 200, body: "{\"status\":200,\"result\":{\"admin_district\":\"Manchester\",\"codes\":{\"admin_district\": \"E08000003\"}}}", headers: {})
      end

      let!(:address_lettings_log) do
        described_class.create({
          managing_organisation: owning_organisation,
          owning_organisation:,
          assigned_to: assigned_to_user,
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

    context "when uprn is not confirmed" do
      it "clears previous address on renewal logs" do
        log = FactoryBot.build(:lettings_log, uprn_known: 1, uprn: 1, uprn_confirmed: 0, renewal: 1, prevloc: "E08000003", ppostcode_full: "A1 1AA", ppcodenk: 0, previous_la_known: 1)

        expect { log.set_derived_fields! }.to change(log, :prevloc).from("E08000003").to(nil)
                                          .and change(log, :ppostcode_full).from("A1 1AA").to(nil)
                                          .and change(log, :ppcodenk).from(0).to(nil)
                                          .and change(log, :previous_la_known).from(1).to(nil)
      end

      it "does not clear previous address on non renewal logs" do
        log = FactoryBot.build(:lettings_log, uprn_known: 1, uprn: 1, uprn_confirmed: 0, renewal: 0, prevloc: "E08000003", ppostcode_full: "A1 1AA", ppcodenk: 0, previous_la_known: 1)
        log.set_derived_fields!
        expect(log.prevloc).to eq("E08000003")
        expect(log.ppostcode_full).to eq("A1 1AA")
        expect(log.ppcodenk).to eq(0)
        expect(log.previous_la_known).to eq(1)
      end
    end

    context "when saving previous address" do
      before do
        stub_request(:get, /api\.postcodes\.io/)
          .to_return(status: 200, body: "{\"status\":200,\"result\":{\"admin_district\":\"Manchester\", \"codes\":{\"admin_district\": \"E08000003\"}}}", headers: {})
      end

      let!(:address_lettings_log) do
        described_class.create({
          managing_organisation: owning_organisation,
          owning_organisation:,
          assigned_to: assigned_to_user,
          ppcodenk: 0,
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
        address_lettings_log.update!({ ppcodenk: 1 })

        record_from_db = described_class.find(address_lettings_log.id)
        expect(record_from_db["ppostcode_full"]).to eq(nil)
        expect(address_lettings_log.prevloc).to eq(nil)
        expect(record_from_db["prevloc"]).to eq(nil)
      end

      it "correctly resets la if la is not known" do
        address_lettings_log.update!({ ppcodenk: 1 })
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
        address_lettings_log.update!({ ppcodenk: 1 })
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

    context "when a lettings log is a supported housing log" do
      let(:real_2021_2022_form) { Form.new("config/forms/2021_2022.json") }

      before do
        lettings_log.needstype = 2
        allow(FormHandler.instance).to receive(:get_form).and_return(real_2021_2022_form)
      end

      describe "when changing a log's scheme and hence calling reset_scheme_location!" do
        before do
          Timecop.return
          Singleton.__init__(FormHandler)
        end

        context "when there is one valid location and many invalid locations in the new scheme" do
          let(:scheme) { create(:scheme) }
          let(:invalid_location_1) { create(:location, scheme:, startdate: Time.zone.today + 3.weeks) }
          let(:valid_location) { create(:location, scheme:, startdate: Time.zone.yesterday) }
          let(:invalid_location_2) { create(:location, scheme:, startdate: Time.zone.today + 3.weeks) }
          let(:log) { create(:lettings_log, scheme: nil, location_id: nil, startdate: Time.zone.today) }

          it "infers that the log is for the valid location" do
            expect { log.update!(scheme:) }.to change(log, :location_id).from(nil).to(valid_location.id)
          end
        end

        context "when there are many valid locations in the new scheme" do
          let(:old_scheme) { create(:scheme, owning_organisation:) }
          let(:old_location) { create(:location, scheme: old_scheme) }
          let(:new_scheme) { create(:scheme, owning_organisation:) }

          before do
            create_list(:location, 2, scheme: new_scheme)
          end

          context "with a current year log" do
            let(:log) { create(:lettings_log, :completed, :sh, :startdate_today, owning_organisation:, scheme_id: old_scheme.id, location_id: old_location.id) }

            it "clears the location set on the log" do
              expect { log.update!(scheme: new_scheme) }.to change(log, :location_id).from(old_location.id).to(nil)
            end

            it "recalculates the log status" do
              expect { log.update!(scheme: new_scheme) }.to change(log, :status).from("completed").to("in_progress")
            end
          end
        end
      end

      context "and a scheme with a single log is selected" do
        let(:scheme) { create(:scheme, owning_organisation:) }
        let!(:location) { create(:location, scheme:) }

        before do
          Timecop.freeze(Time.zone.local(2022, 4, 2))
          Singleton.__init__(FormHandler)
          lettings_log.update!(startdate: Time.zone.local(2022, 4, 2), scheme:)
        end

        after do
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
            Timecop.freeze(Time.zone.local(2022, 4, 2))
            location.update!(location_code: "E01231231")
            lettings_log.update!(location:)
          end

          after do
            Timecop.return
          end

          it "returns the correct la" do
            expect(location.location_code).to eq("E01231231")
            expect(lettings_log["location_id"]).to eq(location.id)
            expect(lettings_log.la).to eq("E01231231")
          end
        end
      end

      context "and not renewal" do
        let(:scheme) { create(:scheme, owning_organisation:) }
        let(:location) { create(:location, scheme:, postcode: "M11AE", type_of_unit: 1, mobility_type: "W") }

        let(:supported_housing_lettings_log) do
          described_class.create!({
            managing_organisation: owning_organisation,
            owning_organisation:,
            assigned_to: assigned_to_user,
            needstype: 2,
            scheme_id: scheme.id,
            location_id: location.id,
            renewal: 0,
          })
        end

        before do
          stub_request(:get, /api\.postcodes\.io/)
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

    context "when saving rent_type" do
      it "derives lar as yes (1) if rent_type is london affordable rent" do
        lettings_log.update!({ rent_type: 2 })
        record_from_db = described_class.find(lettings_log.id)
        expect(record_from_db["lar"]).to eq(1)
      end

      it "derives lar as no (2) if rent_type is affordable rent" do
        lettings_log.update!({ rent_type: 1 })
        record_from_db = described_class.find(lettings_log.id)
        expect(record_from_db["lar"]).to eq(2)
      end

      it "clears previously set lar if rent_type is not affordable rent" do
        lettings_log.update!({ rent_type: 2 })
        record_from_db = described_class.find(lettings_log.id)
        expect(record_from_db["lar"]).to eq(1)

        lettings_log.update!({ rent_type: 3 })
        record_from_db = described_class.find(lettings_log.id)
        expect(record_from_db["lar"]).to eq(nil)
      end

      it "derives irproduct as rent_to_buy (1) if rent_type is rent_to_buy (3)" do
        lettings_log.update!({ rent_type: 3 })
        record_from_db = described_class.find(lettings_log.id)
        expect(record_from_db["irproduct"]).to eq(1)
      end

      it "derives irproduct as london_living_rent (2) if rent_type is london_living_rent (4)" do
        lettings_log.update!({ rent_type: 4 })
        record_from_db = described_class.find(lettings_log.id)
        expect(record_from_db["irproduct"]).to eq(2)
      end

      it "derives irproduct as other_intermediate_rent_product (3) if rent_type is other_intermediate_rent_product (5)" do
        lettings_log.update!({ rent_type: 5, irproduct_other: "other" })
        record_from_db = described_class.find(lettings_log.id)
        expect(record_from_db["irproduct"]).to eq(3)
      end

      it "clears previously set irproduct if rent_type is intermediate rent" do
        lettings_log.update!({ rent_type: 4 })
        record_from_db = described_class.find(lettings_log.id)
        expect(record_from_db["irproduct"]).to eq(2)

        lettings_log.update!({ rent_type: 2 })
        record_from_db = described_class.find(lettings_log.id)
        expect(record_from_db["irproduct"]).to eq(nil)
      end
    end

    context "when updating nationality_all_group" do
      let!(:lettings_log) do
        described_class.create({
          managing_organisation: owning_organisation,
          owning_organisation:,
          assigned_to: assigned_to_user,
          startdate: Time.zone.local(2024, 4, 10),
          needstype: 1,
          renewal: 1,
          rent_type: 1,
        })
      end

      before do
        Timecop.freeze(Time.zone.local(2024, 4, 10))
        Singleton.__init__(FormHandler)
      end

      after do
        Timecop.return
        Singleton.__init__(FormHandler)
      end

      it "correctly derives nationality_all when it's UK" do
        expect { lettings_log.update!(nationality_all_group: 826, declaration: 1) }.to change(lettings_log, :nationality_all).to 826
      end

      it "correctly derives nationality_all when it's prefers not to say" do
        expect { lettings_log.update!(nationality_all_group: 0, declaration: 1) }.to change(lettings_log, :nationality_all).to 0
      end

      it "does not derive nationality_all when it's other or not given" do
        expect { lettings_log.update!(nationality_all_group: 12, declaration: 1) }.not_to change(lettings_log, :nationality_all)
        expect { lettings_log.update!(nationality_all_group: nil, declaration: 1) }.not_to change(lettings_log, :nationality_all)
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

    context "when startdate is before 2023" do
      let(:lettings_log) { build(:lettings_log, startdate: Time.zone.parse("2022-07-01")) }

      it "returns optional fields" do
        expect(lettings_log.optional_fields).to eq(%w[
          tenancycode
          propcode
          chcharge
          tenancylength
        ])
      end
    end

    context "when startdate is after 2023" do
      let(:lettings_log) { build(:lettings_log, startdate: Time.zone.parse("2023-07-01")) }

      it "returns optional fields" do
        expect(lettings_log.optional_fields).to eq(%w[
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
    let(:scheme) { create(:scheme, owning_organisation: assigned_to_user.organisation) }
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
        assigned_to: assigned_to_user,
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
      let(:lettings_log) { create(:lettings_log, assigned_to: assigned_to_user) }
      let(:organisation_2) { create(:organisation) }

      context "when the organisation selected doesn't match the scheme set" do
        let(:scheme) { create(:scheme, owning_organisation: assigned_to_user.organisation) }
        let(:location) { create_list(:location, 2, scheme:).first }
        let(:lettings_log) { create(:lettings_log, owning_organisation: nil, needstype: 2, scheme_id: scheme.id, location_id: location.id) }

        it "clears the scheme and location values" do
          lettings_log.update!(owning_organisation: organisation_2)
          lettings_log.reload
          expect(lettings_log.scheme).to be nil
          expect(lettings_log.location).to be nil
        end
      end

      context "when the organisation selected still matches the scheme set" do
        let(:scheme) { create(:scheme, owning_organisation: organisation_2) }
        let(:location) { create_list(:location, 2, scheme:).first }
        let(:lettings_log) { create(:lettings_log, owning_organisation: nil, needstype: 2, scheme_id: scheme.id, location_id: location.id) }

        it "does not clear the scheme or location value" do
          lettings_log.update!(owning_organisation: organisation_2)
          lettings_log.reload
          expect(lettings_log.scheme_id).to eq(scheme.id)
          expect(lettings_log.location_id).to eq(location.id)
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
    let!(:lettings_log_1) { create(:lettings_log, :in_progress, startdate: Time.utc(2021, 5, 3), mrcdate: Time.utc(2021, 5, 3), voiddate: Time.utc(2021, 5, 3), assigned_to: assigned_to_user) }
    let!(:lettings_log_2) { create(:lettings_log, :completed, startdate: Time.utc(2021, 5, 3), mrcdate: Time.utc(2021, 5, 3), voiddate: Time.utc(2021, 5, 3), assigned_to: assigned_to_user) }
    let(:postcode_to_search) { "SW1A 0AA" }

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
        context "when not associated with a location" do
          before do
            lettings_log_to_search.update!(postcode_full: postcode_to_search)
          end

          it "allows searching by a Property Postcode" do
            result = described_class.filter_by_postcode(postcode_to_search)
            expect(result.count).to eq(1)
            expect(result.first.id).to eq lettings_log_to_search.id
          end
        end

        context "when lettings log is supported housing" do
          let(:location) { create(:location, postcode: postcode_to_search) }

          before do
            lettings_log_to_search.update!(needstype: 2, location:)
          end

          it "allows searching by a Property Postcode" do
            result = described_class.filter_by_location_postcode(postcode_to_search)
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
          lettings_log_to_search.update!(postcode_full: postcode_to_search)
          result = described_class.search_by(postcode_to_search)
          expect(result.count).to eq(1)
          expect(result.first.id).to eq lettings_log_to_search.id
        end

        it "allows searching by id including the word log" do
          result = described_class.search_by("log#{lettings_log_to_search.id}")
          expect(result.count).to eq(1)
          expect(result.first.id).to eq lettings_log_to_search.id
        end

        it "allows searching by id including the capitalised word Log" do
          result = described_class.search_by("Log#{lettings_log_to_search.id}")
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
          it "allows searching by a Property Postcode" do
            lettings_log_to_search.update!(postcode_full: postcode_to_search)
            unformatted_postcode = postcode_to_search.downcase.chars.join(" ")
            result = described_class.search_by(unformatted_postcode)
            expect(result.count).to eq(1)
            expect(result.first.id).to eq lettings_log_to_search.id
          end
        end

        context "when matching multiple records on different fields" do
          let!(:lettings_log_with_propcode) { create(:lettings_log, propcode: lettings_log_to_search.id) }
          let!(:lettings_log_with_tenancycode) { create(:lettings_log, tenancycode: lettings_log_to_search.id) }
          let!(:lettings_log_with_postcode) { create(:lettings_log, postcode_full: "C1 1AC") }
          let!(:lettings_log_with_postcode_tenancycode) { create(:lettings_log, tenancycode: "C1 1AC") }
          let!(:lettings_log_with_postcode_propcode) { create(:lettings_log, propcode: "C1 1AC") }

          it "returns all matching records in correct order with matching IDs" do
            result = described_class.search_by(lettings_log_to_search.id.to_s)
            expect(result.count).to eq(3)
            expect(result.first.id).to eq lettings_log_to_search.id
            expect(result.second.id).to eq lettings_log_with_tenancycode.id
            expect(result.third.id).to eq lettings_log_with_propcode.id
          end

          it "returns all matching records in correct order with matching postcode" do
            result = described_class.search_by("C1 1AC")
            expect(result.count).to eq(3)
            expect(result.first.id).to eq lettings_log_with_postcode_tenancycode.id
            expect(result.second.id).to eq lettings_log_with_postcode_propcode.id
            expect(result.third.id).to eq lettings_log_with_postcode.id
          end
        end

        it "sanitises input for order" do
          lettings_log_to_search.update!(tenancycode: "' 1234")
          result = described_class.search_by(lettings_log_to_search.tenancycode)
          expect(result.count).to eq(1)
          expect(result.first.id).to eq lettings_log_to_search.id
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

    context "when filtering by year or nil" do
      before do
        Timecop.freeze(Time.utc(2021, 5, 3))
      end

      after do
        Timecop.unfreeze
      end

      it "allows filtering on a single year or nil" do
        lettings_log_1.startdate = nil
        lettings_log_1.save!(validate: false)
        expect(described_class.filter_by_years_or_nil(%w[2021]).count).to eq(2)
      end

      it "allows filtering by multiple years or nil using OR" do
        lettings_log_1.startdate = nil
        lettings_log_1.save!(validate: false)
        expect(described_class.filter_by_years_or_nil(%w[2021 2022]).count).to eq(3)
      end

      it "can filter by year(s) AND status" do
        lettings_log_2.startdate = nil
        lettings_log_2.save!(validate: false)
        expect(described_class.filter_by_years_or_nil(%w[2021 2022]).filter_by_status("in_progress").count).to eq(3)
      end
    end

    context "when filtering by organisation" do
      let(:organisation_1) { create(:organisation) }
      let(:organisation_2) { create(:organisation) }
      let(:organisation_3) { create(:organisation) }

      before do
        create(:lettings_log, :in_progress, owning_organisation: organisation_1, managing_organisation: organisation_1, assigned_to: nil)
        create(:lettings_log, :completed, owning_organisation: organisation_1, managing_organisation: organisation_2, assigned_to: nil)
        create(:lettings_log, :completed, owning_organisation: organisation_2, managing_organisation: organisation_1, assigned_to: nil)
        create(:lettings_log, :completed, owning_organisation: organisation_2, managing_organisation: organisation_2, assigned_to: nil)
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
        create(:lettings_log, :in_progress, owning_organisation: organisation_1, managing_organisation: organisation_1, assigned_to: nil)
        create(:lettings_log, :completed, owning_organisation: organisation_1, managing_organisation: organisation_2, assigned_to: nil)
        create(:lettings_log, :completed, owning_organisation: organisation_2, managing_organisation: organisation_1, assigned_to: nil)
        create(:lettings_log, :completed, owning_organisation: organisation_2, managing_organisation: organisation_2, assigned_to: nil)
      end

      it "filters by given owning organisation" do
        expect(described_class.filter_by_owning_organisation([organisation_1]).count).to eq(2)
        expect(described_class.filter_by_owning_organisation([organisation_1, organisation_2]).count).to eq(4)
        expect(described_class.filter_by_owning_organisation([organisation_3]).count).to eq(0)
      end
    end

    context "when filtering by managing organisation" do
      let(:organisation_1) { create(:organisation) }
      let(:organisation_2) { create(:organisation) }
      let(:organisation_3) { create(:organisation) }

      before do
        create(:lettings_log, :in_progress, managing_organisation: organisation_1)
        create(:lettings_log, :completed, managing_organisation: organisation_1)
        create(:lettings_log, :completed, managing_organisation: organisation_2)
        create(:lettings_log, :completed, managing_organisation: organisation_2)
      end

      it "filters by given managing organisation" do
        expect(described_class.filter_by_managing_organisation([organisation_1]).count).to eq(2)
        expect(described_class.filter_by_managing_organisation([organisation_1, organisation_2]).count).to eq(4)
        expect(described_class.filter_by_managing_organisation([organisation_3]).count).to eq(0)
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
        PaperTrail::Version.find_by(item_id: lettings_log_1.id, event: "create").update!(whodunnit: assigned_to_user.to_global_id.uri.to_s)
        PaperTrail::Version.find_by(item_id: lettings_log_2.id, event: "create").update!(whodunnit: assigned_to_user.to_global_id.uri.to_s)
      end

      it "allows filtering on current user" do
        expect(described_class.filter_by_user(assigned_to_user.id.to_s).count).to eq(2)
      end

      it "returns all logs when all logs selected" do
        expect(described_class.filter_by_user(nil).count).to eq(3)
      end
    end

    context "when filtering duplicate logs" do
      let(:organisation) { create(:organisation) }
      let(:log) { create(:lettings_log, :duplicate, owning_organisation: organisation) }
      let!(:duplicate_log) { create(:lettings_log, :duplicate, owning_organisation: organisation) }

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
        let!(:deleted_duplicate_log) { create(:lettings_log, :duplicate, discarded_at: Time.zone.now, owning_organisation: organisation) }

        it "does not return the deleted log as a duplicate" do
          expect(described_class.duplicate_logs(log)).not_to include(deleted_duplicate_log)
        end
      end

      context "when there is a log with a different start date" do
        let!(:different_start_date_log) { create(:lettings_log, :duplicate, startdate: Time.zone.tomorrow, owning_organisation: organisation) }

        it "does not return a log with a different start date as a duplicate" do
          expect(described_class.duplicate_logs(log)).not_to include(different_start_date_log)
        end
      end

      context "when there is a log with a different age1" do
        let!(:different_age1) { create(:lettings_log, :duplicate, age1: 50, owning_organisation: organisation) }

        it "does not return a log with a different age1 as a duplicate" do
          expect(described_class.duplicate_logs(log)).not_to include(different_age1)
        end
      end

      context "when there is a log with a different sex1" do
        let!(:different_sex1) { create(:lettings_log, :duplicate, sex1: "F", owning_organisation: organisation) }

        it "does not return a log with a different sex1 as a duplicate" do
          expect(described_class.duplicate_logs(log)).not_to include(different_sex1)
        end
      end

      context "when there is a log with a different ecstat1" do
        let!(:different_ecstat1) { create(:lettings_log, :duplicate, ecstat1: 1, owning_organisation: organisation) }

        it "does not return a log with a different ecstat1 as a duplicate" do
          expect(described_class.duplicate_logs(log)).not_to include(different_ecstat1)
        end
      end

      context "when there is a log with a different tcharge" do
        let!(:different_tcharge) { create(:lettings_log, :duplicate, brent: 100, owning_organisation: organisation) }

        it "does not return a log with a different tcharge as a duplicate" do
          expect(described_class.duplicate_logs(log)).not_to include(different_tcharge)
        end
      end

      context "when there is a log with a different tenancycode" do
        let!(:different_tenancycode) { create(:lettings_log, :duplicate, tenancycode: "different", owning_organisation: organisation) }

        it "does not return a log with a different tenancycode as a duplicate" do
          expect(described_class.duplicate_logs(log)).not_to include(different_tenancycode)
        end
      end

      context "when there is a log with a different postcode_full" do
        let!(:different_postcode_full) { create(:lettings_log, :duplicate, postcode_full: "B1 1AA", owning_organisation: organisation) }

        it "does not return a log with a different postcode_full as a duplicate" do
          expect(described_class.duplicate_logs(log)).not_to include(different_postcode_full)
        end
      end

      context "when there is a log with nil values for duplicate check fields" do
        let!(:duplicate_check_fields_not_given) { create(:lettings_log, :duplicate, age1: nil, sex1: nil, ecstat1: nil, postcode_known: 2, postcode_full: nil, owning_organisation: organisation) }

        it "does not return a log with nil values as a duplicate" do
          log.update!(age1: nil, sex1: nil, ecstat1: nil, postcode_known: 2, postcode_full: nil)
          expect(described_class.duplicate_logs(log)).not_to include(duplicate_check_fields_not_given)
        end
      end

      context "when there is a log with nil values for tenancycode" do
        let!(:tenancycode_not_given) { create(:lettings_log, :duplicate, tenancycode: nil, owning_organisation: organisation) }

        it "returns the log as a duplicate if tenancy code is nil" do
          log.update!(tenancycode: nil)
          expect(described_class.duplicate_logs(log)).to include(tenancycode_not_given)
        end
      end

      context "when there is a log with age1 not known" do
        let!(:age1_not_known) { create(:lettings_log, :duplicate, age1_known: 1, age1: nil, owning_organisation: organisation) }

        it "returns the log as a duplicate if age1 is not known" do
          log.update!(age1_known: 1, age1: nil)
          expect(described_class.duplicate_logs(log)).to include(age1_not_known)
        end
      end

      context "when there is a duplicate supported housing log" do
        let(:scheme) { create(:scheme) }
        let(:location) { create(:location, scheme:) }
        let(:location_2) { create(:location, scheme:) }
        let(:supported_housing_log) { create(:lettings_log, :duplicate, needstype: 2, location:, scheme:, owning_organisation: organisation) }
        let!(:duplicate_supported_housing_log) { create(:lettings_log, :duplicate, needstype: 2, location:, scheme:, owning_organisation: organisation) }

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

    context "when getting list of duplicate logs" do
      let(:organisation) { create(:organisation) }
      let!(:log) { create(:lettings_log, :duplicate, owning_organisation: organisation) }
      let!(:duplicate_log) { create(:lettings_log, :duplicate, owning_organisation: organisation) }
      let(:duplicate_sets) { described_class.duplicate_sets }

      it "returns a list of duplicates in the same organisation" do
        expect(duplicate_sets.count).to eq(1)
        expect(duplicate_sets.first).to contain_exactly(log.id, duplicate_log.id)
      end

      context "when there is a deleted duplicate log" do
        before do
          create(:lettings_log, :duplicate, discarded_at: Time.zone.now, status: 4)
        end

        it "does not return the deleted log as a duplicate" do
          expect(duplicate_sets.count).to eq(1)
          expect(duplicate_sets.first).to contain_exactly(log.id, duplicate_log.id)
        end
      end

      context "when there is a log with a different start date" do
        before do
          create(:lettings_log, :duplicate, startdate: Time.zone.tomorrow)
        end

        it "does not return a log with a different start date as a duplicate" do
          expect(duplicate_sets.count).to eq(1)
          expect(duplicate_sets.first).to contain_exactly(log.id, duplicate_log.id)
        end
      end

      context "when there is a log with a different age1" do
        before do
          create(:lettings_log, :duplicate, age1: 50)
        end

        it "does not return a log with a different age1 as a duplicate" do
          expect(duplicate_sets.count).to eq(1)
          expect(duplicate_sets.first).to contain_exactly(log.id, duplicate_log.id)
        end
      end

      context "when there is a log with a different sex1" do
        before do
          create(:lettings_log, :duplicate, sex1: "F")
        end

        it "does not return a log with a different sex1 as a duplicate" do
          expect(duplicate_sets.count).to eq(1)
          expect(duplicate_sets.first).to contain_exactly(log.id, duplicate_log.id)
        end
      end

      context "when there is a log with a different ecstat1" do
        before do
          create(:lettings_log, :duplicate, ecstat1: 1)
        end

        it "does not return a log with a different ecstat1 as a duplicate" do
          expect(duplicate_sets.count).to eq(1)
          expect(duplicate_sets.first).to contain_exactly(log.id, duplicate_log.id)
        end
      end

      context "when there is a log with a different tcharge" do
        before do
          create(:lettings_log, :duplicate, brent: 100)
        end

        it "does not return a log with a different tcharge as a duplicate" do
          expect(duplicate_sets.count).to eq(1)
          expect(duplicate_sets.first).to contain_exactly(duplicate_log.id, log.id)
        end
      end

      context "when there is a log with a different tenancycode" do
        before do
          create(:lettings_log, :duplicate, tenancycode: "different")
        end

        it "does not return a log with a different tenancycode as a duplicate" do
          expect(duplicate_sets.count).to eq(1)
          expect(duplicate_sets.first).to contain_exactly(log.id, duplicate_log.id)
        end
      end

      context "when there is a log with a different postcode_full" do
        before do
          create(:lettings_log, :duplicate, postcode_full: "B1 1AA")
        end

        it "does not return a log with a different postcode_full as a duplicate" do
          expect(duplicate_sets.count).to eq(1)
          expect(duplicate_sets.first).to contain_exactly(log.id, duplicate_log.id)
        end
      end

      context "when there is a log with nil values for duplicate check fields" do
        before do
          create(:lettings_log, :duplicate, age1: nil, sex1: nil, ecstat1: nil, postcode_known: 2, postcode_full: nil)
        end

        it "does not return a log with nil values as a duplicate" do
          log.update!(age1: nil, sex1: nil, ecstat1: nil, postcode_known: 2, postcode_full: nil)
          expect(duplicate_sets).to be_empty
        end
      end

      context "when there is a log with nil values for tenancycode" do
        let!(:tenancycode_not_given) { create(:lettings_log, :duplicate, tenancycode: nil, owning_organisation: organisation) }

        it "returns the log as a duplicate if tenancy code is nil" do
          log.update!(tenancycode: nil)
          expect(duplicate_sets.count).to eq(1)
          expect(duplicate_sets.first).to contain_exactly(log.id, tenancycode_not_given.id)
        end
      end

      context "when there is a log with age1 not known" do
        let!(:age1_not_known) { create(:lettings_log, :duplicate, age1_known: 1, age1: nil, owning_organisation: organisation) }

        it "returns the log as a duplicate if age1 is not known" do
          log.update!(age1_known: 1, age1: nil)
          expect(duplicate_sets.count).to eq(1)
          expect(duplicate_sets.first).to contain_exactly(age1_not_known.id, log.id)
        end
      end

      context "when there is a duplicate supported housing log" do
        let(:scheme) { create(:scheme, owning_organisation: organisation) }
        let(:location) { create(:location, scheme:) }
        let(:location_2) { create(:location, scheme:) }
        let!(:supported_housing_log) { create(:lettings_log, :duplicate, needstype: 2, location:, scheme:, owning_organisation: organisation) }
        let!(:duplicate_supported_housing_log) { create(:lettings_log, :duplicate, needstype: 2, location:, scheme:, owning_organisation: organisation) }

        it "returns the log as a duplicate" do
          expect(duplicate_sets.count).to eq(2)
          expect(duplicate_sets.first).to contain_exactly(log.id, duplicate_log.id)
          expect(duplicate_sets.second).to contain_exactly(duplicate_supported_housing_log.id, supported_housing_log.id)
        end

        it "does not return the log if the locations are different" do
          duplicate_supported_housing_log.update!(location: location_2)
          expect(duplicate_sets.count).to eq(1)
          expect(duplicate_sets.first).to contain_exactly(log.id, duplicate_log.id)
        end

        it "does not compare tcharge if there are no household charges" do
          supported_housing_log.update!(household_charge: 1, supcharg: nil, brent: nil, scharge: nil, pscharge: nil, tcharge: nil, owning_organisation: organisation)
          duplicate_supported_housing_log.update!(household_charge: 1, supcharg: nil, brent: nil, scharge: nil, pscharge: nil, tcharge: nil, owning_organisation: organisation)
          expect(duplicate_sets.count).to eq(2)
          expect(duplicate_sets.first).to contain_exactly(log.id, duplicate_log.id)
          expect(duplicate_sets.second).to contain_exactly(supported_housing_log.id, duplicate_supported_housing_log.id)
        end

        it "does not return logs not associated with the user if user is given" do
          user = create(:user, organisation:)
          supported_housing_log.update!(assigned_to: user)
          duplicate_sets = described_class.duplicate_sets(user.id)
          expect(duplicate_sets.count).to eq(1)
          expect(duplicate_sets.first).to contain_exactly(supported_housing_log.id, duplicate_supported_housing_log.id)
        end

        it "compares chcharge if it's a carehome" do
          supported_housing_log.update!(is_carehome: 1, chcharge: 100, supcharg: nil, brent: nil, scharge: nil, pscharge: nil, tcharge: nil, owning_organisation: organisation)
          duplicate_supported_housing_log.update!(is_carehome: 1, chcharge: 100, supcharg: nil, brent: nil, scharge: nil, pscharge: nil, tcharge: nil, owning_organisation: organisation)
          expect(duplicate_sets.count).to eq(2)
          expect(duplicate_sets.first).to contain_exactly(log.id, duplicate_log.id)
          expect(duplicate_sets.second).to contain_exactly(supported_housing_log.id, duplicate_supported_housing_log.id)
        end

        it "does not return a duplicate if carehome charge is not given" do
          supported_housing_log.update!(is_carehome: 1, chcharge: nil, supcharg: nil, brent: nil, scharge: nil, pscharge: nil, tcharge: nil, owning_organisation: organisation)
          duplicate_supported_housing_log.update!(is_carehome: 1, chcharge: nil, supcharg: nil, brent: nil, scharge: nil, pscharge: nil, tcharge: nil, owning_organisation: organisation)
          expect(duplicate_sets.count).to eq(1)
          expect(duplicate_sets.first).to contain_exactly(log.id, duplicate_log.id)
        end
      end
    end
  end

  context "when a postcode contains unicode characters" do
    let(:lettings_log) { build(:lettings_log, postcode_full: "SR81LS\u00A0") }

    it "triggers a validation error" do
      expect { lettings_log.save! }.to raise_error(ActiveRecord::RecordInvalid, /Enter a postcode in the correct format/)
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

  describe "#applicable_income_range" do
    context "when ecstat for a non-lead tenant is not set" do
      context "and their age is >= 16" do
        let(:lettings_log) { build(:lettings_log, hhmemb: 2, ecstat1: 1, age2: 16) }

        it "uses the prefers-not-to-say values for that tenant to calculate the range" do
          range = lettings_log.applicable_income_range
          expected_range = OpenStruct.new(
            soft_min: 143 + 47,
            soft_max: 730 + 730,
            hard_min: 90 + 10,
            hard_max: 1230 + 2000,
          )
          expect(range).to eq(expected_range)
        end
      end

      context "and their age is blank" do
        let(:lettings_log) { build(:lettings_log, hhmemb: 2, ecstat1: 1, age2: nil) }

        it "uses the prefers-not-to-say values for that tenant to calculate the range" do
          range = lettings_log.applicable_income_range
          expected_range = OpenStruct.new(
            soft_min: 143 + 47,
            soft_max: 730 + 730,
            hard_min: 90 + 10,
            hard_max: 1230 + 2000,
          )
          expect(range).to eq(expected_range)
        end
      end

      context "and their age is < 16" do
        let(:lettings_log) { build(:lettings_log, hhmemb: 2, ecstat1: 1, age2: 15) }

        it "uses the child-under-16 values for that tenant to calculate the range" do
          range = lettings_log.applicable_income_range
          expected_range = OpenStruct.new(
            soft_min: 143 + 50,
            soft_max: 730 + 450,
            hard_min: 90 + 10,
            hard_max: 1230 + 750,
          )
          expect(range).to eq(expected_range)
        end
      end
    end

    context "when ecstat for a non-lead tenant is set" do
      let(:lettings_log) { build(:lettings_log, hhmemb: 2, ecstat1: 1, ecstat2: 2) }

      it "uses the relevant income range values for that tenant to calculate the range" do
        range = lettings_log.applicable_income_range
        expected_range = OpenStruct.new(
          soft_min: 143 + 67,
          soft_max: 730 + 620,
          hard_min: 90 + 50,
          hard_max: 1230 + 950,
        )
        expect(range).to eq(expected_range)
      end
    end
  end

  describe "#non_location_setup_questions_completed" do
    before do
      Timecop.return
      allow(FormHandler.instance).to receive(:current_lettings_form).and_call_original
      Singleton.__init__(FormHandler)
    end

    context "when setup section has been completed" do
      let(:lettings_log) { build_stubbed(:lettings_log, :setup_completed) }

      it "returns true" do
        expect(lettings_log).to be_non_location_setup_questions_completed
      end
    end

    context "when the declaration has not been completed for a 2024 log" do
      let(:lettings_log) { build_stubbed(:lettings_log, :setup_completed, startdate: Time.utc(2024, 10, 1), declaration: nil) }

      it "returns false" do
        expect(lettings_log).not_to be_non_location_setup_questions_completed
      end
    end

    context "when an optional question has not been completed" do
      let(:lettings_log) { build_stubbed(:lettings_log, :setup_completed, propcode: nil) }

      it "returns true" do
        expect(lettings_log).to be_non_location_setup_questions_completed
      end
    end

    context "when scheme and location have not been completed" do
      let(:lettings_log) { build_stubbed(:lettings_log, :setup_completed, :sh, scheme_id: nil, location_id: nil) }

      it "returns true" do
        expect(lettings_log).to be_non_location_setup_questions_completed
      end
    end
  end
end
# rubocop:enable RSpec/MessageChain
