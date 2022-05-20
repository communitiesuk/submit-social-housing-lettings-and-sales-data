namespace :core do
  desc "Export data XMLs for import into Central Data System (CDS)"
  task :data_export, %i[format full_update] => :environment do |_task, args|
    format = args[:format]
    full_update = args[:full_update].present? && args[:full_update] == "true"

    storage_service = StorageService.new(PaasConfigurationService.new, ENV["EXPORT_PAAS_INSTANCE"])
    export_service = Exports::CaseLogExportService.new(storage_service)

    if format.present? && format == "CSV"
      export_service.export_csv_case_logs
    else
      export_service.export_xml_case_logs(full_update:)
    end
  end
end
