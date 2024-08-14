class ProcessMergeRequestJob < ApplicationJob
  queue_as :default

  def perform(merge_request:)
    absorbing_organisation_id = merge_request.absorbing_organisation_id
    merging_organisation_ids = merge_request.merging_organisations.pluck(:id)
    merge_date = merge_request.merge_date

    Merge::MergeOrganisationsService.new(absorbing_organisation_id:, merging_organisation_ids:, merge_date:).call
  end
end
