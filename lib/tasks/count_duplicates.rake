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
      csv << ["Organisation id", "Duplicate sets within individual schemes", "Duplicate locations within individual schemes", "All duplicate sets", "All duplicates"]

      Organisation.visible.each do |organisation|
        duplicate_sets_within_individual_schemes = []

        organisation.owned_schemes.each do |scheme|
          duplicate_sets_within_individual_schemes += scheme.locations.duplicate_sets
        end
        duplicate_locations_within_individual_schemes = duplicate_sets_within_individual_schemes.flatten

        duplicate_sets_within_duplicate_schemes = []
        if organisation.owned_schemes.duplicate_sets.count.positive?
          organisation.owned_schemes.duplicate_sets.each do |duplicate_set|
            duplicate_sets_within_duplicate_schemes += Location.where(scheme_id: duplicate_set).duplicate_sets_within_given_schemes
          end
          duplicate_locations_within_duplicate_schemes_ids = duplicate_sets_within_duplicate_schemes.flatten

          duplicate_sets_within_individual_schemes_without_intersecting_sets = duplicate_sets_within_individual_schemes.reject { |set| set.any? { |id| duplicate_sets_within_duplicate_schemes.any? { |duplicate_set| duplicate_set.include?(id) } } }
          all_duplicate_sets_count = (duplicate_sets_within_individual_schemes_without_intersecting_sets + duplicate_sets_within_duplicate_schemes).count
          all_duplicate_locations_count = (duplicate_locations_within_duplicate_schemes_ids + duplicate_locations_within_individual_schemes).uniq.count
        else
          all_duplicate_sets_count = duplicate_sets_within_individual_schemes.count
          all_duplicate_locations_count = duplicate_locations_within_individual_schemes.count
        end

        if all_duplicate_locations_count.positive?
          csv << [organisation.id, duplicate_sets_within_individual_schemes.count, duplicate_locations_within_individual_schemes.count, all_duplicate_sets_count, all_duplicate_locations_count]
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
