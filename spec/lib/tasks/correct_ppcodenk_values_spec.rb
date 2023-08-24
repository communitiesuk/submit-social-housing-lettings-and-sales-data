require "rails_helper"
require "rake"

RSpec.describe "correct_ppcodenk_values" do
  describe ":correct_ppcodenk_values", type: :task do
    subject(:task) { Rake::Task["correct_ppcodenk_values"] }

    before do
      Rake.application.rake_require("tasks/correct_ppcodenk_values")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let!(:lettings_log) { create(:lettings_log, :completed) }

      it "updates lettings logs with ppcodenk 0 to have ppcodenk 1" do
        lettings_log.update!(ppcodenk: 0)
        task.invoke
        expect(lettings_log.reload.ppcodenk).to eq(1)
      end

      it "updates lettings logs with ppcodenk 1 to have ppcodenk 0" do
        lettings_log.update!(ppcodenk: 1)
        task.invoke
        expect(lettings_log.reload.ppcodenk).to eq(0)
      end

      it "does not update lettings logs with ppcodenk nil" do
        lettings_log.update!(ppcodenk: nil)
        task.invoke
        expect(lettings_log.reload.ppcodenk).to eq(nil)
      end

      context "with multiple lettings logs" do
        let(:lettings_log_2) { create(:lettings_log, :completed) }
        let(:lettings_log_3) { create(:lettings_log, :completed) }

        it "only updates each log once" do
          lettings_log.update!(ppcodenk: nil)
          lettings_log_2.update!(ppcodenk: 0)
          lettings_log_3.update!(ppcodenk: 1)
          task.invoke
          expect(lettings_log.reload.ppcodenk).to eq(nil)
          expect(lettings_log_2.reload.ppcodenk).to eq(1)
          expect(lettings_log_3.reload.ppcodenk).to eq(0)
        end
      end

      it "does not update updated_at value" do
        lettings_log.updated_at = Time.zone.local(2021, 3, 3)
        lettings_log.save!(validate: false)
        expect(lettings_log.updated_at.to_date).to eq(Time.zone.local(2021, 3, 3))
        task.invoke
        expect(lettings_log.updated_at.to_date).to eq(Time.zone.local(2021, 3, 3))
      end

      it "skips validations for previous years" do
        lettings_log.update!(ppcodenk: 1)
        lettings_log.startdate = Time.zone.local(2021, 3, 3)
        lettings_log.save!(validate: false)
        task.invoke
        expect(lettings_log.reload.ppcodenk).to eq(0)
      end
    end
  end
end
