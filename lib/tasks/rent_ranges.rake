require "csv"

namespace :data_import do
  desc "Import annual rent range data"
  task :rent_ranges, %i[start_year path] => :environment do |_task, args|
    start_year = args[:start_year]
    path = args[:path]
    count = 0

    raise "Usage: rake data_import:rent_ranges[start_year,'path/to/csv_file']" if path.blank? || start_year.blank?

    CSV.foreach(path, headers: true) do |row|
      LaRentRange.upsert(
        { ranges_rent_id: row["ranges_rent_id"],
          lettype: row["lettype"],
          beds: row["beds"],
          start_year:,
          la: row["la"],
          soft_min: row["soft_min"],
          soft_max: row["soft_max"],
          hard_min: row["hard_min"],
          hard_max: row["hard_max"] },
        unique_by: %i[start_year lettype beds la],
      )
      count +=1
    end
    pp "Created/updated #{count} records"
  end
end
