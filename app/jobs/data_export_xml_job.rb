class DataExportXmlJob < ApplicationJob
  queue_as :default

  def perform(full_update: false)
    storage_service = Storage::S3Service.new(Configuration::S3Service.new(name: ENV["EXPORT_PAAS_INSTANCE"]))
    export_service = Exports::LettingsLogExportService.new(storage_service)

    export_service.export_xml_lettings_logs(full_update:)
  end
end
