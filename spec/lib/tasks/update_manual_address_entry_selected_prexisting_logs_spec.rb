require "rails_helper"
require "rake"

RSpec.describe "bulk_update:update_manual_address_entry_selected", type: :task do
  let(:task) { Rake::Task["bulk_update:update_manual_address_entry_selected"] }

  let(:lettings_log_uprn_entered) do
    build(:lettings_log, :completed, startdate: Time.zone.local(2024, 6, 1), needstype: 1, manual_address_entry_selected: false)
  end

  let(:lettings_log_uprn_found) do
    build(:lettings_log, :completed, startdate: Time.zone.local(2024, 9, 1), needstype: 1, manual_address_entry_selected: false, address_line1_input: "1 Test Street", postcode_full_input: "SW1 1AA")
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

  let(:sales_log_address_manually_entered) do
    build(:sales_log, :completed_without_uprn, saledate: Time.zone.local(2024, 12, 30))
  end

  before do
    Rake.application.rake_require("tasks/update_manual_address_entry_selected_prexisting_logs")
    Rake::Task.define_task(:environment)
  end

  context "when running the task" do
    context "when logs do not meet the criteria" do
      before do
        lettings_log_uprn_found.save!(validate: false)
        lettings_log_uprn_entered.save!(validate: false)
        sales_log_uprn_found.save!(validate: false)
        sales_log_uprn_entered.save!(validate: false)
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
