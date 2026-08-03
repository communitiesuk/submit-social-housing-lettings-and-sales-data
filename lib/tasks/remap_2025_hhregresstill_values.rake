desc "Remaps hhregresstill values for manually created 2025/26 sales logs"
task :remap_2025_hhregresstill_values, %i[before_datetime] => :environment do |_task, args|
  usage_message = "Usage: rake remap_2025_hhregresstill_values['before_datetime']. before_datetime must be in format YYYY-MM-DDTHH:MM:SS"
  raise usage_message if args[:before_datetime].blank?

  before_datetime = Time.zone.parse(args[:before_datetime])
  raise usage_message if before_datetime.nil?

  logs = SalesLog.filter_by_year(2025).where(bulk_upload_id: nil).where(hhregresstill: [5, 6, 7]).where("created_at < ?", before_datetime)
  puts "Updating #{logs.count} sales logs"

  updated_ids = []
  logs.find_each do |log|
    new_value = case log.hhregresstill
                when 5 then 10
                when 6, 7 then 9
                end
    log.update!(hhregresstill: new_value)
    updated_ids << log.id
  end

  puts "Updated log IDs: #{updated_ids.join(', ')}"
  puts "Done"
end
