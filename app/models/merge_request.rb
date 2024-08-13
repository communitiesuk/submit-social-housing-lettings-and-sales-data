class MergeRequest < ApplicationRecord
  belongs_to :requesting_organisation, class_name: "Organisation"
  has_many :merge_request_organisations
  belongs_to :absorbing_organisation, class_name: "Organisation", optional: true
  has_many :merging_organisations, through: :merge_request_organisations, source: :merging_organisation
  belongs_to :requester, class_name: "User", optional: true

  STATUS = {
    "merge_issues" => 0,
    "incomplete" => 1,
    "ready_to_merge" => 2,
    "processing" => 3,
    "request_merged" => 4,
  }.freeze
  enum status: STATUS

  scope :not_merged, -> { where.not(status: "request_merged") }
  scope :merged, -> { where(status: "request_merged") }
  scope :visible, lambda {
    open_collection_period_start_date = FormHandler.instance.start_date_of_earliest_open_collection_period
    merged.where("merge_requests.merge_date >= ?", open_collection_period_start_date).or(not_merged)
  }

  def absorbing_organisation_name
    absorbing_organisation&.name || ""
  end

  def dpo_user
    absorbing_organisation.data_protection_officers.filter_by_active.first
  end
end
