Import = Struct.new("Import", :import_class, :import_method, :folder)

namespace :import do
  desc "Import orgs, schemes, users, data protection confirmations, and rent periods"
  task :org_data, %i[org_csv] => :environment do |_task, args|
    org_csv_str = args[:org_csv]
    raise "todo" if org_csv_str.blank?

    s3_service = Storage::S3Service.new(Configuration::PaasConfigurationService.new, ENV["IMPORT_PAAS_INSTANCE"])
    csv = CSV.parse(org_csv_str)

    import_list = [
      Import.new(Imports::OrganisationImportService, :create_organisations, "institution"),
      Import.new(Imports::SchemeImportService, :create_schemes, "mgmtgroups"),
      Import.new(Imports::SchemeLocationImportService, :create_scheme_locations, "schemes"),
      Import.new(Imports::UserImportService, :create_users, "user"),
      Import.new(Imports::DataProtectionConfirmationImportService, :create_data_protection_confirmations, "dataprotect"),
      Import.new(Imports::OrganisationRentPeriodImportService, :create_organisation_rent_periods, "rent-period"),
    ]

    csv.each { |row|
      archive_path = row[1]
      archive_io = s3_service.get_file_io(archive_path)
      archive_service = Storage::ArchiveService.new(archive_io)

      import_list.each do |step|
        if archive_service.folder_present?(step.folder)
          Rails.logger.info("Importing folder #{step.folder} for organisation #{row[0]}")
          step.import_class.new(archive_service).send(step.import_method, step.folder)
        else
          Rails.logger.info("#{step.folder} does not exist for organisation #{row[0]}, skipping #{step.import_class}")
        end
      end
    }

    Rails.logger.info("Import complete")
  end

  desc "Import logs"
  task :logs, %i[org_csv] => :environment do |_task, args|
    org_csv_str = args[:org_csv]
    raise "todo" if org_csv_str.blank?

    s3_service = Storage::S3Service.new(Configuration::PaasConfigurationService.new, ENV["IMPORT_PAAS_INSTANCE"])
    csv = CSV.parse(org_csv_str)

    import_list = [
      Import.new(Imports::LettingsLogsImportService, :create_logs, "logs"),
      Import.new(Imports::SalesLogsImportService, :create_logs, "logs"),
    ]

    csv.each { |row|
      archive_path = row[1]
      archive_io = s3_service.get_file_io(archive_path)
      archive_service = Storage::ArchiveService.new(archive_io)

      import_list.each do |step|
        if archive_service.folder_present?(step.folder)
          Rails.logger.info("Importing folder #{step.folder} using #{step.import_class} for organisation #{row[0]}")
          step.import_class.new(archive_service).send(step.import_method, step.folder)
        else
          Rails.logger.info("#{step.folder} does not exist for organisation #{row[0]}, skipping #{step.import_class}")
        end
      end
    }

    Rails.logger.info("Import complete")
  end
end
