require "rails_helper"
require "rake"

RSpec.describe "fix_nil_letting_allocation_values" do
  describe ":fix_nil_letting_allocation_values", type: :task do
    subject(:task) { Rake::Task["fix_nil_letting_allocation_values"] }

    before do
      Rake.application.rake_require("tasks/fix_nil_letting_allocation_values")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    it "sets nil values to 0 when one allocation type value is non-nil" do
      log = create(:lettings_log, :setup_completed, :startdate_today, cbl: nil, chr: nil, cap: 1, accessible_register: nil, letting_allocation_unknown: nil)

      task.invoke

      log.reload
      expect(log.cbl).to be 0
      expect(log.chr).to be 0
      expect(log.cap).to be 1
      expect(log.accessible_register).to be 0
      expect(log.letting_allocation_unknown).to be 0
    end

    it "sets nil values to 0 and letting_allocation_unknown to 1 when non-nil allocation type values are 0" do
      log = create(:lettings_log, :setup_completed, :startdate_today, cbl: 0, chr: 0, cap: nil, accessible_register: nil, letting_allocation_unknown: nil)

      task.invoke

      log.reload
      expect(log.cbl).to be 0
      expect(log.chr).to be 0
      expect(log.cap).to be 0
      expect(log.accessible_register).to be 0
      expect(log.letting_allocation_unknown).to be 1
    end

    it "does not set anything when question has not been answered at all" do
      log = create(:lettings_log, :setup_completed, :startdate_today, cbl: nil, chr: nil, cap: nil, accessible_register: nil, letting_allocation_unknown: nil)

      task.invoke

      log.reload
      expect(log.cbl).to be_nil
      expect(log.chr).to be_nil
      expect(log.cap).to be_nil
      expect(log.accessible_register).to be_nil
      expect(log.letting_allocation_unknown).to be_nil
    end

    it "does not set accessible_register for logs before 2024" do
      log = create(:lettings_log, :setup_completed, startdate: Time.zone.local(2023, 5, 1), cbl: 1, chr: nil, cap: nil, accessible_register: nil, letting_allocation_unknown: nil)

      task.invoke

      log.reload
      expect(log.cbl).to be 1
      expect(log.chr).to be 0
      expect(log.cap).to be 0
      expect(log.accessible_register).to be_nil
      expect(log.letting_allocation_unknown).to be 0
    end

    it "logs the log id if the change cannot be saved" do
      log = create(:lettings_log, :ignore_validation_errors, :setup_completed, startdate: Time.zone.local(2022, 4, 1), cbl: 1, chr: nil, cap: nil, letting_allocation_unknown: nil)

      expect(Rails.logger).to receive(:info).with(match(/log #{log.id}/))
      task.invoke
    end
  end
end
