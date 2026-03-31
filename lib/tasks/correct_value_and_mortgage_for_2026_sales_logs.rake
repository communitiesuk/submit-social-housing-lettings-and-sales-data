desc "Clears mortgage and value values for sales logs in the database if they are over 999,999"
task correct_value_and_mortgage_for_2026_sales_logs: :environment do
  ids = SalesLog.filter_by_year(2026).where("mortgage > 999999").pluck(:id) + SalesLog.filter_by_year(2026).where("value > 999999").pluck(:id).uniq
  puts "Correcting #{ids.count} sales logs, #{ids}"

  SalesLog.filter_by_year(2026).where("mortgage > 999999").update!(mortgage: nil)
  SalesLog.filter_by_year(2026).where("value > 999999").update!(value: nil)

  puts "Done"
end
