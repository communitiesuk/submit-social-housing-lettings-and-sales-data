module Imports
  class LettingsLogsImportService < ImportService
    def initialize(storage_service, logger = Rails.logger)
      super
    end

    def create_logs(folder)
      @run_id = "LLRun-#{Time.zone.now.strftime('%d%m%Y%H%M')}"
      @logger.info("START: Importing Lettings Logs @ #{Time.zone.now.strftime('%d-%m-%Y %H:%M')}. RunId: #{@run_id}")

      import_from(folder, :enqueue_job)

      @logger.info("FINISH: Importing Lettings Logs @ #{Time.zone.now.strftime('%d-%m-%Y %H:%M')}. RunId: #{@run_id}")
    end

    def enqueue_job(xml_document)
      LettingsLogImportJob.perform_later(@run_id, xml_document.to_s)
    end
  end
end
