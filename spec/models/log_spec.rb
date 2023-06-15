require "rails_helper"

RSpec.describe Log, type: :model do
  it "has two child log classes" do
    expect(SalesLog).to be < described_class
    expect(LettingsLog).to be < described_class
  end

  describe "#calculate_status" do
    it "returns the correct status for a completed sales log" do
      complete_sales_log = create(:sales_log, :completed, status: nil)
      expect(complete_sales_log.calculate_status).to eq "completed"
    end

    it "returns the correct status for an in progress sales log" do
      in_progress_sales_log = create(:sales_log, :in_progress, status: nil)
      expect(in_progress_sales_log.calculate_status).to eq "in_progress"
    end

    it "returns the correct status for a completed lettings log" do
      complete_lettings_log = create(:lettings_log, :completed, status: nil)
      binding.pry
      expect(complete_lettings_log.calculate_status).to eq "completed"
    end

    it "returns the correct status for an in progress lettings log" do
      in_progress_lettings_log = create(:lettings_log, :in_progress, status: nil)
      expect(in_progress_lettings_log.calculate_status).to eq "in_progress"
    end
  end
end
