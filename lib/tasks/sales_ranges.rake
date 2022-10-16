require "csv"

namespace :data_import do
  desc "Import annual sales range data"
  task :sales_ranges, %i[start_year path] => :environment do |_task, args|
    start_year = args[:start_year]
    path = args[:path]
    count = 0

    raise "Usage: rake data_import:sales_ranges[start_year,'path/to/csv_file']" if path.blank? || start_year.blank?

    CSV.foreach(path, headers: true) do |row|
      LaSalesRange.upsert(
        {
          beds: row["beds"],
          start_year: start_year,
          la: row["la"],
          soft_min: row["soft_min"],
          soft_max: row["soft_max"]
        },
        unique_by: %i[start_year beds la],
      )
      count += 1
    end
    pp "Created/updated #{count} LA Sales Range records" unless Rails.env.test?
  end
end
