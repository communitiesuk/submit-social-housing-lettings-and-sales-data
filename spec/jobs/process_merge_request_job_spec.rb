require "rails_helper"

describe ProcessMergeRequestJob do
  let(:job) { described_class.new }
  let(:merge_organisations_service) { instance_double(Merge::MergeOrganisationsService) }

  before do
    allow(Merge::MergeOrganisationsService).to receive(:new).and_return(merge_organisations_service)
    allow(merge_organisations_service).to receive(:call).and_return(nil)
  end

  context "when processing a merge request" do
    let(:organisation) { create(:organisation) }
    let(:merging_organisation) { create(:organisation) }
    let(:other_merging_organisation) { create(:organisation) }
    let(:merge_request) { MergeRequest.create!(requesting_organisation: organisation, absorbing_organisation: organisation, merge_date: Time.zone.local(2022, 3, 3)) }

    before do
      create(:merge_request_organisation, merge_request:, merging_organisation:)
      create(:merge_request_organisation, merge_request:, merging_organisation: other_merging_organisation)
    end

    it "calls the merge organisations service with correct arguments" do
      expect(Merge::MergeOrganisationsService).to receive(:new).with(absorbing_organisation_id: organisation.id, merging_organisation_ids: [merging_organisation.id, other_merging_organisation.id], merge_date: Time.zone.local(2022, 3, 3))

      job.perform(merge_request:)
      expect(merge_request.reload.status).to eq("request_merged")
    end

    it "sets last_failed_attempt value if there's an error and sets processing to false" do
      allow(merge_organisations_service).to receive(:call).and_raise(ActiveRecord::Rollback)

      expect(merge_request.last_failed_attempt).to be_nil
      job.perform(merge_request:)

      merge_request.reload
      expect(merge_request.last_failed_attempt).to be_within(10.seconds).of(Time.zone.now)
      expect(merge_request.processing).to eq(false)
    end
  end
end
