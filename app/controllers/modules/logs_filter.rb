module Modules::LogsFilter
  def filtered_logs(logs, search_term, filters)
    all_orgs = params["organisation_select"] == "all"
    FilterService.filter_logs(logs, search_term, filters, all_orgs, current_user)
  end

  def load_session_filters(specific_org: false)
    current_filters = session[:logs_filters]
    new_filters = current_filters.present? ? JSON.parse(current_filters) : {}
    current_user.logs_filters(specific_org:).each { |filter| new_filters[filter] = params[filter] if params[filter].present? }
    params["organisation_select"] == "all" ? new_filters.except("organisation") : new_filters
  end

  def session_filters(specific_org: false)
    @session_filters ||= load_session_filters(specific_org:)
  end

  def set_session_filters
    session[:logs_filters] = @session_filters.to_json
  end
end
