class Csv::Downloader
  attr_reader :csv_download

  delegate :path, to: :file

  def initialize(csv_download:)
    @csv_download = csv_download
  end

  def call
    download
  end

  def delete_local_file!
    file.unlink
  end

  def presigned_url
    s3_storage_service.get_presigned_url(csv_download.filename, 60, response_content_disposition: "attachment; filename=#{csv_download.filename}")
  end

private

  def download
    io = storage_service.get_file_io(csv_download.filename)
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
    Storage::S3Service.new(Configuration::EnvConfigurationService.new, ENV["BULK_UPLOAD_BUCKET"])
  end

  def local_disk_storage_service
    Storage::LocalDiskService.new
  end
end
