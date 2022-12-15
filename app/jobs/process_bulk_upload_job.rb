class ProcessBulkUploadJob < ApplicationJob
  queue_as :default

  def perform(bulk_upload:)
    BulkUpload::Processor.new(bulk_upload:).call
  end
end
