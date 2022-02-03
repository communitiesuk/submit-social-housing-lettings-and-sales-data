require "nokogiri"

namespace :data_import do
  desc "Import Organisation XMLs from Softwire system"

  # rake data_import:organisations['path/to/xml_files']
  task :organisations, %i[path] => :environment do |_task, args|
    directory = args.path
    storage_service = StorageService.new(PaasConfigurationService.new, ENV["IMPORT_PAAS_INSTANCE"])
    import_service = ImportService.new(storage_service)
    import_service.update_organisations(directory)
  end
end
