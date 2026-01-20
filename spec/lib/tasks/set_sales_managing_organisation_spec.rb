require "rails_helper"
require "rake"

RSpec.describe "set_sales_managing_organisation" do
  describe ":set_sales_managing_organisation", type: :task do
    subject(:task) { Rake::Task["set_sales_managing_organisation"] }

    before do
      Rake.application.rake_require("tasks/set_sales_managing_organisation")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let!(:sales_log) { create(:sales_log, :completed, managing_organisation_id: nil) }

      it "updates sales log managing_organisation_id with owning_organisation_id" do
        expect(sales_log.managing_organisation_id).to eq(nil)
        expect(sales_log.status).to eq("in_progress")
        task.invoke
        sales_log.reload
        expect(sales_log.managing_organisation_id).to eq(sales_log.owning_organisation_id)
        expect(sales_log.status).to eq("in_progress")
      end

      it "does not update sales log managing_organisation_id if owning_organisation_id is nil" do
        sales_log.update!(owning_organisation_id: nil)
        expect(sales_log.status).to eq("in_progress")
        expect(sales_log.managing_organisation_id).to eq(nil)
        task.invoke
        sales_log.reload
        expect(sales_log.managing_organisation_id).to eq(nil)
        expect(sales_log.status).to eq("in_progress")
      end

      it "skips validations" do
        sales_log.saledate = Time.zone.local(2021, 3, 3)
        sales_log.save!(validate: false)
        expect(sales_log.managing_organisation_id).to eq(nil)
        expect(sales_log.status).to eq("in_progress")
        task.invoke
        sales_log.reload
        expect(sales_log.managing_organisation_id).to eq(sales_log.owning_organisation_id)
        expect(sales_log.status).to eq("in_progress")
      end
    end
  end
end
