module FiltersHelper
  include CollectionTimeHelper

  def filter_selected?(filter, value, filter_type)
    return false unless session[session_name_for(filter_type)]

    selected_filters = JSON.parse(session[session_name_for(filter_type)])

    case filter
    when "assigned_to"
      assigned_to_filter_selected?(selected_filters, value)
    when "owning_organisation_select"
      owning_organisation_filter_selected?(selected_filters, value)
    when "managing_organisation_select"
      managing_organisation_filter_selected?(selected_filters, value)
    when "uploaded_by"
      uploaded_by_filter_selected?(selected_filters, value)
    when "uploading_organisation_select"
      uploading_organisation_filter_selected?(selected_filters, value)
    else
      selected_filters[filter]&.include?(value.to_s) || false
    end
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

  def user_role_type_filters(include_support = false)
    roles = {
      "1" => "Data provider",
      "2" => "Coordinator",
    }
    roles["99"] = "Support" if include_support
    roles.freeze
  end

  def user_additional_responsibilities_filters
    {
      "data_protection_officer" => "Data protection officer",
      "key_contact" => "Key contact",
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

  def salestype_filters
    {
      "1" => "Shared ownership",
      "2" => "Discounted ownership",
      "3" => "Outright or other sale",
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

  def all_owning_organisation_filter_options(user)
    organisation_options = user.support? ? Organisation.all : ([user.organisation] + user.organisation.stock_owners + user.organisation.absorbed_organisations).uniq
    [OpenStruct.new(id: "", name: "Select an option")] + organisation_options.map { |org| OpenStruct.new(id: org.id, name: org.name) }
  end

  def owning_organisation_filter_options(user, filter_type)
    if applied_filters(filter_type)["owning_organisation"].present?
      organisation_id = applied_filters(filter_type)["owning_organisation"]

      org = if user.support?
              Organisation.where(id: organisation_id)&.first
            else
              Organisation.affiliated_organisations(user.organisation).where(id: organisation_id)&.first
            end
      return [OpenStruct.new(id: org.id, name: org.name)] if org.present?
    end

    [OpenStruct.new(id: "", name: "Select an option")]
  end

  def assigned_to_csv_filter_options(user)
    user_options = user.support? ? User.all : (user.organisation.users + user.organisation.managing_agents.flat_map(&:users) + user.organisation.stock_owners.flat_map(&:users)).uniq
    [OpenStruct.new(id: "", name: "Select an option", hint: "")] + user_options.map { |user_option| OpenStruct.new(id: user_option.id, name: user_option.name, hint: user_option.email) }
  end

  def assigned_to_filter_options(filter_type)
    if applied_filters(filter_type)["assigned_to"] == "specific_user" && applied_filters(filter_type)["user"].present?
      user_id = applied_filters(filter_type)["user"]
      selected_user = User.visible(current_user).where(id: user_id)&.first

      return [OpenStruct.new(id: selected_user.id, name: selected_user.name, hint: selected_user.email)] if selected_user.present?
    end
    [OpenStruct.new(id: "", name: "Select an option", hint: "")]
  end

  def uploaded_by_filter_options
    user_options = User.all
    [OpenStruct.new(id: "", name: "Select an option", hint: "")] + user_options.map { |user_option| OpenStruct.new(id: user_option.id, name: user_option.name, hint: user_option.email) }
  end

  def filter_search_url(category)
    case category
    when :user
      search_users_path
    when :owning_organisation, :managing_organisation
      search_organisations_path
    end
  end

  def collection_year_options
    years = {
      current_collection_start_year.to_s => year_combo(current_collection_start_year),
      previous_collection_start_year.to_s => year_combo(previous_collection_start_year),
    }

    if FormHandler.instance.in_crossover_period?
      years = years.merge({ archived_collection_start_year.to_s => year_combo(archived_collection_start_year) })
    end

    if FeatureToggle.allow_future_form_use?
      years = { next_collection_start_year.to_s => year_combo(next_collection_start_year) }.merge(years)
    end

    years
  end

  def collection_year_radio_options
    options = {}
    collection_year_options.map do |year, label|
      options[year] = { label: }
    end
    options
  end

  def filters_applied_text(filter_type)
    applied_filters_count(filter_type).zero? ? "No filters applied" : "#{pluralize(applied_filters_count(filter_type), 'filter')} applied"
  end

  def reset_filters_link(filter_type, filter_path_params = {})
    if applied_filters_count(filter_type).positive?
      govuk_link_to "Clear", clear_filters_path(filter_type:, filter_path_params:), aria: { label: "Clear filters" }
    end
  end

  def managing_organisation_csv_filter_options(user)
    organisation_options = user.support? ? Organisation.all : ([user.organisation] + user.organisation.managing_agents + user.organisation.absorbed_organisations).uniq
    [OpenStruct.new(id: "", name: "Select an option")] + organisation_options.map { |org| OpenStruct.new(id: org.id, name: org.name) }
  end

  def managing_organisation_filter_options(user, filter_type)
    if applied_filters(filter_type)["managing_organisation"].present?
      organisation_id = applied_filters(filter_type)["managing_organisation"]

      org = if user.support?
              Organisation.where(id: organisation_id)&.first
            else
              Organisation.affiliated_organisations(user.organisation).where(id: organisation_id)&.first
            end
      return [OpenStruct.new(id: org.id, name: org.name)] if org.present?
    end

    [OpenStruct.new(id: "", name: "Select an option")]
  end

  def show_scheme_managing_org_filter?(user)
    return true if user.support?

    org = user.organisation
    stock_owners = org.stock_owners.count
    recently_absorbed_with_stock = org.absorbed_organisations.visible.merged_during_open_collection_period.where(holds_own_stock: true).count

    relevant_orgs_count = stock_owners + recently_absorbed_with_stock + (org.holds_own_stock? ? 1 : 0)

    relevant_orgs_count > 1
  end

  def logs_for_both_needstypes_present?(organisation)
    return true if current_user.support? && organisation.blank?
    return [1, 2].all? { |needstype| organisation.lettings_logs.visible.where(needstype:).count.positive? } if current_user.support?

    [1, 2].all? { |needstype| current_user.lettings_logs.visible.where(needstype:).count.positive? }
  end

  def logs_for_multiple_salestypes_present?(organisation)
    return true if current_user.support? && organisation.blank?
    return [1, 2, 3].count { |ownershipsch| organisation.sales_logs.visible.where(ownershipsch:).count.positive? } > 1 if current_user.support?

    [1, 2, 3].count { |ownershipsch| current_user.sales_logs.visible.where(ownershipsch:).count.positive? } > 1
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

  def user_or_org_sales_path?
    request.path.include?("/sales-logs")
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
      filter_type == "sales_logs" ? { id: "salestype", label: "Sales type", value: formatted_salestype_filter(session_filters) } : nil,
      { id: "assigned_to", label: "Assigned to", value: formatted_assigned_to_filter(session_filters) },
      { id: "owned_by", label: "Owned by", value: formatted_owned_by_filter(session_filters, filter_type) },
      { id: "managed_by", label: "Managed by", value: formatted_managed_by_filter(session_filters, filter_type) },
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
      if %w[years status needstypes bulk_upload_id role additional_responsibilities].include?(category)
        category_filters.count(&:present?)
      elsif %w[user owning_organisation managing_organisation user_text_search owning_organisation_text_search managing_organisation_text_search uploading_organisation].include?(category)
        1
      else
        0
      end
    end
  end

  def year_combo(year)
    "#{year} to #{year + 1}"
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

  def formatted_salestype_filter(session_filters)
    return unanswered_filter_value if session_filters["salestypes"].blank?

    session_filters["salestypes"].map { |salestype| salestype_filters[salestype] }.to_sentence
  end

  def formatted_assigned_to_filter(session_filters)
    return unanswered_filter_value if session_filters["assigned_to"].blank?
    return "All" if session_filters["assigned_to"].include?("all")
    return "You" if session_filters["assigned_to"].include?("you")

    user_id = session_filters["user"].to_i
    selected_user_option = User.visible(current_user).where(id: user_id)&.first

    return unless selected_user_option

    "#{selected_user_option.name} (#{selected_user_option.email})"
  end

  def formatted_owned_by_filter(session_filters, filter_type)
    return "All" if params["id"].blank? && (session_filters["owning_organisation"].blank? || session_filters["owning_organisation"]&.include?("all"))

    session_org_id = session_filters["owning_organisation"] || params["id"]
    selected_owning_organisation_option = owning_organisation_filter_options(current_user, filter_type).find { |org| org.id == session_org_id.to_i }
    return unless selected_owning_organisation_option

    selected_owning_organisation_option&.name
  end

  def formatted_managed_by_filter(session_filters, filter_type)
    return "All" if session_filters["managing_organisation"].blank? || session_filters["managing_organisation"].include?("all")

    selected_managing_organisation_option = managing_organisation_filter_options(current_user, filter_type).find { |org| org.id == session_filters["managing_organisation"].to_i }
    return unless selected_managing_organisation_option

    selected_managing_organisation_option&.name
  end

  def unanswered_filter_value
    "<span class=\"app-!-colour-muted\">You didn’t answer this filter</span>".html_safe
  end

  def assigned_to_filter_selected?(selected_filters, value)
    return true if !selected_filters.key?("user") && value == :all

    selected_filters["assigned_to"] == value.to_s
  end

  def owning_organisation_filter_selected?(selected_filters, value)
    return true if !selected_filters.key?("owning_organisation") && value == :all

    (selected_filters["owning_organisation"].present? || selected_filters["owning_organisation_text_search"].present?) && value == :specific_org
  end

  def managing_organisation_filter_selected?(selected_filters, value)
    return true if !selected_filters.key?("managing_organisation") && value == :all

    (selected_filters["managing_organisation"].present? || selected_filters["managing_organisation_text_search"].present?) && value == :specific_org
  end

  def uploaded_by_filter_selected?(selected_filters, value)
    return true if !selected_filters.key?("user") && value == :all

    selected_filters["uploaded_by"] == value.to_s
  end

  def uploading_organisation_filter_selected?(selected_filters, value)
    return true if !selected_filters.key?("uploading_organisation") && value == :all

    (selected_filters["uploading_organisation"].present? || selected_filters["uploading_organisation_text_search"].present?) && value == :specific_org
  end
end
