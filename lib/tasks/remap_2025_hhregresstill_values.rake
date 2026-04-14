desc "Remaps hhregresstill values for manually created 2025/26 sales logs"
task :remap_2025_hhregresstill_values, %i[before_datetime] => :environment do |_task, args|
  usage_message = "Usage: rake remap_2025_hhregresstill_values['before_datetime']. before_datetime must be in format YYYY-MM-DDTHH:MM:SS"
  raise usage_message if args[:before_datetime].blank?

  before_datetime = Time.zone.parse(args[:before_datetime])
  raise usage_message if before_datetime.nil?

  logs = SalesLog.filter_by_year(2025).where(bulk_upload_id: nil).where(hhregresstill: [5, 6, 7]).where("created_at < ?", before_datetime)
  puts "Updating #{logs.count} sales logs"

  logs.where(hhregresstill: 5).update_all(hhregresstill: 10)
  logs.where(hhregresstill: 6).update_all(hhregresstill: 9)
  logs.where(hhregresstill: 7).update_all(hhregresstill: 9)

  puts "Done"
end
