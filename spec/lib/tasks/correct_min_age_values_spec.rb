require "rails_helper"
require "rake"

RSpec.describe "correct_min_age_values" do
  describe ":correct_min_age_values", type: :task do
    subject(:task) { Rake::Task["correct_min_age_values"] }

    before do
      Rake.application.rake_require("tasks/correct_min_age_values")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let!(:lettings_log) { create(:lettings_log, :completed) }

      it "updates lettings logs with age2..8 0 to have age2..8 1" do
        lettings_log.hhmemb = 8
        lettings_log.age2_known = 0
        lettings_log.age2 = 0
        lettings_log.age3_known = 0
        lettings_log.age3 = 0
        lettings_log.age4_known = 0
        lettings_log.age4 = 0
        lettings_log.age5_known = 0
        lettings_log.age5 = 0
        lettings_log.age6_known = 0
        lettings_log.age6 = 0
        lettings_log.age7_known = 0
        lettings_log.age7 = 0
        lettings_log.age8_known = 0
        lettings_log.age8 = 0

        lettings_log.save!(validate: false)

        task.invoke
        lettings_log.reload
        expect(lettings_log.age2).to eq(1)
        expect(lettings_log.age3).to eq(1)
        expect(lettings_log.age4).to eq(1)
        expect(lettings_log.age5).to eq(1)
        expect(lettings_log.age6).to eq(1)
        expect(lettings_log.age7).to eq(1)
        expect(lettings_log.age8).to eq(1)
        expect(lettings_log.values_updated_at).not_to be_nil
      end

      it "does not update valid age2..8 values" do
        lettings_log.hhmemb = 8
        lettings_log.age2_known = 0
        lettings_log.age2 = 2
        lettings_log.age3_known = 0
        lettings_log.age3 = 4
        lettings_log.age4_known = 0
        lettings_log.age4 = 2
        lettings_log.age5_known = 0
        lettings_log.age5 = 2
        lettings_log.age6_known = 0
        lettings_log.age6 = 3
        lettings_log.age7_known = 0
        lettings_log.age7 = 6
        lettings_log.age8_known = 0
        lettings_log.age8 = 20

        lettings_log.save!(validate: false)

        task.invoke
        lettings_log.reload
        expect(lettings_log.age2).to eq(2)
        expect(lettings_log.age3).to eq(4)
        expect(lettings_log.age4).to eq(2)
        expect(lettings_log.age5).to eq(2)
        expect(lettings_log.age6).to eq(3)
        expect(lettings_log.age7).to eq(6)
        expect(lettings_log.age8).to eq(20)
        expect(lettings_log.values_updated_at).to be_nil
      end
    end
  end
end
