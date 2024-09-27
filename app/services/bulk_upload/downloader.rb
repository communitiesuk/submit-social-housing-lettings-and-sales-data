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

  def file_path
    file.path
  end

  def presigned_url
    s3_storage_service.get_presigned_url(bulk_upload.identifier, 60)
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
    # or use !Rails.env.development?
    @storage_service ||= if FeatureToggle.upload_enabled?
                           s3_storage_service
                         else
                           local_disk_storage_service
                         end
  end

  def s3_storage_service
    Storage::S3Service.new(Configuration::EnvConfigurationService.new, ENV["BULK_UPLOAD_BUCKET"])
  end

  def local_disk_storage_service
    Storage::LocalDiskService.new
  end
end
