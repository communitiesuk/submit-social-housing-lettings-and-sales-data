module FiltersHelper
  def filter_selected?(filter, value, filter_type)
    return false unless session[session_name_for(filter_type)]

    selected_filters = JSON.parse(session[session_name_for(filter_type)])
    return true if selected_filters.blank? && filter == "user" && value == :all
    return true if !selected_filters.key?("owning_organisation") && filter == "owning_organisation_select" && value == :all
    return true if selected_filters["owning_organisation"].present? && filter == "owning_organisation_select" && value == :specific_org
    return false if selected_filters[filter].blank?

    selected_filters[filter].include?(value.to_s)
  end

  def any_filter_selected?(filter_type)
    filters_json = session[session_name_for(filter_type)]
    return false unless filters_json

    filters = JSON.parse(filters_json)
    filters["user"] == "yours" ||
      filters["organisation"].present? ||
      filters["status"]&.compact_blank&.any? ||
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

  def selected_option(filter, filter_type)
    return false unless session[session_name_for(filter_type)]

    JSON.parse(session[session_name_for(filter_type)])[filter] || ""
  end

  def owning_organisations_filter_options(user)
    organisation_options = user.support? ? Organisation.all : [user.organisation] + user.organisation.stock_owners
    [OpenStruct.new(id: "", name: "Select an option")] + organisation_options.map { |org| OpenStruct.new(id: org.id, name: org.name) }
  end

  def collection_year_options
    { "2023": "2023/24", "2022": "2022/23", "2021": "2021/22" }
  end

private

  def session_name_for(filter_type)
    "#{filter_type}_filters"
  end
end
