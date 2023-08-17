namespace :core do
  desc "Update database field from data XMLs provided by Softwire"
  task :data_import_field, %i[field path] => :environment do |_task, args|
    field = args[:field]
    path = args[:path]
    raise "Usage: rake core:data_import_field['field','path/to/xml_files']" if path.blank? || field.blank?

    # We only allow a reduced list of known fields to be updatable
    case field
    when "tenancycode", "major_repairs", "lettings_allocation", "offered", "owning_organisation_id"
      s3_service = Storage::S3Service.new(PlatformHelper.is_paas? ? Configuration::PaasConfigurationService.new : Configuration::EnvConfigurationService.new, ENV["IMPORT_PAAS_INSTANCE"])
      archive_io = s3_service.get_file_io(path)
      archive_service = Storage::ArchiveService.new(archive_io)
      if archive_service.folder_present?("logs")
        Rails.logger.info("Start importing field from folder logs")
        if field == "owning_organisation_id"
          Imports::SalesLogsFieldImportService.new(archive_service).update_field(field, "logs")
        else
          Imports::LettingsLogsFieldImportService.new(archive_service).update_field(field, "logs")
        end
        Rails.logger.info("Imported")
      end
    else
      raise "Field #{field} cannot be updated by data_import_field"
    end
  end
end
