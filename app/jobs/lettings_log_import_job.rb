
class LettingsLogImportJob < ApplicationJob
  self.queue_name_prefix = 'lettings_logs_import'
  queue_as :default

  def perform(run_id, xml_document)
    Imports::LettingsLogsImportProcessor.new(xml_document)
  end    
end
