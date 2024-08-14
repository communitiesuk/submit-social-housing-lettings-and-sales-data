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

    it "sets the discarded_at field" do
      merge_request.discard!
      expect(merge_request.discarded_at).not_to be_nil
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

  describe "#calculate_status" do
    it "returns the correct status for deleted merge request" do
      merge_request = build(:merge_request, id: 1, discarded_at: Time.zone.today)
      expect(merge_request.calculate_status).to eq "deleted"
    end

    it "returns the correct status for a merged request" do
      merge_request = build(:merge_request, id: 1, status: "request_merged")
      expect(merge_request.calculate_status).to eq "request_merged"
    end

    it "returns the correct status for a ready to merge request" do
      merge_request = build(:merge_request, id: 1, absorbing_organisation: create(:organisation), merge_date: Time.zone.today)
      create(:merge_request_organisation, merge_request:)
      expect(merge_request.calculate_status).to eq "ready_to_merge"
    end

    it "returns the merge issues if dsa is not signed for absorbing organisation" do
      merge_request = build(:merge_request, id: 1, absorbing_organisation: create(:organisation, with_dsa: false), merge_date: Time.zone.today)
      create(:merge_request_organisation, merge_request:)
      expect(merge_request.calculate_status).to eq "merge_issues"
    end

    it "returns the incomplete if absorbing organisation is missing" do
      merge_request = build(:merge_request, id: 1, absorbing_organisation: nil, merge_date: Time.zone.today)
      create(:merge_request_organisation, merge_request:)
      expect(merge_request.calculate_status).to eq "incomplete"
    end

    it "returns the incomplete if merge requests organisation is missing" do
      merge_request = build(:merge_request, id: 1, absorbing_organisation: create(:organisation), merge_date: Time.zone.today)
      expect(merge_request.calculate_status).to eq "incomplete"
    end

    it "returns the incomplete if merge date is missing" do
      merge_request = build(:merge_request, id: 1, absorbing_organisation: create(:organisation))
      create(:merge_request_organisation, merge_request:)
      expect(merge_request.calculate_status).to eq "incomplete"
    end

    it "returns processing if merge is processing" do
      merge_request = build(:merge_request, id: 1, absorbing_organisation: create(:organisation), status: "processing")
      create(:merge_request_organisation, merge_request:)
      expect(merge_request.calculate_status).to eq "processing"
    end
  end
end
