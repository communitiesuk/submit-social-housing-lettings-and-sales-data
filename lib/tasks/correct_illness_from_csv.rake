namespace :correct_illness do
  desc "Export data CSVs for import into Central Data System (CDS)"
  task :create_illness_csv, %i[organisation_id] => :environment do |_task, args|
    organisation_id = args[:organisation_id]
    raise "Usage: rake correct_illness:create_illness_csv['organisation_id']" if organisation_id.blank?

    organisation = Organisation.find_by(id: organisation_id)
    if organisation.present?
      CreateIllnessCsvJob.perform_later(organisation)
      Rails.logger.info("Creating illness CSV for #{organisation.name}")
    else
      Rails.logger.error("Organisation with ID #{organisation_id} not found")
    end
  end

  desc "Export data CSVs for import into Central Data System (CDS)"
  task :correct_illness_from_csv, %i[file_name] => :environment do |_task, args|
    file_name = args[:file_name]

    raise "Usage: rake correct_illness:correct_illness_from_csv['csv_file_name']" if file_name.blank?

    s3_service = Storage::S3Service.new(PlatformHelper.is_paas? ? Configuration::PaasConfigurationService.new : Configuration::EnvConfigurationService.new, ENV["IMPORT_PAAS_INSTANCE"])
    illness_csv = CSV.parse(s3_service.get_file_io(file_name), headers: false)

    illness_csv.each_with_index do |row, index|
      next if index < 3

      lettings_log_id = row[1]

      if lettings_log_id.blank?
        Rails.logger.info("Lettings log ID not provided")
        next
      end

      lettings_log = LettingsLog.find_by(id: lettings_log_id)
      if lettings_log.blank?
        Rails.logger.info("Could not find a lettings log with id #{lettings_log_id}")
        next
      end

      lettings_log.illness = row[8]
      lettings_log.illness_type_1 = row[9].presence || 0
      lettings_log.illness_type_2 = row[10].presence || 0
      lettings_log.illness_type_3 = row[11].presence || 0
      lettings_log.illness_type_4 = row[12].presence || 0
      lettings_log.illness_type_5 = row[13].presence || 0
      lettings_log.illness_type_6 = row[14].presence || 0
      lettings_log.illness_type_7 = row[15].presence || 0
      lettings_log.illness_type_8 = row[16].presence || 0
      lettings_log.illness_type_9 = row[17].presence || 0
      lettings_log.illness_type_10 = row[18].presence || 0
      lettings_log.values_updated_at = Time.zone.now

      if lettings_log.save
        Rails.logger.info("Updated lettings log #{lettings_log_id}, with illness: #{([lettings_log.illness] + %w[illness_type_1 illness_type_2 illness_type_3 illness_type_4 illness_type_5 illness_type_6 illness_type_7 illness_type_8 illness_type_9 illness_type_10].select { |illness_type| lettings_log[illness_type] == 1 }).join(', ')}")
      else
        Rails.logger.error("Validation failed for lettings log with ID #{lettings_log.id}: #{lettings_log.errors.full_messages.join(', ')}}")
      end
    end
  end
end
