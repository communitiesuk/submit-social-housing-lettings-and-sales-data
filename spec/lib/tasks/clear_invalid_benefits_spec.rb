require "rails_helper"
require "rake"

RSpec.describe "clear_invalid_benefits" do
  describe ":clear_invalid_benefits", type: :task do
    subject(:task) { Rake::Task["clear_invalid_benefits"] }

    before do
      Rake.application.rake_require("tasks/clear_invalid_benefits")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      context "and there is a completed lettings log that trips the validation" do
        let(:log) { build(:lettings_log, :completed, ecstat1: 1, benefits: 1, assigned_to: create(:user), period: nil, startdate: Time.zone.local(2024, 5, 6)) }

        before do
          log.status = "completed"
          log.skip_update_status = true
          log.save!(validate: false)
        end

        it "clear benefits and sets the log to in progress" do
          expect(log.reload.benefits).to eq(1)
          task.invoke
          log.reload
          expect(log.benefits).to eq(nil)
          expect(log.status).to eq("in_progress")
        end
      end

      context "and there is a lettings log that trips the validation for person 2" do
        let(:log) { build(:lettings_log, :completed, ecstat2: 2, benefits: 1, relat2: "P", assigned_to: create(:user), period: nil, startdate: Time.zone.local(2024, 8, 11)) }

        before do
          log.status = "completed"
          log.skip_update_status = true
          log.save!(validate: false)
        end

        it "clear benefits and sets the log to in progress" do
          expect(log.reload.benefits).to eq(1)
          task.invoke
          log.reload
          expect(log.benefits).to eq(nil)
          expect(log.status).to eq("in_progress")
        end
      end

      context "and there is a lettings log that trips the validation for person 8" do
        let(:log) { build(:lettings_log, :completed, ecstat8: 1, benefits: 1, relat8: "P", assigned_to: create(:user), period: nil, startdate: Time.zone.local(2024, 7, 8)) }

        before do
          log.status = "completed"
          log.skip_update_status = true
          log.save!(validate: false)
        end

        it "clear benefits and sets the log to in progress" do
          expect(log.reload.benefits).to eq(1)
          task.invoke
          log.reload
          expect(log.benefits).to eq(nil)
          expect(log.status).to eq("in_progress")
        end
      end

      context "and there is a pending lettings log that trips the validation" do
        let(:log) { build(:lettings_log, :completed, ecstat1: 1, benefits: 1, assigned_to: create(:user), period: nil, startdate: Time.zone.local(2024, 9, 7)) }

        before do
          log.status = "pending"
          log.status_cache = "completed"
          log.skip_update_status = true
          log.save!(validate: false)
        end

        it "clears benefits and updates the status cache" do
          expect(log.reload.benefits).to eq(1)
          task.invoke
          log.reload
          expect(log.benefits).to eq(nil)
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
