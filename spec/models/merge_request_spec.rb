require "rails_helper"

RSpec.describe MergeRequest, type: :model do
  describe ".visible" do
    let(:open_collection_period_start_date) { 1.year.ago }
    let!(:merged_recent) { create(:merge_request, status: "request_merged", merge_date: 3.months.ago) }
    let!(:merged_old) { create(:merge_request, status: "request_merged", merge_date: 18.months.ago) }
    let!(:not_merged) { create(:merge_request, status: "incomplete") }

    before do
      allow(FormHandler.instance).to receive(:start_date_of_earliest_open_collection_period).and_return(open_collection_period_start_date)
    end

    it "includes merged requests with merge dates after the open collection period start date" do
      expect(described_class.visible).to include(merged_recent)
    end

    it "excludes merged requests with merge dates before the open collection period start date" do
      expect(described_class.visible).not_to include(merged_old)
    end

    it "includes not_merged requests" do
      expect(described_class.visible).to include(not_merged)
    end
  end

  describe "#discard!" do
    let(:merge_request) { create(:merge_request) }

    it "sets the discarded_at field to the current time" do
      let(:time) { Time.zone.now }
      Timecop.freeze(time) do
        merge_request.discard!
        expect(merge_request.discarded_at).to eq(time)
      end
    end

    it "does not delete the record" do
      merge_request.discard!
      expect(merge_request).to be_persisted
    end

    it "is not visible in the visible scope" do
      merge_request.discard!
      expect(described_class.visible).not_to include(merge_request)
    end
  end
end
