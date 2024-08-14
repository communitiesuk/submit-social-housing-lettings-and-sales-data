module FiltersHelper
  include CollectionTimeHelper

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
      "activating_soon" => "Activating soon",
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
    [OpenStruct.new(id: "", name: "Select an option", hint: "")] + user_options.map { |user_option| OpenStruct.new(id: user_option.id, name: user_option.name, hint: user_option.email) }
  end

  def collection_year_options
    years = {
      current_collection_start_year.to_s => year_combo(current_collection_start_year),
      previous_collection_start_year.to_s => year_combo(previous_collection_start_year),
    }

    if FormHandler.instance.in_crossover_period?
      return years.merge({ archived_collection_start_year.to_s => year_combo(archived_collection_start_year) })
    end

    years
  end

  def collection_year_radio_options
    {
      current_collection_start_year.to_s => { label: year_combo(current_collection_start_year) },
      previous_collection_start_year.to_s => { label: year_combo(previous_collection_start_year) },
      archived_collection_start_year.to_s => { label: year_combo(archived_collection_start_year) },
    }
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

  def logs_for_both_needstypes_present?(organisation)
    return true if current_user.support? && organisation.blank?
    return [1, 2].all? { |needstype| organisation.lettings_logs.visible.where(needstype:).count.positive? } if current_user.support?

    [1, 2].all? { |needstype| current_user.lettings_logs.visible.where(needstype:).count.positive? }
  end

  def non_support_with_multiple_owning_orgs?
    return true if current_user.organisation.stock_owners.count > 1
    return true if current_user.organisation.stock_owners.count.positive? && current_user.organisation.holds_own_stock?

    current_user.organisation.has_organisations_absorbed_during_displayed_collection_period?
  end

  def non_support_with_managing_orgs?
    current_user.organisation.managing_agents.count >= 1 || current_user.organisation.has_organisations_absorbed_during_displayed_collection_period?
  end

  def user_lettings_path?
    request.path == lettings_logs_path
  end

  def user_or_org_lettings_path?
    request.path.include?("/lettings-logs")
  end

  def specific_organisation_path?
    request.path.include?("/organisations")
  end

  def applied_filters_count(filter_type)
    filters_count(applied_filters(filter_type))
  end

  def check_your_answers_filters_list(session_filters, filter_type)
    [
      { id: "years", label: "Collection year", value: formatted_years_filter(session_filters) },
      { id: "status", label: "Status", value: formatted_status_filter(session_filters) },
      filter_type == "lettings_logs" ? { id: "needstype", label: "Needs type", value: formatted_needstype_filter(session_filters) } : nil,
      { id: "assigned_to", label: "Assigned to", value: formatted_assigned_to_filter(session_filters) },
      { id: "owned_by", label: "Owned by", value: formatted_owned_by_filter(session_filters) },
      { id: "managed_by", label: "Managed by", value: formatted_managed_by_filter(session_filters) },
    ].compact
  end

  def update_csv_filters_url(filter_type, filter, organisation_id)
    if organisation_id.present?
      send("#{filter_type}_filters_update_#{filter}_organisation_path", organisation_id)
    else
      send("filters_update_#{filter}_#{filter_type}_path")
    end
  end

  def cancel_csv_filters_update_url(filter_type, search, codes_only, organisation_id)
    if organisation_id.present?
      send("#{filter_type}_csv_download_organisation_path", id: organisation_id, search:, codes_only:)
    else
      send("csv_download_#{filter_type}_path", search:, codes_only:)
    end
  end

  def change_filter_for_csv_url(filter, filter_type, search_term, codes_only, organisation_id)
    if organisation_id.present?
      send("#{filter_type}_filters_#{filter[:id]}_organisation_path", organisation_id, search: search_term, codes_only:, referrer: "check_answers")
    else
      send("filters_#{filter[:id]}_#{filter_type}_path", search: search_term, codes_only:, referrer: "check_answers")
    end
  end

private

  def applied_filters(filter_type)
    return {} unless session[session_name_for(filter_type)]

    JSON.parse(session[session_name_for(filter_type)])
  end

  def session_name_for(filter_type)
    "#{filter_type}_filters"
  end

  def filters_count(filters)
    filters.each.sum do |category, category_filters|
      if %w[years status needstypes bulk_upload_id].include?(category)
        category_filters.count(&:present?)
      elsif %w[user owning_organisation managing_organisation].include?(category)
        1
      else
        0
      end
    end
  end

  def year_combo(year)
    "#{year}/#{year - 2000 + 1}"
  end

  def formatted_years_filter(session_filters)
    return unanswered_filter_value if session_filters["years"].blank?

    session_filters["years"].map { |year| year_combo(year.to_i) }.to_sentence
  end

  def formatted_status_filter(session_filters)
    return unanswered_filter_value if session_filters["status"].blank?

    session_filters["status"].map { |status| status_filters[status] }.to_sentence
  end

  def formatted_needstype_filter(session_filters)
    return unanswered_filter_value if session_filters["needstypes"].blank?

    session_filters["needstypes"].map { |needstype| needstype_filters[needstype] }.to_sentence
  end

  def formatted_assigned_to_filter(session_filters)
    return unanswered_filter_value if session_filters["assigned_to"].blank?
    return "All" if session_filters["assigned_to"].include?("all")
    return "You" if session_filters["assigned_to"].include?("you")

    selected_user_option = assigned_to_filter_options(current_user).find { |x| x.id == session_filters["user"].to_i }
    return unless selected_user_option

    "#{selected_user_option.name} (#{selected_user_option.hint})"
  end

  def formatted_owned_by_filter(session_filters)
    return "All" if params["id"].blank? && (session_filters["owning_organisation"].blank? || session_filters["owning_organisation"]&.include?("all"))

    session_org_id = session_filters["owning_organisation"] || params["id"]
    selected_owning_organisation_option = owning_organisation_filter_options(current_user).find { |org| org.id == session_org_id.to_i }
    return unless selected_owning_organisation_option

    selected_owning_organisation_option&.name
  end

  def formatted_managed_by_filter(session_filters)
    return "All" if session_filters["managing_organisation"].blank? || session_filters["managing_organisation"].include?("all")

    selected_managing_organisation_option = managing_organisation_filter_options(current_user).find { |org| org.id == session_filters["managing_organisation"].to_i }
    return unless selected_managing_organisation_option

    selected_managing_organisation_option&.name
  end

  def unanswered_filter_value
    "<span class=\"app-!-colour-muted\">You didn’t answer this filter</span>".html_safe
  end
end
