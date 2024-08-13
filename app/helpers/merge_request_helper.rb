module MergeRequestHelper
  def ordered_merging_organisations(merge_request)
    merge_request.merge_request_organisations.order(created_at: :desc).map(&:merging_organisation)
  end
end
