require "rails_helper"
require "shared/shared_examples_for_derived_fields"

# rubocop:disable RSpec/AnyInstance
RSpec.describe SalesLog, type: :model do
  let(:owning_organisation) { create(:organisation) }
  let(:created_by_user) { create(:user) }

  include_examples "shared examples for derived fields", :sales_log

  it "inherits from log" do
    expect(described_class).to be < Log
    expect(described_class).to be < ApplicationRecord
  end

  it "is a not a lettings log" do
    sales_log = build(:sales_log, created_by: created_by_user)
    expect(sales_log.lettings?).to be false
  end

  it "is a sales log" do
    sales_log = build(:sales_log, created_by: created_by_user)
    expect(sales_log.sales?).to be true
  end

  describe "#new" do
    context "when creating a record" do
      let(:sales_log) do
        described_class.create
      end

      it "attaches the correct custom validator" do
        expect(sales_log._validators.values.flatten.map(&:class))
          .to include(SalesLogValidator)
      end
    end
  end

  describe "#update" do
    let(:sales_log) { create(:sales_log, created_by: created_by_user) }
    let(:validator) { sales_log._validators[nil].first }

    after do
      sales_log.update(age1: 25)
    end

    it "validates other household member details" do
      expect(validator).to receive(:validate_household_number_of_other_members)
    end
  end

  describe "#optional_fields" do
    context "when saledate is before 2023" do
      let(:sales_log) { build(:sales_log, saledate: Time.zone.parse("2022-07-01")) }

      it "returns optional fields" do
        expect(sales_log.optional_fields).to eq(%w[
          saledate_check
          purchid
          monthly_charges_value_check
          old_persons_shared_ownership_value_check
          mortgagelender
          othtype
          proplen
          mortlen
          frombeds
        ])
      end
    end

    context "when saledate is after 2023" do
      let(:sales_log) { build(:sales_log, saledate: Time.zone.parse("2023-07-01")) }

      it "returns optional fields" do
        expect(sales_log.optional_fields).to eq(%w[
          saledate_check
          purchid
          monthly_charges_value_check
          old_persons_shared_ownership_value_check
          mortgagelender
          othtype
          address_line2
          county
          postcode_full
        ])
      end
    end
  end

  describe "#form" do
    let(:sales_log) { build(:sales_log, created_by: created_by_user) }
    let(:sales_log_2) { build(:sales_log, saledate: Time.zone.local(2022, 5, 1), created_by: created_by_user) }

    it "has returns the correct form based on the start date" do
      expect(sales_log.form_name).to be_nil
      expect(sales_log.form).to be_a(Form)
      expect(sales_log_2.form_name).to eq("current_sales")
      expect(sales_log_2.form).to be_a(Form)
    end
  end

  describe "status" do
    let!(:empty_sales_log) { create(:sales_log) }
    let!(:in_progress_sales_log) { create(:sales_log, :in_progress) }
    let!(:completed_sales_log) { create(:sales_log, :completed) }

    it "is set to not started for an empty sales log" do
      expect(empty_sales_log.not_started?).to be(true)
      expect(empty_sales_log.in_progress?).to be(false)
      expect(empty_sales_log.completed?).to be(false)
    end

    it "is set to in progress for a started sales log" do
      expect(in_progress_sales_log.in_progress?).to be(true)
      expect(in_progress_sales_log.not_started?).to be(false)
      expect(in_progress_sales_log.completed?).to be(false)
    end

    it "is set to completed for a completed sales log" do
      expect(completed_sales_log.in_progress?).to be(false)
      expect(completed_sales_log.not_started?).to be(false)
      expect(completed_sales_log.completed?).to be(true)
    end

    context "when proplen is not given" do
      before do
        Timecop.freeze(Time.zone.local(2023, 5, 1))
      end

      after do
        Timecop.unfreeze
      end

      it "is set to completed for a log with a saledate before 23/24" do
        completed_sales_log.update!(proplen: nil, saledate: Time.zone.local(2022, 5, 1))
        expect(completed_sales_log.in_progress?).to be(false)
        expect(completed_sales_log.not_started?).to be(false)
        expect(completed_sales_log.completed?).to be(true)
      end

      it "is set to in_progress for a log with a saledate after 23/24" do
        completed_sales_log.update!(proplen: nil, saledate: Time.zone.local(2023, 5, 1))
        expect(completed_sales_log.in_progress?).to be(true)
        expect(completed_sales_log.not_started?).to be(false)
        expect(completed_sales_log.completed?).to be(false)
      end
    end
  end

  context "when filtering by organisation" do
    let(:organisation_1) { create(:organisation) }
    let(:organisation_2) { create(:organisation) }
    let(:organisation_3) { create(:organisation) }

    before do
      create(:sales_log, :in_progress, owning_organisation: organisation_1)
      create(:sales_log, :completed, owning_organisation: organisation_1)
      create(:sales_log, :completed, owning_organisation: organisation_2)
    end

    it "filters by given organisation" do
      expect(described_class.filter_by_organisation([organisation_1]).count).to eq(2)
      expect(described_class.filter_by_organisation([organisation_1, organisation_2]).count).to eq(3)
      expect(described_class.filter_by_organisation([organisation_3]).count).to eq(0)
    end
  end

  describe "derived variables" do
    let(:sales_log) { create(:sales_log, :completed) }

    it "correctly derives and saves exday, exmonth and exyear" do
      sales_log.update!(exdate: Time.gm(2022, 5, 4), saledate: Time.gm(2022, 7, 4), ownershipsch: 1, staircase: 2, resale: 2)
      record_from_db = ActiveRecord::Base.connection.execute("select exday, exmonth, exyear from sales_logs where id=#{sales_log.id}").to_a[0]
      expect(record_from_db["exday"]).to eq(4)
      expect(record_from_db["exmonth"]).to eq(5)
      expect(record_from_db["exyear"]).to eq(2022)
    end

    it "correctly derives and saves deposit for outright sales when no mortgage is used" do
      sales_log.update!(value: 123_400, deposit: nil, mortgageused: 2, ownershipsch: 3, type: 10, companybuy: 1, jointpur: 1, jointmore: 1)
      record_from_db = ActiveRecord::Base.connection.execute("select deposit from sales_logs where id=#{sales_log.id}").to_a[0]
      expect(record_from_db["deposit"]).to eq(123_400)
    end

    it "does not derive deposit if the sale isn't outright" do
      sales_log.update!(value: 123_400, deposit: nil, mortgageused: 2, ownershipsch: 2)
      record_from_db = ActiveRecord::Base.connection.execute("select deposit from sales_logs where id=#{sales_log.id}").to_a[0]
      expect(record_from_db["deposit"]).to eq(nil)
    end

    it "does not derive deposit if the mortgage is used" do
      sales_log.update!(value: 123_400, deposit: nil, mortgageused: 1, ownershipsch: 3, type: 10, companybuy: 1, jointpur: 1, jointmore: 1)
      record_from_db = ActiveRecord::Base.connection.execute("select deposit from sales_logs where id=#{sales_log.id}").to_a[0]
      expect(record_from_db["deposit"]).to eq(nil)
    end

    it "correctly derives and saves pcode1 and pcode1 and pcode2" do
      sales_log.update!(postcode_full: "W6 0SP")
      record_from_db = ActiveRecord::Base.connection.execute("select pcode1, pcode2 from sales_logs where id=#{sales_log.id}").to_a[0]
      expect(record_from_db["pcode1"]).to eq("W6")
      expect(record_from_db["pcode2"]).to eq("0SP")
    end

    it "derives a mortgage value of 0 when mortgage is not used" do
      # to avoid log failing validations when mortgage value is removed:
      new_grant_value = sales_log.grant + sales_log.mortgage
      sales_log.update!(mortgageused: 2, grant: new_grant_value)
      record_from_db = ActiveRecord::Base.connection.execute("select mortgage from sales_logs where id=#{sales_log.id}").to_a[0]
      expect(record_from_db["mortgage"]).to eq(0.0)
    end
  end

  context "when saving addresses" do
    before do
      stub_request(:get, /api.postcodes.io/)
        .to_return(status: 200, body: "{\"status\":200,\"result\":{\"admin_district\":\"Manchester\",\"codes\":{\"admin_district\": \"E08000003\"}}}", headers: {})
    end

    def check_postcode_fields(postcode_field)
      record_from_db = ActiveRecord::Base.connection.execute("select #{postcode_field} from sales_logs where id=#{address_sales_log.id}").to_a[0]
      expect(address_sales_log[postcode_field]).to eq("M1 1AE")
      expect(record_from_db[postcode_field]).to eq("M1 1AE")
    end

    let!(:address_sales_log) do
      create(
        :sales_log,
        :completed,
        owning_organisation:,
        created_by: created_by_user,
        pcodenk: 0,
        postcode_full: "M1 1AE",
      )
    end

    def check_property_postcode_fields
      check_postcode_fields("postcode_full")
    end

    it "correctly formats previous postcode" do
      address_sales_log.update!(postcode_full: "M1 1AE")
      check_property_postcode_fields

      address_sales_log.update!(postcode_full: "m1 1ae")
      check_property_postcode_fields

      address_sales_log.update!(postcode_full: "m11Ae")
      check_property_postcode_fields

      address_sales_log.update!(postcode_full: "m11ae")
      check_property_postcode_fields
    end

    it "correctly infers la" do
      record_from_db = ActiveRecord::Base.connection.execute("select la from sales_logs where id=#{address_sales_log.id}").to_a[0]
      expect(address_sales_log.la).to eq("E08000003")
      expect(record_from_db["la"]).to eq("E08000003")
    end

    context "with 22/23 logs" do
      let(:address_sales_log_22_23) do
        described_class.create({
          owning_organisation:,
          created_by: created_by_user,
          ppcodenk: 1,
          postcode_full: "CA10 1AA",
          saledate: Time.zone.local(2022, 5, 2),
        })
      end

      before do
        WebMock.stub_request(:get, /api.postcodes.io\/postcodes\/CA101AA/)
               .to_return(status: 200, body: '{"status":200,"result":{"admin_district":"Cumberland","codes":{"admin_district":"E06000064"}}}', headers: {})

        Timecop.freeze(2023, 5, 1)
        Singleton.__init__(FormHandler)
      end

      after do
        Timecop.unfreeze
      end

      it "correctly sets la as nil" do
        record_from_db = ActiveRecord::Base.connection.execute("select la from sales_logs where id=#{address_sales_log_22_23.id}").to_a[0]
        expect(address_sales_log_22_23.la).to eq(nil)
        expect(record_from_db["la"]).to eq(nil)
      end
    end

    context "with 23/24 logs" do
      let(:address_sales_log_23_24) do
        described_class.create({
          owning_organisation:,
          created_by: created_by_user,
          ppcodenk: 1,
          postcode_full: "CA10 1AA",
          saledate: Time.zone.local(2023, 5, 2),
        })
      end

      before do
        WebMock.stub_request(:get, /api.postcodes.io\/postcodes\/CA101AA/)
        .to_return(status: 200, body: '{"status":200,"result":{"admin_district":"Eden","codes":{"admin_district":"E07000030"}}}', headers: {})

        Timecop.freeze(2023, 4, 1)
        Singleton.__init__(FormHandler)
      end

      after do
        Timecop.unfreeze
      end

      it "correctly infers new la" do
        record_from_db = ActiveRecord::Base.connection.execute("select la from sales_logs where id=#{address_sales_log_23_24.id}").to_a[0]
        expect(address_sales_log_23_24.la).to eq("E06000064")
        expect(record_from_db["la"]).to eq("E06000064")
      end
    end

    it "errors if the property postcode is emptied" do
      expect { address_sales_log.update!({ postcode_full: "" }) }
        .to raise_error(ActiveRecord::RecordInvalid, /#{I18n.t("validations.postcode")}/)
    end

    it "errors if the property postcode is not valid" do
      expect { address_sales_log.update!({ postcode_full: "invalid_postcode" }) }
        .to raise_error(ActiveRecord::RecordInvalid, /#{I18n.t("validations.postcode")}/)
    end

    context "when the local authority lookup times out" do
      before do
        allow(Timeout).to receive(:timeout).and_raise(Timeout::Error)
      end

      it "logs a warning" do
        expect(Rails.logger).to receive(:warn).with("Postcodes.io lookup timed out")
        address_sales_log.update!({ pcodenk: 1, postcode_full: "M1 1AD" })
      end
    end

    it "correctly resets all fields if property postcode not known" do
      address_sales_log.update!({ pcodenk: 1 })

      record_from_db = ActiveRecord::Base.connection.execute("select la, postcode_full from sales_logs where id=#{address_sales_log.id}").to_a[0]
      expect(record_from_db["postcode_full"]).to eq(nil)
      expect(address_sales_log.la).to eq(nil)
      expect(record_from_db["la"]).to eq(nil)
    end

    it "changes the LA if property postcode changes from not known to known and provided" do
      address_sales_log.update!({ pcodenk: 1 })
      address_sales_log.update!({ la: "E09000033" })

      record_from_db = ActiveRecord::Base.connection.execute("select la, postcode_full from sales_logs where id=#{address_sales_log.id}").to_a[0]
      expect(record_from_db["postcode_full"]).to eq(nil)
      expect(address_sales_log.la).to eq("E09000033")
      expect(record_from_db["la"]).to eq("E09000033")

      address_sales_log.update!({ pcodenk: 0, postcode_full: "M1 1AD" })

      record_from_db = ActiveRecord::Base.connection.execute("select la, postcode_full from sales_logs where id=#{address_sales_log.id}").to_a[0]
      expect(record_from_db["postcode_full"]).to eq("M1 1AD")
      expect(address_sales_log.la).to eq("E08000003")
      expect(record_from_db["la"]).to eq("E08000003")
    end
  end

  context "when deriving household variables" do
    let!(:sales_log) do
      create(
        :sales_log,
        :completed,
        jointpur: 1,
        hholdcount: 4,
        details_known_3: 1,
        details_known_4: 1,
        details_known_5: 1,
        details_known_6: 1,
        relat2: "C",
        relat3: "C",
        relat4: "X",
        relat5: "X",
        relat6: "P",
        income2: 0,
        ecstat2: 9,
        ecstat3: 7,
        age1: 47,
        age2: 14,
        age3: 17,
        age4: 88,
        age5: 19,
        age6: 46,
      )
    end

    it "correctly derives and saves hhmemb" do
      record_from_db = ActiveRecord::Base.connection.execute("select hhmemb from sales_logs where id=#{sales_log.id}").to_a[0]
      expect(record_from_db["hhmemb"]).to eq(6)
    end

    it "correctly derives and saves hhmemb if it's a joint purchase" do
      sales_log.update!(jointpur: 2, jointmore: 2)
      record_from_db = ActiveRecord::Base.connection.execute("select hhmemb from sales_logs where id=#{sales_log.id}").to_a[0]
      expect(record_from_db["hhmemb"]).to eq(5)
    end

    it "correctly derives and saves totchild" do
      record_from_db = ActiveRecord::Base.connection.execute("select totchild from sales_logs where id=#{sales_log.id}").to_a[0]
      expect(record_from_db["totchild"]).to eq(2)
    end

    it "correctly derives and saves totadult" do
      record_from_db = ActiveRecord::Base.connection.execute("select totadult from sales_logs where id=#{sales_log.id}").to_a[0]
      expect(record_from_db["totadult"]).to eq(4)
    end

    it "correctly derives and saves hhtype" do
      record_from_db = ActiveRecord::Base.connection.execute("select hhtype from sales_logs where id=#{sales_log.id}").to_a[0]
      expect(record_from_db["hhtype"]).to eq(9)
    end
  end

  context "when saving previous address" do
    def check_previous_postcode_fields(postcode_field)
      record_from_db = ActiveRecord::Base.connection.execute("select #{postcode_field} from sales_logs where id=#{address_sales_log.id}").to_a[0]
      expect(address_sales_log[postcode_field]).to eq("M1 1AE")
      expect(record_from_db[postcode_field]).to eq("M1 1AE")
    end

    before do
      stub_request(:get, /api.postcodes.io/)
        .to_return(status: 200, body: "{\"status\":200,\"result\":{\"admin_district\":\"Manchester\", \"codes\":{\"admin_district\": \"E08000003\"}}}", headers: {})
    end

    let!(:address_sales_log) do
      described_class.create({
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
      address_sales_log.update!(ppostcode_full: "M1 1AE")
      previous_postcode_fields

      address_sales_log.update!(ppostcode_full: "m1 1ae")
      previous_postcode_fields

      address_sales_log.update!(ppostcode_full: "m11Ae")
      previous_postcode_fields

      address_sales_log.update!(ppostcode_full: "m11ae")
      previous_postcode_fields
    end

    it "correctly infers prevloc" do
      record_from_db = ActiveRecord::Base.connection.execute("select prevloc from sales_logs where id=#{address_sales_log.id}").to_a[0]
      expect(address_sales_log.prevloc).to eq("E08000003")
      expect(record_from_db["prevloc"]).to eq("E08000003")
    end

    it "errors if the previous postcode is emptied" do
      expect { address_sales_log.update!({ ppostcode_full: "" }) }
        .to raise_error(ActiveRecord::RecordInvalid, /#{I18n.t("validations.postcode")}/)
    end

    it "errors if the previous postcode is not valid" do
      expect { address_sales_log.update!({ ppostcode_full: "invalid_postcode" }) }
        .to raise_error(ActiveRecord::RecordInvalid, /#{I18n.t("validations.postcode")}/)
    end

    it "correctly resets all fields if previous postcode not known" do
      address_sales_log.update!({ ppcodenk: 1 })

      record_from_db = ActiveRecord::Base.connection.execute("select prevloc, ppostcode_full from sales_logs where id=#{address_sales_log.id}").to_a[0]
      expect(record_from_db["ppostcode_full"]).to eq(nil)
      expect(address_sales_log.prevloc).to eq(nil)
      expect(record_from_db["prevloc"]).to eq(nil)
    end
  end

  describe "expected_shared_ownership_deposit_value" do
    let!(:completed_sales_log) { create(:sales_log, :completed, ownershipsch: 1, type: 2, value: 1000, equity: 50) }

    it "is set to completed for a completed sales log" do
      expect(completed_sales_log.expected_shared_ownership_deposit_value).to eq(500)
    end
  end

  describe "#field_formatted_as_currency" do
    let(:completed_sales_log) { create(:sales_log, :completed) }

    it "returns small numbers correctly formatted as currency" do
      completed_sales_log.update!(savings: 4)

      expect(completed_sales_log.field_formatted_as_currency("savings")).to eq("£4.00")
    end

    it "returns quite large numbers correctly formatted as currency" do
      completed_sales_log.update!(savings: 40_000)

      expect(completed_sales_log.field_formatted_as_currency("savings")).to eq("£40,000.00")
    end

    it "returns very large numbers correctly formatted as currency" do
      completed_sales_log.update!(savings: 400_000_000)

      expect(completed_sales_log.field_formatted_as_currency("savings")).to eq("£400,000,000.00")
    end
  end

  describe "#process_uprn_change!" do
    context "when UPRN set to a value" do
      let(:sales_log) { create(:sales_log, uprn: "123456789", uprn_confirmed: 1) }

      it "updates sales log fields" do
        sales_log.uprn = "1111111"

        allow_any_instance_of(UprnClient).to receive(:call)
        allow_any_instance_of(UprnClient).to receive(:result).and_return({
          "UPRN" => "UPRN",
          "UDPRN" => "UDPRN",
          "ADDRESS" => "full address",
          "SUB_BUILDING_NAME" => "0",
          "BUILDING_NAME" => "building name",
          "THOROUGHFARE_NAME" => "thoroughfare",
          "POST_TOWN" => "posttown",
          "POSTCODE" => "postcode",
        })

        expect { sales_log.process_uprn_change! }.to change(sales_log, :address_line1).from(nil).to("0, Building Name, Thoroughfare")
        .and change(sales_log, :town_or_city).from(nil).to("Posttown")
        .and change(sales_log, :postcode_full).from(nil).to("POSTCODE")
        .and change(sales_log, :uprn_confirmed).from(1).to(nil)
      end
    end

    context "when UPRN nil" do
      let(:sales_log) { create(:sales_log, uprn: nil) }

      it "does not update sales log" do
        expect { sales_log.process_uprn_change! }.not_to change(sales_log, :attributes)
      end
    end

    context "when service errors" do
      let(:sales_log) { create(:sales_log, uprn: "123456789", uprn_confirmed: 1) }
      let(:error_message) { "error" }

      it "adds error to sales log" do
        allow_any_instance_of(UprnClient).to receive(:call)
        allow_any_instance_of(UprnClient).to receive(:error).and_return(error_message)

        expect { sales_log.process_uprn_change! }.to change { sales_log.errors[:uprn] }.from([]).to([error_message])
      end
    end
  end
end
# rubocop:enable RSpec/AnyInstance
