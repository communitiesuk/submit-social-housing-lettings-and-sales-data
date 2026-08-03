desc "Deletes all logs in a given collection year and earlier. Note that this operation is PERMANENT and this will bypass callbacks/paper trail. Use only as instructed in a yearly cleanup task."
task :delete_logs_in_collection_year_and_earlier, %i[year] => :environment do |_task, args|
  year = args[:year].to_i

  if year < 2020
    raise ArgumentError, "Year must be above 2020. Make sure you've written out the entire year"
  end

  if year > Time.zone.now.year - 3
    raise ArgumentError, "Year cannot be the last 3 years, as these may contain visible logs"
  end

  puts "Deleting Logs before #{year}"

  puts "Deleting Sales Logs in batches of 10000"
  logs = SalesLog.filter_by_year_or_earlier(year)

  logs.in_batches(of: 10_000).each_with_index do |logs, i|
    puts "Deleting batch #{i + 1}"
    logs.delete_all
  end
  puts "Done deleting Sales Logs"

  puts "Deleting Lettings Logs in batches of 10000"
  logs = LettingsLog.filter_by_year_or_earlier(year)

  logs.in_batches(of: 10_000).each_with_index do |logs, i|
    puts "Deleting batch #{i + 1}"
    logs.delete_all
  end
  puts "Done deleting Lettings Logs"

  puts "Done deleting Logs before #{year}"
end
