namespace :core do
  desc "Import all data XMLs from legacy CORE"
  task :full_import, %i[path] => :environment do |_task, args|
    path = args[:path]
    raise "Usage: rake core:full_import['path/to/xml_files']" if path.blank?

    storage_service = StorageService.new(PaasConfigurationService.new, ENV["IMPORT_PAAS_INSTANCE"])

    Imports::OrganisationImportService.new(storage_service).create_organisations(path)
    Imports::SchemeImportService.new(storage_service).create_schemes(path)
    Imports::SchemeLocationImportService.new(storage_service).create_scheme_locations(path)
    Imports::UserImportService.new(storage_service).create_users(path)
    Imports::DataProtectionConfirmationImportService.new(storage_service).create_data_protection_confirmations(path)
    Imports::OrganisationRentPeriodImportService.new(storage_service).create_organisation_rent_periods(path)
    Imports::CaseLogsImportService.new(storage_service).create_logs(path)
  end
end
