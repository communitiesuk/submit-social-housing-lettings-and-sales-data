class BulkUpload::Processor
  attr_reader :bulk_upload

  def initialize(bulk_upload:)
    @bulk_upload = bulk_upload
  end

  def call
    download
    validator.call
  ensure
    downloader.delete_local_file!
  end

private

  def downloader
    @downloader ||= BulkUpload::Downloader.new(bulk_upload:)
  end

  def download
    downloader.call
  end

  # TODO: handle sales
  def validator
    @validator ||= BulkUpload::Lettings::Validator.new(
      bulk_upload:,
      path: downloader.path,
    )
  end
end
