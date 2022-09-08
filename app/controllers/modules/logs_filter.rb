module Modules::LogsFilter
  def filtered_logs(logs)
    if session[:logs_filters].present?
      filters = JSON.parse(session[:logs_filters])
      filters.each do |category, values|
        next if Array(values).reject(&:empty?).blank?
        next if category == "organisation" && params["organisation_select"] == "all"

        logs = logs.public_send("filter_by_#{category}", values, current_user)
      end
    end
    logs = logs.sort_by(&:created_at)
    current_user.support? ? logs.all.includes(:owning_organisation, :managing_organisation) : logs
  end

  def set_session_filters(specific_org: false)
    new_filters = session[:logs_filters].present? ? JSON.parse(session[:logs_filters]) : {}
    current_user.logs_filters(specific_org:).each { |filter| new_filters[filter] = params[filter] if params[filter].present? }
    new_filters = new_filters.except("organisation") if params["organisation_select"] == "all"

    session[:logs_filters] = new_filters.to_json
  end
end
