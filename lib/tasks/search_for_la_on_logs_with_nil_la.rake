desc "For all logs missing an LA that could have one, call the postcode changed method to request a new one from postcodes API. For logs where an LA still cannot be found, this will set them back to in progress."
task :search_for_la_on_logs_with_nil_la, [:year] => :environment do |_task, args|
  include CollectionTimeHelper

  year = args[:year]&.to_i || current_collection_start_year

  lettings_logs = LettingsLog.filter_by_year(year).where(la: nil, needstype: 1, bulk_upload_id: nil)
  sales_logs = LettingsLog.filter_by_year(year).where(la: nil, bulk_upload_id: nil)

  puts "Checking LA on #{lettings_logs.count} lettings logs in #{year}"

  i = 0
  lettings_logs.find_each do |log|
    next unless log.valid?

    log.process_postcode_changes!
    unless log.save
      puts "Failed to save lettings log #{log.id}"
      puts "Errors: #{log.errors.full_messages}"
    end
    i += 1
    if (i % 100).zero?
      puts "Processed #{i} lettings logs"
    end
  end

  puts "Checking LA on #{sales_logs.count} sales logs in #{year}"

  i = 0
  sales_logs.find_each do |log|
    next unless log.valid?

    log.process_postcode_changes!
    unless log.save
      puts "Failed to save sales log #{log.id}"
      puts "Errors: #{log.errors.full_messages}"
    end
    i += 1
    if (i % 100).zero?
      puts "Processed #{i} sales logs"
    end
  end

  puts "Done"
end
