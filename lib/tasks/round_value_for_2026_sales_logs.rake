desc "Rounds purchase price (the 'value' field) for sales logs in the database if not a whole number"
task round_value_for_2026_sales_logs: :environment do
  logs = SalesLog.filter_by_year(2026).where("value % 1 != 0")
  puts "Correcting #{logs.count} sales logs, #{logs.map(&:id)}"

  logs.find_each do |log|
    log.update(value: log.value.round)
  end

  puts "Done"
end
