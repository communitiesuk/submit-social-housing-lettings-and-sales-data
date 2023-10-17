require "rails_helper"
require "rake"

RSpec.describe "blank_migrated_soctenant_values" do
  describe ":blank_migrated_soctenant_values", type: :task do
    subject(:task) { Rake::Task["blank_migrated_soctenant_values"] }

    before do
      Rake.application.rake_require("tasks/blank_migrated_soctenant_values")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let!(:sales_log) { create(:sales_log, :completed, :shared_ownership, values_updated_at: nil) }

      it "blanks soctenant (and subsequent questions) values from relevant migrated logs" do
        sales_log.old_id = "404"
        sales_log.frombeds = nil
        sales_log.fromprop = 0 # don't know
        sales_log.socprevten = 10 # don't know
        sales_log.soctenant = 0 # don't know
        sales_log.save!
        task.invoke
        sales_log.reload
        expect(sales_log.soctenant).to eq(nil)
        expect(sales_log.frombeds).to eq(nil)
        expect(sales_log.fromprop).to eq(nil)
        expect(sales_log.socprevten).to eq(nil)
        expect(sales_log.values_updated_at).not_to be_nil
      end

      it "does not blank soctenant (and subsequent questions) values from 2022 logs" do
        sales_log.old_id = "404"
        sales_log.frombeds = nil
        sales_log.fromprop = 0 # don't know
        sales_log.socprevten = 10 # don't know
        sales_log.soctenant = 0 # don't know
        sales_log.saledate = Time.zone.local(2022, 5, 5)
        sales_log.save!
        task.invoke
        sales_log.reload
        expect(sales_log.soctenant).to eq(0)
        expect(sales_log.frombeds).to eq(nil)
        expect(sales_log.fromprop).to eq(0)
        expect(sales_log.socprevten).to eq(10)
        expect(sales_log.values_updated_at).to be_nil
      end

      it "does not blank soctenant (and subsequent questions) values from non imported logs" do
        sales_log.old_id = nil
        sales_log.frombeds = nil
        sales_log.fromprop = 0 # don't know
        sales_log.socprevten = 10 # don't know
        sales_log.soctenant = 0 # don't know
        sales_log.save!
        task.invoke
        sales_log.reload
        expect(sales_log.soctenant).to eq(0)
        expect(sales_log.frombeds).to eq(nil)
        expect(sales_log.fromprop).to eq(0)
        expect(sales_log.socprevten).to eq(10)
        expect(sales_log.values_updated_at).to be_nil
      end
    end
  end
end
