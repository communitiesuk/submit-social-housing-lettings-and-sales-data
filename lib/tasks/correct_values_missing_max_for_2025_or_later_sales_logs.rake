desc "Clears mortgage, purchase price (the 'value' field), monthly rent before staircasing and management fee values for sales logs in the database if they are over their new max"
task correct_values_missing_max_for_2025_or_later_sales_logs: :environment do
  mortgage_incorrect_logs = SalesLog.filter_by_year_or_later(2025).where("mortgage > 999999")
  value_incorrect_logs = SalesLog.filter_by_year_or_later(2025).where("value > 999999")
  mrentprestaircasing_incorrect_logs = SalesLog.filter_by_year_or_later(2025).where("mrentprestaircasing > 9999")
  management_fee_incorrect_logs = SalesLog.filter_by_year_or_later(2025).where("management_fee > 9999")
  all_incorrect_logs = (mortgage_incorrect_logs + value_incorrect_logs + mrentprestaircasing_incorrect_logs + management_fee_incorrect_logs).uniq
  puts "Correcting #{all_incorrect_logs.count} sales logs, #{all_incorrect_logs.map(&:id)}"

  mortgage_incorrect_logs.update!(mortgage: nil)
  value_incorrect_logs.update!(value: nil)
  mrentprestaircasing_incorrect_logs.update!(mrentprestaircasing: nil)
  management_fee_incorrect_logs.update!(management_fee: nil)

  puts "Done"
end
