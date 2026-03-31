desc "Rounds and value for sales logs in the database if they are not a whole number"
task round_value_for_2026_sales_logs: :environment do
  ids = SalesLog.filter_by_year(2026).where("value % 1 != 0").pluck(:id)
  puts "Correcting #{ids.count} sales logs, #{ids}"

  # find all values of mortgage that are not a whole number
  SalesLog.filter_by_year(2026).where("value % 1 != 0").find_each do |log|
    log.update(value: log.value.round)
  end

  puts "Done"
end
