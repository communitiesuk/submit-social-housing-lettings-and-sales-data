namespace :logs do
  desc "Count the number of invalid LettingsLog and SalesLog for a given year"
  task :count_invalid, [:year] => :environment do |_task, args|
    include CollectionTimeHelper
    include InvalidLogsHelper

    year = args[:year] || current_collection_year
    count_and_display_invalid_logs(LettingsLog, "LettingsLog", year)
    count_and_display_invalid_logs(SalesLog, "SalesLog", year)
  end

  desc "Surface all invalid logs and output their error messages for a given year"
  task :surface_invalid, [:year] => :environment do |_task, args|
    include CollectionTimeHelper
    include InvalidLogsHelper

    year = args[:year] || current_collection_year
    surface_invalid_logs(LettingsLog, "LettingsLog", year)
    surface_invalid_logs(SalesLog, "SalesLog", year)
  end
end
