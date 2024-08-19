class ProcessMergeRequestJob < ApplicationJob
  queue_as :default

  def perform(merge_request:)
    absorbing_organisation_id = merge_request.absorbing_organisation_id
    merging_organisation_ids = merge_request.merging_organisations.pluck(:id)
    merge_date = merge_request.merge_date

    Merge::MergeOrganisationsService.new(absorbing_organisation_id:, merging_organisation_ids:, merge_date:).call
    merge_request.update!(request_merged: true, last_failed_attempt: nil)
  rescue StandardError
    merge_request.update!(last_failed_attempt: Time.zone.now)
  end
end
