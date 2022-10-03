class LettingsLogImportJob < ApplicationJob
  self.queue_name_prefix = "lettings_logs_import"
  queue_as :default

  def perform(run_id, xml_document_as_string)
    logger.info("[LettingsLogImportJob] Processing log entry for run #{run_id}")
    Imports::LettingsLogsImportProcessor.new(xml_document_as_string)
  end
end
