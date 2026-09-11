desc "Clears already-collected address/UPRN data for 2026/27 lettings logs in confidential (sensitive) schemes"
task clear_confidential_address_data: :environment do
  year = 2026

  fields_present_scope = %w[
    uprn
    uprn_known
    uprn_confirmed
    uprn_selection
    address_line1
    address_line2
    town_or_city
    county
    postcode_full
    postcode_known
    address_line1_input
    postcode_full_input
    address_line1_as_entered
    address_line2_as_entered
    town_or_city_as_entered
    county_as_entered
    postcode_full_as_entered
    la_as_entered
    address_search_value_check
    la
  ]

  scope = LettingsLog
            .filter_by_year(year)
            .joins(:scheme)
            .where(schemes: { sensitive: "Yes" })
            .where(fields_present_scope.map { |field| "#{LettingsLog.table_name}.#{field} IS NOT NULL" }.join(" OR "))

  puts "Found #{scope.count} confidential-scheme lettings logs in #{year}/#{year + 1} with address data to clear"
  scope.find_each do |log|
    puts "log_id=#{log.id} scheme_id=#{log.scheme_id} location_id=#{log.location_id} status=#{log.status} la=#{log.la} postcode_full=#{log.postcode_full}"
  end

  updated = 0

  scope.find_each do |log|
    original_status = log.status

    fields_present_scope.each { |field| log[field] = nil }
    log.is_la_inferred = log.la.present?

    if log.save(validate: false)
      updated += 1
      puts "log_id=#{log.id} status changed: #{original_status} -> #{log.status}" if log.status != original_status
    else
      Rails.logger.error "CLDC-4462: failed to clear address data for log #{log.id}: #{log.errors.full_messages.join(', ')}"
    end
  end

  puts "#{updated} logs updated"
end
