class FilterManager
  attr_reader :current_user, :session, :params, :filter_type

  def initialize(current_user:, session:, params:, filter_type:)
    @current_user = current_user
    @session = session
    @params = params
    @filter_type = filter_type
  end

  def self.filter_by_search(base_collection, search_term = nil)
    if search_term.present?
      base_collection.search_by(search_term)
    else
      base_collection
    end
  end

  def self.filter_logs(logs, search_term, filters, all_orgs, user)
    logs = filter_by_search(logs, search_term)

    filters.each do |category, values|
      next if Array(values).reject(&:empty?).blank?
      next if category == "owning_organisation" && all_orgs
      next if category == "managing_organisation" && all_orgs
      next if category == "assigned_to"
      next if category == "user_text_search" && filters["assigned_to"] != "specific_user"
      next if category == "owning_organisation_text_search" && all_orgs
      next if category == "managing_organisation_text_search" && all_orgs

      logs = logs.public_send("filter_by_#{category}", values, user)
    end
    logs = logs.order(id: :desc)
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

  def self.filter_users(users, search_term, filters, user)
    users = filter_by_search(users, search_term)

    filters.each do |category, values|
      next if Array(values).reject(&:empty?).blank?

      users = users.public_send("filter_by_#{category}", values, user)
    end
    users
  end

  def self.filter_schemes(schemes, search_term, filters, all_orgs, user)
    schemes = filter_by_search(schemes, search_term)

    filters.each do |category, values|
      next if Array(values).reject(&:empty?).blank?
      next if category == "owning_organisation" && all_orgs

      schemes = schemes.public_send("filter_by_#{category}", values, user)
    end
    schemes.order_by_service_name
  end

  def self.filter_locations(locations, search_term, filters, user)
    locations = filter_by_search(locations, search_term)

    filters.each do |category, values|
      next if Array(values).reject(&:empty?).blank?

      locations = locations.public_send("filter_by_#{category}", values, user)
    end
    locations.order(created_at: :desc)
  end

  def self.filter_uploads(uploads, search_term, filters, all_orgs, user)
    uploads = filter_by_search(uploads, search_term)

    filters.each do |category, values|
      next if Array(values).reject(&:empty?).blank?
      next if category == "uploading_organisation" && all_orgs
      next if category == "uploading_organisation_text_search" && all_orgs
      next if category == "uploaded_by"
      next if category == "uploaded_by_text_search" && filters["uploaded_by"] != "specific_user"

      uploads = uploads.public_send("filter_by_#{category}", values, user)
    end
    uploads.order(created_at: :desc)
  end

  def serialize_filters_to_session(specific_org: false)
    session[session_name_for(filter_type)] = session_filters(specific_org:).to_json
  end

  def session_filters(specific_org: false)
    @session_filters ||= deserialize_filters_from_session(specific_org)
  end

  def deserialize_filters_from_session(specific_org)
    current_filters = session[session_name_for(filter_type)]
    new_filters = if current_filters.present?
                    JSON.parse(current_filters).transform_values { |value| value.is_a?(Array) ? value.reject(&:blank?) : value }
                  else
                    {}
                  end
    if filter_type.include?("logs")
      current_user.logs_filters(specific_org:).each do |filter|
        new_filters[filter] = params[filter] if params[filter].present?
      end

      if params["action"] == "download_csv"
        new_filters["assigned_to"] = "all" if new_filters["assigned_to"] == "specific_user" && new_filters["user_text_search"].present?
        new_filters["owning_organisation_select"] = "all" if new_filters["owning_organisation_select"] == "specific_organisation" && new_filters["owning_organisation_text_search"].present?
        new_filters["managing_organisation_select"] = "all" if new_filters["managing_organisation_select"] == "specific_organisation" && new_filters["managing_organisation_text_search"].present?
      end
      new_filters = new_filters.except("owning_organisation") if params["owning_organisation_select"] == "all"
      new_filters = new_filters.except("managing_organisation") if params["managing_organisation_select"] == "all"

      new_filters = new_filters.except("user") if params["assigned_to"] == "all"
      new_filters["user"] = current_user.id.to_s if params["assigned_to"] == "you"
      new_filters = new_filters.except("user_text_search") if params["assigned_to"] == "all" || params["assigned_to"] == "you"
      new_filters = new_filters.except("owning_organisation_text_search") if params["owning_organisation_select"] == "all"
      new_filters = new_filters.except("managing_organisation_text_search") if params["managing_organisation_select"] == "all"
    end

    if (filter_type.include?("schemes") || filter_type.include?("users") || filter_type.include?("scheme_locations")) && params["status"].present?
      new_filters["status"] = params["status"]
    end

    if filter_type.include?("users") && params["role"].present?
      new_filters["role"] = params["role"]
    end

    if filter_type.include?("users") && params["additional_responsibilities"].present?
      new_filters["additional_responsibilities"] = params["additional_responsibilities"]
    end

    if filter_type.include?("schemes")
      current_user.scheme_filters(specific_org:).each do |filter|
        new_filters[filter] = params[filter] if params[filter].present?
      end

      new_filters = new_filters.except("owning_organisation") if params["owning_organisation_select"] == "all"
    end

    if filter_type.include?("bulk_uploads")
      current_user.bulk_uploads_filters(specific_org:).each do |filter|
        new_filters[filter] = params[filter] if params[filter].present?
      end
      new_filters = new_filters.except("uploading_organisation") if params["uploading_organisation_select"] == "all"
      new_filters = new_filters.except("user") if params["uploaded_by"] == "all"
      new_filters["user"] = current_user.id.to_s if params["uploaded_by"] == "you"
    end
    new_filters
  end

  def filtered_logs(logs, search_term, filters)
    all_orgs = params["managing_organisation_select"] == "all" && params["owning_organisation_select"] == "all"

    FilterManager.filter_logs(logs, search_term, filters, all_orgs, current_user)
  end

  def filtered_users(users, search_term, filters)
    FilterManager.filter_users(users, search_term, filters, current_user)
  end

  def filtered_schemes(schemes, search_term, filters)
    all_orgs = params["owning_organisation_select"] == "all"

    FilterManager.filter_schemes(schemes, search_term, filters, all_orgs, current_user)
  end

  def filtered_locations(locations, search_term, filters)
    FilterManager.filter_locations(locations, search_term, filters, current_user)
  end

  def bulk_upload
    id = (logs_filters["bulk_upload_id"] || []).reject(&:blank?)[0]
    @bulk_upload ||= current_user.bulk_uploads.find_by(id:)
  end

  def filtered_uploads(uploads, search_term, filters)
    all_orgs = params["uploading_organisation_select"] == "all"

    FilterManager.filter_uploads(uploads, search_term, filters, all_orgs, current_user)
  end

private

  def logs_filters
    JSON.parse(session[session_name_for(filter_type)] || "{}") || {}
  end

  def session_name_for(filter_type)
    "#{filter_type}_filters"
  end
end
