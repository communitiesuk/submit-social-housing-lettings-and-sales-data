class DataExportXmlJob < ApplicationJob
  queue_as :default

  def perform(full_update: false)
    storage_service = Storage::S3Service.new(Configuration::EnvConfigurationService.new, ENV["EXPORT_BUCKET"])
    export_service = Exports::ExportService.new(storage_service)

    export_service.export_xml(full_update:)
  end
end
