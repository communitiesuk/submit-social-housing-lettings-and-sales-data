namespace :core do
  desc "Export data CSVs for import into Central Data System (CDS)"
  task data_export_csv: :environment do |_task, _args|
    DataExportCsvJob.perform_later
  end

  desc "Export data XMLs for import into Central Data System (CDS)"
  task :data_export_xml, %i[full_update] => :environment do |_task, args|
    full_update = args[:full_update].present? && args[:full_update] == "true"

    DataExportXmlJob.perform_later(full_update:)
  end

  desc "Export all data XMLs for import into Central Data System (CDS)"
  task :full_data_export_xml, %i[year] => :environment do |_task, args|
    collection_year = args[:year].present? ? args[:year].to_i : nil
    storage_service = Storage::S3Service.new(PlatformHelper.is_paas? ? Configuration::PaasConfigurationService.new : Configuration::EnvConfigurationService.new, ENV["EXPORT_PAAS_INSTANCE"])
    export_service = Exports::LettingsLogExportService.new(storage_service)

    export_service.export_xml_lettings_logs(full_update: true, collection_year:)
  end
end
