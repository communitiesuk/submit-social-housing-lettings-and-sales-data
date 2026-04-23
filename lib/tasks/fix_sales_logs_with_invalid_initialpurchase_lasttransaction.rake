desc "We tightened the validation between initial purchase date in 2026, last transaction date and sale date so the two can no longer be equal. To avoid invalid logs we clear initialpurchase if it equals saledate and if initialpurchase = lasttransaction we clear both"
task fix_sales_logs_with_invalid_initialpurchase_lasttransaction: :environment do
  lasttransaction_equal_saledate_logs = SalesLog.filter_by_year_or_later(2026).where("lasttransaction = saledate")
  initial_purchase_equal_lasttransaction_logs = SalesLog.filter_by_year_or_later(2026).where("initialpurchase = lasttransaction")

  puts "Updating #{lasttransaction_equal_saledate_logs.count} logs where lasttransaction = saledate, #{lasttransaction_equal_saledate_logs.map(&:id)}"
  lasttransaction_equal_saledate_logs.update!(lasttransaction: nil)

  puts "Updating #{initial_purchase_equal_lasttransaction_logs.count} logs where initialpurchase = lasttransaction, #{initial_purchase_equal_lasttransaction_logs.map(&:id)}"
  initial_purchase_equal_lasttransaction_logs.update!(initialpurchase: nil, lasttransaction: nil)

  puts "Done"
end
