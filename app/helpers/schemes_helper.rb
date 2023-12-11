module SchemesHelper
  def scheme_availability(scheme)
    availability = ""
    scheme_active_periods(scheme).each do |period|
      if period.from.present?
        availability << "\nActive from #{period.from.to_formatted_s(:govuk_date)}"
        availability << " to #{(period.to - 1.day).to_formatted_s(:govuk_date)}\nDeactivated on #{period.to.to_formatted_s(:govuk_date)}" if period.to.present?
      end
    end
    availability.strip
  end

  def toggle_scheme_link(scheme)
    return govuk_button_link_to "Deactivate this scheme", scheme_new_deactivation_path(scheme), warning: true if scheme.active? || scheme.deactivates_in_a_long_time?
    return govuk_button_link_to "Reactivate this scheme", scheme_new_reactivation_path(scheme) if scheme.deactivated?
  end

  def owning_organisation_options(current_user)
    all_orgs = Organisation.all.map { |org| OpenStruct.new(id: org.id, name: org.name) }
    user_org = [OpenStruct.new(id: current_user.organisation_id, name: current_user.organisation.name)]
    stock_owners = current_user.organisation.stock_owners.map { |org| OpenStruct.new(id: org.id, name: org.name) }
    merged_organisations = current_user.organisation.absorbed_organisations.merged_during_open_collection_period.map { |org| OpenStruct.new(id: org.id, name: org.name) }
    current_user.support? ? all_orgs : user_org + stock_owners + merged_organisations
  end

  def null_option
    [OpenStruct.new(id: "", name: "Select an option")]
  end

  def edit_scheme_text(scheme, user)
    if user.data_provider?
      "If you think this scheme should be updated, ask a data coordinator to make the changes. Find your data coordinators on the #{link_to('users page', users_path)}.".html_safe
    elsif user.data_coordinator? && user.organisation.parent_organisations.include?(scheme.owning_organisation)
      "This scheme belongs to your stock owner #{scheme.owning_organisation.name}."
    end
  end

  def selected_schemes_and_locations_text(download_type, schemes)
    scheme_count = schemes.count
    case download_type
    when "schemes"
      "You've selected #{pluralize(scheme_count, 'scheme')}."
    when "locations"
      location_count = Location.where(scheme: schemes).count
      "You've selected #{pluralize(location_count, 'location')} from #{pluralize(scheme_count, 'scheme')}."
    when "combined"
      location_count = Location.where(scheme: schemes).count
      "You've selected #{pluralize(scheme_count, 'scheme')} with #{pluralize(location_count, 'location')}. The CSV will have one location per row with scheme details listed for each location."
    end
  end

  def primary_schemes_csv_download_url(search, download_type)
    csv_download_schemes_path(search:, download_type:)
  end

  def secondary_schemes_csv_download_url(organisation, search, download_type)
    schemes_csv_download_organisation_path(organisation, search:, download_type:)
  end

private

  ActivePeriod = Struct.new(:from, :to)
  def scheme_active_periods(scheme)
    periods = [ActivePeriod.new(scheme.available_from, nil)]

    sorted_deactivation_periods = remove_nested_periods(scheme.scheme_deactivation_periods.sort_by(&:deactivation_date))
    sorted_deactivation_periods.each do |deactivation|
      periods.last.to = deactivation.deactivation_date
      periods << ActivePeriod.new(deactivation.reactivation_date, nil)
    end

    remove_overlapping_and_empty_periods(periods)
  end

  def remove_overlapping_and_empty_periods(periods)
    periods.select { |period| period.from.present? && (period.to.nil? || period.from < period.to) }
  end

  def remove_nested_periods(periods)
    periods.select { |inner_period| periods.none? { |outer_period| is_nested?(inner_period, outer_period) } }
  end

  def is_nested?(inner, outer)
    return false if inner == outer
    return false if [inner.deactivation_date, inner.reactivation_date, outer.deactivation_date, outer.reactivation_date].any?(&:blank?)

    [inner.deactivation_date, inner.reactivation_date].all? { |date| date.between?(outer.deactivation_date, outer.reactivation_date) }
  end
end
