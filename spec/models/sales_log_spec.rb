require "rails_helper"
require "shared/shared_examples_for_derived_fields"

RSpec.describe SalesLog, type: :model do
  let(:owning_organisation) { create(:organisation) }
  let(:created_by_user) { create(:user) }

  include_examples "shared examples for derived fields", :sales_log

  it "inherits from log" do
    expect(described_class).to be < Log
    expect(described_class).to be < ApplicationRecord
  end

  it "is a sales log" do
    sales_log = build(:sales_log, created_by: created_by_user)
    expect(sales_log.lettings?).to be false
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

  describe "#optional_fields" do
    let(:sales_log) { build(:sales_log) }

    it "returns optional fields" do
      expect(sales_log.optional_fields).to eq(%w[purchid])
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

    it "filters by given organisation id" do
      expect(described_class.filter_by_organisation([organisation_1.id]).count).to eq(2)
      expect(described_class.filter_by_organisation([organisation_1.id, organisation_2.id]).count).to eq(3)
      expect(described_class.filter_by_organisation([organisation_3.id]).count).to eq(0)
    end

    it "filters by given organisation" do
      expect(described_class.filter_by_organisation([organisation_1]).count).to eq(2)
      expect(described_class.filter_by_organisation([organisation_1, organisation_2]).count).to eq(3)
      expect(described_class.filter_by_organisation([organisation_3]).count).to eq(0)
    end
  end

  describe "derived variables" do
    let(:sales_log) { FactoryBot.create(:sales_log, :completed) }

    it "correctly derives and saves exday, exmonth and exyear" do
      sales_log.update!(exdate: Time.gm(2022, 5, 4))
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
end
