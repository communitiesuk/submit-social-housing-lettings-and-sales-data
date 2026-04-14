desc "Remaps hhregresstill values for manually created 2025/26 sales logs"
task :remap_2025_hhregresstill_values, %i[before_date] => :environment do |_task, args|
  usage_message = "Usage: rake remap_2025_hhregresstill_values['before_date']. before_date must be in format YYYY-MM-DD"
  raise usage_message if args[:before_date].blank?

  begin
    before_date = Date.parse(args[:before_date])
  rescue Date::Error
    raise usage_message
  end

  logs = SalesLog.filter_by_year(2025).where(bulk_upload_id: nil).where(hhregresstill: [5, 6, 7]).where("created_at < ?", before_date)
  puts "Updating #{logs.count} sales logs"

  logs.where(hhregresstill: 5).update_all(hhregresstill: 10)
  logs.where(hhregresstill: 6).update_all(hhregresstill: 9)
  logs.where(hhregresstill: 7).update_all(hhregresstill: 9)

  puts "Done"
end
