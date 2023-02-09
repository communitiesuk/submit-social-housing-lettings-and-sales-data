class DataExportCsvJob < ApplicationJob
  queue_as :default

  def perform
    storage_service = Storage::S3Service.new(Configuration::PaasConfigurationService.new, ENV["EXPORT_PAAS_INSTANCE"])
    export_service = Exports::LettingsLogExportService.new(storage_service)

    export_service.export_csv_lettings_logs
  end
end
