class FilterService
  attr_reader :current_user, :session, :params, :filter_type

  def initialize(current_user:, session:, params:, filter_type:)
    @current_user = current_user
    @session = session
    @params = params
    @filter_type = filter_type
  end

  def filter_by_search(base_collection, search_term = nil)
    if search_term.present?
      base_collection.search_by(search_term)
    else
      base_collection
    end
  end

  def filter_logs(logs, search_term, filters, all_orgs, user)
    logs = filter_by_search(logs, search_term)

    filters.each do |category, values|
      next if Array(values).reject(&:empty?).blank?
      next if category == "organisation" && all_orgs

      logs = logs.public_send("filter_by_#{category}", values, user)
    end
    logs = logs.order(created_at: :desc)
    if user.support?
      if logs.first&.lettings?
        logs.all.includes(:owning_organisation, :managing_organisation)
      else
        logs.all.includes(:owning_organisation)
      end
    else
      logs
    end
  end

  def serialize_filters_to_session(specific_org: false)
    session["#{@filter_type}_filters"] = session_filters(specific_org:).to_json
  end

  def session_filters(specific_org: false)
    @session_filters ||= deserialize_filters_from_session(specific_org)
  end

  def deserialize_filters_from_session(specific_org)
    current_filters = session["#{@filter_type}_filters"]
    new_filters = current_filters.present? ? JSON.parse(current_filters) : {}
    if @filter_type.include?("logs")
      current_user.logs_filters(specific_org:).each do |filter|
        new_filters[filter] = params[filter] if params[filter].present?
      end
    end
    params["organisation_select"] == "all" ? new_filters.except("organisation") : new_filters
  end

  def filtered_logs(logs, search_term, filters)
    all_orgs = params["organisation_select"] == "all"
    filter_logs(logs, search_term, filters, all_orgs, current_user)
  end

  def bulk_upload
    id = (logs_filters["bulk_upload_id"] || []).reject(&:blank?)[0]
    @bulk_upload ||= current_user.bulk_uploads.find_by(id:)
  end

private

  def logs_filters
    JSON.parse(session["#{@filter_type}_filters"] || "{}") || {}
  end
end
