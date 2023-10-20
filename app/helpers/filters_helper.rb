module FiltersHelper
  def filter_selected?(filter, value, filter_type)
    return false unless session[session_name_for(filter_type)]

    selected_filters = JSON.parse(session[session_name_for(filter_type)])
    return true if !selected_filters.key?("user") && filter == "assigned_to" && value == :all
    return true if selected_filters["assigned_to"] == "specific_user" && filter == "assigned_to" && value == :specific_user

    return true if !selected_filters.key?("owning_organisation") && filter == "owning_organisation_select" && value == :all
    return true if !selected_filters.key?("managing_organisation") && filter == "managing_organisation_select" && value == :all

    return true if selected_filters["owning_organisation"].present? && filter == "owning_organisation_select" && value == :specific_org
    return true if selected_filters["managing_organisation"].present? && filter == "managing_organisation_select" && value == :specific_org

    return false if selected_filters[filter].blank?

    selected_filters[filter].include?(value.to_s)
  end

  def any_filter_selected?(filter_type)
    filters_json = session[session_name_for(filter_type)]
    return false unless filters_json

    filters = JSON.parse(filters_json)
    filters["user"].present? ||
      filters["organisation"].present? ||
      filters["managing_organisation"].present? ||
      filters["status"]&.compact_blank&.any? ||
      filters["needstypes"]&.compact_blank&.any? ||
      filters["years"]&.compact_blank&.any? ||
      filters["bulk_upload_id"].present?
  end

  def status_filters
    {
      "not_started" => "Not started",
      "in_progress" => "In progress",
      "completed" => "Completed",
    }.freeze
  end

  def user_status_filters
    {
      "active" => "Active",
      "deactivated" => "Deactivated",
      "unconfirmed" => "Unconfirmed",
    }.freeze
  end

  def scheme_status_filters
    {
      "incomplete" => "Incomplete",
      "active" => "Active",
      "deactivating_soon" => "Deactivating soon",
      "reactivating_soon" => "Reactivating soon",
      "deactivated" => "Deactivated",
    }.freeze
  end

  def needstype_filters
    {
      "1" => "General needs",
      "2" => "Supported housing",
    }.freeze
  end

  def location_status_filters
    {
      "incomplete" => "Incomplete",
      "active" => "Active",
      "deactivating_soon" => "Deactivating soon",
      "activating_soon" => "Activating soon",
      "reactivating_soon" => "Reactivating soon",
      "deactivated" => "Deactivated",
    }.freeze
  end

  def selected_option(filter, filter_type)
    return false unless session[session_name_for(filter_type)]

    JSON.parse(session[session_name_for(filter_type)])[filter] || ""
  end

  def owning_organisation_filter_options(user)
    organisation_options = user.support? ? Organisation.all : ([user.organisation] + user.organisation.stock_owners + user.organisation.absorbed_organisations).uniq
    [OpenStruct.new(id: "", name: "Select an option")] + organisation_options.map { |org| OpenStruct.new(id: org.id, name: org.name) }
  end

  def assigned_to_filter_options(user)
    user_options = user.support? ? User.all : (user.organisation.users + user.organisation.managing_agents.flat_map(&:users) + user.organisation.stock_owners.flat_map(&:users)).uniq
    [OpenStruct.new(id: "", name: "Select an option")] + user_options.map { |user_option| OpenStruct.new(id: user_option.id, name: user_option.name) }
  end

  def collection_year_options
    { "2023": "2023/24", "2022": "2022/23", "2021": "2021/22" }
  end

  def filters_applied_text(filter_type)
    applied_filters_count(filter_type).zero? ? "No filters applied" : "#{pluralize(applied_filters_count(filter_type), 'filter')} applied"
  end

  def reset_filters_link(filter_type, path_params = {})
    if applied_filters_count(filter_type).positive?
      govuk_link_to "Clear", clear_filters_path(filter_type:, path_params:)
    end
  end

  def managing_organisation_filter_options(user)
    organisation_options = user.support? ? Organisation.all : ([user.organisation] + user.organisation.managing_agents + user.organisation.absorbed_organisations).uniq
    [OpenStruct.new(id: "", name: "Select an option")] + organisation_options.map { |org| OpenStruct.new(id: org.id, name: org.name) }
  end

  def show_scheme_managing_org_filter?(user)
    org = user.organisation

    user.support? || org.stock_owners.count > 1 || (org.holds_own_stock? && org.stock_owners.count.positive?)
  end

  def has_logs_for_both_needstypes?
    [1, 2].all? { |needstype| current_user.lettings_logs.where(needstype:).count.positive? }
  end

  def multiple_owning_orgs?
    current_user.support? || current_user.organisation.stock_owners.count > 1
  end

  def multiple_managing_orgs?
    current_user.support? || current_user.organisation.managing_agents.count > 1
  end

  def user_or_org_lettings_path?
    request.path.include?("/lettings-logs")
  end

private

  def applied_filters_count(filter_type)
    filters_count(applied_filters(filter_type))
  end

  def applied_filters(filter_type)
    return {} unless session[session_name_for(filter_type)]

    JSON.parse(session[session_name_for(filter_type)])
  end

  def session_name_for(filter_type)
    "#{filter_type}_filters"
  end

  def filters_count(filters)
    filters.each.sum do |category, category_filters|
      if %w[status needstypes years bulk_upload_id].include?(category)
        category_filters.count(&:present?)
      elsif %w[user owning_organisation managing_organisation].include?(category)
        1
      else
        0
      end
    end
  end
end
