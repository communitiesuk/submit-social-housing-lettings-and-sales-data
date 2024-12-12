require "rails_helper"
require "rake"

RSpec.describe "recalculate_status_after_sales_over_retirement_age_validation" do
  describe ":recalculate_status_over_retirement", type: :task do
    subject(:task) { Rake::Task["recalculate_status_over_retirement"] }

    before do
      Rake.application.rake_require("tasks/recalculate_status_after_sales_over_retirement_age_validation")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      context "and there is a completed sales log that trips the validation" do
        let(:log) { create(:sales_log, :completed, ecstat1: 1, age1: 67) }

        before do
          log.status = "completed"
          log.save!
        end

        it "sets the log to in progress" do
          task.invoke
          log.reload
          expect(log.status).to eq("in_progress")
        end
      end

      context "and there is a pending sales log that trips the validation" do
        let(:log) { create(:sales_log, :completed, ecstat2: 1, age2: 70) }

        before do
          log.status = "pending"
          log.status_cache = "completed"
          log.save!
        end

        it "updates the status cache" do
          task.invoke
          log.reload
          expect(log.status_cache).to eq("in_progress")
        end

        it "does not change the log status" do
          task.invoke
          log.reload
          expect(log.status).to eq("pending")
        end
      end
    end
  end
end
