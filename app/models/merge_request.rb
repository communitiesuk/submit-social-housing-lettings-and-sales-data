class MergeRequest < ApplicationRecord
  belongs_to :requesting_organisation, class_name: "Organisation"
  has_many :merge_request_organisations
  belongs_to :absorbing_organisation, class_name: "Organisation", optional: true
  has_many :merging_organisations, through: :merge_request_organisations, source: :merging_organisation
  belongs_to :requester, class_name: "User", optional: true

  STATUS = {
    merge_issues: "merge_issues",
    incomplete: "incomplete",
    ready_to_merge: "ready_to_merge",
    processing: "processing",
    request_merged: "request_merged",
    deleted: "deleted",
  }.freeze
  enum status: STATUS

  scope :not_merged, -> { where(request_merged: [false, nil]) }
  scope :merged, -> { where(request_merged: true) }
  scope :visible, lambda {
    open_collection_period_start_date = FormHandler.instance.start_date_of_earliest_open_collection_period
    merged.where("merge_requests.merge_date >= ?", open_collection_period_start_date).or(not_merged).where(discarded_at: nil)
  }

  def absorbing_organisation_name
    absorbing_organisation&.name || ""
  end

  def dpo_user
    absorbing_organisation.data_protection_officers.filter_by_active.first
  end

  def discard!
    update!(discarded_at: Time.zone.now)
  end

  def status
    return STATUS[:deleted] if discarded_at.present?
    return STATUS[:request_merged] if request_merged
    return STATUS[:processing] if processing
    return STATUS[:incomplete] unless required_questions_answered?
    return STATUS[:ready_to_merge] if absorbing_organisation_signed_dsa?

    STATUS[:merge_issues]
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

  def total_visible_users_after_merge
    return total_users if status == STATUS[:request_merged] || status == STATUS[:processing]

    absorbing_organisation.users.visible.count + merging_organisations.sum { |org| org.users.visible.count }
  end

  def total_users_label
    "#{total_visible_users_after_merge} #{'User'.pluralize(total_visible_users_after_merge)}"
  end

  def organisations_with_users
    return [] unless absorbing_organisation.present? && merging_organisations.any?

    ([absorbing_organisation] + merging_organisations).select(&:has_visible_users?)
  end

  def organisations_without_users
    return [] unless absorbing_organisation.present? && merging_organisations.any?

    ([absorbing_organisation] + merging_organisations).reject(&:has_visible_users?)
  end
end
