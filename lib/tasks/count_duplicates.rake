namespace :count_duplicates do
  desc "Count the number of duplicate schemes per organisation"
  task scheme_duplicates_per_org: :environment do
    duplicates_csv = CSV.generate(headers: true) do |csv|
      csv << ["Organisation id", "Number of duplicate sets", "Total duplicate schemes"]

      Organisation.visible.each do |organisation|
        if organisation.owned_schemes.duplicate_sets.count.positive?
          csv << [organisation.id, organisation.owned_schemes.duplicate_sets.count, organisation.owned_schemes.duplicate_sets.sum(&:size)]
        end
      end
    end

    filename = "scheme-duplicates-#{Time.zone.now}.csv"
    storage_service = Storage::S3Service.new(Configuration::EnvConfigurationService.new, ENV["BULK_UPLOAD_BUCKET"])
    storage_service.write_file(filename, "﻿#{duplicates_csv}")

    url = storage_service.get_presigned_url(filename, 72.hours.to_i)
    Rails.logger.info("Download URL: #{url}")
  end

  desc "Count the number of duplicate locations per organisation"
  task location_duplicates_per_org: :environment do
    duplicates_csv = CSV.generate(headers: true) do |csv|
      csv << ["Organisation id", "Number of duplicate sets", "Total duplicate locations"]

      Organisation.visible.each do |organisation|
        duplicate_sets_count = 0
        total_duplicate_locations = 0
        organisation.owned_schemes.each do |scheme|
          duplicate_sets_count += scheme.locations.duplicate_sets.count
          total_duplicate_locations += scheme.locations.duplicate_sets.sum(&:size)
        end

        if duplicate_sets_count.positive?
          csv << [organisation.id, duplicate_sets_count, total_duplicate_locations]
        end
      end
    end

    filename = "location-duplicates-#{Time.zone.now}.csv"
    storage_service = Storage::S3Service.new(Configuration::EnvConfigurationService.new, ENV["BULK_UPLOAD_BUCKET"])
    storage_service.write_file(filename, "﻿#{duplicates_csv}")

    url = storage_service.get_presigned_url(filename, 72.hours.to_i)
    Rails.logger.info("Download URL: #{url}")
  end
end
