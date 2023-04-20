class BulkUpload::Downloader
  attr_reader :bulk_upload

  delegate :path, to: :file

  def initialize(bulk_upload:)
    @bulk_upload = bulk_upload
  end

  def call
    download
  end

  def delete_local_file!
    file.unlink
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
    @storage_service ||= if FeatureToggle.upload_enabled?
                           s3_storage_service
                         else
                           local_disk_storage_service
                         end
  end

  def s3_storage_service
    Storage::S3Service.new(
      Configuration::S3Service.new(name: ENV["CSV_DOWNLOAD_PAAS_INSTANCE"]),
    )
  end

  def local_disk_storage_service
    Storage::LocalDiskService.new
  end
end
