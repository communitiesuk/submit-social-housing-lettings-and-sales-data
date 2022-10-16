require "rails_helper"
require "shared/shared_examples_for_derived_fields"

RSpec.describe SalesLog, type: :model do
  let(:owning_organisation) { FactoryBot.create(:organisation) }
  let(:created_by_user) { FactoryBot.create(:user) }

  include_examples "shared examples for derived fields", :sales_log

  it "inherits from log" do
    expect(described_class).to be < Log
    expect(described_class).to be < ApplicationRecord
  end

  it "is a sales log" do
    sales_log = FactoryBot.build(:sales_log, created_by: created_by_user)
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

  describe "#form" do
    let(:sales_log) { FactoryBot.build(:sales_log, created_by: created_by_user) }
    let(:sales_log_2) { FactoryBot.build(:sales_log, saledate: Time.zone.local(2022, 5, 1), created_by: created_by_user) }

    it "has returns the correct form based on the start date" do
      expect(sales_log.form_name).to be_nil
      expect(sales_log.form).to be_a(Form)
      expect(sales_log_2.form_name).to eq("current_sales")
      expect(sales_log_2.form).to be_a(Form)
    end
  end

  describe "status" do
    let!(:empty_sales_log) { FactoryBot.create(:sales_log) }
    let!(:in_progress_sales_log) { FactoryBot.create(:sales_log, :in_progress) }
    let!(:completed_sales_log) { FactoryBot.create(:sales_log, :completed) }

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
    let(:organisation_1) { FactoryBot.create(:organisation) }
    let(:organisation_2) { FactoryBot.create(:organisation) }
    let(:organisation_3) { FactoryBot.create(:organisation) }

    before do
      FactoryBot.create(:sales_log, :in_progress, owning_organisation: organisation_1, managing_organisation: organisation_1)
      FactoryBot.create(:sales_log, :completed, owning_organisation: organisation_1, managing_organisation: organisation_2)
      FactoryBot.create(:sales_log, :completed, owning_organisation: organisation_2, managing_organisation: organisation_1)
      FactoryBot.create(:sales_log, :completed, owning_organisation: organisation_2, managing_organisation: organisation_2)
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

  # Rails helper validations only. Custom validations belong in their respective
  # validations spec
  describe "validations" do
    describe "#beds" do
      before do
        expect(sales_log).to be_valid
      end

      context "when property is a bedsit" do
        let(:sales_log) {FactoryBot.build(:sales_log, :completed, :bedsit) }

        # Set error for :beds and :proptype to ensure message is shown in
        # both bedroom number selection and property type selection
        it "must only have 1 bedroom" do
          sales_log.beds = 3

          expect(sales_log).to_not be_valid
          expect(sales_log.errors[:beds]).to eq ["A bedsit can not have more than 1 bedroom"]
          expect(sales_log.errors[:proptype]).to eq ["A bedsit can not have more than 1 bedroom"]
        end
      end

      context "when property is not a bedsit" do
        let(:sales_log) { FactoryBot.build(:sales_log, :completed, beds: 4, proptype: 3) }

        it "must have 1 to 9 bedrooms", aggregate_failures: true do
          [0, 10].each do |num_beds|
            sales_log.beds = num_beds

            expect(sales_log).to_not be_valid
            expect(sales_log.errors[:beds]).to eq ["Number of bedrooms must be between 1 and 9"]
          end
        end
      end

      context "when given invalid data" do
        let(:sales_log) { FactoryBot.build(:sales_log, :completed) }

        it "fails with appropriate error message", aggregate_failures: true do
          invalid_beds_values = {
            "Four" => ["Number of bedrooms must be between 1 and 9", "Number of bedrooms must be between 1 and 9"],
            -2 => ["Number of bedrooms must be between 1 and 9"],
            2.5 => ["Number of bedrooms must be a whole number between 1 and 9"]
          }

          invalid_beds_values.each do |beds_value, expected_error|
            sales_log.beds = beds_value

            expect(sales_log).to_not be_valid
            expect(sales_log.errors[:beds]).to eq expected_error
          end
        end
      end
    end
  end
end
