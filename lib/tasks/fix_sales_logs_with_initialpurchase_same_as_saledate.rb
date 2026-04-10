desc "We tightened the validation between initial purchase date and sale date so the two can no longer be equal. To avoid invalid logs we clear initialpurchase if it equals saledate"
task fix_sales_logs_with_initialpurchase_same_as_saledate: :environment do
  logs = SalesLog.filter_by_year_or_later(2025).where("initialpurchase = saledate")

  puts "Updating #{logs.count} logs, #{logs.map(&:id)}"

  logs.update!(initialpurchase: nil)

  puts "Done"
end
