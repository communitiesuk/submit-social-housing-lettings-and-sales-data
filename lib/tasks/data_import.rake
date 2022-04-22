namespace :core do
  desc "Import data XMLs from Softwire system"
  task :data_import, %i[type path] => :environment do |_task, args|
    type = args[:type]
    path = args[:path]
    raise "Usage: rake core:data_import['data_type', 'path/to/xml_files']" if path.blank? || type.blank?

    storage_service = StorageService.new(PaasConfigurationService.new, ENV["IMPORT_PAAS_INSTANCE"])

    case type
    when "organisation"
      Imports::OrganisationImportService.new(storage_service).create_organisations(path)
    when "user"
      Imports::UserImportService.new(storage_service).create_users(path)
    when "data-protection-confirmation"
      Imports::DataProtectionConfirmationImportService.new(storage_service).create_data_protection_confirmations(path)
    when "organisation-las"
      Imports::OrganisationLaImportService.new(storage_service).create_organisation_las(path)
    else
      raise "Type #{type} is not supported by data_import"
    end
  end
end
