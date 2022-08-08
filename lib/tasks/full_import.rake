Import = Struct.new("Import", :import_class, :import_method, :folder)

namespace :core do
  desc "Import all data XMLs from legacy CORE"
  task :full_import, %i[path] => :environment do |_task, args|
    path = args[:path]
    raise "Usage: rake core:full_import['path/to/main_folder']" if path.blank?

    storage_service = StorageService.new(PaasConfigurationService.new, ENV["IMPORT_PAAS_INSTANCE"])

    import_list = [
      Import.new(Imports::OrganisationImportService, :create_organisations, "institution"),
      Import.new(Imports::SchemeImportService, :create_schemes, "mgmtgroups"),
      Import.new(Imports::SchemeLocationImportService, :create_scheme_locations, "schemes"),
      Import.new(Imports::UserImportService, :create_users, "user"),
      Import.new(Imports::DataProtectionConfirmationImportService, :create_data_protection_confirmations, "dataprotect"),
      Import.new(Imports::OrganisationRentPeriodImportService, :create_organisation_rent_periods, "rent-period"),
      Import.new(Imports::CaseLogsImportService, :create_logs, "logs"),
    ]

    import_list.each do |import|
      folder_path = File.join(path, import.folder, "")
      if storage_service.folder_present?(folder_path)
        import.import_class.new(storage_service).send(import.import_method, folder_path)
      else
        Rails.logger.info("#{folder_path} does not exist, skipping #{import.import_class}")
      end
    end
  end
end
