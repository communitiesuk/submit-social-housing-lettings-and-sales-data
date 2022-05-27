namespace :core do
  desc "Update database field from data XMLs provided by Softwire"
  task :data_import_field, %i[field path] => :environment do |_task, args|
    field = args[:field]
    path = args[:path]
    raise "Usage: rake core:data_import_field['field','path/to/xml_files']" if path.blank? || field.blank?

    storage_service = StorageService.new(PaasConfigurationService.new, ENV["IMPORT_PAAS_INSTANCE"])

    # We only allow a reduced list of known fields to be updatable
    case field
    when "tenant_code"
      Imports::CaseLogsFieldImportService.new(storage_service).update_field(field, path)
    else
      raise "Field #{field} cannot be updated by data_import_field"
    end
  end
end
