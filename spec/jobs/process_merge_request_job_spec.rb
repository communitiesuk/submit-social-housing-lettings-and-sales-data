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
    let(:merge_request) { MergeRequest.create!(requesting_organisation: organisation, absorbing_organisation: organisation, merge_date: Time.zone.local(2022, 3, 3), total_users: 5, total_schemes: 5, total_lettings_logs: 2, total_sales_logs: 8, total_managing_agents: 2, total_stock_owners: 1, existing_absorbing_organisation: true) }

    before do
      create(:merge_request_organisation, merge_request:, merging_organisation:)
      create(:merge_request_organisation, merge_request:, merging_organisation: other_merging_organisation)
    end

    it "calls the merge organisations service with correct arguments" do
      expect(Merge::MergeOrganisationsService).to receive(:new).with(absorbing_organisation_id: organisation.id, merging_organisation_ids: [merging_organisation.id, other_merging_organisation.id], merge_date: Time.zone.local(2022, 3, 3), absorbing_organisation_active_from_merge_date: false)

      job.perform(merge_request:)
      expect(merge_request.reload.status).to eq("request_merged")
    end

    context "with new absorbing organisation" do
      let(:merge_request) { MergeRequest.create!(requesting_organisation: organisation, absorbing_organisation: organisation, merge_date: Time.zone.local(2022, 3, 3), existing_absorbing_organisation: false) }

      it "calls the merge organisations service with correct arguments" do
        expect(Merge::MergeOrganisationsService).to receive(:new).with(absorbing_organisation_id: organisation.id, merging_organisation_ids: match_array([merging_organisation.id, other_merging_organisation.id]), merge_date: Time.zone.local(2022, 3, 3), absorbing_organisation_active_from_merge_date: true)

        job.perform(merge_request:)
        expect(merge_request.reload.status).to eq("request_merged")
      end
    end

    it "clears last_failed_attempt value" do
      merge_request.update!(last_failed_attempt: Time.zone.now)
      job.perform(merge_request:)

      expect(merge_request.reload.last_failed_attempt).to be_nil
    end

    it "sets last_failed_attempt value, sets processing to false and clears all outcomes if there's an error" do
      allow(merge_organisations_service).to receive(:call).and_raise(ActiveRecord::Rollback)

      expect(merge_request.last_failed_attempt).to be_nil
      job.perform(merge_request:)

      merge_request.reload
      expect(merge_request.last_failed_attempt).to be_within(10.seconds).of(Time.zone.now)
      expect(merge_request.processing).to eq(false)
      expect(merge_request.total_users).to be_nil
      expect(merge_request.total_schemes).to be_nil
      expect(merge_request.total_managing_agents).to be_nil
      expect(merge_request.total_stock_owners).to be_nil
      expect(merge_request.total_lettings_logs).to be_nil
      expect(merge_request.total_sales_logs).to be_nil
    end
  end
end
