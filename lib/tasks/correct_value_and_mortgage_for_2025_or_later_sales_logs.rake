desc "Clears mortgage and purchase price (the 'value' field) values for sales logs in the database if they are over 999,999"
task correct_value_and_mortgage_for_2025_or_later_sales_logs: :environment do
  mortgage_incorrect_logs = SalesLog.filter_by_year_or_later(2025).where("mortgage > 999999")
  value_incorrect_logs = SalesLog.filter_by_year_or_later(2025).where("value > 999999")
  all_incorrect_logs = (mortgage_incorrect_logs + value_incorrect_logs).uniq
  puts "Correcting #{all_incorrect_logs.count} sales logs, #{all_incorrect_logs.map(&:id)}"

  mortgage_incorrect_logs.update!(mortgage: nil)
  value_incorrect_logs.update!(value: nil)

  puts "Done"
end
