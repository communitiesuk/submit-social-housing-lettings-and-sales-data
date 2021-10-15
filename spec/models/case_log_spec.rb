require "rails_helper"

RSpec.describe Form, type: :model do
  describe "#new" do
    it "validates age is a number" do
      expect { CaseLog.create!(tenant_age: "random") }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "validates age is under 120" do
      expect { CaseLog.create!(tenant_age: 121) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "validates age is over 0" do
      expect { CaseLog.create!(tenant_age: 0) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe "status" do
    let!(:empty_case_log) { FactoryBot.create(:case_log) }
    let!(:in_progress_case_log) { FactoryBot.create(:case_log, :in_progress) }

    it "is set to not started for an empty case log" do
      expect(empty_case_log.not_started?).to be(true)
      expect(empty_case_log.in_progress?).to be(false)
      expect(empty_case_log.completed?).to be(false)
    end

    it "is set to not started for an empty case log" do
      expect(in_progress_case_log.in_progress?).to be(true)
      expect(in_progress_case_log.not_started?).to be(false)
      expect(in_progress_case_log.completed?).to be(false)
    end
  end
end
