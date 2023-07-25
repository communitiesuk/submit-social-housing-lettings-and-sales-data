namespace :import do
  task :full, %i[institutions_csv_path] => :environment do |_task, args|
    institutions_csv_path = args[:institutions_csv_path]
    raise "Must provide institutions csv path" if institutions_csv_path.blank?

    s3_service = Storage::S3Service.new(Configuration::PaasConfigurationService.new, ENV["IMPORT_PAAS_INSTANCE"])
    csv = CSV.parse(s3_service.get_file_io(institutions_csv_path))
    org_count = csv.length

    initial_import_list = [
      Import.new(Imports::OrganisationImportService, :create_organisations, "institution"),
      Import.new(Imports::SchemeImportService, :create_schemes, "mgmtgroups"),
      Import.new(Imports::SchemeLocationImportService, :create_scheme_locations, "schemes"),
      Import.new(Imports::UserImportService, :create_users, "user"),
      Import.new(Imports::DataProtectionConfirmationImportService, :create_data_protection_confirmations, "dataprotect"),
      Import.new(Imports::OrganisationRentPeriodImportService, :create_organisation_rent_periods, "rent-period"),
    ]

    Rails.logger.info("Beginning initial imports for #{org_count} organisations")

    csv.each { |row|
      archive_path = row[1]
      archive_io = s3_service.get_file_io(archive_path)
      archive_service = Storage::ArchiveService.new(archive_io)

      Rails.logger.info("Performing initial imports for organisation #{row[0]}")

      initial_import_list.each do |step|
        if archive_service.folder_present?(step.folder)
          step.import_class.new(archive_service).send(step.import_method, step.folder)
        end
      end
    }

    logs_import_list = [
      Import.new(Imports::LettingsLogsImportService, :create_logs, "logs"),
      Import.new(Imports::SalesLogsImportService, :create_logs, "logs"),
    ]

    Rails.logger.info("Beginning log imports for #{org_count} organisations")

    csv.each { |row|
      archive_path = row[1]
      archive_io = s3_service.get_file_io(archive_path)
      archive_service = Storage::ArchiveService.new(archive_io)

      log_count = row[2].to_i + row[3].to_i + row[4].to_i + row[5].to_i
      Rails.logger.info("Performing log imports for organisation #{row[0]}, expecting #{log_count} logs")

      logs_import_list.each do |step|
        if archive_service.folder_present?(step.folder)
          step.import_class.new(archive_service).send(step.import_method, step.folder)
        end
      end
    }

    Rails.logger.info("Import complete, triggering user invite emails")

    csv.each { |row|
      organisation = Organisation.find_by(name: row[0])
      next unless organisation
      users = User.where(:organisation, active: true)
      users.each { |user| ResendInvitationMailer.resend_invitation_email(user).deliver_later }
    }

    Rails.logger.info("Invite emails triggered")

    # Do output data
  end
end
