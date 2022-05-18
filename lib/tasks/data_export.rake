namespace :core do
  desc "Export data XMLs for import into Central Data System (CDS)"
  task :data_export, %i[full_update] => :environment do |_task, args|
    storage_service = StorageService.new(PaasConfigurationService.new, ENV["EXPORT_PAAS_INSTANCE"])
    full_update = args[:full_update].present? && args[:full_update] == "true"
    Exports::CaseLogExportService.new(storage_service).export_case_logs(full_update:)
  end
end
