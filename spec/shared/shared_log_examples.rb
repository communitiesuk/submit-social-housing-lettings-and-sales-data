require "rails_helper"

RSpec.shared_examples "shared log examples" do |log_type|
  describe "status" do
    let(:empty_log) { create(log_type) }
    let(:in_progress_log) { create(log_type, :in_progress) }
    let(:completed_log) { create(log_type, :completed) }

    it "is set to not started for an empty #{log_type} log" do
      expect(empty_log.not_started?).to be(true)
      expect(empty_log.in_progress?).to be(false)
      expect(empty_log.completed?).to be(false)
      expect(empty_log.deleted?).to be(false)
    end

    it "is set to in progress for a started #{log_type} log" do
      expect(in_progress_log.in_progress?).to be(true)
      expect(in_progress_log.not_started?).to be(false)
      expect(in_progress_log.completed?).to be(false)
      expect(in_progress_log.deleted?).to be(false)
    end

    it "is set to completed for a completed #{log_type} log" do
      expect(completed_log.in_progress?).to be(false)
      expect(completed_log.not_started?).to be(false)
      expect(completed_log.completed?).to be(true)
      expect(completed_log.deleted?).to be(false)
    end
  end

  describe "discard!" do
    around do |example|
      Timecop.freeze(Time.zone.local(2022, 1, 1)) do
        example.run
      end
      Timecop.return
    end

    let(:log) { create(log_type) }

    it "updates discarded at with current time" do
      expect { log.discard! }.to change { log.reload.discarded_at }.from(nil).to(Time.zone.now)
    end

    it "updates status to deleted" do
      expect { log.discard! }.to change { log.reload.status }.to("deleted")
    end
  end
end
