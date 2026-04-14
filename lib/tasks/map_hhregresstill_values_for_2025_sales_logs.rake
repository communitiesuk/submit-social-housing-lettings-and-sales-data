desc "Remaps hhregresstill values for 2025/26 sales logs made in UI"
task remap_hhregresstill_values_for_2025_sales_logs: :environment do
  logs = SalesLog.filter_by_year(2025).where(bulk_upload_id: nil).where(hhregresstill: [5, 6, 7])
  puts "Updating #{logs.count} sales logs"

  logs.where(hhregresstill: 5).update_all(hhregresstill: 10)
  logs.where(hhregresstill: 6).update_all(hhregresstill: 9)
  logs.where(hhregresstill: 7).update_all(hhregresstill: 9)

  puts "Done"
end
