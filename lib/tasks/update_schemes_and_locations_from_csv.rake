namespace :bulk_update do
  desc "Bulk update scheme data from a csv file"
  task :update_schemes_from_csv, %i[original_file_name updated_file_name] => :environment do |_task, args|
    original_file_name = args[:original_file_name]
    updated_file_name = args[:updated_file_name]

    raise "Usage: rake bulk_update:update_schemes_from_csv['original_file_name','updated_file_name']" if original_file_name.blank? || updated_file_name.blank?

    BulkUpdateFromCsv::UpdateSchemesFromCsvService.new(original_file_name:, updated_file_name:).call
  end

  desc "Bulk update location data from a csv file"
  task :update_locations_from_csv, %i[original_file_name updated_file_name] => :environment do |_task, args|
    original_file_name = args[:original_file_name]
    updated_file_name = args[:updated_file_name]

    raise "Usage: rake bulk_update:update_locations_from_csv['original_file_name','updated_file_name']" if original_file_name.blank? || updated_file_name.blank?

    BulkUpdateFromCsv::UpdateLocationsFromCsvService.new(original_file_name:, updated_file_name:).call
  end
end
