
class LettingsLogImportJob < ApplicationJob
  include Wisper::Publisher

  self.queue_name_prefix = '_lettings_logs'
  queue_as :default

  def perform(run_id, xml_document)
    puts "PERFORMING RUN: #{run_id} WITH XML DOC: #{xml_document}"
    #Wisper.subscribe(LettingsLogImportListener.new, prefix: :on)

    processor = Imports::LettingsLogsImportProcessor.new(xml_document)

    broadcast(::Import::ITEM_PROCESSED, run_id, processor)
  end    
end
