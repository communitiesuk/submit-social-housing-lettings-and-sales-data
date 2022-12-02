class BulkUpload::Downloader
  attr_reader :bulk_upload

  delegate :path, to: :file

  def initialize(bulk_upload:)
    @bulk_upload = bulk_upload
  end

  def call
    download
  end

private

  def download
    io = storage_service.get_file_io(bulk_upload.identifier)
    file.write(io.read)
    io.close
    file.close
  end

  def file
    @file ||= Tempfile.new
  end

  def storage_service
    @storage_service ||= Storage::S3Service.new(
      Configuration::PaasConfigurationService.new,
      ENV["CSV_DOWNLOAD_PAAS_INSTANCE"],
    )
  end
end
