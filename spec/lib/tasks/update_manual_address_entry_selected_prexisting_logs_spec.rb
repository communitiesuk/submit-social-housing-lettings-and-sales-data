require "rails_helper"
require "rake"

RSpec.describe "update_manual_address_entry_selected_preexisting_logs_spec", type: :task do
  include CollectionTimeHelper

  before do
    Rake.application.rake_require("tasks/update_manual_address_entry_selected_prexisting_logs")
    Rake::Task.define_task(:environment)
    task.reenable
    Timecop.freeze(previous_collection_end_date)
  end

  after do
    Timecop.return
  end

  describe "bulk_update:update_manual_address_entry_selected" do
    let(:task) { Rake::Task["bulk_update:update_manual_address_entry_selected"] }

    let(:lettings_log_uprn_entered) do
      build(:lettings_log, :completed, startdate: Time.zone.local(2024, 6, 1), needstype: 1, manual_address_entry_selected: false)
    end

    let(:lettings_log_uprn_found) do
      build(:lettings_log, :completed, startdate: Time.zone.local(2024, 9, 1), needstype: 1, manual_address_entry_selected: false, address_line1_input: "1 Test Street", postcode_full_input: "SW1 1AA")
    end

    let(:lettings_log_address_fields_not_entered) do
      build(:lettings_log, :inprogress_without_address_fields, startdate: Time.zone.local(2024, 9, 1), needstype: 1)
    end

    let(:lettings_log_address_manually_entered) do
      build(:lettings_log, :completed_without_uprn, startdate: Time.zone.local(2024, 12, 1), needstype: 1)
    end

    let(:sales_log_uprn_entered) do
      build(:sales_log, :completed, saledate: Time.zone.local(2024, 12, 1), manual_address_entry_selected: false)
    end

    let(:sales_log_uprn_found) do
      build(:sales_log, :completed, saledate: Time.zone.local(2024, 7, 1), manual_address_entry_selected: false, address_line1_input: "1 Test Street", postcode_full_input: "SW1 1AA")
    end

    let(:sales_log_address_fields_not_entered) do
      build(:sales_log, :inprogress_without_address_fields, saledate: Time.zone.local(2024, 12, 30))
    end

    let(:sales_log_address_manually_entered) do
      build(:sales_log, :completed_without_uprn, saledate: Time.zone.local(2024, 12, 30))
    end

    context "when running the task" do
      context "when logs do not meet the criteria" do
        before do
          lettings_log_uprn_found.save!(validate: false)
          lettings_log_uprn_entered.save!(validate: false)
          lettings_log_address_fields_not_entered.save!(validate: false)

          sales_log_uprn_found.save!(validate: false)
          sales_log_uprn_entered.save!(validate: false)
          sales_log_address_fields_not_entered.save!(validate: false)
        end

        it "does not update logs with a UPRN entered" do
          task.invoke

          lettings_log_uprn_entered.reload
          sales_log_uprn_entered.reload

          expect(lettings_log_uprn_entered.manual_address_entry_selected).to be false
          expect(lettings_log_uprn_entered.uprn).to eq("10033558653")
          expect(sales_log_uprn_entered.manual_address_entry_selected).to be false
          expect(sales_log_uprn_entered.uprn).to eq("10033558653")
        end

        it "does not update logs with a UPRN found" do
          task.invoke

          lettings_log_uprn_found.reload
          sales_log_uprn_found.reload

          expect(lettings_log_uprn_found.manual_address_entry_selected).to be false
          expect(lettings_log_uprn_found.uprn).to eq("10033558653")
          expect(sales_log_uprn_found.manual_address_entry_selected).to be false
          expect(sales_log_uprn_found.uprn).to eq("10033558653")
        end

        it "does not update logs with no UPRN or address fields entered" do
          task.invoke

          lettings_log_address_fields_not_entered.reload
          sales_log_address_fields_not_entered.reload

          expect(lettings_log_address_fields_not_entered.manual_address_entry_selected).to be false
          expect(sales_log_address_fields_not_entered.manual_address_entry_selected).to be false
        end
      end

      context "when logs do meet the criteria" do
        before do
          lettings_log_address_manually_entered.manual_address_entry_selected = false
          lettings_log_address_manually_entered.save!(validate: false)

          sales_log_address_manually_entered.manual_address_entry_selected = false
          sales_log_address_manually_entered.save!(validate: false)
        end

        it "updates logs with an address manually entered" do
          expect(lettings_log_address_manually_entered.manual_address_entry_selected).to be false
          expect(lettings_log_address_manually_entered.address_line1).to eq("1 Test Street")
          expect(lettings_log_address_manually_entered.address_line2).to eq("Testville")
          expect(lettings_log_address_manually_entered.town_or_city).to eq("Testford")
          expect(lettings_log_address_manually_entered.postcode_full).to eq("SW1 1AA")

          expect(sales_log_address_manually_entered.manual_address_entry_selected).to be false
          expect(sales_log_address_manually_entered.address_line1).to eq("1 Test Street")
          expect(sales_log_address_manually_entered.address_line2).to eq("Testville")
          expect(sales_log_address_manually_entered.town_or_city).to eq("Testford")
          expect(sales_log_address_manually_entered.postcode_full).to eq("SW1 1AA")

          task.invoke

          lettings_log_address_manually_entered.reload
          sales_log_address_manually_entered.reload

          expect(lettings_log_address_manually_entered.manual_address_entry_selected).to be true
          expect(lettings_log_address_manually_entered.address_line1).to eq("1 Test Street")
          expect(lettings_log_address_manually_entered.address_line2).to eq("Testville")
          expect(lettings_log_address_manually_entered.town_or_city).to eq("Testford")
          expect(lettings_log_address_manually_entered.postcode_full).to eq("SW1 1AA")

          expect(sales_log_address_manually_entered.manual_address_entry_selected).to be true
          expect(sales_log_address_manually_entered.address_line1).to eq("1 Test Street")
          expect(sales_log_address_manually_entered.address_line2).to eq("Testville")
          expect(sales_log_address_manually_entered.town_or_city).to eq("Testford")
          expect(sales_log_address_manually_entered.postcode_full).to eq("SW1 1AA")
        end
      end
    end
  end

  describe "bulk_update:update_postcode_full_preexisting_manual_entry_logs" do
    let(:task) { Rake::Task["bulk_update:update_postcode_full_preexisting_manual_entry_logs"] }

    let(:lettings_log_to_fix) do
      build(:lettings_log, :inprogress_without_address_fields, startdate: Time.zone.local(2024, 6, 1), updated_at: Time.zone.parse("2025-03-19 16:30:00"))
    end

    let(:bu_lettings_log_to_fix) do
      build(:lettings_log, :inprogress_without_address_fields, startdate: Time.zone.local(2024, 6, 1), creation_method: "bulk upload", updated_at: Time.zone.parse("2025-03-19 16:30:00"))
    end

    let(:lettings_log_not_to_fix) do
      build(:lettings_log, :inprogress_without_address_fields, startdate: Time.zone.local(2024, 6, 1), updated_at: Time.zone.parse("2025-03-19 15:30:00"))
    end

    before do
      lettings_log_to_fix.manual_address_entry_selected = true
      lettings_log_to_fix.address_line1 = "1 Test Street"
      lettings_log_to_fix.address_line2 = "Testville"
      lettings_log_to_fix.town_or_city = "Testford"
      lettings_log_to_fix.postcode_full = nil
      lettings_log_to_fix.address_line1_input = "1 Test Street"
      lettings_log_to_fix.postcode_full_input = "SW1 2BB"
      lettings_log_to_fix.save!(validate: false)

      bu_lettings_log_to_fix.manual_address_entry_selected = true
      bu_lettings_log_to_fix.address_line1 = "1 Test Street"
      bu_lettings_log_to_fix.address_line2 = "Testville"
      bu_lettings_log_to_fix.town_or_city = "Testford"
      bu_lettings_log_to_fix.postcode_full = nil
      bu_lettings_log_to_fix.address_line1_as_entered = "1 Test Street"
      bu_lettings_log_to_fix.postcode_full_as_entered = "SW1 2BB"
      bu_lettings_log_to_fix.save!(validate: false)

      lettings_log_not_to_fix.postcode_full = nil
      lettings_log_not_to_fix.save!(validate: false)
    end

    context "when running the task" do
      it "updates logs that meet the criteria" do
        expect(lettings_log_to_fix.postcode_full).to be_nil
        expect(lettings_log_to_fix.address_line1).to eq("1 Test Street")
        expect(lettings_log_to_fix.address_line2).to eq("Testville")
        expect(lettings_log_to_fix.town_or_city).to eq("Testford")
        expect(lettings_log_to_fix.address_line1_input).to eq("1 Test Street")
        expect(lettings_log_to_fix.postcode_full_input).to eq("SW1 2BB")

        expect(bu_lettings_log_to_fix.postcode_full).to be_nil
        expect(bu_lettings_log_to_fix.address_line1_input).to be_nil
        expect(bu_lettings_log_to_fix.address_line1).to eq("1 Test Street")
        expect(bu_lettings_log_to_fix.address_line2).to eq("Testville")
        expect(bu_lettings_log_to_fix.town_or_city).to eq("Testford")
        expect(bu_lettings_log_to_fix.address_line1_as_entered).to eq("1 Test Street")
        expect(bu_lettings_log_to_fix.postcode_full_as_entered).to eq("SW1 2BB")

        task.invoke

        lettings_log_to_fix.reload
        bu_lettings_log_to_fix.reload

        expect(lettings_log_to_fix.postcode_full).to eq(lettings_log_to_fix.postcode_full_input)
        expect(lettings_log_to_fix.postcode_full).to eq("SW1 2BB")
        expect(bu_lettings_log_to_fix.postcode_full).to eq(bu_lettings_log_to_fix.postcode_full_as_entered)
        expect(bu_lettings_log_to_fix.postcode_full).to eq("SW1 2BB")
      end

      it "does not update logs that do not meet the criteria" do
        task.invoke

        lettings_log_not_to_fix.reload

        expect(lettings_log_not_to_fix.postcode_full).to be_nil
      end
    end
  end
end
