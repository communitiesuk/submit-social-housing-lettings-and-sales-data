desc "Maps hhregresstill values for 2025 sales logs created before a given date: 5 -> 10, 6 -> 9, 7 -> 9"
task :map_hhregresstill_values_for_2025_sales_logs, %i[before_date] => :environment do |_task, args|
  before_date = Date.parse(args[:before_date])
  logs = SalesLog.filter_by_year(2025).where(bulk_upload_id: nil).where(hhregresstill: [5, 6, 7]).where("created_at < ?", before_date)
  puts "Updating #{logs.count} sales logs"

  logs.where(hhregresstill: 5).update_all(hhregresstill: 10)
  logs.where(hhregresstill: 6).update_all(hhregresstill: 9)
  logs.where(hhregresstill: 7).update_all(hhregresstill: 9)

  puts "Done"
end
