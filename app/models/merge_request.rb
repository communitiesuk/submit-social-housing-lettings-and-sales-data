class MergeRequest < ApplicationRecord
  belongs_to :requesting_organisation, class_name: "Organisation"
  has_many :merge_request_organisations
  belongs_to :absorbing_organisation, class_name: "Organisation", optional: true
  has_many :merging_organisations, through: :merge_request_organisations, source: :merging_organisation
  belongs_to :requester, class_name: "User", optional: true
  before_save :update_status!

  STATUS = {
    "merge_issues" => 0,
    "incomplete" => 1,
    "ready_to_merge" => 2,
    "processing" => 3,
    "request_merged" => 4,
    "deleted" => 5,
  }.freeze
  enum status: STATUS

  scope :not_merged, -> { where.not(status: "request_merged") }
  scope :merged, -> { where(status: "request_merged") }
  scope :visible, lambda {
    open_collection_period_start_date = FormHandler.instance.start_date_of_earliest_open_collection_period
    merged.where("merge_requests.merge_date >= ?", open_collection_period_start_date).or(not_merged).where(discarded_at: nil)
  }

  attr_accessor :skip_update_status

  def absorbing_organisation_name
    absorbing_organisation&.name || ""
  end

  def dpo_user
    absorbing_organisation.data_protection_officers.filter_by_active.first
  end

  def discard!
    update!(discarded_at: Time.zone.now)
  end

  def update_status!
    return if skip_update_status

    self.status = calculate_status
  end

  def calculate_status
    return "deleted" if discarded_at.present?
    return "request_merged" if status == "request_merged"
    return "processing" if status == "processing"
    return "incomplete" unless required_questions_answered?
    return "ready_to_merge" if absorbing_organisation_signed_dsa?

    "merge_issues"
  end

  def required_questions_answered?
    absorbing_organisation_id.present? &&
      merge_date.present? &&
      merging_organisations.count.positive? &&
      errors.empty?
  end

  def absorbing_organisation_signed_dsa?
    absorbing_organisation&.data_protection_confirmed?
  end
end
