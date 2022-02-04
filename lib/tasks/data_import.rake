require "nokogiri"

namespace :core do
  desc "Import data XMLs from Softwire system"
  task :data_import, %i[type path] => :environment do |_task, args|
    type = args[:type]
    path = args[:path]
    raise "Usage: rake core:data_import['data_type', 'path/to/xml_files']" if path.blank? || type.blank?

    storage_service = StorageService.new(PaasConfigurationService.new, ENV["IMPORT_PAAS_INSTANCE"])
    import_service = ImportService.new(storage_service)

    case type
    when "organisation"
      import_service.update_organisations(path)
    else
      raise "Type #{type} is not supported by data_import"
    end
  end
end
