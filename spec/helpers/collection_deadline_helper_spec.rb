require "rails_helper"

RSpec.describe CollectionDeadlineHelper do
  let(:current_user) { create(:user, :data_coordinator) }
  let(:user) { create(:user, :data_coordinator) }

  describe "#quarter_for_date" do
    it "returns correct cutoff date for the first quarter of 2025/26" do
      quarter = quarter_for_date(date: Time.zone.local(2025, 4, 1))
      expect(quarter.cutoff_date).to eq(Time.zone.local(2025, 7, 11))
      expect(quarter.quarter_start_date).to eq(Time.zone.local(2025, 4, 1))
      expect(quarter.quarter_end_date).to eq(Time.zone.local(2025, 6, 30))
    end

    it "returns correct cutoff date for the second quarter of 2025/26" do
      quarter = quarter_for_date(date: Time.zone.local(2025, 9, 30))
      expect(quarter.cutoff_date).to eq(Time.zone.local(2025, 10, 10))
      expect(quarter.quarter_start_date).to eq(Time.zone.local(2025, 7, 1))
      expect(quarter.quarter_end_date).to eq(Time.zone.local(2025, 9, 30))
    end

    it "returns correct cutoff date for the third quarter of 2025/26" do
      quarter = quarter_for_date(date: Time.zone.local(2025, 10, 25))
      expect(quarter.cutoff_date).to eq(Time.zone.local(2026, 1, 16))
      expect(quarter.quarter_start_date).to eq(Time.zone.local(2025, 10, 1))
      expect(quarter.quarter_end_date).to eq(Time.zone.local(2025, 12, 31))
    end
  end
end
