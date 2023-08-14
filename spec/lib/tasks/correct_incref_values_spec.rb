require "rails_helper"
require "rake"

RSpec.describe "correct_incref_values" do
  describe ":correct_incref_values", type: :task do
    subject(:task) { Rake::Task["correct_incref_values"] }

    before do
      Rake.application.rake_require("tasks/correct_incref_values")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let!(:lettings_log) { create(:lettings_log, :completed) }

      it "updates lettings logs with net_income_known 0 (yes) to have incref 0 (no)" do
        lettings_log.update!(net_income_known: 0, incref: nil)
        task.invoke
        expect(lettings_log.reload.incref).to eq(0)
      end

      it "updates lettings logs with net_income_known 1 (no) to have incref 2 (don't know)" do
        lettings_log.update!(net_income_known: 1, incref: nil)
        task.invoke
        expect(lettings_log.reload.incref).to eq(2)
      end

      it "updates lettings logs with net_income_known 2 (prefers not to say) to have incref 1 (yes)" do
        lettings_log.update!(net_income_known: 2, incref: nil)
        task.invoke
        expect(lettings_log.reload.incref).to eq(1)
      end

      it "skips validations for previous years" do
        lettings_log.update!(net_income_known: 2, incref: nil)
        lettings_log.startdate = Time.zone.local(2021, 3, 3)
        lettings_log.save!(validate: false)
        task.invoke
        expect(lettings_log.reload.incref).to eq(1)
      end
    end
  end
end
