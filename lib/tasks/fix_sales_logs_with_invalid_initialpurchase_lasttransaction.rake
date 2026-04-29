desc "We tightened the validation in 2026 between initial purchase date, last transaction date and sale date so that no two can be equal and initial purchase date < last transaction date < sale date. To avoid invalid logs we clear lasttransaction if it equals saledate and if initialpurchase = lasttransaction we clear both"
task fix_sales_logs_with_invalid_initialpurchase_lasttransaction: :environment do
  lasttransaction_equal_saledate_logs = SalesLog.filter_by_year_or_later(2026).where("lasttransaction = saledate")
  initial_purchase_equal_lasttransaction_logs = SalesLog.filter_by_year_or_later(2026).where("initialpurchase = lasttransaction")

  puts "Updating #{lasttransaction_equal_saledate_logs.count} logs where lasttransaction = saledate, #{lasttransaction_equal_saledate_logs.map(&:id)}"
  lasttransaction_equal_saledate_logs.update!(lasttransaction: nil)

  puts "Updating #{initial_purchase_equal_lasttransaction_logs.count} logs where initialpurchase = lasttransaction, #{initial_purchase_equal_lasttransaction_logs.map(&:id)}"
  initial_purchase_equal_lasttransaction_logs.update!(initialpurchase: nil, lasttransaction: nil)

  puts "Done"
end
