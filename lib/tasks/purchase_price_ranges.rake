namespace :data_import do
  desc "Import annual purchase price range data"
  task :purchase_price_ranges, %i[start_year path] => :environment do |_task, args|
    start_year = args[:start_year]
    path = args[:path]

    raise "Usage: rake data_import:purchase_price_ranges[start_year,'path/to/csv_file']" if path.blank? || start_year.blank?

    service = Imports::PurchasePriceRangesService.new(start_year:, path:)
    service.call

    pp "Created/updated #{service.count} LA Purchase Price Range records for #{start_year}" unless Rails.env.test?
  end
end
