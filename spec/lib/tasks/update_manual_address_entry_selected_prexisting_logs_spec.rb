# spec/tasks/update_manual_address_entry_selected_prexisting_logs_spec.rb
require "rails_helper"
require "rake"

RSpec.describe "bulk_update:update_manual_address_entry_selected", type: :task do
  let(:task) { Rake::Task["bulk_update:update_manual_address_entry_selected"] }

  let(:lettings_log_uprn_entered) do
    create(:lettings_log, :completed,
           needstype: 1,
           manual_address_entry_selected: false,
           uprn: "123",
           address_line1: nil,
           address_line2: nil,
           town_or_city: nil,
           postcode_full: nil,
           address_line1_input: nil,
           postcode_full_input: nil)
  end

  let(:lettings_log_uprn_found) do
    create(:lettings_log, :completed,
           needstype: 1,
           manual_address_entry_selected: false,
           uprn: "123",
           address_line1: nil,
           address_line2: nil,
           town_or_city: nil,
           postcode_full: nil,
           address_line1_input: "1 Test Street",
           postcode_full_input: "SW1 1AA")
  end

  let(:lettings_log_address_manually_entered) do
    create(:lettings_log, :completed,
           needstype: 1,
           manual_address_entry_selected: false,
           uprn: nil,
           address_line1: "1 Test Street",
           address_line2: "Testville",
           town_or_city: "Testford",
           postcode_full: "SW1 1AA",
           address_line1_input: nil,
           postcode_full_input: nil)
  end

  let(:sales_log_uprn_entered) do
    create(:sales_log, :completed,
           manual_address_entry_selected: false,
           uprn: "123",
           address_line1: nil,
           address_line2: nil,
           town_or_city: nil,
           postcode_full: nil,
           address_line1_input: nil,
           postcode_full_input: nil)
  end

  let(:sales_log_uprn_found) do
    create(:sales_log, :completed,
           manual_address_entry_selected: false,
           uprn: "123",
           address_line1: nil,
           address_line2: nil,
           town_or_city: nil,
           postcode_full: nil,
           address_line1_input: "1 Test Street",
           postcode_full_input: "SW1 1AA")
  end

  let(:sales_log_address_manually_entered) do
    create(:sales_log, :completed,
           manual_address_entry_selected: false,
           uprn: nil,
           address_line1: "1 Test Street",
           address_line2: "Testville",
           town_or_city: "Testford",
           postcode_full: "SW1 1AA",
           address_line1_input: nil,
           postcode_full_input: nil)
  end

  before do
    Rake.application.rake_require("tasks/update_manual_address_entry_selected_prexisting_logs")
    Rake::Task.define_task(:environment)
  end

  context "when running the task" do
    context "when logs do not meet the criteria" do
      it "does not update logs with a UPRN entered" do
        task.invoke
        lettings_log_uprn_entered.reload
        sales_log_uprn_entered.reload
        expect(lettings_log_uprn_entered.manual_address_entry_selected).to be false
        expect(lettings_log_uprn_entered.uprn).to eq("123")
        expect(sales_log_uprn_entered.manual_address_entry_selected).to be false
        expect(sales_log_uprn_entered.uprn).to eq("123")
      end

      it "does not update logs with a UPRN found" do
        task.invoke
        lettings_log_uprn_found.reload
        sales_log_uprn_found.reload
        expect(lettings_log_uprn_found.manual_address_entry_selected).to be false
        expect(lettings_log_uprn_found.uprn).to eq("123")
        expect(sales_log_uprn_found.manual_address_entry_selected).to be false
        expect(sales_log_uprn_found.uprn).to eq("123")
      end
    end

    context "when logs do meet the criteria" do
      it "updates logs with an address manually entered" do
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
