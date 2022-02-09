namespace :core do
  desc "Export data XMLs for import into Central Data System (CDS)"
  task data_export: :environment do
    storage_service = StorageService.new(PaasConfigurationService.new, ENV["EXPORT_PAAS_INSTANCE"])
    Exports::CaseLogExportService.new(storage_service).export_case_logs
  end
end
