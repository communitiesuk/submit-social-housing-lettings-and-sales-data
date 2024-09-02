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
      !existing_absorbing_organisation.nil? &&
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
    "#{total_visible_users_after_merge} #{'user'.pluralize(total_visible_users_after_merge)}"
  end

  def organisations_with_users
    return [] unless absorbing_organisation.present? && merging_organisations.any?

    ([absorbing_organisation] + merging_organisations).select(&:has_visible_users?)
  end

  def organisations_without_users
    return [] unless absorbing_organisation.present? && merging_organisations.any?

    ([absorbing_organisation] + merging_organisations).reject(&:has_visible_users?)
  end

  def total_visible_schemes_after_merge
    return total_schemes if status == STATUS[:request_merged] || status == STATUS[:processing]

    absorbing_organisation.owned_schemes.visible.count + merging_organisations.sum { |org| org.owned_schemes.visible.count }
  end

  def total_schemes_label
    "#{total_visible_schemes_after_merge} #{'scheme'.pluralize(total_visible_schemes_after_merge)}"
  end

  def organisations_with_schemes
    return [] unless absorbing_organisation.present? && merging_organisations.any?

    ([absorbing_organisation] + merging_organisations).select(&:has_visible_schemes?)
  end

  def organisations_without_schemes
    return [] unless absorbing_organisation.present? && merging_organisations.any?

    ([absorbing_organisation] + merging_organisations).reject(&:has_visible_schemes?)
  end

  def existing_absorbing_organisation_label
    return if existing_absorbing_organisation.nil?

    existing_absorbing_organisation ? "Yes" : "No"
  end

  def filter_relationships(absorbing_relationships, merging_relationships, absorbing_organisation, merging_organisations)
    filtered_absorbing_relationships = absorbing_relationships.reject do |relationship|
      merging_relationships.include?(relationship) || merging_organisations.include?(relationship)
    end

    filtered_merging_relationships = merging_relationships.reject do |relationship|
      absorbing_relationships.include?(relationship) || relationship == absorbing_organisation || merging_organisations.include?(relationship)
    end

    (filtered_absorbing_relationships + filtered_merging_relationships).uniq
  end

  def total_stock_owners_after_merge
    return total_stock_owners if status == STATUS[:request_merged] || status == STATUS[:processing]

    absorbing_stock_owners = absorbing_organisation.stock_owners.visible
    merging_stock_owners = merging_organisations.flat_map { |org| org.stock_owners.visible }

    total_filtered_stock_owners = filter_relationships(absorbing_stock_owners, merging_stock_owners, absorbing_organisation, merging_organisations)
    total_filtered_stock_owners.count
  end

  def total_managing_agents_after_merge
    return total_managing_agents if status == STATUS[:request_merged] || status == STATUS[:processing]

    absorbing_managing_agents = absorbing_organisation.managing_agents.visible
    merging_managing_agents = merging_organisations.flat_map { |org| org.managing_agents.visible }

    total_filtered_managing_agents = filter_relationships(absorbing_managing_agents, merging_managing_agents, absorbing_organisation, merging_organisations)
    total_filtered_managing_agents.count
  end

  def total_stock_owners_managing_agents_label
    stock_owners_count = total_stock_owners_after_merge
    managing_agents_count = total_managing_agents_after_merge

    "#{stock_owners_count} #{'stock owner'.pluralize(stock_owners_count)}\n#{managing_agents_count} #{'managing agent'.pluralize(managing_agents_count)}"
  end

  def total_sales_logs_after_merge
    return total_sales_logs if status == STATUS[:request_merged] || status == STATUS[:processing]

    (absorbing_organisation.sales_logs.pluck(:id) + merging_organisations.map { |org| org.sales_logs.pluck(:id) }.flatten).uniq.count
  end

  def total_lettings_logs_after_merge
    return total_lettings_logs if status == STATUS[:request_merged] || status == STATUS[:processing]

    (absorbing_organisation.lettings_logs.pluck(:id) + merging_organisations.map { |org| org.lettings_logs.pluck(:id) }.flatten).uniq.count
  end

  def total_logs_label
    "#{total_lettings_logs_after_merge} lettings logs<br>#{total_sales_logs_after_merge} sales logs"
  end
end
