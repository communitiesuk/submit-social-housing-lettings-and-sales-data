Import = Struct.new("Import", :import_class, :import_method, :folder)

namespace :core do
  desc "Import all data XMLs from legacy CORE"
  task :full_import, %i[archive_path] => :environment do |_task, args|
    archive_path = args[:archive_path]
    raise "Usage: rake core:full_import['path/to/archive']" if archive_path.blank?

    s3_service = Storage::S3Service.new(Configuration::S3Service.new(name: ENV["IMPORT_PAAS_INSTANCE"]))
    archive_io = s3_service.get_file_io(archive_path)
    archive_service = Storage::ArchiveService.new(archive_io)

    import_list = [
      Import.new(Imports::OrganisationImportService, :create_organisations, "institution"),
      Import.new(Imports::SchemeImportService, :create_schemes, "mgmtgroups"),
      Import.new(Imports::SchemeLocationImportService, :create_scheme_locations, "schemes"),
      Import.new(Imports::UserImportService, :create_users, "user"),
      Import.new(Imports::DataProtectionConfirmationImportService, :create_data_protection_confirmations, "dataprotect"),
      Import.new(Imports::OrganisationRentPeriodImportService, :create_organisation_rent_periods, "rent-period"),
      Import.new(Imports::LettingsLogsImportService, :create_logs, "logs"),
      # Import.new(Imports::SalesLogsImportService, :create_logs, "logs"),
    ]

    import_list.each do |step|
      if archive_service.folder_present?(step.folder)
        Rails.logger.info("Start importing folder #{step.folder}")
        step.import_class.new(archive_service).send(step.import_method, step.folder)
      else
        Rails.logger.info("#{step.folder} does not exist, skipping #{step.import_class}")
      end
    end
  end
end
