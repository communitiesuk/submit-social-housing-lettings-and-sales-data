namespace :data_import do
  desc "Import lettings address data from a csv file"
  task :import_lettings_addresses_from_csv, %i[file_name] => :environment do |_task, args|
    file_name = args[:file_name]

    raise "Usage: rake data_import:import_lettings_addresses_from_csv['csv_file_name']" if file_name.blank?

    s3_service = Storage::S3Service.new(PlatformHelper.is_paas? ? Configuration::PaasConfigurationService.new : Configuration::EnvConfigurationService.new, ENV["IMPORT_PAAS_INSTANCE"])
    addresses_csv = CSV.parse(s3_service.get_file_io(file_name), headers: true)
    contains_issue_type = addresses_csv.headers.include?("Issue type")

    addresses_csv.each do |row|
      lettings_log_id = contains_issue_type ? row[1] : row[0]
      uprn = contains_issue_type ? row[8] : row[7]
      address_line1 = contains_issue_type ? row[9] : row[8]
      address_line2 = contains_issue_type ? row[10] : row[9]
      town_or_city = contains_issue_type ?  row[11] : row[10]
      county = contains_issue_type ? row[12] : row[11]
      postcode_full = contains_issue_type ? row[13] : row[12]

      if lettings_log_id.blank?
        Rails.logger.info("Lettings log ID not provided for address: #{[address_line1, address_line2, town_or_city, county, postcode_full].join(', ')}")
        next
      end

      if uprn.present?
        Rails.logger.info("Lettings log with ID #{lettings_log_id} contains uprn, skipping log")
        next
      end

      if address_line1.blank? || town_or_city.blank? || postcode_full.blank?
        Rails.logger.info("Lettings log with ID #{lettings_log_id} is missing required address data, skipping log")
        next
      end

      lettings_log = LettingsLog.find_by(id: lettings_log_id)
      if lettings_log.blank?
        Rails.logger.info("Could not find a lettings log with id #{lettings_log_id}")
        next
      end

      lettings_log.uprn_known = 0
      lettings_log.uprn = nil
      lettings_log.uprn_confirmed = nil
      lettings_log.address_line1 = address_line1
      lettings_log.address_line2 = address_line2
      lettings_log.town_or_city = town_or_city
      lettings_log.county = county
      lettings_log.postcode_full = postcode_full
      lettings_log.postcode_known = lettings_log.postcode_full.present? ? 1 : nil
      lettings_log.is_la_inferred = nil
      lettings_log.la = nil
      lettings_log.values_updated_at = Time.zone.now

      lettings_log.save!
      Rails.logger.info("Updated lettings log #{lettings_log_id}, with address: #{[lettings_log.address_line1, lettings_log.address_line2, lettings_log.town_or_city, lettings_log.county, lettings_log.postcode_full].join(', ')}")
    end
  end

  desc "Import sales address data from a csv file"
  task :import_sales_addresses_from_csv, %i[file_name] => :environment do |_task, args|
    file_name = args[:file_name]

    raise "Usage: rake data_import:import_sales_addresses_from_csv['csv_file_name']" if file_name.blank?

    s3_service = Storage::S3Service.new(PlatformHelper.is_paas? ? Configuration::PaasConfigurationService.new : Configuration::EnvConfigurationService.new, ENV["IMPORT_PAAS_INSTANCE"])
    addresses_csv = CSV.parse(s3_service.get_file_io(file_name), headers: true)
    contains_issue_type = addresses_csv.headers.include?("Issue type")

    addresses_csv.each do |row|
      sales_log_id = contains_issue_type ? row[1] : row[0]
      uprn = contains_issue_type ? row[6] : row[5]
      address_line1 = contains_issue_type ? row[7] : row[6]
      address_line2 = contains_issue_type ? row[8] : row[7]
      town_or_city = contains_issue_type ? row[9] : row[8]
      county = contains_issue_type ? row[10] : row[9]
      postcode_full = contains_issue_type ? row[11] : row[10]

      if sales_log_id.blank?
        Rails.logger.info("Sales log ID not provided for address: #{[address_line1, address_line2, town_or_city, county, postcode_full].join(', ')}")
        next
      end

      if uprn.present?
        Rails.logger.info("Sales log with ID #{sales_log_id} contains uprn, skipping log")
        next
      end

      if address_line1.blank? || town_or_city.blank? || postcode_full.blank?
        Rails.logger.info("Sales log with ID #{sales_log_id} is missing required address data, skipping log")
        next
      end

      sales_log = SalesLog.find_by(id: sales_log_id)
      if sales_log.blank?
        Rails.logger.info("Could not find a sales log with id #{sales_log_id}")
        next
      end

      sales_log.uprn_known = 0
      sales_log.uprn = nil
      sales_log.uprn_confirmed = nil
      sales_log.address_line1 = address_line1
      sales_log.address_line2 = address_line2
      sales_log.town_or_city = town_or_city
      sales_log.county = county
      sales_log.postcode_full = postcode_full
      sales_log.pcodenk = sales_log.postcode_full.present? ? 0 : nil
      sales_log.is_la_inferred = nil
      sales_log.la = nil
      sales_log.values_updated_at = Time.zone.now

      sales_log.save!
      Rails.logger.info("Updated sales log #{sales_log_id}, with address: #{[sales_log.address_line1, sales_log.address_line2, sales_log.town_or_city, sales_log.county, sales_log.postcode_full].join(', ')}")
    end
  end
end
