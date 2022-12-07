require "csv"

namespace :data_import do
  desc "Import annual rent range data"
  task :rent_ranges, %i[start_year path] => :environment do |_task, args|
    start_year = args[:start_year]
    path = args[:path]

    raise "Usage: rake data_import:rent_ranges[start_year,'path/to/csv_file']" if path.blank? || start_year.blank?

    service = Imports::RentRangesService.new(start_year:, path:)
    service.call

    pp "Created/updated #{service.count} LA Rent Range records for #{start_year}" unless Rails.env.test?
  end
end
