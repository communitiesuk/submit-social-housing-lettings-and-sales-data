namespace :core do
  desc "Export data XMLs for import into Central Data System (CDS)"
  task :data_export_xml, %i[full_update] => :environment do |_task, args|
    full_update = args[:full_update].present? && args[:full_update] == "true"

    DataExportXmlJob.perform_later(full_update:)
  end

  desc "Export all data XMLs for import into Central Data System (CDS)"
  task :full_data_export_xml, %i[collection] => :environment do |_task, args|
    collection = args[:collection].presence
    collection = collection.to_i if collection.present? && collection.scan(/\D/).empty?

    storage_service = Storage::S3Service.new(Configuration::EnvConfigurationService.new, ENV["EXPORT_BUCKET"])
    export_service = Exports::ExportService.new(storage_service)

    export_service.export_xml(full_update: true, collection:)
  end
end
